"""限流中间件"""

import time

from fastapi import Request, HTTPException
from starlette.middleware.base import BaseHTTPMiddleware

from app.core.redis_client import redis_client


class RateLimitMiddleware(BaseHTTPMiddleware):
    """基于 Redis 的滑动窗口限流中间件"""

    def __init__(self, app, max_requests: int = 60, window: int = 60):
        """Args:
            max_requests: 窗口内最大请求数
            window: 时间窗口(秒)
        """
        super().__init__(app)
        self.max_requests = max_requests
        self.window = window

    async def dispatch(self, request: Request, call_next):
        # 仅限制 /chat 接口
        if request.url.path.startswith("/chat") and request.method == "POST":
            client_ip = request.client.host if request.client else "unknown"
            key = f"chat:{client_ip}"

            allowed = await redis_client.check_rate_limit(
                key, self.max_requests, self.window
            )
            if not allowed:
                raise HTTPException(
                    status_code=429,
                    detail="请求过于频繁，请稍后再试",
                )

        return await call_next(request)