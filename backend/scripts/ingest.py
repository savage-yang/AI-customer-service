"""独立灌库脚本 — 扫描 data/knowledge_base/ 目录批量导入知识库

用法:
    # 扫描 data/knowledge_base/ 目录下所有文件自动灌库
    python scripts/ingest.py

    # 导入单个文件
    python scripts/ingest.py --file data/knowledge_base/faq.pdf

    # 导入纯文本
    python scripts/ingest.py --text "如何退货？请访问官网退货页面。" --source "退货FAQ"

    # 导入问答对
    python scripts/ingest.py --qa '[{"question":"如何退货？","answer":"访问官网退货页面"}]' --source "FAQ"

    # 清除指定来源后重新导入
    python scripts/ingest.py --clear "退货FAQ" --file data/knowledge_base/faq.pdf

    # 只看统计
    python scripts/ingest.py --stats

Remove-Item backend\data\milvus_kb.db -Force -ErrorAction SilentlyContinue
"""

import argparse
import json
import os
import sys
from pathlib import Path

# 确保导入路径正确
_backend_dir = Path(__file__).parent.parent.resolve()
if str(_backend_dir) not in sys.path:
    sys.path.insert(0, str(_backend_dir))

from app.core.vector_store import vector_store_client
from app.services.knowledge_service import knowledge_service, LOADER_MAP

# 知识库文档目录
KNOWLEDGE_BASE_DIR = _backend_dir / "data" / "knowledge_base"

# 扫描时忽略的文件
IGNORE_PATTERNS = [".gitkeep", ".DS_Store", "Thumbs.db"]


def scan_files() -> list[Path]:
    """扫描 knowledge_base 目录下所有支持的文件"""
    if not KNOWLEDGE_BASE_DIR.exists():
        print(f"[ERROR] 知识库目录不存在: {KNOWLEDGE_BASE_DIR}")
        return []

    files = []
    for f in KNOWLEDGE_BASE_DIR.iterdir():
        if f.name in IGNORE_PATTERNS:
            continue
        if f.suffix.lower() in LOADER_MAP:
            files.append(f)
        else:
            print(f"[SKIP] 不支持的类型: {f.name}")
    return files


def ingest_file(file_path: Path, source: str = None) -> dict:
    """导入单个文件（自动清除旧数据避免重复）"""
    if source is None:
        source = file_path.name
    # 先清除旧数据，避免重复插入
    deleted = vector_store_client.delete_by_source(source)
    if deleted > 0:
        print(f"[CLEAR] 已删除 {deleted} 条旧数据 (source={source})")

    print(f"[INGEST] {file_path.name} ...", end=" ", flush=True)
    result = knowledge_service.import_document(str(file_path), source=source)
    print(f"完成 ({result['chunks']} 个分块)")
    return result


def ingest_texts(texts: list[str], source: str) -> dict:
    """导入纯文本（自动清除旧数据避免重复）"""
    deleted = vector_store_client.delete_by_source(source)
    if deleted > 0:
        print(f"[CLEAR] 已删除 {deleted} 条旧数据 (source={source})")

    print(f"[INGEST] 文本导入 (source={source}) ...", end=" ", flush=True)
    result = knowledge_service.import_texts(texts, source=source)
    print(f"完成 ({result['chunks']} 个分块)")
    return result


def ingest_qa_pairs(qa_pairs: list[dict], source: str) -> dict:
    """导入问答对（自动清除旧数据避免重复）"""
    deleted = vector_store_client.delete_by_source(source)
    if deleted > 0:
        print(f"[CLEAR] 已删除 {deleted} 条旧数据 (source={source})")

    print(f"[INGEST] 问答对导入 (source={source}) ...", end=" ", flush=True)
    result = knowledge_service.import_qa_pairs(qa_pairs, source=source)
    print(f"完成 ({result['chunks']} 个分块)")
    return result


def clear_source(source: str):
    """清除指定来源"""
    count = vector_store_client.delete_by_source(source)
    print(f"[CLEAR] 已删除 {count} 条，来源: {source}")


def show_stats():
    """显示知识库统计"""
    stats = vector_store_client.get_collection_stats()
    print(f"[STATS] 知识库: {stats['name']}")
    print(f"[STATS] 向量总数: {stats['num_entities']}")


def main():
    parser = argparse.ArgumentParser(description="知识库灌库脚本")
    parser.add_argument("--file", type=str, help="导入单个文件")
    parser.add_argument("--dir", type=str, help="扫描指定目录（默认: data/knowledge_base/）")
    parser.add_argument("--text", type=str, help="导入纯文本（多个用逗号分隔）")
    parser.add_argument("--qa", type=str, help="导入问答对（JSON 格式）")
    parser.add_argument("--source", type=str, help="知识来源标识")
    parser.add_argument("--clear", type=str, help="先清除指定来源再导入")
    parser.add_argument("--stats", action="store_true", help="仅查看统计")
    args = parser.parse_args()

    # 确保 vector_store 已初始化
    vector_store_client._ensure_collection()

    # 仅查看统计
    if args.stats:
        show_stats()
        return

    # 清除指定来源
    if args.clear:
        clear_source(args.clear)

    # 扫描目录批量导入
    scan_dir = args.dir or None
    if not args.file and not args.text and not args.qa:
        # 默认扫描 knowledge_base 目录
        files = scan_files()
        if not files:
            print("[INFO] knowledge_base 目录为空，无文件需要导入。")
            print(f"[INFO] 请将文档放入: {KNOWLEDGE_BASE_DIR}")
            show_stats()
            return
        print(f"[INFO] 扫描到 {len(files)} 个文件，开始导入...")
        print("=" * 60)
        total_chunks = 0
        for f in sorted(files):
            result = ingest_file(f)
            total_chunks += result["chunks"]
        print("=" * 60)
        print(f"[DONE] 导入完成，共 {total_chunks} 个分块")
        show_stats()
        return

    # 导入单个文件
    if args.file:
        file_path = Path(args.file)
        if not file_path.exists():
            print(f"[ERROR] 文件不存在: {file_path}")
            sys.exit(1)
        source = args.source or file_path.name
        ingest_file(file_path, source=source)
        show_stats()
        return

    # 导入纯文本
    if args.text:
        source = args.source or "manual_text"
        texts = [t.strip() for t in args.text.split(",") if t.strip()]
        ingest_texts(texts, source=source)
        show_stats()
        return

    # 导入问答对
    if args.qa:
        source = args.source or "manual_qa"
        qa_pairs = json.loads(args.qa)
        ingest_qa_pairs(qa_pairs, source=source)
        show_stats()
        return


if __name__ == "__main__":
    main()