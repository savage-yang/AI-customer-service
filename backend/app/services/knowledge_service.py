"""知识库管理服务 —— 文档导入 / 切分 / 向量化 / 入库"""

import os
import re
from typing import Optional

from langchain_text_splitters import RecursiveCharacterTextSplitter
from langchain_community.document_loaders import (
    PyPDFLoader,
    TextLoader,
    CSVLoader,
    Docx2txtLoader,
    UnstructuredMarkdownLoader,
)

from app.core.config import settings
from app.core.vector_store import vector_store_client


# 支持的文件类型映射
LOADER_MAP = {
    ".txt": TextLoader,
    ".pdf": PyPDFLoader,
    ".csv": CSVLoader,
    ".docx": Docx2txtLoader,
    ".md": UnstructuredMarkdownLoader,
}

# 结构化 QA 格式检测正则
_QA_CATEGORY_PATTERN = re.compile(r"^[一二三四五六七八九十]+、")       # 一、二、三、...
_QA_ITEM_PATTERN = re.compile(r"^\d+\.\d+\s")                         # 1.1, 2.1, 3.2 ...
_QA_SEPARATOR_PATTERN = re.compile(r"^━{3,}")                         # ━━━━━━━━━


class KnowledgeService:
    """知识库管理服务"""

    def __init__(self):
        self.text_splitter = RecursiveCharacterTextSplitter(
            chunk_size=settings.chunk_size,
            chunk_overlap=settings.chunk_overlap,
            separators=["\n\n", "\n", "。", "！", "？", "；", "，", " ", ""],
            length_function=len,
        )

    def _get_loader(self, file_path: str):
        """根据文件扩展名获取对应的 Loader"""
        ext = os.path.splitext(file_path)[1].lower()
        loader_cls = LOADER_MAP.get(ext)
        if loader_cls is None:
            raise ValueError(f"不支持的文件类型: {ext}，支持的类型: {list(LOADER_MAP.keys())}")
        return loader_cls(file_path, encoding="utf-8")

    # ── 结构化 QA 切分（按"一、1.1"层级切分，不做 chunk_size 切分）──

    def _is_structured_qa(self, text: str) -> bool:
        """检测文本是否为结构化 QA 格式（包含「一、」类目 + 「1.1」子条目）"""
        lines = text.strip().split("\n")
        has_category = any(_QA_CATEGORY_PATTERN.match(line.strip()) for line in lines)
        has_item = any(_QA_ITEM_PATTERN.match(line.strip()) for line in lines)
        return has_category and has_item

    def _split_structured_qa(self, text: str) -> list[str]:
        """按「类目 → 子条目」层级切分结构化 QA 文档

        输入格式:
            一、上电与启动
            ━━━━━━━━━
            1.1 问题标题
              内容...
            1.2 问题标题
              内容...

        输出:
            ["[上电与启动] 1.1 设备通电后无任何反应...\\n可能原因: ...", ...]
        """
        lines = text.strip().split("\n")
        chunks = []
        current_category = ""          # 当前类目名（一、上电与启动）
        current_item_title = ""        # 当前子条目标题（1.1 xxx）
        current_item_lines = []        # 当前子条目的内容行

        def _flush():
            """将当前积累的子条目内容输出为一个 chunk"""
            nonlocal current_category, current_item_title, current_item_lines
            if current_item_title and current_item_lines:
                body = "\n".join(current_item_lines).strip()
                # 拼接: [类目] 1.1 标题\n内容
                chunk = f"[{current_category}]\n{current_item_title}\n{body}"
                chunks.append(chunk)
            current_item_title = ""
            current_item_lines = []

        for line in lines:
            stripped = line.strip()

            # 空行跳过
            if not stripped:
                current_item_lines.append("")
                continue

            # 分隔线跳过（━━━ 这种）
            if _QA_SEPARATOR_PATTERN.match(stripped):
                continue

            # 检测类目头: 一、上电与启动
            if _QA_CATEGORY_PATTERN.match(stripped):
                _flush()                          # 先输出上一个子条目
                current_category = stripped       # 更新当前类目
                continue

            # 检测子条目: 1.1 设备通电后无任何反应
            if _QA_ITEM_PATTERN.match(stripped):
                _flush()                          # 先输出上一个子条目
                current_item_title = stripped     # 开启新子条目
                continue

            # 普通内容行，追加到当前子条目
            current_item_lines.append(stripped)

        # 最后一个子条目
        _flush()

        return chunks

    # ── 文档导入 ──

    def import_document(self, file_path: str, source: str = None) -> dict:
        """导入单个文档到知识库

        自动检测格式:
        - 结构化 QA（一、1.1 层级）→ 按子条目切分，每一条一个 chunk
        - 普通文档 → 按 chunk_size 滑动窗口切分

        Args:
            file_path: 文档路径
            source: 来源标识，默认使用文件名

        Returns:
            dict: {"source": str, "chunks": int, "ids": list}
        """
        if source is None:
            source = os.path.basename(file_path)

        # 1. 加载文档
        loader = self._get_loader(file_path)
        documents = loader.load()

        # 2. 合并全文，检测格式，选择切分策略
        full_text = "\n".join(doc.page_content for doc in documents)

        if self._is_structured_qa(full_text):
            texts = self._split_structured_qa(full_text)
            print(f"[INFO] 检测到结构化 QA 格式，按子条目切分 → {len(texts)} 条")
        else:
            chunks = self.text_splitter.split_documents(documents)
            texts = [chunk.page_content for chunk in chunks]
            print(f"[INFO] 普通文档格式，按 chunk_size 切分 → {len(texts)} 个分块")

        if not texts:
            return {"source": source, "chunks": 0, "ids": []}

        # 打印切分后的 chunk 内容
        print(f"\n{'='*60}")
        print(f"[CHUNKS] 切分结果 (共 {len(texts)} 条):")
        print(f"{'='*60}")
        for i, text in enumerate(texts):
            preview = text[:120].replace("\n", "\\n")
            print(f"  [{i+1}] len={len(text)} | {preview}{'...' if len(text) > 120 else ''}")
        print(f"{'='*60}\n")

        # 3. 向量化 + 入库
        ids = vector_store_client.insert_texts(texts, source=source)

        return {
            "source": source,
            "chunks": len(texts),
            "ids": [int(i) for i in ids],
        }

    def import_texts(self, texts: list[str], source: str) -> dict:
        """直接导入文本列表到知识库

        Args:
            texts: 文本列表
            source: 来源标识

        Returns:
            dict: {"source": str, "chunks": int, "ids": list}
        """
        all_chunks = []
        for text in texts:
            chunks = self.text_splitter.split_text(text)
            all_chunks.extend(chunks)

        if not all_chunks:
            return {"source": source, "chunks": 0, "ids": []}

        ids = vector_store_client.insert_texts(all_chunks, source=source)

        return {
            "source": source,
            "chunks": len(all_chunks),
            "ids": [int(i) for i in ids],
        }

    def import_qa_pairs(self, qa_pairs: list[dict], source: str) -> dict:
        """导入问答对到知识库

        Args:
            qa_pairs: [{"question": str, "answer": str}, ...]
            source: 来源标识

        Returns:
            dict: {"source": str, "chunks": int, "ids": list}
        """
        texts = [f"问题：{qa['question']}\n回答：{qa['answer']}" for qa in qa_pairs]
        return self.import_texts(texts, source=source)

    def delete_source(self, source: str) -> int:
        """按来源删除知识"""
        return vector_store_client.delete_by_source(source)

    def get_stats(self) -> dict:
        """获取知识库统计信息"""
        return vector_store_client.get_collection_stats()


knowledge_service = KnowledgeService()