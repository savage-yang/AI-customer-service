"""Redis 客户端封装"""

import json
from typing import Optional

import redis.asyncio as aioredis
from app.core.config import settings


class RedisClient:
    """Redis 异步客户端"""

    _instance = None
    _redis: Optional[aioredis.Redis] = None

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance

    async def connect(self):
        if self._redis is None:
            self._redis = await aioredis.from_url(
                f"redis://{settings.redis_host}:{settings.redis_port}/{settings.redis_db}",
                password=settings.redis_password or None,
                encoding="utf-8",
                decode_responses=True,
            )

    async def disconnect(self):
        if self._redis:
            await self._redis.close()
            self._redis = None

    @property
    def client(self) -> aioredis.Redis:
        if self._redis is None:
            raise RuntimeError("Redis 未连接，请先调用 connect()")
        return self._redis

    # ========== 会话缓存 ==========

    async def cache_session(self, session_id: str, messages: list[dict], ttl: int = 3600):
        """缓存对话历史"""
        key = f"chat:session:{session_id}"
        await self.client.setex(key, ttl, json.dumps(messages, ensure_ascii=False))

    async def get_session(self, session_id: str) -> list[dict]:
        """获取缓存的对话历史"""
        key = f"chat:session:{session_id}"
        data = await self.client.get(key)
        return json.loads(data) if data else []

    async def delete_session(self, session_id: str):
        """删除会话缓存"""
        await self.client.delete(f"chat:session:{session_id}")

    # ========== 限流 ==========

    async def check_rate_limit(self, key: str, max_requests: int, window: int) -> bool:
        """滑动窗口限流，返回是否允许"""
        redis_key = f"rate_limit:{key}"
        current = await self.client.incr(redis_key)
        if current == 1:
            await self.client.expire(redis_key, window)
        return current <= max_requests

    # ========== 缓存工具 ==========

    async def cache_set(self, key: str, value: str, ttl: int = 300):
        await self.client.setex(key, ttl, value)

    async def cache_get(self, key: str) -> Optional[str]:
        return await self.client.get(key)


redis_client = RedisClient()