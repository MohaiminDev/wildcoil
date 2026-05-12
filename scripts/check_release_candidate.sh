#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_DIR="${1:-"$ROOT_DIR/build/release-gate/latest"}"
GODOT_BIN="${GODOT_BIN:-godot}"
MARKET_AUDIT="$ROOT_DIR/docs/market-readiness-audit-2026-05-10.md"
COMPLETION_AUDIT="$LOG_DIR/completion-audit.md"

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

marker_in_log() {
  local log_name="$1"
  local marker="$2"
  local log_path="$LOG_DIR/${log_name}.log"

  [[ -f "$log_path" ]] && grep -q "$marker" "$log_path"
}

write_completion_audit() {
  local decision="$1"
  local playable_status="checked"
  local package_status="checked"
  local screenshot_playtest_status="checked"
  local godot_version_status="checked"
  local validation_status="checked"
  local assessment_status="checked"
  local public_status="checked"
  local player_love_status="checked"

  if ! marker_in_log check "RIFT_ROAD_RUNTIME_OK smoke" \
    || ! marker_in_log exported_app_smoke "RIFT_ROAD_EXPORTED_APP_SMOKE ok" \
    || ! marker_in_log exported_app_keyboard_fallback "RIFT_ROAD_EXPORTED_KEYBOARD_FALLBACK ok" \
    || ! marker_in_log exported_app_focus_resume "RIFT_ROAD_EXPORTED_FOCUS_RESUME ok"; then
    playable_status="blocked"
  fi

  if ! marker_in_log signing_preflight "RIFT_ROAD_SIGNING_PREFLIGHT ok" \
    || ! marker_in_log package_audit "RIFT_ROAD_PACKAGE_AUDIT release-candidate" \
    || ! marker_in_log second_machine_evidence "RIFT_ROAD_SECOND_MACHINE_EVIDENCE ok"; then
    package_status="blocked"
  fi

  if ! marker_in_log exported_app_smoke "RIFT_ROAD_EXPORTED_APP_SMOKE ok" \
    || ! marker_in_log playtest_evidence "RIFT_ROAD_PLAYTEST_EVIDENCE public-playtest-candidate" \
    || ! marker_in_log controller_evidence "RIFT_ROAD_CONTROLLER_EVIDENCE ok" \
    || ! marker_in_log focus_audio_evidence "RIFT_ROAD_FOCUS_AUDIO_EVIDENCE ok"; then
    screenshot_playtest_status="blocked"
  fi

  if ! marker_in_log check "RIFT_ROAD_GODOT_VERSION ok"; then
    godot_version_status="blocked"
  fi

  if ! marker_in_log check "RIFT_ROAD_GODOT_VERSION ok" \
    || ! marker_in_log check "RIFT_ROAD_RUNTIME_OK smoke" \
    || ! marker_in_log exported_app_performance "RIFT_ROAD_EXPORTED_PERF stage1" \
    || ! marker_in_log performance "RIFT_ROAD_PERF stage1"; then
    validation_status="blocked"
  fi

  if [[ ! -f "$MARKET_AUDIT" ]] \
    || ! grep -q "## Objective Restated" "$MARKET_AUDIT" \
    || ! grep -q "## Prompt-To-Artifact Checklist" "$MARKET_AUDIT"; then
    assessment_status="blocked"
  fi

  if [[ "$decision" != "release-candidate" ]] \
    || grep -q "| Public playtest or release-candidate proof |.*| Not achieved |" "$MARKET_AUDIT"; then
    public_status="blocked"
  fi

  if grep -q "| Player love / commercial viability |.*| Not achieved |" "$MARKET_AUDIT"; then
    player_love_status="blocked"
  fi

  {
    printf '# Rift Road Release Completion Audit\n\n'
    printf '## Objective Restated\n\n'
    printf 'Make `Rift Road: Beasts of the Afterglow` meaningfully marketable with a playable Stage 1 vertical slice, a production-deployable macOS path, real launched-game screenshot/playtest evidence, validation results, and a candid market-readiness assessment. Do not treat the goal as complete unless evidence supports a public playtest or release-candidate claim, and do not claim player love or commercial viability without player or market evidence.\n\n'
    printf '## Prompt-To-Artifact Checklist\n\n'
    printf '| Requirement | Evidence checked in this run | Status |\n'
    printf '| --- | --- | --- |\n'
    printf '| Playable Stage 1 vertical slice | `logs/check.log`, `logs/exported_app_smoke.log`, `logs/exported_app_keyboard_fallback.log`, `logs/exported_app_focus_resume.log` | `%s` |\n' "$playable_status"
    printf '| Production-deployable macOS build path | `logs/signing_preflight.log`, `logs/package.log`, `logs/package_audit.log`, `logs/second_machine_evidence.log` | `%s` |\n' "$package_status"
    printf '| Real launched-game screenshot and playtest evidence | `logs/exported_app_smoke.log`, `logs/playtest_evidence.log`, `logs/controller_evidence.log`, `logs/focus_audio_evidence.log` | `%s` |\n' "$screenshot_playtest_status"
    printf '| Godot engine version gate | `logs/check.log` marker `RIFT_ROAD_GODOT_VERSION ok` | `%s` |\n' "$godot_version_status"
    printf '| Current validation results | `logs/check.log`, `logs/exported_app_performance.log`, `logs/performance.log` | `%s` |\n' "$validation_status"
    printf '| Candid market-readiness assessment | `docs/market-readiness-audit-2026-05-10.md` | `%s` |\n' "$assessment_status"
    printf '| Public playtest or release-candidate proof | release-gate blockers plus `docs/public_playtest_gate.md` | `%s` |\n' "$public_status"
    printf '| Player love / commercial viability | `docs/playtest_log.md` and market-readiness audit player-evidence row | `%s` |\n\n' "$player_love_status"
    printf '## Blockers\n\n'
    if [[ "${#blockers[@]}" -gt 0 ]]; then
      for blocker in "${blockers[@]}"; do
        printf -- '- %s\n' "$blocker"
      done
    else
      printf -- '- none\n'
    fi
    printf '\n## Completion Decision\n\n'
    printf 'RIFT_ROAD_RELEASE_GATE %s\n' "$decision"
  } > "$COMPLETION_AUDIT"
}

