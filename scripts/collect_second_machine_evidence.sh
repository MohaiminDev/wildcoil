#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPTS_DIR="$ROOT_DIR/scripts"

usage() {
  cat <<'USAGE'
Usage:
  RIFT_ROAD_SECOND_MACHINE_LABEL="Apple Silicon Mac B" bash scripts/collect_second_machine_evidence.sh [package_zip] [output_dir]

Collect second-machine evidence for Rift Road on a real second Apple Silicon Mac.

Defaults:
  package_zip: build/macos/Rift Road-signed-notarized.zip when present,
               otherwise build/macos/Rift Road.zip, or the matching zip
               inside a known-tester packet
  output_dir:  docs/playtest-captures/second-machine-latest

The collector writes:
  host-profile.md
  install-smoke.md
  package-audit.log
  stage1-second-machine-title.png
  stage1-second-machine-gameplay.png

It only writes RIFT_ROAD_SECOND_MACHINE_INSTALL ok when the package audit reports
RIFT_ROAD_PACKAGE_AUDIT release-candidate, Gatekeeper accepts the app, and the
launched exported-app smoke captures title and gameplay images. The generated
host profile and install smoke record the package SHA-256 for the exact zip.
The second-machine evidence gate only accepts signed/notarized package-source
proof; the unsigned fallback is internal-only handoff evidence.
USAGE
}

