"""全局配置管理"""

from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    # ========== 模型缓存路径 ==========
    model_cache_dir: str = ""

    # ========== LLM 配置 (vLLM 本地部署) ==========
    vllm_base_url: str = "http://localhost:8081/v1"
    vllm_api_key: str = "EMPTY"
    llm_model_name: str = "Qwen3.5-9B"
    llm_temperature: float = 0.1
    llm_max_tokens: int = 2048

    # ========== Embedding 配置 ==========
    embedding_model_name: str = "BAAI/bge-large-zh-v1.5"
    embedding_device: str = "cuda:1"

    # ========== Reranker 配置 ==========
    reranker_model_name: str = "BAAI/bge-reranker-large"
    reranker_device: str = "cuda:1"

    # ========== Milvus 配置 ==========
    milvus_host: str = "localhost"
    milvus_port: int = 19530
    milvus_collection_name: str = "customer_service_kb"

    # ========== PostgreSQL 配置 ==========
    postgres_host: str = "localhost"
    postgres_port: int = 5432
    postgres_user: str = "postgres"
    postgres_password: str = "postgres123"
    postgres_db: str = "customer_service"

    @property
    def postgres_url(self) -> str:
        return (
            f"postgresql+asyncpg://{self.postgres_user}:{self.postgres_password}"
            f"@{self.postgres_host}:{self.postgres_port}/{self.postgres_db}"
        )

    @property
    def postgres_sync_url(self) -> str:
        return (
            f"postgresql://{self.postgres_user}:{self.postgres_password}"
            f"@{self.postgres_host}:{self.postgres_port}/{self.postgres_db}"
        )

    # ========== Redis 配置 ==========
    redis_host: str = "localhost"
    redis_port: int = 6379
    redis_db: int = 0
    redis_password: str = ""

    # ========== 服务配置 ==========
    app_host: str = "0.0.0.0"
    app_port: int = 8000
    app_debug: bool = True

    # ========== 知识库配置 ==========
    chunk_size: int = 500
    chunk_overlap: int = 50
    retrieval_top_k: int = 5
    retrieval_score_threshold: float = 0.7
    rerank_top_k: int = 3
    knowledge_base_topics: str = "产品使用指南、故障排查、售后服务、订单处理、常见问题"

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"


settings = Settings()