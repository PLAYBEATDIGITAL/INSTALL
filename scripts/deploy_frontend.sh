#!/usr/bin/env bash
set -euo pipefail

# deploy_frontend.sh — Create a static site on Render, set basic config, and trigger a deploy.
# Usage: export RENDER_API_KEY and edit placeholders, then run.

: ${RENDER_API_KEY:=""}
if [ -z "$RENDER_API_KEY" ]; then
  echo "ERROR: set RENDER_API_KEY env var or edit this script with your key." >&2
  exit 1
fi

SITE_NAME="playbeat-frontend"   # change if desired
GIT_REPO="https://github.com/USER/FRONTEND_REPO.git"  # replace with your frontend repo URL
BRANCH="main"

echo "Creating Render static site '$SITE_NAME'..."
CREATE_RESP=$(curl -s -X POST "https://api.render.com/v1/sites" \
  -H "Authorization: Bearer $RENDER_API_KEY" \
  -H "Content-Type: application/json" \
  -d "{\"name\":\"$SITE_NAME\",\"repo\":\"$GIT_REPO\",\"branch\":\"$BRANCH\",\"buildCommand\":\"npm run build\",\"publishPath\":\"build\"}")

echo "$CREATE_RESP" | jq .
SITE_ID=$(echo "$CREATE_RESP" | jq -r .id)
if [ -z "$SITE_ID" ] || [ "$SITE_ID" = "null" ]; then
  echo "Failed to create site — inspect the JSON above." >&2
  exit 1
fi

echo "Site created with ID: $SITE_ID"

echo "To trigger a deploy via API:"
cat <<EOF
curl -X POST "https://api.render.com/v1/sites/$SITE_ID/deploys" \
  -H "Authorization: Bearer $RENDER_API_KEY" \
  -H "Content-Type: application/json" -d '{}' | jq .
EOF

cat <<'EOF'
Next steps:
- Replace GIT_REPO with your frontend repo URL and re-run.
- Or import the repo using the Render dashboard and set Build Command = "npm run build" and Publish Path = "build".
EOF
