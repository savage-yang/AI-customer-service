"""BGE 中文 Embedding 模型封装 — 支持从 ModelScope / HuggingFace 本地缓存加载"""

import os
from pathlib import Path

from sentence_transformers import SentenceTransformer
from app.core.config import settings


def _get_model_path() -> str:
    """查找本地 Embedding 模型路径（递归搜索 MODEL_CACHE_DIR）"""
    models_dir = Path(os.environ.get("MODEL_CACHE_DIR", ""))
    if models_dir.exists():
        for root, dirs, files in os.walk(models_dir):
            if "sentence_bert_config.json" in files and "pytorch_model.bin" in files:
                return root
    return settings.embedding_model_name


class EmbeddingClient:
    """BGE Embedding 单例客户端"""

    _instance = None

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
            cls._instance._embeddings = None
        return cls._instance

    @property
    def embeddings(self):
        if self._embeddings is None:
            model_path = _get_model_path()
            self._embeddings = SentenceTransformer(
                model_name_or_path=model_path,
                device=settings.embedding_device,
            )
        return self._embeddings

    @property
    def dimension(self) -> int:
        """获取 embedding 向量维度"""
        return self.embeddings.get_embedding_dimension()

    def encode_query(self, query: str) -> list[float]:
        """将单个查询文本转为向量"""
        return self.embeddings.encode(query, normalize_embeddings=True).tolist()

    def encode_documents(self, texts: list[str]) -> list[list[float]]:
        """批量将文本转为向量"""
        return self.embeddings.encode(texts, normalize_embeddings=True).tolist()


embedding_client = EmbeddingClient()
