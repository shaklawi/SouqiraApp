#!/usr/bin/env bash
set -euo pipefail

# Prepare Firebase config and build Android app.
# Usage:
#   ./android/scripts/build-with-firebase.sh [path-to-google-services.json] [debug|release]

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
BUILD_TYPE="${2:-debug}"

"$REPO_ROOT/android/scripts/setup-firebase-android.sh" "${1:-$REPO_ROOT/android/google-services.json}"

pushd "$REPO_ROOT/android" >/dev/null
if [[ "$BUILD_TYPE" == "release" ]]; then
  ./gradlew :app:assembleRelease
else
  ./gradlew :app:assembleDebug
fi
popd >/dev/null

echo "Android build completed: $BUILD_TYPE"
