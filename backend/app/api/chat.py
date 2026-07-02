"""对话 API 路由"""

import uuid

from fastapi import APIRouter
from fastapi.responses import StreamingResponse

from app.schemas.chat import (
    ChatRequest,
    ChatHistoryResponse,
    ClearSessionResponse,
)
from app.services.chat_service import chat_service

router = APIRouter(prefix="/chat", tags=["对话"])


@router.post("/", summary="发送消息（流式）")
async def chat(req: ChatRequest):
    """发送消息，SSE 流式返回 AI 回复"""
    session_id = req.session_id if req.session_id != "default" else f"session_{uuid.uuid4().hex[:12]}"

    async def generate():
        try:
            async for chunk in chat_service.chat_stream(
                session_id=session_id,
                question=req.question,
            ):
                yield f"data: {chunk}\n\n"
            yield "data: [DONE]\n\n"
        except Exception as e:
            yield f"data: [ERROR] {str(e)}\n\n"

    return StreamingResponse(
        generate(),
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "Connection": "keep-alive",
            "X-Accel-Buffering": "no",
            "X-Session-Id": session_id,
        },
    )


@router.get("/history/{session_id}", response_model=ChatHistoryResponse, summary="获取会话历史")
async def get_history(session_id: str):
    messages = await chat_service.get_history(session_id)
    return ChatHistoryResponse(session_id=session_id, messages=messages)


@router.delete("/session/{session_id}", response_model=ClearSessionResponse, summary="清除会话")
async def clear_session(session_id: str):
    await chat_service.clear_session(session_id)
    return ClearSessionResponse(session_id=session_id, message="会话已清除")
