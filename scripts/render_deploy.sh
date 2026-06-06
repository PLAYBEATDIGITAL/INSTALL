#!/bin/bash

# Replace these with your actual values:
GIT_REPO="https://github.com/playbeatdigital-tech/newDx.git"
SITE_NAME="playbeat-frontend"
BRANCH="main"

if [ -z "$RENDER_API_KEY" ]; then
  echo "Error: RENDER_API_KEY environment variable not set."
  exit 1
fi

# Create or get site ID
echo "Checking if site '$SITE_NAME' exists..."
SITE_ID=$(curl -s -H "Authorization: Bearer $RENDER_API_KEY" \
  https://api.render.com/v1/services | jq -r ".[] | select(.repo == \"$GIT_REPO\" and .name == \"$SITE_NAME\") | .id")

if [ -z "$SITE_ID" ]; then
  echo "Site not found; creating new site..."
  create_response=$(curl -s -X POST -H "Authorization: Bearer $RENDER_API_KEY" \
    -H "Content-Type: application/json" \
    -d "{\n      \"name\": \"$SITE_NAME\",\n      \"repo\": \"$GIT_REPO\",\n      \"branch\": \"$BRANCH\",\n      \"env\": [],\n      \"rootDirectory\": \"frontend\",\n      \"buildCommand\": \"npm run build\",\n      \"startCommand\": \"npm run start\",\n      \"serviceType\": \"static_site\"\n    }" \
    https://api.render.com/v1/services)
  SITE_ID=$(echo "$create_response" | jq -r '.id')
  echo "Created site with ID: $SITE_ID"
else
  echo "Found existing site with ID: $SITE_ID"
fi

# Trigger a deploy
deploy_response=$(curl -s -X POST -H "Authorization: Bearer $RENDER_API_KEY" \
  https://api.render.com/v1/services/$SITE_ID/deploys)

DEPLOY_ID=$(echo "$deploy_response" | jq -r '.id')

echo "Deployment triggered with ID: $DEPLOY_ID"
echo "You can monitor deployment logs at Render dashboard Live Logs."

exit 0
