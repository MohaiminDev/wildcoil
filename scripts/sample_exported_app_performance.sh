#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACKAGE_PATH="${1:-"$ROOT_DIR/build/macos/Rift Road.zip"}"
OUTPUT_DIR="${2:-"$ROOT_DIR/docs/playtest-captures/exported-app-performance-latest"}"
PERF_ARG="--rift-road-render-perf-sample"
PERF_WINDOW_SIZE="${RIFT_ROAD_PERF_WINDOW_SIZE:-1280x720}"
PERF_WINDOW_MODE="${RIFT_ROAD_PERF_WINDOW_MODE:-windowed}"
APP_PID=""

for required_command in unzip open pgrep python3; do
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
OUTPUT_JSON="$OUTPUT_DIR/stage1-exported-performance.json"
OUTPUT_ARG="--rift-road-render-perf-output=$OUTPUT_JSON"
WINDOW_SIZE_ARG="--rift-road-render-perf-window-size=$PERF_WINDOW_SIZE"
WINDOW_MODE_ARG="--rift-road-render-perf-window-mode=$PERF_WINDOW_MODE"
rm -f "$OUTPUT_JSON"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/rift-road-exported-perf.XXXXXX")"

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

open -n "$APP_PATH" --args "$PERF_ARG" "$OUTPUT_ARG" "$WINDOW_SIZE_ARG" "$WINDOW_MODE_ARG"

for _attempt in {1..40}; do
  APP_PID="$(pgrep -f "$APP_PATH/Contents/MacOS" | awk 'NR == 1 {print $1}' || true)"
  if [[ -n "$APP_PID" ]]; then
    break
  fi
  sleep 0.5
done

if [[ -z "$APP_PID" ]]; then
  echo "ERROR: Rift Road app process did not start from $APP_PATH" >&2
  exit 1
fi

for _attempt in {1..80}; do
  if [[ -s "$OUTPUT_JSON" ]]; then
    break
  fi
  sleep 0.5
done

if [[ ! -s "$OUTPUT_JSON" ]]; then
  echo "ERROR: Exported app did not write performance output: $OUTPUT_JSON" >&2
  exit 1
fi

python3 - "$OUTPUT_JSON" <<'PY'
import json
import sys

path = sys.argv[1]
with open(path, "r", encoding="utf-8") as handle:
    data = json.load(handle)

frames = int(data["frames"])
avg_ms = float(data["avg_ms"])
max_ms = float(data["max_ms"])
budget_ms = float(data["budget_ms"])
max_budget_ms = float(data["max_budget_ms"])
window_size = str(data.get("window_size", "unknown"))
window_mode = str(data.get("window_mode", "unknown"))

if frames < 120:
    raise SystemExit(f"too few frames sampled: {frames}")
if avg_ms > budget_ms:
    raise SystemExit(f"average frame time {avg_ms:.3f} exceeds budget {budget_ms:.1f}")
if max_ms > max_budget_ms:
    raise SystemExit(f"max frame time {max_ms:.3f} exceeds max budget {max_budget_ms:.1f}")

print(
    "RIFT_ROAD_EXPORTED_PERF stage1 "
    f"frames={frames} avg_ms={avg_ms:.3f} max_ms={max_ms:.3f} "
    f"budget_ms={budget_ms:.1f} max_budget_ms={max_budget_ms:.1f} "
    f"window_size={window_size} window_mode={window_mode}"
)
PY
