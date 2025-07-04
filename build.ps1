# Build script for Don't Sleep
param(
    [string]$Version = "v1.0.0",
    [string]$OutputDir = "dist"
)

Write-Host "開始建構 Don't Sleep..." -ForegroundColor Green

# 建立輸出目錄
if (Test-Path $OutputDir) {
    Remove-Item $OutputDir -Recurse -Force
}
New-Item -ItemType Directory -Path $OutputDir | Out-Null

# 設定建構資訊
$BuildTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$GitCommit = ""
try {
    $GitCommit = git rev-parse --short HEAD 2>$null
} catch {
    $GitCommit = "unknown"
}

# 建構 Windows 64 位元版本
Write-Host "建構 Windows 64 位元版本..." -ForegroundColor Yellow
$env:GOOS = "windows"
$env:GOARCH = "amd64" 
$env:CGO_ENABLED = "0"

$LdFlags = "-X main.Version=$Version -X 'main.BuildTime=$BuildTime' -X main.GitCommit=$GitCommit -s -w"

go build -ldflags $LdFlags -o "$OutputDir\dont-sleep-windows-amd64.exe" main.go

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Windows 64 位元版本建構成功" -ForegroundColor Green
} else {
    Write-Host "✗ Windows 64 位元版本建構失敗" -ForegroundColor Red
    exit 1
}

# 建構 Windows 32 位元版本
Write-Host "建構 Windows 32 位元版本..." -ForegroundColor Yellow
$env:GOARCH = "386"

go build -ldflags $LdFlags -o "$OutputDir\dont-sleep-windows-386.exe" main.go

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Windows 32 位元版本建構成功" -ForegroundColor Green
} else {
    Write-Host "✗ Windows 32 位元版本建構失敗" -ForegroundColor Red
    exit 1
}

# 複製設定檔
Copy-Item "config.json" "$OutputDir\" -Force
Copy-Item "README.md" "$OutputDir\" -Force

# 顯示建構結果
Write-Host "`n建構完成！檔案位於 $OutputDir 目錄：" -ForegroundColor Green
Get-ChildItem $OutputDir | ForEach-Object {
    $Size = [math]::Round($_.Length / 1KB, 2)
    Write-Host "  $($_.Name) ($Size KB)" -ForegroundColor Cyan
}

Write-Host "`n建構資訊：" -ForegroundColor Green
Write-Host "  版本: $Version" -ForegroundColor Cyan
Write-Host "  建構時間: $BuildTime" -ForegroundColor Cyan
Write-Host "  Git Commit: $GitCommit" -ForegroundColor Cyan
