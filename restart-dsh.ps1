# DSH 重启脚本：杀掉旧进程 → 等端口释放 → 启动新进程
$nodeExe = "C:\Users\chenz\.workbuddy\binaries\node\versions\22.22.2\node.exe"
$dshDir = "E:\AI_Project\deepseek-harness"

# 等待 3 秒，让当前命令执行完毕
Start-Sleep -Seconds 3

# 杀掉旧的 DSH web 进程
Write-Host "Stopping old DSH process (PID 16504)..."
Stop-Process -Id 16504 -Force -ErrorAction SilentlyContinue

# 也杀掉辅助进程
Stop-Process -Id 10084 -Force -ErrorAction SilentlyContinue

# 等待端口释放
Start-Sleep -Seconds 3
Write-Host "Port should be free now. Starting new DSH process..."

# 启动新的 DSH web 进程
Set-Location $dshDir
& $nodeExe apps/cli/lib/bin.js --profile web --host 127.0.0.1 --port 3080 --no-open
