"""对话服务 —— 会话管理 + 多轮对话 + RAG 问答"""

from app.core.redis_client import redis_client
from app.services.rag_service import rag_service


class ChatService:
    """对话服务"""

    async def chat_stream(self, session_id: str, question: str):
        """流式多轮对话（重排序始终启用）"""
        history = await redis_client.get_session(session_id)

        context_str = ""
        if history:
            recent = history[-6:]
            context_lines = []
            for msg in recent:
                role = "用户" if msg["role"] == "user" else "助手"
                context_lines.append(f"{role}: {msg['content']}")
            context_str = "\n".join(context_lines)

        full_answer = ""
        async for chunk in rag_service.ask_stream(
            question=question,
            history=context_str if history else "",
        ):
            full_answer += chunk
            yield chunk

        history.append({"role": "user", "content": question})
        history.append({"role": "assistant", "content": full_answer})
        await redis_client.cache_session(session_id, history)

    async def clear_session(self, session_id: str):
        """清除会话"""
        await redis_client.delete_session(session_id)

    async def get_history(self, session_id: str) -> list[dict]:
        """获取会话历史"""
        return await redis_client.get_session(session_id)


chat_service = ChatService()
