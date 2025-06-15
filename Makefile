# Don't Sleep Makefile

# 變數設定
APP_NAME = dont-sleep
VERSION ?= v1.0.0
BUILD_TIME = $(shell date "+%Y-%m-%d %H:%M:%S")
GIT_COMMIT = $(shell git rev-parse --short HEAD 2>/dev/null || echo "unknown")

# 建構標誌
LDFLAGS = -X main.Version=$(VERSION) -X "main.BuildTime=$(BUILD_TIME)" -X main.GitCommit=$(GIT_COMMIT) -s -w

# 預設目標
.PHONY: all
all: build

# 建構所有版本
.PHONY: build
build: clean
	@echo "開始建構 $(APP_NAME)..."
	@mkdir -p dist
	
	@echo "建構 Windows 64 位元版本..."
	@set GOOS=windows && set GOARCH=amd64 && set CGO_ENABLED=0 && go build -ldflags "$(LDFLAGS)" -o dist/$(APP_NAME)-windows-amd64.exe main.go
	
	@echo "建構 Windows 32 位元版本..."
	@set GOOS=windows && set GOARCH=386 && set CGO_ENABLED=0 && go build -ldflags "$(LDFLAGS)" -o dist/$(APP_NAME)-windows-386.exe main.go
	
	@copy config.json dist\ > nul
	@copy README.md dist\ > nul
	
	@echo "建構完成！"
	@dir dist

# 只建構 64 位元版本（開發用）
.PHONY: build-dev
build-dev: clean
	@echo "建構開發版本..."
	@mkdir -p dist
	@set GOOS=windows && set GOARCH=amd64 && set CGO_ENABLED=0 && go build -ldflags "$(LDFLAGS)" -o dist/$(APP_NAME).exe main.go
	@copy config.json dist\ > nul
	@echo "開發版本建構完成！"

# 清理建構檔案
.PHONY: clean
clean:
	@if exist dist rmdir /s /q dist
	@echo "清理完成"

# 執行測試
.PHONY: test
test:
	@go test ./...

# 檢查程式碼品質
.PHONY: lint
lint:
	@go vet ./...
	@go fmt ./...

# 顯示說明
.PHONY: help
help:
	@echo "可用的 make 指令："
	@echo "  make build      - 建構所有版本"
	@echo "  make build-dev  - 建構開發版本"
	@echo "  make clean      - 清理建構檔案"
	@echo "  make test       - 執行測試"
	@echo "  make lint       - 檢查程式碼品質"
	@echo "  make help       - 顯示此說明"
	@echo ""
	@echo "環境變數："
	@echo "  VERSION         - 設定版本號 (預設: $(VERSION))"
