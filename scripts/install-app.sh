#!/bin/bash
# Builds from source and installs into /Applications. For development.
set -euo pipefail

repo_dir="$(cd "$(dirname "$0")/.." && pwd)"
target="/Applications/Token Monitor.app"

"$repo_dir/scripts/build-app.sh"

osascript -e 'quit app "Token Monitor"' 2>/dev/null || true
rm -rf "$target"
cp -R "$repo_dir/dist/Token Monitor.app" /Applications/
open "$target"

echo "$target"
