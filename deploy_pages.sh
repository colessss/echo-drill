#!/bin/zsh
# One-shot: create the GitHub repo, push, enable GitHub Pages, print the permanent URL.
# Requires: gh auth login (done once). Re-run after edits to push updates (Pages redeploys itself).
set -e
cd "$(dirname "$0")"
OWNER=$(gh api user -q .login)
REPO=echo-drill
if ! gh repo view "$OWNER/$REPO" >/dev/null 2>&1; then
  gh repo create "$REPO" --public --source=. --remote=origin --push \
    --description "Echo Drill: hear a line, say it back"
else
  git remote get-url origin >/dev/null 2>&1 || git remote add origin "git@github.com:$OWNER/$REPO.git"
  git push -u origin main
fi
# Enable Pages from the main branch root (idempotent).
gh api -X POST "repos/$OWNER/$REPO/pages" -f build_type=legacy -f 'source[branch]=main' -f 'source[path]=/' >/dev/null 2>&1 || true
URL="https://$OWNER.github.io/$REPO/"
echo "Waiting for GitHub Pages to build..."
for i in {1..40}; do
  code=$(curl -s -o /dev/null -w "%{http_code}" "$URL")
  [[ "$code" == "200" ]] && break
  sleep 6
done
echo "Echo Drill is live at: $URL  (status $code)"
