#!/bin/zsh
# Serve Echo Drill locally and expose it over HTTPS via localhost.run (SSH tunnel, no account).
# Usage: ./serve.sh   -> prints the public URL; keeps running until Ctrl+C. URL changes each run.
cd "$(dirname "$0")"
pkill -f "http.server 8791" 2>/dev/null
pkill -f "nokey@localhost.run" 2>/dev/null
python3.11 -m http.server 8791 --directory "$PWD" >/dev/null 2>&1 &
ssh -o StrictHostKeyChecking=no -o ServerAliveInterval=30 -o ExitOnForwardFailure=yes \
    -R 80:localhost:8791 nokey@localhost.run > lhr.log 2>&1 &
for i in {1..40}; do
  url=$(grep -oE 'https://[a-z0-9]+\.lhr\.life' lhr.log | head -1)
  [[ -n "$url" ]] && break
  sleep 1
done
echo "Echo Drill is live at: $url"
echo "(URL changes each run. Leave this window open; Ctrl+C stops it.)"
wait
