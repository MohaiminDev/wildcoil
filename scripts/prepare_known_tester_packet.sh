#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_DIR="${1:-"$ROOT_DIR/build/known-tester-packet/latest"}"
PACKAGE_PATH="$ROOT_DIR/build/macos/Rift Road.zip"
LOG_DIR="$OUTPUT_DIR/logs"
DOCS_DIR="$OUTPUT_DIR/docs"
EVIDENCE_DIR="$OUTPUT_DIR/evidence"
MANIFEST_PATH="$OUTPUT_DIR/manifest.md"

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
    printf 'RIFT_ROAD_KNOWN_TESTER_PACKET failed output_dir=%s\n' "$OUTPUT_DIR"
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

copy_if_exists() {
  local source_path="$1"
  local destination_path="$2"
  if [[ -e "$source_path" ]]; then
    mkdir -p "$(dirname "$destination_path")"
    cp -R "$source_path" "$destination_path"
  fi
}

rm -rf "$OUTPUT_DIR"
mkdir -p "$LOG_DIR" "$DOCS_DIR" "$EVIDENCE_DIR"

run_logged check bash "$ROOT_DIR/scripts/check.sh"
run_logged package bash "$ROOT_DIR/scripts/package_macos.sh"
signing_status="ok"
if ! run_logged_allow_failure signing_preflight bash "$ROOT_DIR/scripts/check_macos_signing_env.sh"; then
  signing_status="blocked"
fi
run_logged package_audit bash "$ROOT_DIR/scripts/audit_macos_package.sh"
run_logged exported_app_smoke bash "$ROOT_DIR/scripts/smoke_exported_macos_app.sh"
run_logged exported_app_performance bash "$ROOT_DIR/scripts/sample_exported_app_performance.sh"

packet_status="internal-only"
if grep -q "RIFT_ROAD_PACKAGE_AUDIT release-candidate" "$LOG_DIR/package_audit.log"; then
  packet_status="release-candidate-audit"
fi

cp "$PACKAGE_PATH" "$OUTPUT_DIR/Rift Road.zip"
copy_if_exists "$ROOT_DIR/docs/public_playtest_gate.md" "$DOCS_DIR/public_playtest_gate.md"
copy_if_exists "$ROOT_DIR/docs/playtest_log.md" "$DOCS_DIR/playtest_log.md"
copy_if_exists "$ROOT_DIR/docs/macos_build_and_distribution.md" "$DOCS_DIR/macos_build_and_distribution.md"
copy_if_exists "$ROOT_DIR/docs/controller_validation.md" "$DOCS_DIR/controller_validation.md"
copy_if_exists "$ROOT_DIR/docs/second_machine_validation.md" "$DOCS_DIR/second_machine_validation.md"
copy_if_exists "$ROOT_DIR/docs/performance_budget.md" "$DOCS_DIR/performance_budget.md"
copy_if_exists "$ROOT_DIR/docs/market-readiness-audit-2026-05-10.md" "$DOCS_DIR/market-readiness-audit-2026-05-10.md"
copy_if_exists "$ROOT_DIR/docs/playtest-captures/stage1-marketability-handoff-2026-05-10.md" "$DOCS_DIR/stage1-marketability-handoff-2026-05-10.md"
copy_if_exists "$ROOT_DIR/docs/playtest-captures/exported-app-smoke-latest" "$EVIDENCE_DIR/exported-app-smoke-latest"
copy_if_exists "$ROOT_DIR/docs/playtest-captures/exported-app-performance-latest" "$EVIDENCE_DIR/exported-app-performance-latest"
copy_if_exists "$ROOT_DIR/docs/playtest-captures/exported-app-performance-windowed-1080p-latest" "$EVIDENCE_DIR/exported-app-performance-windowed-1080p-latest"
copy_if_exists "$ROOT_DIR/docs/playtest-captures/exported-app-performance-fullscreen-latest" "$EVIDENCE_DIR/exported-app-performance-fullscreen-latest"
copy_if_exists "$ROOT_DIR/docs/playtest-captures/performance-host-latest" "$EVIDENCE_DIR/performance-host-latest"

{
  printf '# Rift Road Known-Tester Packet\n\n'
  printf -- '- Package: `Rift Road.zip`\n'
  printf -- '- Packet status: `%s`\n' "$packet_status"
  printf -- '- Signing preflight: `%s`\n' "$signing_status"
  printf -- '- Build source: `%s`\n' "$ROOT_DIR"
  printf -- '- Public playtest protocol: `docs/public_playtest_gate.md`\n'
  printf -- '- Playtest log template: `docs/playtest_log.md`\n\n'
  printf -- '- Controller validation checklist: `docs/controller_validation.md`\n'
  printf -- '- Second-machine validation checklist: `docs/second_machine_validation.md`\n\n'
  printf '## Critical Distribution Warning\n\n'
  printf 'This packet is for supervised internal or known-tester sessions only while the package audit remains `internal-only`. It is not a public build, not notarized release evidence, and not a marketability claim.\n\n'
  printf '## Logs\n\n'
  printf -- '- `logs/check.log`\n'
  printf -- '- `logs/signing_preflight.log`\n'
  printf -- '- `logs/package_audit.log`\n'
  printf -- '- `logs/exported_app_smoke.log`\n'
  printf -- '- `logs/exported_app_performance.log`\n\n'
  printf '## Evidence\n\n'
  printf -- '- `evidence/exported-app-smoke-latest/`\n'
  printf -- '- `evidence/exported-app-performance-latest/`\n'
  printf -- '- `evidence/exported-app-performance-windowed-1080p-latest/`\n'
  printf -- '- `evidence/exported-app-performance-fullscreen-latest/`\n'
  printf -- '- `evidence/performance-host-latest/`\n'
} > "$MANIFEST_PATH"

printf 'RIFT_ROAD_KNOWN_TESTER_PACKET %s output_dir=%s manifest=%s\n' "$packet_status" "$OUTPUT_DIR" "$MANIFEST_PATH"