run_logged check bash "$ROOT_DIR/scripts/check.sh"
if ! run_logged_allow_failure signing_preflight bash "$ROOT_DIR/scripts/check_macos_signing_env.sh"; then
  add_blocker "macOS signing preflight is blocked"
fi
run_logged package bash "$ROOT_DIR/scripts/package_macos.sh"
run_logged package_audit bash "$ROOT_DIR/scripts/audit_macos_package.sh"
run_logged exported_app_smoke bash "$ROOT_DIR/scripts/smoke_exported_macos_app.sh"
run_logged exported_app_keyboard_fallback bash "$ROOT_DIR/scripts/smoke_exported_keyboard_fallback.sh"
run_logged exported_app_focus_resume bash "$ROOT_DIR/scripts/smoke_exported_focus_resume.sh"
if ! run_logged_allow_failure focus_audio_evidence bash "$ROOT_DIR/scripts/check_focus_audio_evidence.sh"; then
  add_blocker "Focus/audio evidence gate is blocked"
elif ! grep -q "RIFT_ROAD_FOCUS_AUDIO_EVIDENCE ok" "$LOG_DIR/focus_audio_evidence.log"; then
  add_blocker "Focus/audio evidence gate did not report ok"
fi
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
run_logged performance "$GODOT_BIN" --path "$ROOT_DIR/src/wildcoil" --log-file "$LOG_DIR/godot-performance.log" --headless --script "$ROOT_DIR/src/wildcoil/tools/runtime_test_runner.gd" -- stage1_performance_sample

if ! grep -q "RIFT_ROAD_PACKAGE_AUDIT release-candidate" "$LOG_DIR/package_audit.log"; then
  add_blocker "macOS package audit is not release-candidate"
fi

if ! grep -q "RIFT_ROAD_EXPORTED_KEYBOARD_FALLBACK ok" "$LOG_DIR/exported_app_keyboard_fallback.log"; then
  add_blocker "Exported-app keyboard fallback smoke did not report ok"
fi

if ! grep -q "RIFT_ROAD_EXPORTED_FOCUS_RESUME ok" "$LOG_DIR/exported_app_focus_resume.log"; then
  add_blocker "Exported-app focus/resume smoke did not report ok"
fi

if grep -q "| Public playtest or release-candidate proof |.*| Not achieved |" "$MARKET_AUDIT"; then
  add_blocker "Public playtest or release-candidate proof is marked Not achieved"
fi

if grep -q "| Player love / commercial viability |.*| Not achieved |" "$MARKET_AUDIT"; then
  add_blocker "Player love / commercial viability is marked Not achieved"
fi

if [[ "${#blockers[@]}" -gt 0 ]]; then
  write_completion_audit "blocked"
  printf 'Release gate blockers:\n'
  for blocker in "${blockers[@]}"; do
    printf -- '- %s\n' "$blocker"
  done
  printf 'Completion audit: %s\n' "$COMPLETION_AUDIT"
  printf 'RIFT_ROAD_RELEASE_GATE blocked\n'
  exit 1
fi

write_completion_audit "release-candidate"
printf 'Completion audit: %s\n' "$COMPLETION_AUDIT"
printf 'RIFT_ROAD_RELEASE_GATE release-candidate\n'
