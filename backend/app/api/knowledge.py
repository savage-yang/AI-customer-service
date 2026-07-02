"""知识库管理 API 路由"""

from fastapi import APIRouter, File, UploadFile, HTTPException
import os
import tempfile

from app.schemas.knowledge import (
    KnowledgeImportRequest,
    KnowledgeImportResponse,
    KnowledgeDeleteRequest,
    KnowledgeDeleteResponse,
    KnowledgeStatsResponse,
    KnowledgeSearchRequest,
    KnowledgeSearchResponse,
)
from app.services.knowledge_service import knowledge_service
from app.core.vector_store import vector_store_client

router = APIRouter(prefix="/knowledge", tags=["知识库"])


@router.post("/import", response_model=KnowledgeImportResponse, summary="导入文本/问答对")
async def import_knowledge(req: KnowledgeImportRequest):
    """导入文本或问答对到知识库"""
    if req.texts:
        result = knowledge_service.import_texts(req.texts, source=req.source)
    elif req.qa_pairs:
        qa_list = [{"question": qa.question, "answer": qa.answer} for qa in req.qa_pairs]
        result = knowledge_service.import_qa_pairs(qa_list, source=req.source)
    else:
        raise HTTPException(status_code=400, detail="请提供 texts 或 qa_pairs")
    return KnowledgeImportResponse(**result)


@router.post("/upload", response_model=KnowledgeImportResponse, summary="上传文件导入")
async def upload_file(
    file: UploadFile = File(..., description="支持 txt, pdf, csv, docx, md"),
    source: str = "",
):
    """上传文件导入知识库"""
    ext = os.path.splitext(file.filename or "")[1].lower()
    allowed = {".txt", ".pdf", ".csv", ".docx", ".md"}
    if ext not in allowed:
        raise HTTPException(status_code=400, detail=f"不支持的文件类型: {ext}")

    if not source:
        source = file.filename or "uploaded_file"

    # 保存临时文件
    with tempfile.NamedTemporaryFile(delete=False, suffix=ext) as tmp:
        content = await file.read()
        tmp.write(content)
        tmp_path = tmp.name

    try:
        result = knowledge_service.import_document(tmp_path, source=source)
        return KnowledgeImportResponse(**result)
    finally:
        os.unlink(tmp_path)


@router.post("/search", response_model=KnowledgeSearchResponse, summary="知识库检索")
async def search_knowledge(req: KnowledgeSearchRequest):
    """语义检索知识库"""
    results = vector_store_client.search(req.query, top_k=req.top_k)
    return KnowledgeSearchResponse(query=req.query, results=results)


@router.delete("/delete", response_model=KnowledgeDeleteResponse, summary="删除知识")
async def delete_knowledge(req: KnowledgeDeleteRequest):
    """按来源删除知识"""
    count = knowledge_service.delete_source(req.source)
    return KnowledgeDeleteResponse(source=req.source, deleted_count=count)


@router.get("/stats", response_model=KnowledgeStatsResponse, summary="知识库统计")
async def get_stats():
    stats = knowledge_service.get_stats()
    return KnowledgeStatsResponse(**stats)