#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Resolve bluesky handle
# @raycast.mode compact

# Optional parameters:
# @raycast.icon ☁️
# @raycast.argument1 { "type": "text", "placeholder": "handle" }

# From: https://codeberg.org/hrbrmstr/besolve/src/commit/69d1687a545f3f0c3d17a25384925b96babe5083/besolve.sh

resolve_bluesky_handle() {
  local handle="${1:-}"

  # Remove leading '@' if present
  handle=$(echo "${handle}" | sed -e 's/^@//')

  # Check if curl is installed
  if ! command -v curl &>/dev/null; then
    echo "Error: curl is not installed."
    return 1
  fi

  # Check if jq is installed
  if ! command -v jq &>/dev/null; then
    echo "Error: jq is not installed."
    return 1
  fi

  api_url="https://bsky.social/xrpc/com.atproto.identity.resolveHandle"
  response=$(curl --silent --header "Accept: application/json" "${api_url}?handle=${handle}")

  # Check if the curl command was successful
  if [[ $? -ne 0 ]]; then
    echo "Error: Failed to fetch data from Bluesky API."
    return 1
  fi

  # Extract the DID from the response
  did=$(echo "${response}" | jq -r '.did')

  # Check if jq command was successful
  if [[ $? -ne 0 ]]; then
    echo "Error: Failed to parse JSON response."
    return 1
  fi

  # Check if DID is empty
  if [[ -z "${did}" ]]; then
    echo "Error: DID not found in the response."
    return 1
  fi

  echo "${did}"
}

# Check if exactly one argument is provided
if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <handle>"
  exit 1
fi

resolve_bluesky_handle "${1}"
