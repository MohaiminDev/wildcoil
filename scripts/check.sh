#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_DIR="$ROOT_DIR/src/wildcoil"
GODOT_BIN="${GODOT_BIN:-godot}"

"$GODOT_BIN" --headless --path "$PROJECT_DIR" --import
python3 -m pytest "$ROOT_DIR/tests"
