#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT_BIN="${GODOT_BIN:-godot}"

cd "${ROOT_DIR}"
python3 -m pytest tests -v
"${GODOT_BIN}" --path "${ROOT_DIR}/src/wildcoil" --headless --script "${ROOT_DIR}/src/wildcoil/tools/runtime_test_runner.gd" -- smoke

