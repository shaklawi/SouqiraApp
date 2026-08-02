#!/usr/bin/env bash
set -euo pipefail

# Install Firebase Android config file to expected path.
# Usage:
#   ./android/scripts/setup-firebase-android.sh [path-to-google-services.json]

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TARGET_FILE="$REPO_ROOT/android/app/google-services.json"
SOURCE_FILE="${1:-$REPO_ROOT/android/google-services.json}"

if [[ ! -f "$SOURCE_FILE" ]]; then
  echo "Error: source file not found: $SOURCE_FILE"
  echo "Download it from Firebase Console > Project settings > Android app > google-services.json"
  exit 1
fi

mkdir -p "$(dirname "$TARGET_FILE")"
cp "$SOURCE_FILE" "$TARGET_FILE"

echo "Installed Firebase config at: $TARGET_FILE"
