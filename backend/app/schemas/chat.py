"""对话相关 Schema"""

from pydantic import BaseModel, Field


class ChatRequest(BaseModel):
    question: str = Field(..., description="用户问题", min_length=1, max_length=5000)
    session_id: str = Field(default="default", description="会话ID")
    user_id: str = Field(default="anonymous", description="用户ID")


class ChatHistoryResponse(BaseModel):
    session_id: str
    messages: list[dict]


class ClearSessionResponse(BaseModel):
    session_id: str
    message: str
