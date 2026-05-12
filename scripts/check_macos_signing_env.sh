#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EXPORT_PRESET="$ROOT_DIR/src/wildcoil/export_presets.cfg"

blockers=()

add_blocker() {
  blockers+=("$1")
}

require_command() {
  local command_name="$1"
  if ! command -v "$command_name" >/dev/null 2>&1; then
    add_blocker "Missing command: $command_name"
  fi
}

require_env() {
  local variable_name="$1"
  if [[ -z "${!variable_name:-}" ]]; then
    add_blocker "Missing environment variable: $variable_name"
  else
    printf 'env: %s is set\n' "$variable_name"
  fi
}

require_command security
require_command xcrun
require_command codesign
require_command spctl
require_command stapler

require_env RIFT_ROAD_APPLE_TEAM_ID
require_env RIFT_ROAD_DEVELOPER_ID_APPLICATION
require_env RIFT_ROAD_NOTARY_KEYCHAIN_PROFILE

if command -v security >/dev/null 2>&1 && [[ -n "${RIFT_ROAD_DEVELOPER_ID_APPLICATION:-}" ]]; then
  if security find-identity -v -p codesigning 2>/dev/null | grep -F "$RIFT_ROAD_DEVELOPER_ID_APPLICATION" >/dev/null 2>&1; then
    printf 'codesign identity: Developer ID identity is available in the keychain\n'
  else
    add_blocker "Developer ID identity named by RIFT_ROAD_DEVELOPER_ID_APPLICATION was not found in the keychain"
  fi
fi

if command -v xcrun >/dev/null 2>&1; then
  if xcrun notarytool --help >/dev/null 2>&1; then
    printf 'notarytool: available\n'
  else
    add_blocker "xcrun notarytool is not available"
  fi
fi

if [[ ! -f "$EXPORT_PRESET" ]]; then
  add_blocker "Missing Godot export preset: $EXPORT_PRESET"
else
  if grep -q 'codesign/apple_team_id=""' "$EXPORT_PRESET"; then
    add_blocker "codesign/apple_team_id is empty in export_presets.cfg"
  fi
  if grep -q 'codesign/identity=""' "$EXPORT_PRESET"; then
    add_blocker "codesign/identity is empty in export_presets.cfg"
  fi
  if grep -q 'notarization/notarization=0' "$EXPORT_PRESET"; then
    add_blocker "notarization/notarization=0 in export_presets.cfg"
  fi
fi

if [[ "${#blockers[@]}" -gt 0 ]]; then
  printf 'Signing preflight blockers:\n'
  for blocker in "${blockers[@]}"; do
    printf -- '- %s\n' "$blocker"
  done
  printf 'RIFT_ROAD_SIGNING_PREFLIGHT blocked\n'
  exit 1
fi

printf 'RIFT_ROAD_SIGNING_PREFLIGHT ok\n'
