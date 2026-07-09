"""对话数据仓库 —— PostgreSQL 持久化操作"""

from typing import Optional

from sqlalchemy import select, delete, func
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.database import ChatLog


class ConversationRepo:
    """PG 对话仓库：source of truth"""

    async def save_message(
        self,
        db: AsyncSession,
        user_id: str,
        session_id: str,
        role: str,
        content: str,
        sources: Optional[list] = None,
        confidence: Optional[float] = None,
        latency_ms: Optional[int] = None,
    ):
        """保存单条消息到 PG"""
        log = ChatLog(
            user_id=user_id,
            session_id=session_id,
            role=role,
            content=content,
            sources=sources,
            confidence=confidence,
            latency_ms=latency_ms,
        )
        db.add(log)
        await db.commit()

    async def get_history(self, db: AsyncSession, session_id: str, limit: int = 50) -> list[dict]:
        """从 PG 获取会话历史（按时间正序）"""
        result = await db.execute(
            select(ChatLog)
            .where(ChatLog.session_id == session_id)
            .order_by(ChatLog.created_at.asc())
            .limit(limit)
        )
        rows = result.scalars().all()
        return [{"role": r.role, "content": r.content} for r in rows]

    async def get_user_sessions(self, db: AsyncSession, user_id: str) -> list[dict]:
        """获取用户所有会话列表（按最后活跃时间倒序）"""
        result = await db.execute(
            select(
                ChatLog.session_id,
                func.max(ChatLog.created_at).label("last_at"),
            )
            .where(ChatLog.user_id == user_id)
            .group_by(ChatLog.session_id)
            .order_by(func.max(ChatLog.created_at).desc())
        )
        return [{"session_id": row.session_id, "last_at": row.last_at} for row in result.all()]

    async def delete_session(self, db: AsyncSession, session_id: str):
        """删除会话所有消息"""
        await db.execute(delete(ChatLog).where(ChatLog.session_id == session_id))
        await db.commit()


conversation_repo = ConversationRepo()
