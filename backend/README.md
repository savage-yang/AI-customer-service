# AI 客服机器人 — 后端

> 技术栈：FastAPI + LangChain + Qwen(通义千问) + BGE-zh + Milvus Lite + BGE-Reranker + PostgreSQL + Redis

## 环境要求

| 组件 | 版本要求 | 说明 |
|------|----------|------|
| Python | >= 3.10 | |
| PostgreSQL | >= 14 | 存储对话日志、知识文档记录、用户反馈 |
| Redis | >= 6.0 | 会话缓存、限流 |
| Milvus Lite | 嵌入式 | 向量数据库，随 pip 安装，数据存本地文件，无需 Docker |

## 快速启动

### 1. 配置环境变量

复制并修改 `.env` 文件，填入你的通义千问 API Key：

```env
DASHSCOPE_API_KEY=sk-xxxxxxxxxxxxxxxxxxxxxxxx
```

> 在[阿里云百炼平台](https://bailian.console.aliyun.com/) 获取 API Key

### 2. 启动依赖服务

仅需 PostgreSQL 和 Redis（Milvus Lite 已随 pip 自动安装，无需额外服务）：

```powershell
# 安装 Docker Desktop（仅需这两个服务用 Docker）：https://www.docker.com/products/docker-desktop/

cd d:\客服机器人\backend
docker-compose up -d
docker ps
```

确认 `cs_postgres` 和 `cs_redis` 两个容器 running 即可。

<details>
<summary>不使用 Docker 时，各服务手动启动</summary>

**PostgreSQL**

```powershell
# Docker
docker run -d --name cs_postgres `
  -e POSTGRES_USER=postgres `
  -e POSTGRES_PASSWORD=postgres123 `
  -e POSTGRES_DB=customer_service `
  -p 5432:5432 `
  postgres:16

# 或 Windows 原生安装：https://www.postgresql.org/download/windows/
```

**Redis**

```powershell
# Docker
docker run -d --name cs_redis -p 6379:6379 redis:7

# 或 Windows 原生安装：https://github.com/tporadowski/redis/releases
```

</details>

### 3. 安装依赖

```powershell
cd d:\客服机器人\backend
pip install -r requirements.txt
```

### 4. 初始化数据库

```powershell
python -c "from app.models.database import Base; from sqlalchemy import create_engine; from app.core.config import settings; engine = create_engine(settings.postgres_sync_url); Base.metadata.create_all(engine); print('数据库表创建完成')"
```

### 5. 启动服务

```powershell
python -m app.main
```

启动后访问：
- API 文档：http://localhost:8000/docs
- 健康检查：http://localhost:8000/

## 灌入知识库

首次使用需要导入知识库数据：

```powershell
# 方式1：导入文本
curl -X POST http://localhost:8000/knowledge/import `
  -H "Content-Type: application/json" `
  -d '{"source":"常见问题","texts":["问题：如何退货？ 回答：在订单详情页点击申请退货即可。","问题：发货时间？ 回答：下单后24小时内发货。"]}'

# 方式2：上传文件（支持 txt / pdf / csv / docx / md）
curl -X POST http://localhost:8000/knowledge/upload `
  -F "file=@D:/docs/产品手册.pdf" `
  -F "source=产品手册"

# 查看知识库状态
curl http://localhost:8000/knowledge/stats
```

> 知识库数据持久化到 `data/milvus_kb.db` 文件，重启服务无需重新灌库。

## 测试对话

```powershell
# 发送消息
curl -X POST http://localhost:8000/chat/ `
  -H "Content-Type: application/json" `
  -d '{"question":"如何退货？","session_id":"test123"}'
```

## 部署到 Linux 服务器

```bash
# docker-compose 方式完全一致
cd /path/to/backend
docker-compose up -d

# 修改 .env 中的连接地址
# POSTGRES_HOST=服务器IP
# REDIS_HOST=服务器IP
```

## 项目结构

```
backend/
├── app/
│   ├── main.py                   # 入口
│   ├── api/                      # API 路由
│   │   ├── chat.py               # 对话接口
│   │   └── knowledge.py          # 知识库接口
│   ├── services/                 # 业务逻辑
│   │   ├── chat_service.py       # 对话服务
│   │   ├── rag_service.py        # RAG 检索生成
│   │   ├── rerank_service.py     # 重排序
│   │   └── knowledge_service.py  # 知识库管理
│   ├── core/                     # 核心组件
│   │   ├── config.py             # 配置
│   │   ├── llm_client.py         # 通义千问
│   │   ├── embedding.py          # BGE Embedding
│   │   ├── vector_store.py       # Milvus Lite
│   │   └── redis_client.py       # Redis
│   ├── models/database.py        # 数据库模型
│   ├── schemas/                  # 请求/响应模型
│   └── middleware/               # 中间件
├── data/
│   └── milvus_kb.db             # 向量数据库文件（自动生成）
├── docker-compose.yml            # PostgreSQL + Redis
├── .env                         # 环境变量
└── requirements.txt            # 依赖
```
