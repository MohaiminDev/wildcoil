#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACKAGE_PATH="${1:-"$ROOT_DIR/build/macos/Rift Road.zip"}"
OUTPUT_DIR="${2:-"$ROOT_DIR/docs/playtest-captures/focus-resume-latest"}"
SMOKE_ARG="--rift-road-focus-resume-smoke"
OUTPUT_ARG_PREFIX="--rift-road-focus-resume-output="
CAPTURE_ARG_PREFIX="--rift-road-focus-resume-capture-dir="
OUTPUT_JSON=""
CAPTURE_PATH=""

for required_command in unzip open pgrep python3 sips awk; do
  if ! command -v "$required_command" >/dev/null 2>&1; then
    echo "ERROR: Missing required command: $required_command" >&2
    exit 1
  fi
done

PACKAGE_PATH="$(cd "$(dirname "$PACKAGE_PATH")" && pwd -P)/$(basename "$PACKAGE_PATH")"

if [[ ! -f "$PACKAGE_PATH" ]]; then
  echo "ERROR: Missing macOS package: $PACKAGE_PATH" >&2
  echo "Run: bash scripts/package_macos.sh" >&2
  exit 1
fi

mkdir -p "$OUTPUT_DIR"
OUTPUT_DIR="$(cd "$OUTPUT_DIR" && pwd -P)"
OUTPUT_JSON="$OUTPUT_DIR/stage1-exported-app-focus-resume.json"
CAPTURE_PATH="$OUTPUT_DIR/stage1-exported-app-focus-resume.png"
rm -f "$OUTPUT_JSON" "$CAPTURE_PATH"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/rift-road-exported-focus.XXXXXX")"
APP_PID=""

cleanup() {
  if [[ -n "$APP_PID" ]]; then
    kill "$APP_PID" >/dev/null 2>&1 || true
  fi
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

unzip -q "$PACKAGE_PATH" -d "$TMP_DIR"
APP_PATH="$(find "$TMP_DIR" -maxdepth 1 -type d -name "*.app" -print -quit)"

if [[ -z "$APP_PATH" ]]; then
  echo "ERROR: No .app bundle found in $PACKAGE_PATH" >&2
  exit 1
fi

APP_PATH="$(cd "$(dirname "$APP_PATH")" && pwd -P)/$(basename "$APP_PATH")"

wait_for_app_process() {
  for _attempt in {1..30}; do
    APP_PID="$(pgrep -f "$APP_PATH/Contents/MacOS" | awk 'NR == 1 {print $1}' || true)"
    if [[ -n "$APP_PID" ]]; then
      return 0
    fi
    sleep 0.5
  done

  echo "ERROR: Rift Road app process did not start from $APP_PATH" >&2
  exit 1
}

wait_for_artifacts() {
  for _attempt in {1..80}; do
    if [[ -s "$OUTPUT_JSON" && -s "$CAPTURE_PATH" ]]; then
      return 0
    fi
    sleep 0.5
  done

  echo "ERROR: Exported app did not write focus resume artifacts: $OUTPUT_JSON $CAPTURE_PATH" >&2
  exit 1
}

assert_capture_size() {
  local capture_path="$1"
  local width
  local height

  width="$(sips -g pixelWidth "$capture_path" 2>/dev/null | awk '/pixelWidth/ {print $2}')"
  height="$(sips -g pixelHeight "$capture_path" 2>/dev/null | awk '/pixelHeight/ {print $2}')"

  if [[ -z "$width" || -z "$height" || "$width" -lt 320 || "$height" -lt 240 ]]; then
    echo "ERROR: Capture is too small or unreadable: $capture_path (${width:-?}x${height:-?})" >&2
    exit 1
  fi
}

open -n "$APP_PATH" --args "$SMOKE_ARG" "${OUTPUT_ARG_PREFIX}${OUTPUT_JSON}" "${CAPTURE_ARG_PREFIX}${OUTPUT_DIR}"
wait_for_app_process
wait_for_artifacts
assert_capture_size "$CAPTURE_PATH"

python3 - "$OUTPUT_JSON" "$CAPTURE_PATH" <<'PY'
import json
import sys
from pathlib import Path

output_path = Path(sys.argv[1])
capture_path = Path(sys.argv[2])
payload = json.loads(output_path.read_text())
required = [
    "stage_started",
    "focus_pause",
    "overlay",
    "audio",
    "return_focus",
    "resume",
]
missing = [key for key in required if payload.get(key) is not True]
if missing:
    print(f"ERROR: Focus resume smoke checks failed: {', '.join(missing)}", file=sys.stderr)
    sys.exit(1)
if payload.get("capture") != str(capture_path):
    print(f"ERROR: Focus resume capture path mismatch: {payload.get('capture')} != {capture_path}", file=sys.stderr)
    sys.exit(1)
if payload.get("automated") is not True:
    print("ERROR: Focus resume payload must be labeled automated", file=sys.stderr)
    sys.exit(1)
PY

echo "RIFT_ROAD_EXPORTED_FOCUS_RESUME ok output=$OUTPUT_JSON capture=$CAPTURE_PATH"
