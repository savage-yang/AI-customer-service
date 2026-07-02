"""vLLM 本地大模型测试脚本 — 验证 vLLM 部署的模型调用"""

import os
import time
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).parent / "backend"))

# 尝试加载 .env
try:
    from dotenv import load_dotenv
    env_path = Path(__file__).parent / "backend" / ".env"
    if env_path.exists():
        load_dotenv(env_path)
except ImportError:
    pass

VLLM_BASE_URL = os.environ.get("VLLM_BASE_URL", "http://localhost:8081/v1")
VLLM_API_KEY = os.environ.get("VLLM_API_KEY", "EMPTY")
VLLM_MODEL = os.environ.get("VLLM_MODEL_NAME", "Qwen3.5-9B")
# Qwen3.5 思考模式配置（enable_thinking=False 可禁用思考过程，直接输出答案）
VLLM_CHAT_TEMPLATE_KWARGS = {"enable_thinking": True}


def get_response_content(message):
    """提取模型回复内容（兼容 Qwen3.5 等思考型模型）"""
    content = message.content
    if content:
        return content
    # Qwen3.5 等思考型模型可能把回复放在 reasoning 字段
    if hasattr(message, 'reasoning') and message.reasoning:
        return message.reasoning
    return "(无内容)"

def test_vllm_stream():
    """测试 vLLM 流式输出"""
    print("\n" + "=" * 60)
    print("[测试2] vLLM 流式输出")
    print("=" * 60)

    try:
        from openai import OpenAI
    except ImportError:
        print("  失败: 请先安装 openai 库")
        return False

    try:
        client = OpenAI(base_url=VLLM_BASE_URL, api_key=VLLM_API_KEY)

        t0 = time.time()
        print("  回复（流式）:")
        stream = client.chat.completions.create(
            model=VLLM_MODEL,
            messages=[{"role": "user", "content": "简短介绍一下你自己"}],
            temperature=0.1,
            max_tokens=2048,
            stream=True,
            extra_body={"chat_template_kwargs": VLLM_CHAT_TEMPLATE_KWARGS},
        )
        
        # 收集思考和内容，分别显示
        reasoning_buffer = ""
        content_buffer = ""
        in_reasoning = False
        
        for chunk in stream:
            delta = chunk.choices[0].delta
            if hasattr(delta, 'reasoning') and delta.reasoning:
                if not in_reasoning:
                    print("  【思考过程】")
                    in_reasoning = True
                reasoning_buffer += delta.reasoning
                # 实时打印思考内容（不带标记）
                print(delta.reasoning, end="", flush=True)
            elif delta.content:
                if in_reasoning:
                    print("\n")  # 思考结束后换行
                    print("  【最终答案】")
                    in_reasoning = False
                content_buffer += delta.content
                print(delta.content, end="", flush=True)
        
        print(f"\n  耗时: {time.time() - t0:.2f}s")
        return True
    except Exception as e:
        print(f"  失败: {e}")
        return False


def test_vllm_rag_stream():
    """测试 vLLM RAG 场景（流式输出）"""
    print("\n" + "=" * 60)
    print("[测试4] vLLM RAG 场景（流式）")
    print("=" * 60)

    try:
        from openai import OpenAI
    except ImportError:
        print("  失败: 请先安装 openai 库")
        return False

    context = """
    【知识1】退款流程：用户可以在订单详情页点击申请退款按钮，填写退款原因后提交。
    【知识2】退款到账时间：审核通过后1-3个工作日原路返回。
    """
    question = "我申请退款后多久能到账？"

    try:
        client = OpenAI(base_url=VLLM_BASE_URL, api_key=VLLM_API_KEY)

        prompt = f"""你是一个专业的客服助手。请根据以下参考资料回答用户问题。
如果参考资料中没有答案，请礼貌地告知用户。

参考资料：
{context}

用户问题：{question}

回答："""

        t0 = time.time()
        print("  回复（流式）:")
        stream = client.chat.completions.create(
            model=VLLM_MODEL,
            messages=[{"role": "user", "content": prompt}],
            temperature=0.1,
            max_tokens=2048,
            stream=True,  # 开启流式
            extra_body={"chat_template_kwargs": VLLM_CHAT_TEMPLATE_KWARGS},
        )
        
        # 流式处理 - 必须迭代 stream 对象
        in_reasoning = False
        for chunk in stream:
            delta = chunk.choices[0].delta
            if hasattr(delta, 'reasoning') and delta.reasoning:
                if not in_reasoning:
                    print("  【思考过程】")
                    in_reasoning = True
                print(delta.reasoning, end="", flush=True)
            elif delta.content:
                if in_reasoning:
                    print("\n\n  【最终答案】")
                    in_reasoning = False
                print(delta.content, end="", flush=True)
        
        print(f"\n  耗时: {time.time() - t0:.2f}s")
        return True
    except Exception as e:
        print(f"  失败: {e}")
        return False


def test_vllm_health():
    """检查 vLLM 服务是否可用"""
    print("=" * 60)
    print("[检查] vLLM 服务健康状态")
    print("=" * 60)

    try:
        from openai import OpenAI
    except ImportError:
        print("  失败: 请先安装 openai 库")
        return False

    try:
        client = OpenAI(base_url=VLLM_BASE_URL, api_key=VLLM_API_KEY)
        models = client.models.list()
        print(f"  ✅ vLLM 服务可用")
        print(f"  已加载模型:")
        for m in models.data:
            print(f"    - {m.id}")
        return True
    except Exception as e:
        print(f"  ❌ vLLM 服务不可用: {e}")
        print(f"\n  请先启动 vLLM 服务:")
        print(f"    vllm serve {VLLM_MODEL} --host 0.0.0.0 --port 8081")
        return False


def main():
    print("\n" + "=" * 60)
    print("vLLM 本地大模型测试")
    print("=" * 60)

    if not test_vllm_health():
        return

    results = [
        test_vllm_stream(),
        test_vllm_rag_stream(),
    ]

    print("\n" + "=" * 60)
    print(f"测试结果: {sum(results)}/{len(results)} 通过")
    print("=" * 60)


if __name__ == "__main__":
    main()

