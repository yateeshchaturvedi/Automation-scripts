#!/bin/bash

# ========== CONFIG ==========
ORG="<org-name>"
PROJECT="<project name in encoded format>" 
NEW_QUEUE_ID=141                              #agent pool id
NEW_QUEUE_NAME="mdevopspool-bs-prd-01"        #agent pool name
PAT="<PAT Token of azure devops>"
PATH_FILTER="<path filter to select specific release definitions>"

API_VERSION="7.0"
AUTH_HEADER=$(printf ":%s" "$PAT" | base64 | tr -d '\n')
BASE_URL="https://vsrm.dev.azure.com/${ORG}/${PROJECT}"

ENV_NAME="Deploy"

# ========== FETCH RELEASE DEFINITIONS IN DIRECTORY ==========
echo "Fetching release definition..."

RELEASE_IDS=$(curl -s \
  -H "Authorization: Basic $AUTH_HEADER" \
  "${BASE_URL}/_apis/release/definitions?path=${PATH_FILTER}&api-version=${API_VERSION}" \
  | jq -r '.value[].id')
# curl -s \
#   -H "Authorization: Basic $AUTH_HEADER" \
#   "https://vsrm.dev.azure.com/${ORG}/${PROJECT}/_apis/release/definitions?path=${PATH_FILTER}&api-version=7.0" | jq -r '.value[] | "\(.id) | \(.name)"'

for DEFINITION_ID in $RELEASE_IDS; do
  if [ "$DEFINITION_ID" -gt 0 ]; then
    echo "Fetching defintion of $DEFINITION_ID"
    HTTP_CODE=$(curl -s -o definition.json -w "%{http_code}" \
    -H "Authorization: Basic $AUTH_HEADER" \
    -H "Content-Type: application/json" \
    "${BASE_URL}/_apis/release/definitions/${DEFINITION_ID}?api-version=${API_VERSION}")

    echo "HTTP Status: $HTTP_CODE"

    if [ "$HTTP_CODE" != "200" ]; then
    echo "API call failed"
    cat definition.json
    exit 1
    fi
    SiteName=$(jq -r '.name' definition.json)

    echo "Definition fetched successfully"

    # ===== UPDATE AGENT POOL (RELEASE PIPELINE) =====
    echo "Updating agent pool for environment: $ENV_NAME" for site: $SiteName

    jq \
    --arg env "$ENV_NAME" \
    --argjson queueId "$NEW_QUEUE_ID" \
    '
    (.environments[] | select(.name==$env)
    | .deployPhases[]
    | .deploymentInput.queueId) = $queueId
    ' definition.json > updated_definition.json

    # ===== PUSH UPDATED RELEASE DEFINITION =====
    echo "Pushing updated release definition..."

    HTTP_CODE=$(curl -s -o response.json -w "%{http_code}" -X PUT \
    -H "Authorization: Basic $AUTH_HEADER" \
    -H "Content-Type: application/json" \
    "${BASE_URL}/_apis/release/definitions/${DEFINITION_ID}?api-version=${API_VERSION}" \
    --data @updated_definition.json)

    echo "HTTP Status of updated site: $HTTP_CODE"

    if [ "$HTTP_CODE" != "200" ]; then
    echo "Update failed"
    cat response.json
    exit 1
    fi

    echo "Agent pool updated for Release ID: $DEFINITION_ID having Site Name: $SiteName"
  fi
done
echo "All done!"