#!/usr/bin/env bash
set -euo pipefail

# deploy_render.sh — Create a Render service, set env vars, and trigger a deploy.
# Usage: edit placeholders below or export RENDER_API_KEY and run the script.

: ${RENDER_API_KEY:=""}
if [ -z "$RENDER_API_KEY" ]; then
  echo "ERROR: set RENDER_API_KEY env var or edit this script with your key." >&2
  exit 1
fi

SERVICE_NAME="playbeat-backend"   # change if desired
GIT_REPO="https://github.com/USER/REPO.git"  # replace with your repo URL
BRANCH="main"
REGION="oregon"

# Create service
echo "Creating Render service '$SERVICE_NAME'..."
CREATE_RESP=$(curl -s -X POST "https://api.render.com/v1/services" \
  -H "Authorization: Bearer $RENDER_API_KEY" \
  -H "Content-Type: application/json" \
  -d "{\"name\":\"$SERVICE_NAME\",\"repo\":\"$GIT_REPO\",\"branch\":\"$BRANCH\",\"service\":{\"env\":\"node\",\"region\":\"$REGION\",\"plan\":\"free\",\"buildCommand\":\"npm install\",\"startCommand\":\"npm start\"}}")

echo "$CREATE_RESP" | jq .
SERVICE_ID=$(echo "$CREATE_RESP" | jq -r .id)
if [ -z "$SERVICE_ID" ] || [ "$SERVICE_ID" = "null" ]; then
  echo "Failed to create service — inspect the JSON above." >&2
  exit 1
fi

echo "Service created with ID: $SERVICE_ID"

echo "Setting environment variables (examples)." 
# Example: repeat these blocks, replacing values
curl -s -X POST "https://api.render.com/v1/services/$SERVICE_ID/env-vars" \
  -H "Authorization: Bearer $RENDER_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"key":"MONGODB_URI","value":"mongodb+srv://USER:PASS@host/db","secure":true}' | jq .

# Add other env vars similarly (replace values before running)
# JWT_SECRET, EMAIL_HOST, EMAIL_PORT, EMAIL_USER, EMAIL_PASS, EMAIL_FROM

cat <<'EOF'
To finish:
- Replace placeholder values above (GIT_REPO and env var values) and re-run.
- Or use Render dashboard to set secrets and trigger a deploy.
- To trigger a manual deploy via API:
  curl -X POST "https://api.render.com/v1/services/$SERVICE_ID/deploys" \
    -H "Authorization: Bearer $RENDER_API_KEY" \
    -H "Content-Type: application/json" -d '{}'
EOF
