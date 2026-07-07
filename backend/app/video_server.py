import uvicorn
import os
import json
import uuid
from pathlib import Path
from fastapi import FastAPI, WebSocket, WebSocketDisconnect, APIRouter, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
from time import time
from datetime import datetime

router = APIRouter()


class RoomInfo:
    def __init__(self, room_id: str, user_id: str):
        self.room_id = room_id
        self.user_id = user_id
        self.user_ws: WebSocket | None = None
        self.agent_ws: WebSocket | None = None
        self.participants: list[dict] = []
        self.status = "waiting"
        self.created_at = datetime.now()
        self.started_at: datetime | None = None


rooms: dict[str, RoomInfo] = {}
agent_ws_list: list[WebSocket] = []
active_connections: dict[int, dict] = {}


@router.post("/video/call")
async def create_video_call(user_id: str):
    room_id = f"call_{user_id}_{int(time())}"
    rooms[room_id] = RoomInfo(room_id, user_id)

    for ws in agent_ws_list:
        await ws.send_json({
            "type": "new_call",
            "room_id": room_id,
            "user_id": user_id,
            "status": "waiting",
            "created_at": rooms[room_id].created_at.isoformat(),
        })

    return {"room_id": room_id}


@router.get("/video/calls")
async def get_waiting_calls():
    waiting = []
    for room in rooms.values():
        if room.status == "waiting":
            waiting.append({
                "room_id": room.room_id,
                "user_id": room.user_id,
                "status": room.status,
                "created_at": room.created_at.isoformat(),
            })
    return {"calls": waiting}


@router.websocket("/ws/video/{room_id}")
async def video_websocket(websocket: WebSocket, room_id: str):
    await websocket.accept()

    if room_id not in rooms:
        rooms[room_id] = RoomInfo(room_id, "unknown")

    room = rooms[room_id]

    if room.user_ws is None:
        room.user_ws = websocket
        if room.status == "waiting":
            for ws in agent_ws_list:
                await ws.send_json({
                    "type": "call_updated",
                    "room_id": room_id,
                    "status": "connected",
                })
    else:
        room.agent_ws = websocket
        room.status = "calling"
        room.started_at = datetime.now()

        if room.user_ws:
            await room.user_ws.send_json({
                "type": "agent_joined",
                "room_id": room_id,
            })

        for ws in agent_ws_list:
            if ws != websocket:
                await ws.send_json({
                    "type": "call_updated",
                    "room_id": room_id,
                    "status": "calling",
                })

    try:
        while True:
            data = await websocket.receive_json()

            if websocket == room.user_ws and room.agent_ws:
                await room.agent_ws.send_json(data)
            elif websocket == room.agent_ws and room.user_ws:
                await room.user_ws.send_json(data)
    except WebSocketDisconnect:
        room.status = "ended"

        if websocket == room.user_ws:
            room.user_ws = None
        elif websocket == room.agent_ws:
            room.agent_ws = None

        for ws in agent_ws_list:
            await ws.send_json({
                "type": "call_ended",
                "room_id": room_id,
            })


