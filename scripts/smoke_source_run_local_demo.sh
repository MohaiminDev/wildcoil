#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT_BIN="${GODOT_BIN:-godot}"
PROJECT_DIR="$ROOT_DIR/src/wildcoil"
DEFAULT_OUTPUT_DIR="$ROOT_DIR/docs/playtest-captures/source-run-demo-latest"
OUTPUT_DIR="${1:-"$DEFAULT_OUTPUT_DIR"}"
SMOKE_TIMEOUT_SECONDS="${RIFT_ROAD_SOURCE_RUN_SMOKE_TIMEOUT_SECONDS:-60}"

if [[ "$OUTPUT_DIR" != /* ]]; then
  OUTPUT_DIR="$ROOT_DIR/$OUTPUT_DIR"
fi

STAGED_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/rift-road-source-run-demo.XXXXXX")"
STAGED_CAPTURE_DIR="$STAGED_ROOT/captures"
LOG_PATH="$STAGED_ROOT/source-run-demo.log"

cleanup() {
  rm -rf "$STAGED_ROOT"
}
trap cleanup EXIT

required_captures=(
  "stage1-exported-app-smoke-title.png"
  "stage1-exported-app-smoke-hero-select.png"
  "stage1-exported-app-smoke-opening-story.png"
  "stage1-exported-app-smoke-gameplay.png"
  "stage1-exported-app-smoke-combat.png"
  "stage1-exported-app-smoke-pickups.png"
  "stage1-exported-app-smoke-road-collapse.png"
  "stage1-exported-app-smoke-brask-intro.png"
  "stage1-exported-app-smoke-stage-clear.png"
  "stage1-exported-app-smoke-game-over.png"
  "stage1-exported-app-smoke-retry-gameplay.png"
)

activate_source_smoke_window() {
  if [[ ! -x /usr/bin/osascript ]]; then
    return 0
  fi
  for _attempt in 1 2 3 4 5; do
    if /usr/bin/osascript -e 'tell application id "com.riftroad.afterglow" to activate' >/dev/null 2>&1; then
      return 0
    fi
    sleep 0.5
  done
  return 0
}

run_godot_smoke() {
  local log_path="$1"
  RIFT_ROAD_SMOKE_CAPTURE_DIR="$STAGED_CAPTURE_DIR" "$GODOT_BIN" \
    --path "$PROJECT_DIR" \
    -- \
    --rift-road-smoke-stage1 \
    --rift-road-smoke-capture-dir="$STAGED_CAPTURE_DIR" \
    > "$log_path" 2>&1 &
  local godot_pid=$!
  activate_source_smoke_window &
  local activation_pid=$!
  (
    sleep "$SMOKE_TIMEOUT_SECONDS"
    if kill -0 "$godot_pid" 2>/dev/null; then
      printf 'RIFT_ROAD_SOURCE_RUN_DEMO_SMOKE timeout seconds=%s\n' "$SMOKE_TIMEOUT_SECONDS" >> "$log_path"
      kill "$godot_pid" 2>/dev/null || true
    fi
  ) &
  local watchdog_pid=$!
  local godot_status=0
  if wait "$godot_pid"; then
    godot_status=0
  else
    godot_status=$?
  fi
  kill "$activation_pid" 2>/dev/null || true
  wait "$activation_pid" 2>/dev/null || true
  kill "$watchdog_pid" 2>/dev/null || true
  wait "$watchdog_pid" 2>/dev/null || true
  if grep -q "RIFT_ROAD_SOURCE_RUN_DEMO_SMOKE timeout" "$log_path"; then
    return 124
  fi
  return "$godot_status"
}

mkdir -p "$STAGED_CAPTURE_DIR"

bash "$ROOT_DIR/scripts/check_godot_version.sh"

if ! run_godot_smoke "$LOG_PATH"; then
  cat "$LOG_PATH"
  printf 'RIFT_ROAD_SOURCE_RUN_DEMO_SMOKE failed output_dir=%s\n' "$OUTPUT_DIR" >&2
  exit 1
fi

if ! grep -q "RIFT_ROAD_EXPORTED_APP_SMOKE_CAPTURE ok" "$LOG_PATH"; then
  cat "$LOG_PATH"
  printf 'RIFT_ROAD_SOURCE_RUN_DEMO_SMOKE failed missing_capture_marker output_dir=%s\n' "$OUTPUT_DIR" >&2
  exit 1
fi

for capture_name in "${required_captures[@]}"; do
  capture_path="$STAGED_CAPTURE_DIR/$capture_name"
  if [[ ! -s "$capture_path" ]]; then
    cat "$LOG_PATH"
    printf 'RIFT_ROAD_SOURCE_RUN_DEMO_SMOKE failed missing_capture=%s output_dir=%s\n' "$capture_name" "$OUTPUT_DIR" >&2
    exit 1
  fi
done

build_commit="$(git -C "$ROOT_DIR" rev-parse --short HEAD 2>/dev/null || printf 'unknown')"
source_state="unknown"
if git -C "$ROOT_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  if git_status="$(git -C "$ROOT_DIR" status --porcelain --untracked-files=normal 2>/dev/null)"; then
    source_state="clean"
    if [[ -n "$git_status" ]]; then
      source_state="dirty"
    fi
  fi
fi
capture_date="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

output_parent="$(dirname "$OUTPUT_DIR")"
mkdir -p "$output_parent"
publish_tmp="$(mktemp -d "$output_parent/.source-run-demo.XXXXXX")"

cp "$LOG_PATH" "$publish_tmp/source-run-demo.log"
cp "$STAGED_CAPTURE_DIR"/*.png "$publish_tmp/"

{
  printf '# Rift Road Source-Run Local Demo Smoke\n\n'
  printf 'This is automated local source-run viewport evidence from `src/wildcoil`. It is not public-playtest proof and does not require signing, notarization, Gatekeeper, or second-machine evidence.\n\n'
  printf -- '- Result: `RIFT_ROAD_SOURCE_RUN_DEMO_SMOKE ok`\n'
  printf -- '- Build: `commit=%s source_run=local source_state=%s`\n' "$build_commit" "$source_state"
  printf -- '- Captured at: `%s`\n' "$capture_date"
  printf -- '- Command: `bash scripts/smoke_source_run_local_demo.sh`\n'
  printf -- '- Project: `src/wildcoil`\n'
  printf -- '- Log: `source-run-demo.log`\n\n'
  printf '## Captures\n\n'
  for capture_name in "${required_captures[@]}"; do
    printf -- '- `%s`\n' "$capture_name"
  done
} > "$publish_tmp/manifest.md"

if [[ -d "$OUTPUT_DIR" ]]; then
  rm -rf "$OUTPUT_DIR.previous"
  mv "$OUTPUT_DIR" "$OUTPUT_DIR.previous"
fi
mv "$publish_tmp" "$OUTPUT_DIR"
rm -rf "$OUTPUT_DIR.previous"

printf 'RIFT_ROAD_SOURCE_RUN_DEMO_SMOKE ok output_dir=%s captures=%d\n' "$OUTPUT_DIR" "${#required_captures[@]}"