if [[ "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

MACHINE_LABEL="${RIFT_ROAD_SECOND_MACHINE_LABEL:-}"
if [[ "$MACHINE_LABEL" != "Apple Silicon Mac B" ]]; then
  echo 'ERROR: Set RIFT_ROAD_SECOND_MACHINE_LABEL="Apple Silicon Mac B" on the real second Apple Silicon Mac.' >&2
  exit 1
fi

PACKAGE_PATH="${1:-}"
if [[ -z "$PACKAGE_PATH" ]]; then
  if [[ -f "$ROOT_DIR/build/macos/Rift Road-signed-notarized.zip" ]]; then
    PACKAGE_PATH="$ROOT_DIR/build/macos/Rift Road-signed-notarized.zip"
  elif [[ -f "$ROOT_DIR/build/macos/Rift Road.zip" ]]; then
    PACKAGE_PATH="$ROOT_DIR/build/macos/Rift Road.zip"
  elif [[ -f "$ROOT_DIR/Rift Road-signed-notarized.zip" ]]; then
    PACKAGE_PATH="$ROOT_DIR/Rift Road-signed-notarized.zip"
  elif [[ -f "$ROOT_DIR/Rift Road.zip" ]]; then
    PACKAGE_PATH="$ROOT_DIR/Rift Road.zip"
  else
    PACKAGE_PATH="$ROOT_DIR/build/macos/Rift Road.zip"
  fi
fi
OUTPUT_DIR="${2:-"$ROOT_DIR/docs/playtest-captures/second-machine-latest"}"

for required_command in awk bash cp mkdir shasum sw_vers sysctl uname; do
  if ! command -v "$required_command" >/dev/null 2>&1; then
    echo "ERROR: Missing required command: $required_command" >&2
    exit 1
  fi
done

if [[ ! -f "$PACKAGE_PATH" ]]; then
  echo "ERROR: Missing macOS package: $PACKAGE_PATH" >&2
  exit 1
fi

if [[ ! -x "$SCRIPTS_DIR/audit_macos_package.sh" ]]; then
  echo "ERROR: Missing scripts/audit_macos_package.sh" >&2
  exit 1
fi

if [[ ! -x "$SCRIPTS_DIR/smoke_exported_macos_app.sh" ]]; then
  echo "ERROR: Missing scripts/smoke_exported_macos_app.sh" >&2
  exit 1
fi

PACKAGE_PATH="$(cd "$(dirname "$PACKAGE_PATH")" && pwd -P)/$(basename "$PACKAGE_PATH")"
PACKAGE_SOURCE="build/macos/$(basename "$PACKAGE_PATH")"
mkdir -p "$OUTPUT_DIR"
OUTPUT_DIR="$(cd "$OUTPUT_DIR" && pwd -P)"

HOST_PROFILE="$OUTPUT_DIR/host-profile.md"
INSTALL_SMOKE="$OUTPUT_DIR/install-smoke.md"
AUDIT_LOG="$OUTPUT_DIR/package-audit.log"
SMOKE_LOG="$OUTPUT_DIR/exported-app-smoke.log"
SMOKE_DIR="$OUTPUT_DIR/app-smoke"
TITLE_CAPTURE="$OUTPUT_DIR/stage1-second-machine-title.png"
GAMEPLAY_CAPTURE="$OUTPUT_DIR/stage1-second-machine-gameplay.png"

architecture="$(uname -m)"
cpu="$(sysctl -n machdep.cpu.brand_string 2>/dev/null || printf 'unknown')"
model="$(sysctl -n hw.model 2>/dev/null || printf 'unknown')"
memory_bytes="$(sysctl -n hw.memsize 2>/dev/null || printf '0')"
memory_gb="$(awk -v bytes="$memory_bytes" 'BEGIN { if (bytes > 0) printf "%.0f GB", bytes / 1024 / 1024 / 1024; else printf "unknown" }')"
macos_version="$(sw_vers -productVersion 2>/dev/null || printf 'unknown')"
build_version="$(sw_vers -buildVersion 2>/dev/null || printf 'unknown')"
package_sha256="$(shasum -a 256 "$PACKAGE_PATH" | awk '{print $1}')"

{
  printf '# Second-Machine Host Profile\n\n'
  printf -- '- Machine label: `%s`\n' "$MACHINE_LABEL"
  printf -- '- Architecture: `%s`\n' "$architecture"
  printf -- '- CPU: `%s`\n' "$cpu"
  printf -- '- Model: `%s`\n' "$model"
  printf -- '- Memory: `%s`\n' "$memory_gb"
  printf -- '- macOS: `%s`\n' "$macos_version"
  printf -- '- Build: `%s`\n' "$build_version"
  printf -- '- Package SHA256: `%s`\n' "$package_sha256"
} > "$HOST_PROFILE"

set +e
bash "$SCRIPTS_DIR/audit_macos_package.sh" "$PACKAGE_PATH" > "$AUDIT_LOG" 2>&1
audit_status_code="$?"
set -e

package_status="$(awk '/RIFT_ROAD_PACKAGE_AUDIT/ {print $2}' "$AUDIT_LOG" | tail -n 1)"
if [[ -z "$package_status" ]]; then
  package_status="audit-failed"
fi

gatekeeper_result="rejected"
if grep -q 'spctl: Gatekeeper assessment accepted' "$AUDIT_LOG"; then
  gatekeeper_result="accepted"
fi

rm -f "$TITLE_CAPTURE" "$GAMEPLAY_CAPTURE"
set +e
bash "$SCRIPTS_DIR/smoke_exported_macos_app.sh" "$PACKAGE_PATH" "$SMOKE_DIR" > "$SMOKE_LOG" 2>&1
smoke_status_code="$?"
set -e

if [[ "$smoke_status_code" -eq 0 ]]; then
  cp "$SMOKE_DIR/stage1-exported-app-smoke-title.png" "$TITLE_CAPTURE"
  cp "$SMOKE_DIR/stage1-exported-app-smoke-gameplay.png" "$GAMEPLAY_CAPTURE"
fi

host_architecture_ok=false
if [[ "$architecture" == "arm64" ]]; then
  host_architecture_ok=true
fi

install_ok=false
if [[ "$host_architecture_ok" == true && "$audit_status_code" -eq 0 && "$package_status" == "release-candidate" && "$gatekeeper_result" == "accepted" && "$smoke_status_code" -eq 0 && -s "$TITLE_CAPTURE" && -s "$GAMEPLAY_CAPTURE" ]]; then
  install_ok=true
fi

{
  printf '# Second-Machine Install Smoke\n\n'
  printf -- '- Package source: `%s`\n' "$PACKAGE_SOURCE"
  printf -- '- Package path: `%s`\n' "$PACKAGE_PATH"
  printf -- '- Package SHA256: `%s`\n' "$package_sha256"
  printf -- '- Package status: `RIFT_ROAD_PACKAGE_AUDIT %s`\n' "$package_status"
  printf -- '- Gatekeeper result: `%s`\n' "$gatekeeper_result"
  printf -- '- Install method: `scripts/collect_second_machine_evidence.sh`\n'
  printf -- '- Launch path: `scripts/smoke_exported_macos_app.sh`\n'
  printf -- '- Input checked: `keyboard smoke`\n'
  printf -- '- Title capture: `stage1-second-machine-title.png`\n'
  printf -- '- Gameplay capture: `stage1-second-machine-gameplay.png`\n'
  printf -- '- Notes: `See package-audit.log and exported-app-smoke.log`\n\n'
  if [[ "$install_ok" == true ]]; then
    printf 'RIFT_ROAD_SECOND_MACHINE_INSTALL ok\n'
  else
    printf 'RIFT_ROAD_SECOND_MACHINE_INSTALL blocked\n'
  fi
} > "$INSTALL_SMOKE"

if [[ "$install_ok" == true ]]; then
  printf 'RIFT_ROAD_SECOND_MACHINE_COLLECTOR ok evidence_dir=%s\n' "$OUTPUT_DIR"
  exit 0
fi

printf 'RIFT_ROAD_SECOND_MACHINE_COLLECTOR blocked evidence_dir=%s architecture=%s package_status=%s gatekeeper=%s smoke_status=%s\n' "$OUTPUT_DIR" "$architecture" "$package_status" "$gatekeeper_result" "$smoke_status_code"
exit 1
