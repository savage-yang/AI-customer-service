import os
from modelscope.hub.snapshot_download import snapshot_download

MODELS = [
    {
        "model_id": "BAAI/bge-large-zh-v1.5",
        "local_dir": "BAAI/bge-large-zh-v1.5"
    },
    {
        "model_id": "BAAI/bge-reranker-large",
        "local_dir": "BAAI/bge-reranker-large"
    }
]

def download_model(model_id, local_dir):
    print(f"\n{'='*60}")
    print(f"开始下载模型: {model_id}")
    print(f"保存路径: {local_dir}")
    print(f"{'='*60}")
    
    try:
        snapshot_download(
            model_id=model_id,
            local_dir=local_dir
        )
        print(f"\n✓ 模型 {model_id} 下载完成！")
        return True
    except Exception as e:
        print(f"\n✗ 下载失败: {str(e)}")
        return False

if __name__ == "__main__":
    os.makedirs("BAAI", exist_ok=True)
    
    success_count = 0
    for model in MODELS:
        if download_model(model["model_id"], model["local_dir"]):
            success_count += 1
    
    print(f"\n{'='*60}")
    print(f"下载完成！成功: {success_count}/{len(MODELS)}")
    print(f"{'='*60}")