#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_DIR="${1:-"$ROOT_DIR/build/release-gate/latest"}"
GODOT_BIN="${GODOT_BIN:-godot}"
MARKET_AUDIT="$ROOT_DIR/docs/market-readiness-audit-2026-05-10.md"

rm -rf "$LOG_DIR"
mkdir -p "$LOG_DIR"

run_logged() {
  local name="$1"
  shift
  local log_path="$LOG_DIR/${name}.log"

  printf '== %s ==\n' "$name"
  set +e
  "$@" 2>&1 | tee "$log_path"
  local command_status="${PIPESTATUS[0]}"
  set -e

  if [[ "$command_status" -ne 0 ]]; then
    printf 'RIFT_ROAD_RELEASE_GATE blocked\n'
    printf 'ERROR: %s failed; see %s\n' "$name" "$log_path" >&2
    exit "$command_status"
  fi
}

run_logged_allow_failure() {
  local name="$1"
  shift
  local log_path="$LOG_DIR/${name}.log"

  printf '== %s ==\n' "$name"
  set +e
  "$@" 2>&1 | tee "$log_path"
  local command_status="${PIPESTATUS[0]}"
  set -e
  return "$command_status"
}

blockers=()

add_blocker() {
  blockers+=("$1")
}

run_logged check bash "$ROOT_DIR/scripts/check.sh"
if ! run_logged_allow_failure signing_preflight bash "$ROOT_DIR/scripts/check_macos_signing_env.sh"; then
  add_blocker "macOS signing preflight is blocked"
fi
run_logged package bash "$ROOT_DIR/scripts/package_macos.sh"
run_logged package_audit bash "$ROOT_DIR/scripts/audit_macos_package.sh"
run_logged exported_app_smoke bash "$ROOT_DIR/scripts/smoke_exported_macos_app.sh"
run_logged exported_app_keyboard_fallback bash "$ROOT_DIR/scripts/smoke_exported_keyboard_fallback.sh"
run_logged exported_app_performance bash "$ROOT_DIR/scripts/sample_exported_app_performance.sh"
if ! run_logged_allow_failure playtest_evidence bash "$ROOT_DIR/scripts/check_playtest_evidence.sh"; then
  add_blocker "Playtest evidence gate is blocked"
elif ! grep -q "RIFT_ROAD_PLAYTEST_EVIDENCE public-playtest-candidate" "$LOG_DIR/playtest_evidence.log"; then
  add_blocker "Playtest evidence gate did not report public-playtest-candidate"
fi
if ! run_logged_allow_failure second_machine_evidence bash "$ROOT_DIR/scripts/check_second_machine_evidence.sh"; then
  add_blocker "Second-machine evidence gate is blocked"
elif ! grep -q "RIFT_ROAD_SECOND_MACHINE_EVIDENCE ok" "$LOG_DIR/second_machine_evidence.log"; then
  add_blocker "Second-machine evidence gate did not report ok"
fi
if ! run_logged_allow_failure controller_evidence bash "$ROOT_DIR/scripts/check_controller_evidence.sh"; then
  add_blocker "Controller evidence gate is blocked"
elif ! grep -q "RIFT_ROAD_CONTROLLER_EVIDENCE ok" "$LOG_DIR/controller_evidence.log"; then
  add_blocker "Controller evidence gate did not report ok"
fi
run_logged performance "$GODOT_BIN" --path "$ROOT_DIR/src/wildcoil" --headless --script "$ROOT_DIR/src/wildcoil/tools/runtime_test_runner.gd" -- stage1_performance_sample

if ! grep -q "RIFT_ROAD_PACKAGE_AUDIT release-candidate" "$LOG_DIR/package_audit.log"; then
  add_blocker "macOS package audit is not release-candidate"
fi

if ! grep -q "RIFT_ROAD_EXPORTED_KEYBOARD_FALLBACK ok" "$LOG_DIR/exported_app_keyboard_fallback.log"; then
  add_blocker "Exported-app keyboard fallback smoke did not report ok"
fi

if grep -q "| Public playtest or release-candidate proof |.*| Not achieved |" "$MARKET_AUDIT"; then
  add_blocker "Public playtest or release-candidate proof is marked Not achieved"
fi

if grep -q "| Player love / commercial viability |.*| Not achieved |" "$MARKET_AUDIT"; then
  add_blocker "Player love / commercial viability is marked Not achieved"
fi

if [[ "${#blockers[@]}" -gt 0 ]]; then
  printf 'Release gate blockers:\n'
  for blocker in "${blockers[@]}"; do
    printf -- '- %s\n' "$blocker"
  done
  printf 'RIFT_ROAD_RELEASE_GATE blocked\n'
  exit 1
fi

printf 'RIFT_ROAD_RELEASE_GATE release-candidate\n'
