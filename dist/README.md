# Don't Sleep - Windows 防休眠工具

一個輕量級的 Windows 防休眠工具，使用 Go 語言開發，能夠防止系統進入休眠或螢幕保護程式狀態。

## 功能特色

- 🚀 **輕量級**: 低資源消耗，背景執行
- ⚙️ **可設定**: 支援自訂防休眠間隔時間
- 📋 **命令列介面**: 支援多種命令列參數控制
- 🔧 **設定檔管理**: 使用 JSON 設定檔儲存設定
- 🛡️ **優雅關閉**: 支援 Ctrl+C 和系統訊號優雅關閉
- 📊 **狀態查詢**: 可即時查詢程式執行狀態

## 系統需求

- Windows 作業系統
- 無需額外相依套件

## 安裝

### 方法一：下載預編譯版本
直接下載 `dont-sleep.exe` 檔案即可使用。

### 方法二：從原始碼編譯
```powershell
# 複製專案
git clone <repository-url>
cd dont-sleep

# 編譯
go build -o dont-sleep.exe main.go
```

## 使用方法

### 基本使用

```powershell
# 使用預設設定執行（300秒間隔）
.\dont-sleep.exe

# 使用自訂間隔時間執行
.\dont-sleep.exe -interval 600  # 每10分鐘防休眠一次
```

### 命令列參數

| 參數 | 說明 | 範例 |
|------|------|------|
| `-status` | 查詢程式執行狀態 | `.\dont-sleep.exe -status` |
| `-kill` | 終止指定工作緒 | `.\dont-sleep.exe -kill preventSleep1` |
| `-interval` | 設定防休眠間隔時間（秒） | `.\dont-sleep.exe -interval 300` |
| `-version` | 顯示版本資訊 | `.\dont-sleep.exe -version` |

### 使用範例

#### 0. 查看版本資訊
```powershell
.\dont-sleep.exe -version
```
輸出範例：
```
Don't Sleep v1.0.0
建構時間: 2025-06-15 23:45:30
Git Commit: a1b2c3d
```

#### 1. 啟動防休眠服務
```powershell
.\dont-sleep.exe
```
程式將在背景執行，每5分鐘（預設值）呼叫一次防休眠 API。

#### 2. 查詢執行狀態
```powershell
.\dont-sleep.exe -status
```
輸出範例：
```
程式執行時間：1h23m45s
工作緒狀態：
  preventSleep1: 執行中
```

#### 3. 終止防休眠服務
```powershell
.\dont-sleep.exe -kill preventSleep1
```

#### 4. 自訂間隔時間
```powershell
# 每30秒防休眠一次
.\dont-sleep.exe -interval 30

# 每1小時防休眠一次
.\dont-sleep.exe -interval 3600
```

#### 5. 優雅關閉
按下 `Ctrl+C` 或發送 SIGTERM 訊號即可優雅關閉程式。

## 設定檔

程式會自動建立 `config.json` 設定檔：

```json
{
  "preventSleepInterval": 300
}
```

### 設定項目說明

| 設定項目 | 型別 | 預設值 | 說明 |
|----------|------|--------|------|
| `preventSleepInterval` | 整數 | 300 | 防休眠間隔時間（單位：秒） |

### 設定優先級

1. 命令列參數 `-interval`（最高優先級）
2. 設定檔 `config.json` 中的值
3. 預設值（300秒）

## 工作原理

程式使用 Windows API `SetThreadExecutionState` 來防止系統休眠：

- **ES_CONTINUOUS (0x80000000)**: 持續保持喚醒狀態
- **ES_SYSTEM_REQUIRED (0x00000001)**: 防止系統休眠
- **ES_DISPLAY_REQUIRED (0x00000002)**: 防止螢幕關閉

## 日誌輸出

程式會輸出詳細的日誌資訊，包括：

- 設定檔載入狀態
- 防休眠 API 呼叫結果
- 工作緒狀態變化
- 錯誤資訊

