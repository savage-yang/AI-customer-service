import { useState, useRef, useEffect } from 'react';
import { chatStream } from '../api.js';

export default function ChatWindow({ sessionId, messages, onUpdateMessages }) {
  const [input, setInput] = useState('');
  const [streaming, setStreaming] = useState(false);
  const [error, setError] = useState('');
  const endRef = useRef(null);
  const inputRef = useRef(null);

  useEffect(() => {
    endRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  useEffect(() => {
    inputRef.current?.focus();
  }, [sessionId]);

  const handleSend = async () => {
    const text = input.trim();
    if (!text || streaming) return;

    setInput('');
    setError('');

    const userMsg = { role: 'user', content: text };
    const assistantMsg = { role: 'assistant', content: '' };
    const updated = [...messages, userMsg, assistantMsg];
    onUpdateMessages(updated);

    setStreaming(true);
    try {
      await chatStream(
        sessionId,
        text,
        (chunk) => {
          updated[updated.length - 1] = {
            ...updated[updated.length - 1],
            content: updated[updated.length - 1].content + chunk,
          };
          onUpdateMessages([...updated]);
        },
        (err) => {
          setError(err);
          updated[updated.length - 1] = {
            ...updated[updated.length - 1],
            content: updated[updated.length - 1].content + ' [出错: ' + err + ']',
          };
          onUpdateMessages([...updated]);
        },
      );
    } catch (e) {
      setError(e.message);
    } finally {
      setStreaming(false);
    }
  };

  const handleKeyDown = (e) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      handleSend();
    }
  };

  return (
    <main className="chat-window">
      <div className="messages">
        {messages.length === 0 && (
          <div className="empty-state">
            <div className="empty-icon">💬</div>
            <p>AI 客服助手</p>
            <span>输入问题开始对话</span>
          </div>
        )}
        {messages.map((msg, i) => (
          <div key={i} className={`message ${msg.role}`}>
            <div className="avatar">{msg.role === 'user' ? '👤' : '🤖'}</div>
            <div className="bubble">
              {msg.content || (msg.role === 'assistant' && streaming && i === messages.length - 1
                ? <span className="typing">...</span>
                : msg.content)}
            </div>
          </div>
        ))}
        {error && <div className="error-banner">{error}</div>}
        <div ref={endRef} />
      </div>

      <div className="input-area">
        <textarea
          ref={inputRef}
          value={input}
          onChange={(e) => setInput(e.target.value)}
          onKeyDown={handleKeyDown}
          placeholder="输入消息..."
          rows={1}
          disabled={streaming}
        />
        <button
          className="btn-send"
          onClick={handleSend}
          disabled={!input.trim() || streaming}
        >
          <svg width="18" height="18" viewBox="0 0 18 18" fill="none">
            <path d="M2 9l14-7-7 14-2.5-5L2 9z" stroke="currentColor" strokeWidth="1.5"
              strokeLinejoin="round"/>
          </svg>
        </button>
      </div>
    </main>
  );
}