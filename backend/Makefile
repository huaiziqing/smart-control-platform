.PHONY: run build tidy lint test migrate clean

APP := smart-control-backend
BIN_DIR := bin

# 本地开发：使用 config.yaml 启动
run:
	go run ./cmd/server

# 交叉编译前后端通用可执行文件
build:
	CGO_ENABLED=0 go build -ldflags="-s -w" -o $(BIN_DIR)/$(APP) ./cmd/server

# 同步依赖
tidy:
	go mod tidy

lint:
	go vet ./...

test:
	go test ./... -count=1

# 数据库迁移（后续任务接入 goose）
migrate:
	@echo "TODO: 在 Task 4/5 阶段接入 goose 迁移命令"

clean:
	rm -rf $(BIN_DIR)
