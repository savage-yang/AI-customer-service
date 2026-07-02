const API_BASE = 'http://localhost:8000';

/** 发送消息，SSE 流式接收回复 */
export async function chatStream(sessionId, question, onChunk, onError) {
  const response = await fetch(`${API_BASE}/chat/`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ session_id: sessionId, question }),
  });

  if (!response.ok) {
    throw new Error(`请求失败: ${response.status}`);
  }

  const reader = response.body.getReader();
  const decoder = new TextDecoder();
  let buffer = '';

  while (true) {
    const { done, value } = await reader.read();
    if (done) break;

    buffer += decoder.decode(value, { stream: true });
    const lines = buffer.split('\n');
    buffer = lines.pop() || '';

    for (const line of lines) {
      if (line.startsWith('data: ')) {
        const data = line.slice(6);
        if (data === '[DONE]') return;
        if (data.startsWith('[ERROR]')) {
          onError?.(data.slice(7));
          return;
        }
        onChunk(data);
      }
    }
  }
}

/** 获取会话历史 */
export async function getHistory(sessionId) {
  const res = await fetch(`${API_BASE}/chat/history/${sessionId}`);
  if (!res.ok) return { messages: [] };
  return res.json();
}

/** 清除会话 */
export async function clearSession(sessionId) {
  await fetch(`${API_BASE}/chat/session/${sessionId}`, { method: 'DELETE' });
}

/** 检查后端健康状态 */
export async function healthCheck() {
  try {
    const res = await fetch(`${API_BASE}/`);
    return res.ok;
  } catch {
    return false;
  }
}