#!/usr/bin/env bash
# ====== OpenClaw - Chrome Debug Mode (Mac/Linux) ======
set -e
echo "====== OpenClaw - Chrome Debug Mode ======"
echo ""

if [[ "$OSTYPE" == "darwin"* ]]; then
  CHROME_BIN="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
  [ ! -f "$CHROME_BIN" ] && CHROME_BIN="/Applications/Chromium.app/Contents/MacOS/Chromium"
  [ ! -f "$CHROME_BIN" ] && CHROME_BIN="/Applications/Google Chrome Canary.app/Contents/MacOS/Google Chrome Canary"
else
  CHROME_BIN="$(command -v google-chrome || command -v google-chrome-stable || command -v chromium-browser || command -v chromium || echo '')"
fi
[ -n "$CHROME_DEBUG_BIN" ] && CHROME_BIN="$CHROME_DEBUG_BIN"

if [ -z "$CHROME_BIN" ] || { [ ! -f "$CHROME_BIN" ] && [ ! -x "$CHROME_BIN" ]; }; then
  echo -e "\033[31mERROR: Chrome/Chromium not found.\033[0m"
  echo "Install Chrome or: export CHROME_DEBUG_BIN=/path/to/chrome"
  exit 1
fi

echo "Using: $CHROME_BIN"
echo "Killing existing Chrome debug instances..."
pkill -f -- "--remote-debugging-port=9222" 2>/dev/null || true
sleep 2

TMP_DIR="${TMPDIR:-/tmp}/chrome-debug-openclaw"
mkdir -p "$TMP_DIR"

echo "Starting Chrome in Debug Mode (port 9222)..."
"$CHROME_BIN" \
  --remote-debugging-port=9222 \
  --remote-allow-origins=* \
  --user-data-dir="$TMP_DIR" &

sleep 4
if curl -s http://localhost:9222/json/version > /dev/null 2>&1; then
  echo -e "\033[32mOK! Chrome Debug Mode is running on port 9222.\033[0m"
else
  echo -e "\033[31mERROR: Port 9222 not responding.\033[0m"
  exit 1
fi
