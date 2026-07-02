"""知识库相关 Schema"""

from typing import Optional

from pydantic import BaseModel, Field


class QAPair(BaseModel):
    question: str = Field(..., description="问题")
    answer: str = Field(..., description="回答")


class KnowledgeImportRequest(BaseModel):
    source: str = Field(..., description="来源标识", min_length=1, max_length=256)
    texts: Optional[list[str]] = Field(default=None, description="文本列表")
    qa_pairs: Optional[list[QAPair]] = Field(default=None, description="问答对列表")


class KnowledgeImportResponse(BaseModel):
    source: str
    chunks: int
    ids: list[int]


class KnowledgeDeleteRequest(BaseModel):
    source: str = Field(..., description="要删除的来源标识")


class KnowledgeDeleteResponse(BaseModel):
    source: str
    deleted_count: int


class KnowledgeStatsResponse(BaseModel):
    name: str
    num_entities: int


class KnowledgeSearchRequest(BaseModel):
    query: str = Field(..., description="搜索内容", min_length=1)
    top_k: int = Field(default=5, ge=1, le=20, description="返回数量")


class KnowledgeSearchResponse(BaseModel):
    query: str
    results: list[dict]