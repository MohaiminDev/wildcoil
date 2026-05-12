#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEFAULT_INPUT_ZIP="${ROOT_DIR}/build/macos/Rift Road.zip"
DEFAULT_OUTPUT_ZIP="${ROOT_DIR}/build/macos/Rift Road-signed-notarized.zip"

usage() {
  cat <<EOF
Usage: bash scripts/sign_notarize_macos.sh [input_zip] [output_zip]

Signs, notarizes, staples, Gatekeeper-checks, and audits a macOS Rift Road app zip.

Defaults:
  input_zip:  ${DEFAULT_INPUT_ZIP}
  output_zip: ${DEFAULT_OUTPUT_ZIP}

Required environment variables:
  RIFT_ROAD_APPLE_TEAM_ID
  RIFT_ROAD_DEVELOPER_ID_APPLICATION
  RIFT_ROAD_NOTARY_KEYCHAIN_PROFILE

Prepare local values with docs/macos_release_inputs.example.env. Do not commit real
Apple account, certificate, keychain-profile, or notary credentials.
EOF
}

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  usage
  exit 0
fi

INPUT_ZIP="${1:-${DEFAULT_INPUT_ZIP}}"
OUTPUT_ZIP="${2:-${DEFAULT_OUTPUT_ZIP}}"

blockers=()

add_blocker() {
  blockers+=("$1")
}

require_command() {
  local command_name="$1"
  if ! command -v "$command_name" >/dev/null 2>&1; then
    add_blocker "Missing command: ${command_name}"
  fi
}

require_env() {
  local variable_name="$1"
  if [[ -z "${!variable_name:-}" ]]; then
    add_blocker "Missing environment variable: ${variable_name}"
  else
    printf 'env: %s is set\n' "${variable_name}"
  fi
}

require_command ditto
require_command codesign
require_command security
require_command spctl
require_command stapler
require_command xcrun

require_env RIFT_ROAD_APPLE_TEAM_ID
require_env RIFT_ROAD_DEVELOPER_ID_APPLICATION
require_env RIFT_ROAD_NOTARY_KEYCHAIN_PROFILE

if command -v security >/dev/null 2>&1 && [[ -n "${RIFT_ROAD_DEVELOPER_ID_APPLICATION:-}" ]]; then
  if security find-identity -v -p codesigning 2>/dev/null | grep -F "${RIFT_ROAD_DEVELOPER_ID_APPLICATION}" >/dev/null 2>&1; then
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

if [[ ! -f "${INPUT_ZIP}" ]]; then
  add_blocker "Input package not found: ${INPUT_ZIP}"
fi

if [[ "${#blockers[@]}" -gt 0 ]]; then
  printf 'Release signing blockers:\n'
  for blocker in "${blockers[@]}"; do
    printf -- '- %s\n' "${blocker}"
  done
  printf 'RIFT_ROAD_RELEASE_SIGNING blocked\n'
  exit 1
fi

output_dir="$(dirname "${OUTPUT_ZIP}")"
mkdir -p "${output_dir}"

tmp_dir="$(mktemp -d)"
trap 'rm -rf "${tmp_dir}"' EXIT

extract_dir="${tmp_dir}/extract"
notary_zip="${tmp_dir}/Rift Road-notary-submit.zip"
mkdir -p "${extract_dir}"

ditto -x -k "${INPUT_ZIP}" "${extract_dir}"

app_path="$(find "${extract_dir}" -maxdepth 1 -type d -name '*.app' | head -n 1)"
if [[ -z "${app_path}" ]]; then
  printf 'ERROR: No .app bundle found in %s\n' "${INPUT_ZIP}" >&2
  exit 1
fi

printf 'Signing app: %s\n' "${app_path}"
codesign --force --deep --options runtime --timestamp --sign "${RIFT_ROAD_DEVELOPER_ID_APPLICATION}" "${app_path}"
codesign --verify --deep --strict --verbose=2 "${app_path}"

printf 'Creating notarization submission: %s\n' "${notary_zip}"
ditto -c -k --keepParent "${app_path}" "${notary_zip}"

printf 'Submitting notarization request\n'
xcrun notarytool submit "${notary_zip}" --keychain-profile "${RIFT_ROAD_NOTARY_KEYCHAIN_PROFILE}" --team-id "${RIFT_ROAD_APPLE_TEAM_ID}" --wait

printf 'Stapling notarization ticket\n'
stapler staple "${app_path}"
stapler validate "${app_path}"

printf 'Checking Gatekeeper acceptance\n'
spctl -a -vv --type execute "${app_path}"

printf 'Creating signed and notarized zip: %s\n' "${OUTPUT_ZIP}"
ditto -c -k --keepParent "${app_path}" "${OUTPUT_ZIP}"

RIFT_ROAD_AUDIT_ARTIFACT_ONLY=1 "${ROOT_DIR}/scripts/audit_macos_package.sh" "${OUTPUT_ZIP}"

printf 'RIFT_ROAD_RELEASE_SIGNING ok output=%s\n' "${OUTPUT_ZIP}"
