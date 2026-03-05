#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_DIR="$ROOT_DIR/src/wildcoil"
GODOT_BIN="${GODOT_BIN:-godot}"

exec "$GODOT_BIN" --path "$PROJECT_DIR"
