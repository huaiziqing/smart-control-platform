-- Smart Control Platform 初始化 SQL
-- 由 docker-entrypoint-initdb.d 在容器首次启动时自动执行。

-- 1. 扩展
CREATE EXTENSION IF NOT EXISTS timescaledb;
CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. 设备
CREATE TABLE IF NOT EXISTS device (
    id          TEXT PRIMARY KEY,
    name        TEXT NOT NULL,
    type        TEXT NOT NULL,                 -- elevator/water_pump/chiller/...
    status      TEXT NOT NULL DEFAULT 'offline',
    metadata    JSONB NOT NULL DEFAULT '{}',
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_device_type   ON device(type);
CREATE INDEX IF NOT EXISTS idx_device_status ON device(status);

-- 3. 时序指标（TimescaleDB 超表）
CREATE TABLE IF NOT EXISTS metric (
    device_id   TEXT        NOT NULL,
    key         TEXT        NOT NULL,
    value       DOUBLE PRECISION,
    ts          TIMESTAMPTZ NOT NULL DEFAULT now()
);
SELECT create_hypertable('metric', 'ts', if_not_exists => TRUE);
CREATE INDEX IF NOT EXISTS idx_metric_device_key_ts ON metric(device_id, key, ts DESC);

-- 4. 告警
CREATE TABLE IF NOT EXISTS alert (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    device_id   TEXT NOT NULL,
    level       TEXT NOT NULL,                 -- info | warn | error | fatal
    code        TEXT NOT NULL,
    message     TEXT NOT NULL,
    acked       BOOLEAN NOT NULL DEFAULT FALSE,
    acked_by    TEXT,
    acked_at    TIMESTAMPTZ,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_alert_device_created ON alert(device_id, created_at DESC);

-- 5. 用户（app_user 避免和 PG 保留字 user 冲突）
CREATE TABLE IF NOT EXISTS app_user (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username    TEXT NOT NULL UNIQUE,
    password    TEXT NOT NULL,                 -- bcrypt hash
    display     TEXT NOT NULL,
    role        TEXT NOT NULL DEFAULT 'viewer',-- viewer | operator | admin
    enabled     BOOLEAN NOT NULL DEFAULT TRUE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 6. 审计日志（工具调用、HTTP 请求等）
CREATE TABLE IF NOT EXISTS audit_log (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    caller      TEXT NOT NULL,
    role        TEXT NOT NULL,
    action      TEXT NOT NULL,                 -- tool.invoke / http.request / ...
    target      TEXT,
    args_hash   TEXT,
    result_code INTEGER,
    latency_ms  INTEGER,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_audit_created ON audit_log(created_at DESC);

-- 7. 默认 admin 账号：admin / admin123 （bcrypt hash，仅开发环境，务必先改密）
INSERT INTO app_user (username, password, display, role)
VALUES (
    'admin',
    '$2a$10$N9qo8uLOickgx2ZMRZoMye.IjdQXsZQZ6Bj4e2aTqBWQPuZk/6eXu',
    '系统管理员',
    'admin'
) ON CONFLICT (username) DO NOTHING;
