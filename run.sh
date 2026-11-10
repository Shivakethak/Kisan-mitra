#!/usr/bin/env bash
# Kisan Mitra: one-command start on macOS / Linux.  Run:  bash run.sh
set -e
cd "$(dirname "$0")"
PORT="${PORT:-8000}"
PY="$(command -v python3 || command -v python)" || { echo "Python 3.10+ is required: https://www.python.org/downloads/"; exit 1; }

if [ ! -x .venv/bin/python ]; then
  echo "[1/3] Creating virtual environment..."
  "$PY" -m venv .venv
fi
echo "[2/3] Installing dependencies..."
.venv/bin/python -m pip install --disable-pip-version-check -q -r requirements.txt
.venv/bin/python -m app.setup_env

echo "[3/3] Starting Kisan Mitra at http://localhost:$PORT  (Ctrl+C to stop)"
if [ "${NO_BROWSER:-0}" != "1" ]; then (sleep 3; (xdg-open "http://localhost:$PORT" || open "http://localhost:$PORT") >/dev/null 2>&1) & fi
exec .venv/bin/python -m uvicorn app.main:app --port "$PORT"
