"""vLLM 大模型客户端 — 通过 OpenAI 兼容接口调用本地部署的 Qwen"""

from contextlib import asynccontextmanager

from openai import AsyncOpenAI
from app.core.config import settings
import httpx


class LLMClient:
    """vLLM LLM 客户端 — 每次请求独立连接，避免 GOAWAY 错误"""

    _instance = None

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance

    @asynccontextmanager
    async def session(self):
        """每次调用新建独立连接，用完即关，彻底避免 GOAWAY"""
        http_client = httpx.AsyncClient(
            http2=False,
            limits=httpx.Limits(
                max_connections=1,
                max_keepalive_connections=0,
                keepalive_expiry=0.0,
            ),
            timeout=httpx.Timeout(
                connect=30.0,
                read=120.0,
                write=120.0,
                pool=0.0,
            ),
            transport=httpx.AsyncHTTPTransport(
                retries=3,
            ),
        )
        client = AsyncOpenAI(
            base_url=settings.vllm_base_url,
            api_key=settings.vllm_api_key,
            http_client=http_client,
        )
        try:
            yield client
        finally:
            await http_client.aclose()

    def get_model_name(self) -> str:
        return settings.llm_model_name


llm_client = LLMClient()
