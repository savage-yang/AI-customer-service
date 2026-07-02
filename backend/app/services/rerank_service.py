"""BGE Reranker 重排序服务 — 基于 transformers 原生实现，兼容各版本"""

import os
from pathlib import Path
from typing import Optional

import torch
from transformers import AutoTokenizer, AutoModelForSequenceClassification
from app.core.config import settings


def _get_model_path() -> str:
    """查找本地 Reranker 模型路径（递归搜索 MODEL_CACHE_DIR）"""
    models_dir = Path(os.environ.get("MODEL_CACHE_DIR", ""))
    if models_dir.exists():
        for root, dirs, files in os.walk(models_dir):
            if "pytorch_model.bin" in files and "sentencepiece.bpe.model" in files:
                return root
    return settings.reranker_model_name

class RerankService:
    """BGE-Reranker 重排序服务"""

    _instance = None

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
            cls._instance._tokenizer = None
            cls._instance._model = None
        return cls._instance

    def _load(self):
        if self._model is None:
            model_path = _get_model_path()
            device = settings.reranker_device
            self._tokenizer = AutoTokenizer.from_pretrained(model_path)
            self._model = AutoModelForSequenceClassification.from_pretrained(model_path)
            self._model.eval()
            if device != "cpu":
                self._model = self._model.to(device)
            self._device = device

    def _compute_scores(self, pairs: list[list[str]]) -> list[float]:
        """计算 query-document 对的相关性分数（已归一化到 0-1）"""
        self._load()
        all_scores = []
        batch_size = 8

        for i in range(0, len(pairs), batch_size):
            batch = pairs[i:i + batch_size]
            queries = [p[0] for p in batch]
            docs = [p[1] for p in batch]

            inputs = self._tokenizer(
                queries, docs,
                padding=True,
                truncation=True,
                max_length=512,
                return_tensors="pt",
            )

            if self._device != "cpu":
                inputs = {k: v.to(self._device) for k, v in inputs.items()}

            with torch.no_grad():
                logits = self._model(**inputs).logits.squeeze(-1)
                scores = torch.sigmoid(logits).cpu().numpy().tolist()

            if isinstance(scores, float):
                scores = [scores]
            all_scores.extend(scores)

        return all_scores

    def rerank(
        self,
        query: str,
        documents: list[dict],
        top_k: int = None,
    ) -> list[dict]:
        """对检索结果进行重排序"""
        if top_k is None:
            top_k = settings.rerank_top_k

        if not documents:
            return []

        pairs = [[query, doc["content"]] for doc in documents]
        scores = self._compute_scores(pairs)

        reranked = []
        for doc, score in zip(documents, scores):
            reranked.append({
                **doc,
                "rerank_score": float(score),
            })

        reranked.sort(key=lambda x: x["rerank_score"], reverse=True)
        return reranked[:top_k]


rerank_service = RerankService()
