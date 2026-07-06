"""vLLM 大模型客户端 — 通过 OpenAI 兼容接口调用本地部署的 Qwen"""

from openai import AsyncOpenAI
from app.core.config import settings
import httpx


class LLMClient:
    """vLLM LLM 客户端 — 按需连接，不维持持久连接"""

    _instance = None

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
            cls._instance._client = None
        return cls._instance

    @property
    def client(self) -> AsyncOpenAI:
        if self._client is None:
            http_client = httpx.AsyncClient(
                http2=False,
                limits=httpx.Limits(
                    max_connections=10,
                    max_keepalive_connections=0,
                ),
                timeout=httpx.Timeout(
                    connect=30.0,
                    read=60.0,
                    write=60.0,
                    pool=0.0,
                ),
                transport=httpx.AsyncHTTPTransport(
                    retries=3,
                ),
            )
            self._client = AsyncOpenAI(
                base_url=settings.vllm_base_url,
                api_key=settings.vllm_api_key,
                http_client=http_client,
            )
        return self._client

    def get_model_name(self) -> str:
        return settings.llm_model_name


llm_client = LLMClient()