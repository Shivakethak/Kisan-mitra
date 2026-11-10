@echo off
REM Kisan Mitra: one-click start on Windows. Double-click this file.
setlocal
cd /d "%~dp0"
if "%PORT%"=="" set PORT=8000

where python >nul 2>nul
if errorlevel 1 (
  echo Python 3.10+ is required. Install it from https://www.python.org/downloads/ ^(tick "Add to PATH"^).
  pause
  exit /b 1
)

if not exist ".venv\Scripts\python.exe" (
  echo [1/3] Creating virtual environment...
  python -m venv .venv
  if errorlevel 1 ( pause & exit /b 1 )
)

echo [2/3] Installing dependencies...
".venv\Scripts\python.exe" -m pip install --disable-pip-version-check -q -r requirements.txt
if errorlevel 1 ( pause & exit /b 1 )

".venv\Scripts\python.exe" -m app.setup_env
if errorlevel 1 ( pause & exit /b 1 )

echo [3/3] Starting Kisan Mitra at http://localhost:%PORT%  (press Ctrl+C to stop)
if not "%NO_BROWSER%"=="1" start "" "http://localhost:%PORT%"
".venv\Scripts\python.exe" -m uvicorn app.main:app --port %PORT%
