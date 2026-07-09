"""对话服务 —— Write-Through + Cache-Aside 双层存储

架构：
  - PostgreSQL: source of truth（永久存储）
  - Redis: 缓存加速层（TTL=1h，miss 时从 PG 回填）

写入流程（Write-Through）：
  PG 写入成功 → Redis 更新缓存

读取流程（Cache-Aside）：
  Redis 命中 → 直接返回
  Redis 未命中 → PG 查询 → 回填 Redis → 返回
"""

import time

from app.core.database import async_session
from app.core.redis_client import redis_client
from app.repositories.conversation_repo import conversation_repo
from app.services.rag_service import rag_service


class ChatService:
    """对话服务"""

    async def chat_stream(self, session_id: str, question: str, user_id: str = "anonymous"):
        """流式多轮对话（Write-Through + Cache-Aside）"""
        # ── 1. Cache-Aside 读：先 Redis，miss 则从 PG 恢复 ──
        history = await redis_client.get_session(session_id)
        if not history:
            async with async_session() as db:
                history = await conversation_repo.get_history(db, session_id)
            if history:
                await redis_client.cache_session(session_id, history)
                print(f"[Chat] Redis miss, 从 PG 恢复 {len(history)} 条历史")
            else:
                history = []

        # ── 2. 构建上下文（最近6轮）──
        context_str = ""
        if history:
            recent = history[-6:]
            context_lines = []
            for msg in recent:
                role = "用户" if msg["role"] == "user" else "助手"
                context_lines.append(f"{role}: {msg['content']}")
            context_str = "\n".join(context_lines)

        # ── 3. 流式生成回答 ──
        start_time = time.time()
        full_answer = ""
        async for chunk in rag_service.ask_stream(
            question=question,
            history=context_str if history else "",
        ):
            full_answer += chunk
            yield chunk

        latency_ms = int((time.time() - start_time) * 1000)

        # ── 4. Write-Through 写：先 PG（源），再 Redis（缓存）──
        try:
            async with async_session() as db:
                await conversation_repo.save_message(
                    db, user_id, session_id, "user", question
                )
                await conversation_repo.save_message(
                    db, user_id, session_id, "assistant", full_answer,
                    latency_ms=latency_ms,
                )
            print(f"[Chat] PG 写入成功, latency={latency_ms}ms")
        except Exception as e:
            print(f"[Chat] PG 写入失败: {e}")

        # 更新 Redis 缓存
        history.append({"role": "user", "content": question})
        history.append({"role": "assistant", "content": full_answer})
        await redis_client.cache_session(session_id, history)

    async def get_history(self, session_id: str) -> list[dict]:
        """获取会话历史（Cache-Aside）"""
        # 先读 Redis
        history = await redis_client.get_session(session_id)
        if history:
            return history

        # Redis miss → 读 PG → 回填 Redis
        async with async_session() as db:
            history = await conversation_repo.get_history(db, session_id)
        if history:
            await redis_client.cache_session(session_id, history)
            print(f"[Chat] get_history: Redis miss, 从 PG 恢复 {len(history)} 条")
        return history

    async def clear_session(self, session_id: str):
        """清除会话（双删：Redis + PG）"""
        await redis_client.delete_session(session_id)
        try:
            async with async_session() as db:
                await conversation_repo.delete_session(db, session_id)
            print(f"[Chat] 会话已清除: {session_id}")
        except Exception as e:
            print(f"[Chat] PG 删除失败: {e}")

    async def get_user_sessions(self, user_id: str) -> list[dict]:
        """获取用户所有会话列表"""
        async with async_session() as db:
            return await conversation_repo.get_user_sessions(db, user_id)


chat_service = ChatService()
