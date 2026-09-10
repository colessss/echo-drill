#!/bin/zsh
# Serve Echo Drill locally and expose it over HTTPS with a Cloudflare quick tunnel.
# Usage: ./serve.sh        (prints the public URL; keeps running until Ctrl+C)
cd "$(dirname "$0")"
pkill -f "http.server 8791" 2>/dev/null
pkill -f "cloudflared tunnel --url http://localhost:8791" 2>/dev/null
python3.11 -m http.server 8791 --directory "$PWD" >/dev/null 2>&1 &
cloudflared tunnel --url http://localhost:8791 > tunnel.log 2>&1 &
for i in {1..30}; do
  url=$(grep -o 'https://[a-z0-9-]*\.trycloudflare\.com' tunnel.log | head -1)
  [[ -n "$url" ]] && break
  sleep 1
done
echo "Echo Drill is live at: $url"
echo "(URL changes each run. Leave this window open; Ctrl+C stops it.)"
wait
