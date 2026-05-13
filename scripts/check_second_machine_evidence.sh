#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EVIDENCE_DIR="${1:-"$ROOT_DIR/docs/playtest-captures/second-machine-latest"}"

HOST_PROFILE="$EVIDENCE_DIR/host-profile.md"
INSTALL_SMOKE="$EVIDENCE_DIR/install-smoke.md"
TITLE_CAPTURE="$EVIDENCE_DIR/stage1-second-machine-title.png"
GAMEPLAY_CAPTURE="$EVIDENCE_DIR/stage1-second-machine-gameplay.png"

blockers=()

add_blocker() {
  blockers+=("$1")
}

relative_path() {
  local path="$1"
  printf '%s\n' "${path#"$ROOT_DIR"/}"
}

require_file() {
  local path="$1"
  if [[ ! -s "$path" ]]; then
    add_blocker "missing or empty $(relative_path "$path")"
  fi
}

require_file "$HOST_PROFILE"
require_file "$INSTALL_SMOKE"
require_file "$TITLE_CAPTURE"
require_file "$GAMEPLAY_CAPTURE"

if [[ -s "$HOST_PROFILE" ]]; then
  grep -q 'Machine label: `Apple Silicon Mac B`' "$HOST_PROFILE" || add_blocker "host profile does not identify Machine label: Apple Silicon Mac B"
  grep -q 'Architecture: `arm64`' "$HOST_PROFILE" || add_blocker "host profile does not record arm64 architecture"
fi

if [[ -s "$INSTALL_SMOKE" ]]; then
  if ! grep -q 'Package source: `build/macos/Rift Road-signed-notarized.zip`' "$INSTALL_SMOKE"; then
    add_blocker "install smoke does not name signed/notarized package source"
  fi
  if ! grep -Eq 'Package SHA256: `[^`]+`' "$INSTALL_SMOKE" || grep -q 'Package SHA256: `TBD`' "$INSTALL_SMOKE"; then
    add_blocker "install smoke does not record Package SHA256"
  elif ! grep -Eq 'Package SHA256: `[[:xdigit:]]{64}`' "$INSTALL_SMOKE"; then
    add_blocker "install smoke does not record a 64-character Package SHA256"
  fi
  grep -q 'Package status: `RIFT_ROAD_PACKAGE_AUDIT release-candidate`' "$INSTALL_SMOKE" || add_blocker "install smoke does not record a release-candidate package audit"
  grep -q 'Gatekeeper result: `accepted`' "$INSTALL_SMOKE" || add_blocker "install smoke does not record Gatekeeper acceptance"
  grep -q 'RIFT_ROAD_SECOND_MACHINE_INSTALL ok' "$INSTALL_SMOKE" || add_blocker "install smoke does not record RIFT_ROAD_SECOND_MACHINE_INSTALL ok"
fi

if [[ "${#blockers[@]}" -gt 0 ]]; then
  printf 'Second-machine evidence blockers:\n'
  for blocker in "${blockers[@]}"; do
    printf -- '- %s\n' "$blocker"
  done
  printf 'RIFT_ROAD_SECOND_MACHINE_EVIDENCE blocked evidence_dir=%s\n' "$EVIDENCE_DIR"
  exit 1
fi

printf 'RIFT_ROAD_SECOND_MACHINE_EVIDENCE ok evidence_dir=%s\n' "$EVIDENCE_DIR"
