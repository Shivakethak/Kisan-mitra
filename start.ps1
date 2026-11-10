# Starts the Kisan Mitra server and a public HTTPS link for the Android app.
# Run:  powershell -ExecutionPolicy Bypass -File start.ps1
# Then copy the https://....trycloudflare.com link it prints into the app (first launch, or Settings > Change server).
# Anyone with the link can use the app (and your API credits) while this window is open. Close it to stop.

$root = $PSScriptRoot
$up = $false
try { Invoke-WebRequest http://127.0.0.1:8000/api/health -UseBasicParsing -TimeoutSec 3 | Out-Null; $up = $true } catch {}
if (-not $up) {
  Write-Host "Starting server..." -ForegroundColor Green
  Start-Process -FilePath "$root\.venv\Scripts\python.exe" -ArgumentList "-m","uvicorn","app.main:app","--port","8000" -WorkingDirectory $root -WindowStyle Minimized
  Start-Sleep 4
}
Write-Host ""
Write-Host "Creating public HTTPS link... look for the line ending in .trycloudflare.com" -ForegroundColor Yellow
Write-Host ""
& "C:\Users\shrey\android-build\cloudflared.exe" tunnel --no-autoupdate --url http://127.0.0.1:8000
