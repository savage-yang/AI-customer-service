"""RAG 检索增强生成服务 - 核心流程：检索 → 重排序 → 生成（vLLM 流式）"""

from app.core.config import settings
from app.core.llm_client import llm_client
from app.core.vector_store import vector_store_client
from app.services.rerank_service import rerank_service


RAG_SYSTEM_PROMPT = """你是一个专业的客服助手，请根据以下已知信息回答用户的问题。

要求：
1. 如果已知信息可以回答问题，请基于已知信息给出准确、清晰的回答。
2. 如果已知信息不足以回答，请如实告知用户，不要编造任何信息。
3. 回答时请保持友好、专业的语气。"""


class RAGService:
    """RAG 检索增强生成服务"""

    async def ask_stream(self, question: str):
        """流式 RAG 问答（检索 → 重排序 → vLLM 流式生成）"""
        docs = vector_store_client.search(question, top_k=settings.retrieval_top_k)
        docs = rerank_service.rerank(question, docs, top_k=settings.rerank_top_k)

        if not docs:
            yield "抱歉，我暂时没有找到相关知识来回答您的问题。"
            return

        context_parts = []
        for i, doc in enumerate(docs, 1):
            context_parts.append(f"[{i}] {doc['content']}")
        context = "\n\n".join(context_parts)

        user_prompt = f"已知信息：\n{context}\n\n用户问题：{question}\n\n回答："

        stream = await llm_client.client.chat.completions.create(
            model=settings.llm_model_name,
            messages=[
                {"role": "user", "content": RAG_SYSTEM_PROMPT + "\n\n" + user_prompt},
            ],
            temperature=settings.llm_temperature,
            max_tokens=settings.llm_max_tokens,
            stream=True,
        )

        async for chunk in stream:
            content = chunk.choices[0].delta.content
            if content:
                yield content


rag_service = RAGService()