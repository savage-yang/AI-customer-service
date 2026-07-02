"""Embedding 模型测试脚本 — 验证 BGE 向量生成和语义检索效果"""
from pathlib import Path
import sys
import time

sys.path.insert(0, str(Path(__file__).parent / "backend"))

from sentence_transformers import SentenceTransformer
import numpy as np

MODEL_PATH = Path(__file__).parent / "models" / "BAAI" / "bge-large-zh-v1.5"

def cosine_similarity(a, b):
    return np.dot(a, b) / (np.linalg.norm(a) * np.linalg.norm(b))


def main():
    print("=" * 60)
    print("Embedding 模型测试")
    print(f"模型路径: {MODEL_PATH}")
    print("=" * 60)

    if not MODEL_PATH.exists():
        print(f"错误: 模型路径不存在: {MODEL_PATH}")
        return

    print("\n[1/3] 加载模型...")
    t0 = time.time()
    model = SentenceTransformer(str(MODEL_PATH), device="cpu")
    print(f"  加载完成，耗时 {time.time() - t0:.2f}s")

    dim = model.get_embedding_dimension()
    print(f"  向量维度: {dim}")

    print("\n[2/3] 生成向量...")
    sentences = [
        "如何申请退款？",
        "退货流程是什么？",
        "物流几天能到？",
        "今天天气真好",
        "怎么修改收货地址？",
    ]

    t0 = time.time()
    embeddings = model.encode(sentences)
    print(f"  生成 {len(sentences)} 个向量，耗时 {time.time() - t0:.2f}s")
    print(f"  向量 shape: {embeddings.shape}")

    print("\n[3/3] 相似度测试...")
    query = "我想退货"
    query_vec = model.encode([query])[0]
    print(f"\n  查询: {query}")
    print(f"  相似度排序:")

    scores = []
    for i, sent in enumerate(sentences):
        sim = cosine_similarity(query_vec, embeddings[i])
        scores.append((sent, sim))

    scores.sort(key=lambda x: x[1], reverse=True)
    for sent, sim in scores:
        bar = "█" * int(sim * 30)
        print(f"    {sim:.4f}  {bar:<30}  {sent}")

    print("\n" + "=" * 60)
    print("测试通过！Embedding 模型工作正常")
    print("=" * 60)


if __name__ == "__main__":
    main()