範例日誌：
```
2025/06/15 10:30:00 建立預設設定檔
2025/06/15 10:30:00 使用命令列參數設定的間隔時間: 600 秒
2025/06/15 10:30:00 呼叫防休眠 API 成功
2025/06/15 10:40:00 呼叫防休眠 API 成功
```

## 常見問題

### Q: 為什麼程式無法防止休眠？
A: 請確認：
1. 以系統管理員權限執行
2. Windows 電源設定是否正確
3. 檢查日誌是否顯示 API 呼叫成功

### Q: 如何在系統啟動時自動執行？
A: 可以將程式加入 Windows 工作排程器或啟動資料夾中。

### Q: 程式佔用多少系統資源？
A: 程式非常輕量，通常佔用記憶體少於 10MB，CPU 使用率接近 0%。

## 授權

本專案採用 MIT 授權條款。

## 貢獻

歡迎提交 Issue 和 Pull Request！

## 版本歷史

- v1.0.0: 初始版本，支援基本防休眠功能
- 支援命令列參數控制
- 支援設定檔管理
- 支援狀態查詢和工作緒管理

## 開發者資訊

### 建構專案

#### 使用 PowerShell 建構腳本
```powershell
# 建構所有版本
.\build.ps1

# 建構指定版本
.\build.ps1 -Version "v1.1.0"

# 指定輸出目錄
.\build.ps1 -Version "v1.1.0" -OutputDir "release"
```

#### 使用 Make（需要安裝 make 工具）
```powershell
# 建構所有版本
make build

# 建構開發版本
make build-dev

# 清理建構檔案
make clean

# 指定版本
make build VERSION=v1.1.0
```

#### 手動建構
```powershell
# 建構 64 位元版本
$env:GOOS="windows"; $env:GOARCH="amd64"; $env:CGO_ENABLED="0"
go build -ldflags "-X main.Version=v1.0.0 -X 'main.BuildTime=$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')' -X main.GitCommit=$(git rev-parse --short HEAD) -s -w" -o dist/dont-sleep-windows-amd64.exe main.go

# 建構 32 位元版本
$env:GOARCH="386"
go build -ldflags "-X main.Version=v1.0.0 -X 'main.BuildTime=$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')' -X main.GitCommit=$(git rev-parse --short HEAD) -s -w" -o dist/dont-sleep-windows-386.exe main.go
```

### GitHub Actions 自動建構

本專案設定了 GitHub Actions 工作流程，可以自動建構和發布：

#### 自動發布（推送標籤）
```bash
# 建立並推送標籤
git tag v1.0.0
git push origin v1.0.0
```

#### 手動觸發建構
1. 前往 GitHub 專案的 Actions 頁面
2. 選擇 "Build and Release" 工作流程
3. 點擊 "Run workflow"
4. 輸入版本號（例如：v1.0.0）
5. 點擊 "Run workflow" 確認

### 發布流程

1. **準備發布**：
   - 確保程式碼已經完成並測試
   - 更新 README.md 中的版本歷史
   - 確認所有變更都已提交

2. **建立標籤**：
   ```bash
   git tag -a v1.0.0 -m "Release version 1.0.0"
   git push origin v1.0.0
   ```

3. **自動建構**：
   - GitHub Actions 會自動觸發建構
   - 建構完成後會自動建立 GitHub Release
   - 包含 Windows 32/64 位元執行檔和壓縮套件

4. **檢查發布**：
   - 前往 GitHub 專案的 Releases 頁面
   - 確認檔案完整性和校驗碼
   - 測試下載的執行檔是否正常運作

### 檔案結構

```
dont-sleep/
├── .github/
│   └── workflows/
│       └── release.yml          # GitHub Actions 工作流程
├── dist/                        # 建構輸出目錄（自動生成）
├── build.ps1                    # PowerShell 建構腳本
├── Makefile                     # Make 建構檔案
├── config.json                  # 設定檔
├── main.go                      # 主程式
└── README.md                    # 說明文件
```
