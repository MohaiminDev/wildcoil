#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_DIR="$ROOT_DIR/src/wildcoil"
OUTPUT_APP="${1:-$ROOT_DIR/build/macos/Wildcoil.app}"
GODOT_BIN="${GODOT_BIN:-godot}"

mkdir -p "$(dirname "$OUTPUT_APP")"
"$GODOT_BIN" --headless --path "$PROJECT_DIR" --import
"$GODOT_BIN" --headless --path "$PROJECT_DIR" --export-release "macOS" "$OUTPUT_APP"
