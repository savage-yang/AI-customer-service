"""Milvus Lite 向量库操作封装（嵌入式，无需 Docker）"""
import time
from pathlib import Path

from pymilvus import MilvusClient
from app.core.config import settings
from app.core.embedding import embedding_client

# 数据目录（项目根目录下的 data/）
_DATA_DIR = Path(__file__).parent.parent.parent / "data"
_DATA_DIR.mkdir(parents=True, exist_ok=True)
DB_PATH = str(_DATA_DIR / "milvus_kb.db")


class VectorStoreClient:
    """Milvus Lite 单例客户端（嵌入式，数据存本地文件）"""

    _instance = None

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
            cls._instance._client = None
            cls._instance._collection_name = None
        return cls._instance

    @property
    def client(self) -> MilvusClient:
        if self._client is None:
            self._client = MilvusClient(uri=DB_PATH)
            self._collection_name = settings.milvus_collection_name
        return self._client

    def _ensure_collection(self):
        """确保 collection 存在"""
        collection_name = settings.milvus_collection_name
        if not self.client.has_collection(collection_name):
            dim = self._get_embedding_dim()
            self.client.create_collection(
                collection_name=collection_name,
                dimension=dim,
                metric_type="IP",
            )
        return collection_name

    def _get_embedding_dim(self) -> int:
        """获取 Embedding 向量维度"""
        return embedding_client.dimension

    def ensure_loaded(self):
        """启动时验证 collection 是否就绪（只读检查，不创建新 collection）"""
        collection_name = settings.milvus_collection_name
        if self.client.has_collection(collection_name):
            stats = self.client.get_collection_stats(collection_name)
            count = stats.get("row_count", 0)
            print(f"[INFO] Milvus 知识库已就绪，collection='{collection_name}'，向量数={count}")
        else:
            print(f"[WARN] 知识库 collection='{collection_name}' 不存在，请先运行灌库脚本:")
            print(f"       python scripts/ingest.py")

    def insert_texts(self, texts: list[str], source: str = "") -> list[int]:
        """插入文本，返回 ID 列表"""
        collection_name = self._ensure_collection()

        embeddings = embedding_client.encode_documents(texts)
        print(f"\n{'='*60}")
        print(f"[EMBEDDING] 向量化结果 (共 {len(embeddings)} 个向量):")
        print(f"{'='*60}")
        for i, emb in enumerate(embeddings):
            dim = len(emb)
            # 打印前6个和后6个向量值，中间省略
            start = ", ".join(f"{x:.4f}" for x in emb[:6])
            end = ", ".join(f"{x:.4f}" for x in emb[-6:])
            print(f"  [{i+1}] dim={dim} | [{start}, ..., {end}]")
        print(f"{'='*60}\n")

        # 生成唯一 ID（毫秒级时间戳 + 序号）
        base_id = int(time.time() * 1000)
        data = [
            {"id": base_id + i, "content": text, "source": source, "vector": emb}
            for i, (text, emb) in enumerate(zip(texts, embeddings))
        ]
        result = self.client.insert(collection_name=collection_name, data=data)
        # Milvus Lite 在 Windows 上 flush 有 bug（os.rename 失败），移除显式 flush
        # 数据会在下次查询或关闭连接时自动持久化
        return result.get("ids", [])

    def search(self, query: str, top_k: int = None) -> list[dict]:
        """语义检索"""
        if top_k is None:
            top_k = settings.retrieval_top_k

        collection_name = self._ensure_collection()
        self.client.load_collection(collection_name=collection_name)
        query_embedding = embedding_client.encode_query(query)

        results = self.client.search(
            collection_name=collection_name,
            data=[query_embedding],
            limit=top_k,
            output_fields=["content", "source"],
        )

        docs = []
        for hits in results:
            for hit in hits:
                score = float(hit.get("distance", 0))
                if score >= settings.retrieval_score_threshold:
                    docs.append({
                        "content": hit.get("entity", {}).get("content", ""),
                        "source": hit.get("entity", {}).get("source", ""),
                        "score": score,
                    })
        return docs

    def delete_by_source(self, source: str) -> int:
        """按来源删除"""
        collection_name = self._ensure_collection()
        result = self.client.delete(
            collection_name=collection_name,
            filter=f'source == "{source}"',
        )
        return result.get("delete_count", 0)

    def get_collection_stats(self) -> dict:
        """获取统计信息"""
        collection_name = self._ensure_collection()
        stats = self.client.get_collection_stats(collection_name)
        return {
            "name": collection_name,
            "num_entities": stats.get("row_count", 0),
        }


vector_store_client = VectorStoreClient()
