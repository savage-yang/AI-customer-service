"""RAG 检索增强生成服务 - 核心流程：判断是否需要检索 → 检索 → 重排序 → 生成（vLLM 流式）"""

from app.core.config import settings
from app.core.llm_client import llm_client
from app.core.vector_store import vector_store_client
from app.services.rerank_service import rerank_service


SYSTEM_PROMPT = """你是一个智能客服机器人，根据提供的信息回答用户问题。

知识库主题范围：
{knowledge_topics}

任务规则：
- 如果提供了“知识库信息”，只允许依据知识库内容回答用户问题。
- 如果知识库信息为空或与问题不相关，则作为通用客服回答，礼貌回应即可。
- 如果问题超出你的知识范围（包括知识库范围外的内容），直接回复：
“当前问题暂未匹配到可用的知识库内容，或已超出我的处理范围。请联系人工客服电话：xxx-123-456。”
- 如果用户明确要求人工服务，也直接回复上述电话。
- 回答时尽量整理为“可能原因 + 排查步骤”（如有相关知识）。
- 回答应简洁、准确、可执行，不要扩写无关内容。"""

JUDGE_SYSTEM_PROMPT = """你是一个智能判断助手，负责判断用户问题是否需要检索知识库。

知识库主题范围：
{knowledge_topics}

判断规则：
- 如果问题属于上述主题范围（如产品使用、故障排查、售后服务等），回答：YES
- 如果问题是日常问候、闲聊、感谢等通用对话，回答：NO
- 如果问题是关于天气、新闻等知识库范围外的内容，回答：NO
- 如果问题是在对话历史基础上继续追问相关问题，回答：YES

只回答 YES 或 NO，不要输出其他内容。"""


class RAGService:
    """RAG 检索增强生成服务"""

    async def _should_retrieve(self, question: str, history: str = "") -> bool:
        """判断是否需要检索知识库"""
        prompt = JUDGE_SYSTEM_PROMPT.format(knowledge_topics=settings.knowledge_base_topics)
        
        messages = []
        if history:
            messages.append({"role": "user", "content": f"对话历史：\n{history}"})
        messages.append({"role": "user", "content": f"问题：{question}\n\n请判断是否需要检索知识库？"})

        async with llm_client.session() as client:
            response = await client.chat.completions.create(
                model=settings.llm_model_name,
                messages=[
                    {"role": "user", "content": prompt},
                    *messages,
                ],
                temperature=0.0,
                max_tokens=10,
                stream=False,
                extra_body={"chat_template_kwargs": {"enable_thinking": False}}
            )

        content = response.choices[0].message.content
        if content is None:
            print("[RAG] LLM 返回内容为空，默认执行检索")
            return True
        result = content.strip().upper()
        need_retrieve = result == "YES"
        print(f"[RAG] 判断结果: {result} (是否需要检索: {need_retrieve})")
        return need_retrieve

    async def ask_stream(self, question: str, history: str = ""):
        """流式 RAG 问答（判断是否需要检索 → 检索 → 重排序 → vLLM 流式生成）
        
        Args:
            question: 当前问题
            history: 对话历史（可选）
        """
        need_retrieve = await self._should_retrieve(question, history)

        if need_retrieve:
            docs = vector_store_client.search(question, top_k=settings.retrieval_top_k)
            docs = rerank_service.rerank(question, docs, top_k=settings.rerank_top_k)

            context_parts = []
            for i, doc in enumerate(docs, 1):
                context_parts.append(f"[{i}] {doc['content']}")
            context = "\n\n".join(context_parts)
        else:
            context = ""

        parts = []
        if history:
            parts.append(f"对话历史：\n{history}")
        if context:
            parts.append(f"知识库信息：\n{context}")
        parts.append(f"用户问题：{question}")
        parts.append("回答：")
        
        user_prompt = "\n\n".join(parts)
        system_prompt = SYSTEM_PROMPT.format(knowledge_topics=settings.knowledge_base_topics)

        async with llm_client.session() as client:
            stream = await client.chat.completions.create(
                model=settings.llm_model_name,
                messages=[
                    {"role": "user", "content": system_prompt + "\n\n" + user_prompt},
                ],
                temperature=settings.llm_temperature,
                max_tokens=settings.llm_max_tokens,
                stream=True,
                extra_body={"chat_template_kwargs": {"enable_thinking": False}}
            )

            async for chunk in stream:
                content = chunk.choices[0].delta.content
                if content:
                    yield content


rag_service = RAGService()