@router.websocket("/ws/video")
async def remote_video_websocket(websocket: WebSocket):
    await websocket.accept()

    client_id = id(websocket)
    room_id = None
    username = None
    role = None

    try:
        while True:
            data = await websocket.receive_text()
            message = json.loads(data)
            msg_type = message.get("type")

            if msg_type == "join":
                role = message.get("role", "user")

                active_connections[client_id] = {
                    "websocket": websocket,
                    "role": role,
                    "room_id": None,
                    "username": None
                }

                if role == "agent":
                    agent_ws_list.append(websocket)

                    waiting_calls = []
                    for room in rooms.values():
                        if room.status == "waiting":
                            waiting_calls.append({
                                "room_id": room.room_id,
                                "username": room.user_id,
                                "issue": getattr(room, "issue", ""),
                                "status": room.status,
                                "created_at": room.created_at.isoformat(),
                            })

                    await websocket.send_text(json.dumps({
                        "type": "init",
                        "calls": waiting_calls
                    }))
                else:
                    await websocket.send_text(json.dumps({
                        "type": "init",
                        "message": "用户端已连接"
                    }))

            elif msg_type == "create_call":
                username = message.get("username", "用户")
                issue = message.get("issue", "")

                room_id = f"call_{uuid.uuid4().hex[:8]}"
                rooms[room_id] = RoomInfo(room_id, username)
                rooms[room_id].issue = issue
                rooms[room_id].user_ws = websocket

                active_connections[client_id]["room_id"] = room_id
                active_connections[client_id]["username"] = username

                await websocket.send_text(json.dumps({
                    "type": "call_created",
                    "room_id": room_id
                }))

                for ws in agent_ws_list:
                    await ws.send_text(json.dumps({
                        "type": "new_call",
                        "room_id": room_id,
                        "username": username,
                        "issue": issue,
                        "status": "waiting",
                        "created_at": rooms[room_id].created_at.isoformat(),
                    }))

            elif msg_type == "cancel_call":
                room_id = message.get("room_id")
                if room_id and room_id in rooms:
                    rooms[room_id].status = "canceled"

                    if rooms[room_id].user_ws:
                        await rooms[room_id].user_ws.send_text(json.dumps({
                            "type": "call_canceled",
                            "room_id": room_id
                        }))

                    for ws in agent_ws_list:
                        await ws.send_text(json.dumps({
                            "type": "call_ended",
                            "room_id": room_id
                        }))

                    del rooms[room_id]

            elif msg_type == "accept_call":
                room_id = message.get("room_id")
                if room_id and room_id in rooms and rooms[room_id].status == "waiting":
                    rooms[room_id].status = "calling"
                    rooms[room_id].agent_ws = websocket
                    rooms[room_id].started_at = datetime.now()

                    active_connections[client_id]["room_id"] = room_id

                    if rooms[room_id].user_ws:
                        await rooms[room_id].user_ws.send_text(json.dumps({
                            "type": "agent_joined",
                            "room_id": room_id
                        }))

                    for ws in agent_ws_list:
                        if ws != websocket:
                            await ws.send_text(json.dumps({
                                "type": "call_updated",
                                "room_id": room_id,
                                "status": "calling"
                            }))

            elif msg_type == "reject_call":
                room_id = message.get("room_id")
                if room_id and room_id in rooms:
                    rooms[room_id].status = "rejected"

                    if rooms[room_id].user_ws:
                        await rooms[room_id].user_ws.send_text(json.dumps({
                            "type": "call_rejected",
                            "room_id": room_id
                        }))

                    for ws in agent_ws_list:
                        await ws.send_text(json.dumps({
                            "type": "call_ended",
                            "room_id": room_id
                        }))

                    del rooms[room_id]

            elif msg_type == "end_call":
                room_id = message.get("room_id")
                if room_id and room_id in rooms:
                    rooms[room_id].status = "ended"

                    if rooms[room_id].user_ws and rooms[room_id].user_ws != websocket:
                        await rooms[room_id].user_ws.send_text(json.dumps({
                            "type": "call_ended",
                            "room_id": room_id
                        }))

                    if rooms[room_id].agent_ws and rooms[room_id].agent_ws != websocket:
                        await rooms[room_id].agent_ws.send_text(json.dumps({
                            "type": "call_ended",
                            "room_id": room_id
                        }))

                    for ws in agent_ws_list:
                        await ws.send_text(json.dumps({
                            "type": "call_ended",
                            "room_id": room_id
                        }))

                    del rooms[room_id]

            elif msg_type in ["offer", "answer", "ice_candidate"]:
                room_id = message.get("room_id")
                if room_id and room_id in rooms:
                    room = rooms[room_id]

                    target_ws = None
                    if role == "user" and room.agent_ws:
                        target_ws = room.agent_ws
                    elif role == "agent" and room.user_ws:
                        target_ws = room.user_ws

                    if target_ws:
                        forward_msg = {"type": msg_type}
                        if msg_type == "offer":
                            forward_msg["offer"] = message.get("offer")
                        elif msg_type == "answer":
                            forward_msg["answer"] = message.get("answer")
                        elif msg_type == "ice_candidate":
                            forward_msg["candidate"] = message.get("candidate")
                        await target_ws.send_text(json.dumps(forward_msg))

            elif msg_type == "ping":
                await websocket.send_text(json.dumps({"type": "pong"}))

    except WebSocketDisconnect:
        print(f"远程视频客户端断开: {client_id}")

        if client_id in active_connections:
            conn_info = active_connections[client_id]
            room_id = conn_info.get("room_id")
            role = conn_info.get("role")

            if room_id and room_id in rooms:
                rooms[room_id].status = "ended"

                if role == "user":
                    rooms[room_id].user_ws = None
                    if rooms[room_id].agent_ws:
                        await rooms[room_id].agent_ws.send_text(json.dumps({
                            "type": "call_ended",
                            "room_id": room_id
                        }))
                elif role == "agent":
                    rooms[room_id].agent_ws = None
                    if rooms[room_id].user_ws:
                        await rooms[room_id].user_ws.send_text(json.dumps({
                            "type": "call_ended",
                            "room_id": room_id
                        }))

                for ws in agent_ws_list:
                    await ws.send_text(json.dumps({
                        "type": "call_ended",
                        "room_id": room_id
                    }))

                del rooms[room_id]

            if role == "agent" and websocket in agent_ws_list:
                agent_ws_list.remove(websocket)

            del active_connections[client_id]
    except Exception as e:
        print(f"远程视频WebSocket错误: {e}")
        if client_id in active_connections:
            del active_connections[client_id]


@router.websocket("/ws/agent")
async def agent_websocket(websocket: WebSocket):
    await websocket.accept()
    agent_ws_list.append(websocket)

    waiting_calls = []
    for room in rooms.values():
        if room.status == "waiting":
            waiting_calls.append({
                "room_id": room.room_id,
                "user_id": room.user_id,
                "status": room.status,
                "created_at": room.created_at.isoformat(),
            })

    await websocket.send_json({
        "type": "init",
        "calls": waiting_calls,
    })

    try:
        while True:
            await websocket.receive_text()
    except WebSocketDisconnect:
        agent_ws_list.remove(websocket)


app = FastAPI(title="视频服务", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(router)

_frontend_dist = Path(__file__).parent.parent.parent / "frontend" / "dist"

if _frontend_dist.exists():
    app.mount("/assets", StaticFiles(directory=_frontend_dist / "assets"), name="assets")

    @app.get("/{full_path:path}", summary="客服工作台页面")
    async def serve_spa(full_path: str, request: Request):
        file_path = _frontend_dist / full_path
        if file_path.exists() and file_path.is_file():
            return FileResponse(file_path)
        return FileResponse(_frontend_dist / "index.html")

    print(f"[INFO] 客服工作台前端已挂载: {_frontend_dist}")
else:
    @app.get("/", summary="健康检查")
    async def root():
        return {"service": "视频服务", "version": "1.0.0", "status": "running"}


if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8001)