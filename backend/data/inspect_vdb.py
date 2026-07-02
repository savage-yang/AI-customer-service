from pymilvus import MilvusClient

client = MilvusClient(uri=r"D:\客服机器人\backend\data\milvus_kb.db")

# 先加载 collection（Milvus Lite 需要这一步）
client.load_collection(collection_name='customer_service_kb')

results = client.query(
    collection_name='customer_service_kb',
    filter='',
    output_fields=['id', 'content', 'source', 'vector'],
    limit=10
)

for r in results:
    print(f"id={r['id']}, source={r['source']}")
    print(f"  content: {r['content'][:80]}...")
    print(f"  vector: {r['vector'][:6]}...")
    print()
