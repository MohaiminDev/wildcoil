#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACKAGE_PATH="${1:-"$ROOT_DIR/build/macos/Rift Road.zip"}"
OUTPUT_DIR="${2:-"$ROOT_DIR/docs/playtest-captures/exported-app-smoke-latest"}"
SMOKE_ARG="--rift-road-smoke-stage1"
SMOKE_CAPTURE_ARG_PREFIX="--rift-road-smoke-capture-dir="
TITLE_CAPTURE=""
HERO_SELECT_CAPTURE=""
GAMEPLAY_CAPTURE=""
COMBAT_CAPTURE=""
PICKUP_CAPTURE=""
ROAD_COLLAPSE_CAPTURE=""
BRASK_INTRO_CAPTURE=""
STAGE_CLEAR_CAPTURE=""
GAME_OVER_CAPTURE=""
RETRY_GAMEPLAY_CAPTURE=""

for required_command in unzip open sips awk pgrep; do
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
TITLE_CAPTURE="$OUTPUT_DIR/stage1-exported-app-smoke-title.png"
HERO_SELECT_CAPTURE="$OUTPUT_DIR/stage1-exported-app-smoke-hero-select.png"
GAMEPLAY_CAPTURE="$OUTPUT_DIR/stage1-exported-app-smoke-gameplay.png"
COMBAT_CAPTURE="$OUTPUT_DIR/stage1-exported-app-smoke-combat.png"
PICKUP_CAPTURE="$OUTPUT_DIR/stage1-exported-app-smoke-pickups.png"
ROAD_COLLAPSE_CAPTURE="$OUTPUT_DIR/stage1-exported-app-smoke-road-collapse.png"
BRASK_INTRO_CAPTURE="$OUTPUT_DIR/stage1-exported-app-smoke-brask-intro.png"
STAGE_CLEAR_CAPTURE="$OUTPUT_DIR/stage1-exported-app-smoke-stage-clear.png"
GAME_OVER_CAPTURE="$OUTPUT_DIR/stage1-exported-app-smoke-game-over.png"
RETRY_GAMEPLAY_CAPTURE="$OUTPUT_DIR/stage1-exported-app-smoke-retry-gameplay.png"
SMOKE_CAPTURE_ARG="${SMOKE_CAPTURE_ARG_PREFIX}${OUTPUT_DIR}"
rm -f "$TITLE_CAPTURE" "$HERO_SELECT_CAPTURE" "$GAMEPLAY_CAPTURE" "$COMBAT_CAPTURE" "$PICKUP_CAPTURE" "$ROAD_COLLAPSE_CAPTURE" "$BRASK_INTRO_CAPTURE" "$STAGE_CLEAR_CAPTURE" "$GAME_OVER_CAPTURE" "$RETRY_GAMEPLAY_CAPTURE"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/rift-road-exported-smoke.XXXXXX")"
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

wait_for_captures() {
  for _attempt in {1..80}; do
    if [[ -s "$TITLE_CAPTURE" && -s "$HERO_SELECT_CAPTURE" && -s "$GAMEPLAY_CAPTURE" && -s "$COMBAT_CAPTURE" && -s "$PICKUP_CAPTURE" && -s "$ROAD_COLLAPSE_CAPTURE" && -s "$BRASK_INTRO_CAPTURE" && -s "$STAGE_CLEAR_CAPTURE" && -s "$GAME_OVER_CAPTURE" && -s "$RETRY_GAMEPLAY_CAPTURE" ]]; then
      return 0
    fi
    sleep 0.5
  done

  echo "ERROR: Exported app did not write smoke captures: $TITLE_CAPTURE $HERO_SELECT_CAPTURE $GAMEPLAY_CAPTURE $COMBAT_CAPTURE $PICKUP_CAPTURE $ROAD_COLLAPSE_CAPTURE $BRASK_INTRO_CAPTURE $STAGE_CLEAR_CAPTURE $GAME_OVER_CAPTURE $RETRY_GAMEPLAY_CAPTURE" >&2
  exit 1
}

launch_smoke_capture() {
  APP_PID=""
  open -n "$APP_PATH" --args "$SMOKE_ARG" "$SMOKE_CAPTURE_ARG"
  wait_for_app_process
}

launch_smoke_capture
wait_for_captures
assert_capture_size "$TITLE_CAPTURE"
assert_capture_size "$HERO_SELECT_CAPTURE"
assert_capture_size "$GAMEPLAY_CAPTURE"
assert_capture_size "$COMBAT_CAPTURE"
assert_capture_size "$PICKUP_CAPTURE"
assert_capture_size "$ROAD_COLLAPSE_CAPTURE"
assert_capture_size "$BRASK_INTRO_CAPTURE"
assert_capture_size "$STAGE_CLEAR_CAPTURE"
assert_capture_size "$GAME_OVER_CAPTURE"
assert_capture_size "$RETRY_GAMEPLAY_CAPTURE"

echo "RIFT_ROAD_EXPORTED_APP_SMOKE ok title_capture=$TITLE_CAPTURE hero_select_capture=$HERO_SELECT_CAPTURE gameplay_capture=$GAMEPLAY_CAPTURE combat_capture=$COMBAT_CAPTURE pickup_capture=$PICKUP_CAPTURE road_collapse_capture=$ROAD_COLLAPSE_CAPTURE brask_intro_capture=$BRASK_INTRO_CAPTURE stage_clear_capture=$STAGE_CLEAR_CAPTURE game_over_capture=$GAME_OVER_CAPTURE retry_gameplay_capture=$RETRY_GAMEPLAY_CAPTURE"
