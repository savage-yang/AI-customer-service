"""FastAPI 应用入口"""

import os
import sys
from pathlib import Path

# 确保能找到 app 模块（支持直接运行 python app/main.py）
_backend_dir = Path(__file__).parent.parent.resolve()
if str(_backend_dir) not in sys.path:
    sys.path.insert(0, str(_backend_dir))

from contextlib import asynccontextmanager

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse

# 设置模型本地缓存路径（指向 download_models.py 下载的目录）
models_base = Path(__file__).parent.parent.parent / "models"
if models_base.exists():
    os.environ["MODEL_CACHE_DIR"] = str(models_base)
    print(f"[INFO] 模型路径: {models_base}")

from app.api import chat
from app.core.config import settings
from app.core.redis_client import redis_client
from app.core.vector_store import vector_store_client
from app.core.embedding import embedding_client
from app.services.rerank_service import rerank_service


@asynccontextmanager
async def lifespan(app: FastAPI):
    """应用生命周期管理"""
    # 启动时
    await redis_client.connect()
    print(f"[INFO] Redis 已连接 {settings.redis_host}:{settings.redis_port}")

    # 预加载 Milvus collection 到内存（数据已持久化，不需要重新灌库）
    vector_store_client.ensure_loaded()

    # 预加载 Embedding 模型（避免首次请求冷启动）
    print(f"[INFO] 正在预加载 Embedding 模型: {settings.embedding_model_name}")
    _ = embedding_client.embeddings
    print(f"[INFO] Embedding 模型加载完成，维度: {embedding_client.dimension}")

    # 预加载 Reranker 模型（避免首次请求冷启动）
    print(f"[INFO] 正在预加载 Reranker 模型: {settings.reranker_model_name}")
    rerank_service._load()
    print(f"[INFO] Reranker 模型加载完成")

    print(f"[INFO] 服务已启动 http://{settings.app_host}:{settings.app_port}")
    yield
    # 关闭时
    await redis_client.disconnect()
    print("[INFO] 服务已关闭")


app = FastAPI(
    title="AI 客服机器人",
    description="基于 LangChain + Qwen + BGE + Milvus 的 RAG 智能客服系统",
    version="1.0.0",
    lifespan=lifespan,
)

# CORS 中间件
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 注册路由
app.include_router(chat.router)


# ── 生产环境：提供前端静态文件 ──
# 检查 frontend/dist 是否存在（npm run build 后生成）
_frontend_dist = Path(__file__).parent.parent.parent / "frontend" / "dist"
if _frontend_dist.exists():
    # 挂载静态资源（CSS、JS、图片等）
    app.mount("/assets", StaticFiles(directory=_frontend_dist / "assets"), name="assets")

    # SPA fallback：所有非 API 路径返回 index.html（支持 React Router）
    @app.get("/{full_path:path}", summary="前端页面")
    async def serve_spa(full_path: str, request: Request):
        # 探测文件是否存在（如 favicon.ico、vite.svg）
        file_path = _frontend_dist / full_path
        if file_path.exists() and file_path.is_file():
            return FileResponse(file_path)
        # 其他路径返回 index.html（SPA 路由）
        return FileResponse(_frontend_dist / "index.html")

    print(f"[INFO] 前端静态文件已挂载: {_frontend_dist}")
else:
    # 开发环境：前端由 npm run dev 提供，这里只提供健康检查
    @app.get("/", summary="健康检查")
    async def root():
        return {
            "service": "AI 客服机器人",
            "version": "1.0.0",
            "status": "running",
            "llm_model": settings.llm_model_name,
            "embedding_model": settings.embedding_model_name,
        }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "app.main:app",
        host=settings.app_host,
        port=settings.app_port,
        reload=settings.app_debug,
    )