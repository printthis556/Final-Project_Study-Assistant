#!/usr/bin/env bash
# Simple helper to POST sample notes to the configured Cloudflare Worker
# Usage: ./scripts/post_sample_notes.sh [worker_url]
# If no argument provided, uses $CF_WORKER_URL or the default public worker URL.

set -euo pipefail

DEFAULT_URL="https://ai-study-app.mhess0308.workers.dev/"
URL="${1:-${CF_WORKER_URL:-$DEFAULT_URL}}"

SAMPLE_NOTES=$(cat <<'NOTES'
First concept line
More details here.

Second concept
More detail about second concept.
NOTES
)

echo "Posting sample notes to: $URL"

# Build JSON payload robustly using Python (safe quoting of newlines and quotes)
if command -v jq >/dev/null 2>&1; then
  JSON_PAYLOAD=$(printf '%s' "$SAMPLE_NOTES" | jq -R --slurp --compact-output --arg notes "$(printf '%s' "$SAMPLE_NOTES")" '{notes: $notes}' 2>/dev/null)
else
  # Fallback: escape backslashes, quotes, and newlines using sed (POSIX shell only)
  ESCAPED=$(printf '%s' "$SAMPLE_NOTES" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' -e ':a' -e 'N' -e '$!ba' -e 's/\n/\\n/g')
  JSON_PAYLOAD="{\"notes\": \"$ESCAPED\"}"
fi

RESP=$(curl -sS -w "HTTPSTATUS:%{http_code}" -X POST "$URL" \
  -H "Content-Type: application/json" \
  -d "$JSON_PAYLOAD") || {
  echo "curl failed" >&2; exit 1;
}

HTTP_STATUS=$(printf '%s' "$RESP" | sed -e 's/.*HTTPSTATUS://')
BODY=$(printf '%s' "$RESP" | sed -e 's/HTTPSTATUS:.*//')

if [ "$HTTP_STATUS" -ge 200 ] && [ "$HTTP_STATUS" -lt 300 ]; then
  if command -v jq >/dev/null 2>&1; then
    printf '%s' "$BODY" | jq
  else
    printf '%s' "$BODY"
  fi
else
  echo "Request failed with status $HTTP_STATUS" >&2
  printf '%s' "$BODY" >&2
  exit 1
fi

exit 0
