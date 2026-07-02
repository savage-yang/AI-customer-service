export default function Sidebar({ sessions, activeId, onSelect, onNew, onDelete }) {
  const sorted = [...sessions].sort((a, b) => b.createdAt - a.createdAt);

  return (
    <aside className="sidebar">
      <div className="sidebar-header">
        <h1>AI 客服</h1>
        <button className="btn-new" onClick={onNew} title="新建对话">
          <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
            <path d="M10 4v12M4 10h12" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round"/>
          </svg>
        </button>
      </div>
      <div className="session-list">
        {sorted.map((s) => (
          <div
            key={s.id}
            className={`session-item ${s.id === activeId ? 'active' : ''}`}
            onClick={() => onSelect(s.id)}
          >
            <span className="session-title">{s.title || '新对话'}</span>
            <button
              className="btn-delete"
              onClick={(e) => { e.stopPropagation(); onDelete(s.id); }}
              title="删除"
            >
              <svg width="14" height="14" viewBox="0 0 14 14" fill="none">
                <path d="M3 4h8M5.5 4V3a1 1 0 011-1h1a1 1 0 011 1v1M11 4v7a1 1 0 01-1 1H4a1 1 0 01-1-1V4"
                  stroke="currentColor" strokeWidth="1.2" strokeLinecap="round"/>
              </svg>
            </button>
          </div>
        ))}
      </div>
    </aside>
  );
}