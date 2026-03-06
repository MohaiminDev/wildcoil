#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="${1:-$ROOT_DIR/build/macos}"
LABEL="${2:-$(python3 -c 'import json, pathlib; print(json.loads(pathlib.Path("'"$ROOT_DIR"'/src/wildcoil/data/content_catalog.json").read_text())["build_label"])')}"
APP_PATH="$BUILD_DIR/Wildcoil.app"
ZIP_PATH="$BUILD_DIR/Wildcoil-${LABEL}-macos.zip"
CHECKSUM_PATH="$ZIP_PATH.sha256"

mkdir -p "$BUILD_DIR"
if [[ "${SKIP_CHECK:-0}" != "1" ]]; then
	"$ROOT_DIR/scripts/check.sh"
fi
"$ROOT_DIR/scripts/export_macos.sh" "$APP_PATH"
ditto -c -k --sequesterRsrc --keepParent "$APP_PATH" "$ZIP_PATH"
shasum -a 256 "$ZIP_PATH" > "$CHECKSUM_PATH"

echo "App: $APP_PATH"
echo "Zip: $ZIP_PATH"
echo "SHA256: $CHECKSUM_PATH"
