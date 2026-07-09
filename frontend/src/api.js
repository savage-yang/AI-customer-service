const API_BASE = '';

/** 获取或生成持久化 user_id */
export function getUserId() {
  const KEY = 'ai-cs-user-id';
  let id = localStorage.getItem(KEY);
  if (!id) {
    id = 'u_' + Date.now().toString(36) + Math.random().toString(36).slice(2, 8);
    localStorage.setItem(KEY, id);
  }
  return id;
}

/** 发送消息，SSE 流式接收回复 */
export async function chatStream(sessionId, question, onChunk, onError, userId) {
  const response = await fetch(`${API_BASE}/chat/`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ session_id: sessionId, question, user_id: userId || getUserId() }),
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