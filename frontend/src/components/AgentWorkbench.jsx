import { useState, useEffect, useRef, useCallback } from 'react';

export default function AgentWorkbench() {
  const [calls, setCalls] = useState([]);
  const [activeCall, setActiveCall] = useState(null);
  const [remoteStream, setRemoteStream] = useState(null);
  const [micEnabled, setMicEnabled] = useState(true);
  const [callDuration, setCallDuration] = useState(0);
  const agentWsRef = useRef(null);
  const pcRef = useRef(null);
  const localStreamRef = useRef(null);
  const durationTimerRef = useRef(null);

  useEffect(() => {
    const ws = new WebSocket(`${window.location.origin.replace('http', 'ws')}/ws/agent`);
    agentWsRef.current = ws;

    ws.onmessage = (event) => {
      const data = JSON.parse(event.data);
      switch (data.type) {
        case 'init':
          setCalls(data.calls);
          break;
        case 'new_call':
          setCalls((prev) => [...prev, {
            room_id: data.room_id,
            user_id: data.user_id,
            status: data.status,
            created_at: data.created_at,
          }]);
          break;
        case 'call_updated':
          setCalls((prev) => prev.map((c) =>
            c.room_id === data.room_id ? { ...c, status: data.status } : c
          ));
          break;
        case 'call_ended':
          setCalls((prev) => prev.filter((c) => c.room_id !== data.room_id));
          if (activeCall?.room_id === data.room_id) {
            handleEndCall();
          }
          break;
      }
    };

    ws.onclose = () => {
      setTimeout(() => window.location.reload(), 3000);
    };

    return () => {
      ws.close();
    };
  }, [activeCall]);

  useEffect(() => {
    if (activeCall) {
      durationTimerRef.current = setInterval(() => {
        setCallDuration((prev) => prev + 1);
      }, 1000);
    } else {
      clearInterval(durationTimerRef.current);
    }
    return () => clearInterval(durationTimerRef.current);
  }, [activeCall]);

  const formatDuration = (seconds) => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  };

  const handleAnswer = useCallback(async (roomId) => {
    const pc = new RTCPeerConnection({
      iceServers: [
        { urls: 'stun:stun.l.google.com:19302' },
        { urls: 'stun:stun1.l.google.com:19302' },
      ],
    });
    pcRef.current = pc;

    try {
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true, video: false });
      localStreamRef.current = stream;
      stream.getAudioTracks().forEach((track) => pc.addTrack(track, stream));
    } catch (err) {
      console.error('Failed to get microphone:', err);
    }

    pc.ontrack = (event) => {
      if (event.streams[0]) {
        setRemoteStream(event.streams[0]);
      }
    };

    pc.onicecandidate = (event) => {
      if (event.candidate && agentWsRef.current) {
        const ws = new WebSocket(`${window.location.origin.replace('http', 'ws')}/ws/video/${roomId}`);
        ws.onopen = () => {
          ws.send(JSON.stringify({ type: 'ice_candidate', candidate: event.candidate }));
        };
      }
    };

    const ws = new WebSocket(`${window.location.origin.replace('http', 'ws')}/ws/video/${roomId}`);
    ws.onmessage = (event) => {
      const data = JSON.parse(event.data);
      if (data.type === 'offer') {
        pc.setRemoteDescription(new RTCSessionDescription(data.offer))
          .then(() => pc.createAnswer())
          .then((answer) => {
            pc.setLocalDescription(answer);
            ws.send(JSON.stringify({ type: 'answer', answer }));
          });
      } else if (data.type === 'ice_candidate') {
        pc.addIceCandidate(new RTCIceCandidate(data.candidate));
      }
    };

    setActiveCall({ room_id: roomId });
    setCalls((prev) => prev.map((c) =>
      c.room_id === roomId ? { ...c, status: 'calling' } : c
    ));
  }, []);

  const handleEndCall = useCallback(() => {
    if (pcRef.current) {
      pcRef.current.close();
      pcRef.current = null;
    }
    if (localStreamRef.current) {
      localStreamRef.current.getTracks().forEach((track) => track.stop());
      localStreamRef.current = null;
    }
    setRemoteStream(null);
    setActiveCall(null);
    setCallDuration(0);
  }, []);

  const toggleMic = useCallback(() => {
    if (localStreamRef.current) {
      const enabled = !micEnabled;
      localStreamRef.current.getAudioTracks().forEach((track) => {
        track.enabled = enabled;
      });
      setMicEnabled(enabled);
    }
  }, [micEnabled]);

  const waitingCalls = calls.filter((c) => c.status === 'waiting');
  const connectedCalls = calls.filter((c) => c.status === 'connected');

  return (
    <div className="agent-workbench">
      <aside className="agent-sidebar">
        <div className="agent-sidebar-header">
          <h2>视频请求管理</h2>
          <div className="online-status">
            <span className="status-dot online"></span>
            <span>在线</span>
          </div>
        </div>

        <div className="call-section">
          <h3>等待中 ({waitingCalls.length})</h3>
          {waitingCalls.length === 0 ? (
            <div className="empty-calls">暂无等待的视频请求</div>
          ) : (
            <div className="call-list">
              {waitingCalls.map((call) => (
                <div key={call.room_id} className="call-item waiting">
                  <div className="call-info">
                    <span className="user-id">用户: {call.user_id}</span>
                    <span className="call-time">
                      {new Date(call.created_at).toLocaleTimeString()}
                    </span>
                  </div>
                  <button
                    className="btn-answer"
                    onClick={() => handleAnswer(call.room_id)}
                  >
                    接听
                  </button>
                </div>
              ))}
            </div>
          )}
        </div>

        {connectedCalls.length > 0 && (
          <div className="call-section">
            <h3>已连接 ({connectedCalls.length})</h3>
            <div className="call-list">
              {connectedCalls.map((call) => (
                <div key={call.room_id} className="call-item connected">
                  <div className="call-info">
                    <span className="user-id">用户: {call.user_id}</span>
                    <span className="status-badge">已连接</span>
                  </div>
                  <button
                    className="btn-answer"
                    onClick={() => handleAnswer(call.room_id)}
                  >
                    接听
                  </button>
                </div>
              ))}
            </div>
          </div>
        )}
      </aside>

      <main className="agent-main">
        {activeCall ? (
          <div className="video-container">
            <div className="video-header">
              <h3>正在通话 - 用户: {activeCall.room_id.split('_')[1]}</h3>
              <span className="call-duration">{formatDuration(callDuration)}</span>
            </div>
            <div className="video-area">
              {remoteStream ? (
                <video
                  className="remote-video"
                  srcObject={remoteStream}
                  autoPlay
                  playsInline
                />
              ) : (
                <div className="waiting-video">
                  <div className="waiting-icon">📹</div>
                  <p>等待用户视频...</p>
                </div>
              )}
            </div>
            <div className="video-controls">
              <button
                className={`btn-control ${micEnabled ? '' : 'disabled'}`}
                onClick={toggleMic}
              >
                {micEnabled ? '🎤 麦克风' : '🔇 麦克风已关闭'}
              </button>
              <button className="btn-control btn-end" onClick={handleEndCall}>
                📞 结束通话
              </button>
            </div>
          </div>
        ) : (
          <div className="empty-video">
            <div className="empty-icon">💻</div>
            <p>客服工作台</p>
            <span>等待视频请求...</span>
          </div>
        )}
      </main>
    </div>
  );
}