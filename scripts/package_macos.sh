#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT_BIN="${GODOT_BIN:-godot}"
OUT_DIR="${ROOT_DIR}/build/macos"

mkdir -p "${OUT_DIR}"
"${GODOT_BIN}" --path "${ROOT_DIR}/src/wildcoil" --log-file "${OUT_DIR}/package-godot.log" --headless --export-release "macOS" "${OUT_DIR}/Rift Road.zip"
