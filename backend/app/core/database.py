"""PostgreSQL 异步数据库连接"""

from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker, AsyncSession

from app.core.config import settings

# 异步引擎
engine = create_async_engine(
    settings.postgres_url,
    echo=False,
    pool_size=10,
    max_overflow=20,
    pool_pre_ping=True,
)

# 异步会话工厂
async_session = async_sessionmaker(
    engine,
    class_=AsyncSession,
    expire_on_commit=False,
)


async def init_db():
    """创建所有表（如果不存在）"""
    from app.models.database import Base
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    print(f"[INFO] PostgreSQL 表已初始化 {settings.postgres_host}:{settings.postgres_port}")


async def close_db():
    """关闭数据库连接池"""
    await engine.dispose()
    print("[INFO] PostgreSQL 连接已关闭")
