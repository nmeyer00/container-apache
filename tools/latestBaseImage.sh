#!/bin/bash
set -e
# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purposes

REPO="library/alpine"
SERIES="${1:-}"

if [[ -n "$SERIES" ]]; then
  #Searching for the new Image in a serie like 3.21.x
  LATEST_TAG=$(curl -s "https://hub.docker.com/v2/repositories/${REPO}/tags/?page_size=1000" \
    | jq -r '.results[].name' \
    | grep -E "^${SERIES}\.[0-9]+$" \
    | sort -V \
    | tail -n1)
else
  # Searching the the Base Image
  LATEST_TAG=$(curl -s "https://hub.docker.com/v2/repositories/${REPO}/tags/?page_size=1000" \
    | jq -r '.results[].name' \
    | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' \
    | sort -V \
    | tail -n1)
fi

if [[ -z "$LATEST_TAG" ]]; then
  echo "ERROR: Connection ERROR / No Image found"
  exit 1
fi

IMAGE="alpine:${LATEST_TAG}"
echo "$IMAGE"