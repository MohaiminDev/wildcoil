#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT_BIN="${GODOT_BIN:-godot}"
GODOT_LOG_DIR="${ROOT_DIR}/build/logs"

cd "${ROOT_DIR}"
mkdir -p "${GODOT_LOG_DIR}"
python3 scripts/check_agent_docs.py
python3 -m pytest tests -v
"${GODOT_BIN}" --path "${ROOT_DIR}/src/wildcoil" --log-file "${GODOT_LOG_DIR}/check-runtime-smoke.log" --headless --script "${ROOT_DIR}/src/wildcoil/tools/runtime_test_runner.gd" -- smoke
