#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ZIP_PATH="${1:-${ROOT_DIR}/build/macos/Rift Road.zip}"
EXPORT_PRESET="${ROOT_DIR}/src/wildcoil/export_presets.cfg"
ARTIFACT_ONLY="${RIFT_ROAD_AUDIT_ARTIFACT_ONLY:-0}"

status="release-candidate"

warn() {
  status="internal-only"
  printf 'WARN: %s\n' "$1"
}

fail() {
  printf 'ERROR: %s\n' "$1" >&2
  exit 1
}

command -v ditto >/dev/null 2>&1 || fail "ditto is required to inspect the package"
command -v plutil >/dev/null 2>&1 || fail "plutil is required to inspect app metadata"
command -v codesign >/dev/null 2>&1 || fail "codesign is required for macOS package audit"
command -v spctl >/dev/null 2>&1 || warn "spctl is missing; Gatekeeper assessment cannot run"
command -v stapler >/dev/null 2>&1 || warn "stapler is missing; notarization ticket cannot be checked"

[[ -f "${ZIP_PATH}" ]] || fail "Package not found: ${ZIP_PATH}"

tmp_dir="$(mktemp -d)"
trap 'rm -rf "${tmp_dir}"' EXIT

ditto -x -k "${ZIP_PATH}" "${tmp_dir}"

app_path="$(find "${tmp_dir}" -maxdepth 1 -type d -name '*.app' | head -n 1)"
[[ -n "${app_path}" ]] || fail "No .app bundle found in ${ZIP_PATH}"

info_plist="${app_path}/Contents/Info.plist"
[[ -f "${info_plist}" ]] || fail "Missing Info.plist in app bundle"

bundle_id="$(plutil -extract CFBundleIdentifier raw -o - "${info_plist}" 2>/dev/null || true)"
bundle_name="$(plutil -extract CFBundleName raw -o - "${info_plist}" 2>/dev/null || true)"
bundle_version="$(plutil -extract CFBundleShortVersionString raw -o - "${info_plist}" 2>/dev/null || true)"
executable="$(plutil -extract CFBundleExecutable raw -o - "${info_plist}" 2>/dev/null || true)"

[[ "${bundle_id}" == "com.riftroad.afterglow" ]] || fail "Unexpected bundle id: ${bundle_id:-missing}"
[[ -n "${bundle_name}" ]] || fail "Missing bundle name"
[[ -n "${bundle_version}" ]] || fail "Missing bundle version"
[[ -n "${executable}" ]] || fail "Missing bundle executable"
[[ -x "${app_path}/Contents/MacOS/${executable}" ]] || fail "Bundle executable is missing or not executable"

printf 'Package: %s\n' "${ZIP_PATH}"
printf 'Bundle: %s %s (%s)\n' "${bundle_name}" "${bundle_version}" "${bundle_id}"

if codesign --verify --deep --strict --verbose=2 "${app_path}" >/dev/null 2>&1; then
  printf 'codesign: bundle signature verifies\n'
else
  warn "codesign verification failed"
fi

codesign_details="$(codesign -dv --verbose=4 "${app_path}" 2>&1 || true)"
if printf '%s\n' "${codesign_details}" | grep -q '^Authority='; then
  printf 'codesign: signing authority present\n'
else
  warn "codesign has no Developer ID authority; package is internal-only"
fi

if [[ "${ARTIFACT_ONLY}" == "1" ]]; then
  printf 'audit: artifact-only mode; skipping Godot export preset signing/notarization checks\n'
elif [[ -f "${EXPORT_PRESET}" ]]; then
  if grep -q 'codesign/apple_team_id=""' "${EXPORT_PRESET}"; then
    warn "Apple Team ID is empty in export preset"
  fi
  if grep -q 'codesign/identity=""' "${EXPORT_PRESET}"; then
    warn "Developer ID signing identity is empty in export preset"
  fi
  if grep -q 'notarization/notarization=0' "${EXPORT_PRESET}"; then
    warn "notarization is disabled in export preset"
  fi
fi

if command -v spctl >/dev/null 2>&1; then
  if spctl -a -vv --type execute "${app_path}" >/dev/null 2>&1; then
    printf 'spctl: Gatekeeper assessment accepted\n'
  else
    warn "spctl Gatekeeper assessment did not accept the app"
  fi
fi

if command -v stapler >/dev/null 2>&1; then
  if stapler validate "${app_path}" >/dev/null 2>&1; then
    printf 'stapler: notarization ticket validates\n'
  else
    warn "stapler did not validate a notarization ticket"
  fi
fi

printf 'RIFT_ROAD_PACKAGE_AUDIT %s\n' "${status}"
