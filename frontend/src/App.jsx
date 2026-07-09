import { useState, useCallback, useEffect } from 'react';
import Sidebar from './components/Sidebar.jsx';
import ChatWindow from './components/ChatWindow.jsx';
import AgentWorkbench from './components/AgentWorkbench.jsx';
import { healthCheck } from './api.js';

const STORAGE_KEY = 'ai-cs-sessions';

function loadSessions() {
  try {
    return JSON.parse(localStorage.getItem(STORAGE_KEY)) || [];
  } catch {
    return [];
  }
}

function saveSessions(sessions) {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(sessions));
}

function genId() {
  return 's_' + Date.now().toString(36) + Math.random().toString(36).slice(2, 6);
}

export default function App() {
  const [sessions, setSessions] = useState(loadSessions);
  const [activeId, setActiveId] = useState(null);
  const [healthy, setHealthy] = useState(false);

  useEffect(() => {
    healthCheck().then(setHealthy);
    const timer = setInterval(() => healthCheck().then(setHealthy), 30000);
    return () => clearInterval(timer);
  }, []);

  useEffect(() => {
    saveSessions(sessions);
  }, [sessions]);

  const active = sessions.find((s) => s.id === activeId) || null;

  const handleNew = useCallback(() => {
    const id = genId();
    setSessions((prev) => [{ id, title: '', messages: [], createdAt: Date.now() }, ...prev]);
    setActiveId(id);
  }, []);

  const handleSelect = useCallback((id) => {
    setActiveId(id);
  }, []);

  const handleDelete = useCallback((id) => {
    setSessions((prev) => prev.filter((s) => s.id !== id));
    if (activeId === id) {
      setSessions((prev) => {
        const next = prev[0];
        setActiveId(next?.id || null);
        return prev;
      });
    }
  }, [activeId]);

  const handleUpdateMessages = useCallback((messages) => {
    setSessions((prev) => {
      const updated = prev.map((s) => {
        if (s.id !== activeId) return s;
        const userMsg = messages.find((m) => m.role === 'user');
        const title = s.title || userMsg?.content?.slice(0, 30) || '';
        return { ...s, messages, title };
      });
      return updated;
    });
  }, [activeId]);

  const isAgent = window.location.pathname.startsWith('/video') || window.location.pathname === '/agent' || window.location.port === '8001';

  if (isAgent) {
    return <AgentWorkbench />;
  }

  return (
    <div className="app">
      <Sidebar
        sessions={sessions}
        activeId={activeId}
        onSelect={handleSelect}
        onNew={handleNew}
        onDelete={handleDelete}
      />
      {active ? (
        <ChatWindow
          sessionId={active.id}
          messages={active.messages}
          onUpdateMessages={handleUpdateMessages}
        />
      ) : (
        <main className="chat-window empty">
          <div className="empty-state">
            <div className="empty-icon">💬</div>
            <p>AI 客服机器人</p>
            <span>点击左侧 + 新建对话</span>
            <div className={`status ${healthy ? 'ok' : 'off'}`}>
              {healthy ? '● 后端连接正常' : '○ 后端未连接'}
            </div>
            <a href="/agent" className="agent-link">进入客服工作台</a>
          </div>
        </main>
      )}
    </div>
  );
}