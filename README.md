# Smart Control Platform

面向传统行业的智能中控平台（电梯、水务、能源、楼宇、产线、交通等）。
当前仓库为架构重构后的全新代码库，原 `DataCollect` 仅保留字段语义参考。

## 架构概览

- `backend/`   Go 后端：HTTP / WebSocket / TCP 设备通道 + Agent 编排内核
- `ai-worker/` Python AI Worker：LLM 调用 / 脱敏 NER / RAG / 时序分析（gRPC）
- `web/`       React 管理台：设备监控大屏 + 设备管理 + AI 对话 + 用户权限
- `deploy/`    docker-compose 一键启动脚本 + PostgreSQL 初始化 SQL
- `scripts/`   运维脚本（git 推送、DB 初始化等）
- `docs/`      架构与开发文档

## 技术栈

- Go 1.21 + Gin + gorilla/websocket + pgx + zap + viper
- Python 3.11 + grpcio
- React 18 + TypeScript + Vite + Ant Design 5 + ProComponents + ECharts
- PostgreSQL 15 + TimescaleDB + pgvector

## 快速上手

```bash
# 首次克隆
git clone <your-remote-url>
cd smart-control-platform

# 本地一键起 pg + backend + web（后续阶段交付）
cd deploy && docker compose up -d
```

## 每日推送

```bash
./scripts/push.sh "feat: 今日开发日志"
# 或不带参数，脚本会生成默认提交信息
./scripts/push.sh
```

详见 [scripts/push.sh](scripts/push.sh)。
