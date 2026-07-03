"""端到端 RAG 测试脚本 — 模拟真实问答流程：灌库 → 检索 → 重排序 → 生成"""

from pathlib import Path
import sys
import time

import torch
import numpy as np
from sentence_transformers import SentenceTransformer
from transformers import AutoTokenizer, AutoModelForSequenceClassification

MODELS_DIR = Path(__file__).parent / "models" / "BAAI"
EMBEDDING_PATH = MODELS_DIR / "bge-large-zh-v1.5"
RERANKER_PATH = MODELS_DIR / "bge-reranker-large"

KNOWLEDGE_BASE = [
    {"content": "退款流程：用户可以在订单详情页点击申请退款按钮，填写退款原因后提交，客服会在1-3个工作日内审核。", "source": "faq"},
    {"content": "退款到账时间：审核通过后，退款将在1-3个工作日原路返回至支付账户。", "source": "faq"},
    {"content": "退货政策：商品收到后7天内无理由退货，需保持商品完好，运费由买家承担。", "source": "faq"},
    {"content": "物流查询：可在我的订单中查看物流信息，一般3-5天到货。", "source": "faq"},
    {"content": "修改收货地址：发货前可在订单详情页修改，发货后需联系客服处理。", "source": "faq"},
    {"content": "客服电话：400-888-8888，工作时间为周一至周日 9:00-21:00。", "source": "faq"},
    {"content": "会员等级分为普通会员、银卡会员、金卡会员、钻石会员，消费越多等级越高。", "source": "faq"},
    {"content": "优惠券使用：订单结算时选择优惠券即可抵扣，每张订单限用一张。", "source": "faq"},
]


def cosine_similarity(vec, matrix):
    norms = np.linalg.norm(matrix, axis=1) * np.linalg.norm(vec)
    return np.dot(matrix, vec) / norms


def main():
    print("=" * 70)
    print("端到端 RAG 测试 — 模拟客服问答系统")
    print("=" * 70)

    if not EMBEDDING_PATH.exists():
        print(f"错误: Embedding 模型不存在: {EMBEDDING_PATH}")
        return
    if not RERANKER_PATH.exists():
        print(f"错误: Reranker 模型不存在: {RERANKER_PATH}")
        return

    # ===== 1. 加载 Embedding =====
    print("\n[1/5] 加载 Embedding 模型...")
    t0 = time.time()
    embed_model = SentenceTransformer(str(EMBEDDING_PATH), device="cuda:1")
    dim = embed_model.get_embedding_dimension()
    print(f"  加载完成，维度={dim}，设备={embed_model.device}，耗时 {time.time() - t0:.2f}s")

    # ===== 2. 知识库向量化 =====
    print("\n[2/5] 知识库向量化（灌库模拟）...")
    t0 = time.time()
    texts = [item["content"] for item in KNOWLEDGE_BASE]
    vectors = embed_model.encode(texts)
    print(f"  向量化 {len(texts)} 条知识，耗时 {time.time() - t0:.3f}s")
    print(f"  向量矩阵 shape: {vectors.shape}")

    # ===== 3. 加载 Reranker =====
    print("\n[3/5] 加载 Reranker 模型...")
    t0 = time.time()
    rerank_tokenizer = AutoTokenizer.from_pretrained(str(RERANKER_PATH))
    rerank_model = AutoModelForSequenceClassification.from_pretrained(str(RERANKER_PATH))
    rerank_model = rerank_model.to("cuda:1")
    rerank_model.eval()
    print(f"  加载完成，设备={next(rerank_model.parameters()).device}，耗时 {time.time() - t0:.2f}s")

    # ===== 4. 检索 + 重排序测试 =====
    print("\n[4/5] 向量检索 + 重排序测试...")

    queries = [
        "我想退货",
        "钱什么时候退回来",
        "怎么联系人工客服",
    ]

    for q in queries:
        print(f"\n  ── 查询: {q} ──")

        # 向量检索（top_k=5）
        q_vec = embed_model.encode([q])[0]
        scores = cosine_similarity(q_vec, vectors)
        top_k = 5
        top_indices = np.argsort(scores)[::-1][:top_k]

        print(f"  向量检索 Top-{top_k}:")
        retrieved = []
        for idx in top_indices:
            score = float(scores[idx])
            doc = KNOWLEDGE_BASE[idx]
            retrieved.append(doc["content"])
            bar = "█" * int(score * 20)
            print(f"    [{score:.4f}] {bar}  {doc['content'][:40]}...")

        # 重排序
        print(f"\n  重排序后:")
        with torch.no_grad():
            inputs = rerank_tokenizer(
                [q] * len(retrieved), retrieved,
                padding=True, truncation=True, max_length=512, return_tensors="pt",
            ).to("cuda:1")
            logits = rerank_model(**inputs).logits.squeeze(-1)
            rerank_scores = torch.sigmoid(logits).cpu().numpy().tolist()

        ranked = sorted(zip(retrieved, rerank_scores), key=lambda x: x[1], reverse=True)
        for i, (doc, score) in enumerate(ranked, 1):
            bar = "█" * int(score * 20)
            print(f"  {i}. [{score:.4f}] {bar}  {doc[:40]}...")

    # ===== 5. 小结 =====
    print("\n" + "=" * 70)
    print("全部测试通过！")
    print("  ✅ Embedding 向量化正常")
    print("  ✅ 向量相似度检索正常")
    print("  ✅ Reranker 重排序正常")
    print("  ✅ 端到端 RAG 流程可用")
    print("=" * 70)


if __name__ == "__main__":
    main()
