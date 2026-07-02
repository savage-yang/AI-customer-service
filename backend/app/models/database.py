"""数据库模型 (PostgreSQL + SQLAlchemy)"""

from datetime import datetime

from sqlalchemy import Column, Integer, String, Text, DateTime, Float, JSON
from sqlalchemy.orm import DeclarativeBase


class Base(DeclarativeBase):
    pass


class ChatLog(Base):
    """对话日志表"""
    __tablename__ = "chat_logs"

    id = Column(Integer, primary_key=True, autoincrement=True)
    session_id = Column(String(64), index=True, comment="会话ID")
    question = Column(Text, comment="用户问题")
    answer = Column(Text, comment="AI回答")
    sources = Column(JSON, comment="参考来源")
    confidence = Column(Float, comment="置信度")
    latency_ms = Column(Integer, comment="响应耗时(毫秒)")
    created_at = Column(DateTime, default=datetime.utcnow, index=True, comment="创建时间")


class KnowledgeDocument(Base):
    """知识文档记录表"""
    __tablename__ = "knowledge_documents"

    id = Column(Integer, primary_key=True, autoincrement=True)
    source = Column(String(256), unique=True, index=True, comment="来源标识")
    title = Column(String(256), comment="文档标题")
    file_type = Column(String(16), comment="文件类型")
    chunk_count = Column(Integer, comment="切块数量")
    created_at = Column(DateTime, default=datetime.utcnow, comment="创建时间")
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, comment="更新时间")


class Feedback(Base):
    """用户反馈表"""
    __tablename__ = "feedbacks"

    id = Column(Integer, primary_key=True, autoincrement=True)
    session_id = Column(String(64), index=True, comment="会话ID")
    question = Column(Text, comment="用户问题")
    answer = Column(Text, comment="AI回答")
    rating = Column(Integer, comment="评分 1-5")
    comment = Column(Text, comment="反馈备注")
    created_at = Column(DateTime, default=datetime.utcnow, comment="创建时间")