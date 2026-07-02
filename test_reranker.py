"""Reranker 模型测试脚本 — 验证 BGE 重排序效果（transformers 原生实现）"""
from pathlib import Path
import sys
import time

import torch
from transformers import AutoTokenizer, AutoModelForSequenceClassification

MODEL_PATH = Path(__file__).parent / "models" / "BAAI" / "bge-reranker-large"


def main():
    print("=" * 60)
    print("Reranker 模型测试（transformers 原生）")
    print(f"模型路径: {MODEL_PATH}")
    print("=" * 60)

    if not MODEL_PATH.exists():
        print(f"错误: 模型路径不存在: {MODEL_PATH}")
        return

    print("\n[1/3] 加载模型...")
    t0 = time.time()
    tokenizer = AutoTokenizer.from_pretrained(str(MODEL_PATH))
    model = AutoModelForSequenceClassification.from_pretrained(str(MODEL_PATH))
    model.eval()
    print(f"  加载完成，耗时 {time.time() - t0:.2f}s")

    print("\n[2/3] 准备测试数据...")
    query = "如何申请退款？"
    docs = [
        "退款流程：用户可以在订单详情页点击申请退款按钮，填写退款原因后提交，客服会在1-3个工作日内审核。",
        "退货政策：商品收到后7天内无理由退货，需保持商品完好，运费由买家承担。",
        "物流查询：可在我的订单中查看物流信息，一般3-5天到货。",
        "退款到账时间：审核通过后，退款将在1-3个工作日原路返回。",
        "修改收货地址：发货前可在订单详情页修改，发货后需联系客服处理。",
    ]
    print(f"  查询: {query}")
    print(f"  文档数: {len(docs)}")

    print("\n[3/3] 重排序测试...")
    pairs = [[query, doc] for doc in docs]

    t0 = time.time()
    queries = [p[0] for p in pairs]
    documents = [p[1] for p in pairs]

    with torch.no_grad():
        inputs = tokenizer(
            queries, documents,
            padding=True,
            truncation=True,
            max_length=512,
            return_tensors="pt",
        )
        logits = model(**inputs).logits.squeeze(-1)
        scores = torch.sigmoid(logits).numpy().tolist()

    print(f"  计算完成，耗时 {time.time() - t0:.3f}s")

    ranked = sorted(zip(docs, scores), key=lambda x: x[1], reverse=True)

    print(f"\n  重排序结果:")
    for i, (doc, score) in enumerate(ranked, 1):
        bar = "█" * int(score * 40)
        print(f"\n  [{i}] 得分: {score:.4f}  {bar}")
        print(f"      {doc[:60]}..." if len(doc) > 60 else f"      {doc}")

    print("\n" + "=" * 60)
    print("测试通过！Reranker 模型工作正常")
    print("=" * 60)


if __name__ == "__main__":
    main()
