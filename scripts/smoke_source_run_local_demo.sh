#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT_BIN="${GODOT_BIN:-godot}"
PROJECT_DIR="$ROOT_DIR/src/wildcoil"
DEFAULT_OUTPUT_DIR="$ROOT_DIR/docs/playtest-captures/source-run-demo-latest"
OUTPUT_DIR="${1:-"$DEFAULT_OUTPUT_DIR"}"

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

mkdir -p "$STAGED_CAPTURE_DIR"

bash "$ROOT_DIR/scripts/check_godot_version.sh"

if ! "$GODOT_BIN" \
  --path "$PROJECT_DIR" \
  -- \
  --rift-road-smoke-stage1 \
  --rift-road-smoke-capture-dir="$STAGED_CAPTURE_DIR" \
  > "$LOG_PATH" 2>&1; then
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

output_parent="$(dirname "$OUTPUT_DIR")"
mkdir -p "$output_parent"
publish_tmp="$(mktemp -d "$output_parent/.source-run-demo.XXXXXX")"

cp "$LOG_PATH" "$publish_tmp/source-run-demo.log"
cp "$STAGED_CAPTURE_DIR"/*.png "$publish_tmp/"

build_commit="$(git -C "$ROOT_DIR" rev-parse --short HEAD 2>/dev/null || printf 'unknown')"
capture_date="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

{
  printf '# Rift Road Source-Run Local Demo Smoke\n\n'
  printf 'This is automated local source-run viewport evidence from `src/wildcoil`. It is not public-playtest proof and does not require signing, notarization, Gatekeeper, or second-machine evidence.\n\n'
  printf -- '- Result: `RIFT_ROAD_SOURCE_RUN_DEMO_SMOKE ok`\n'
  printf -- '- Build: `commit=%s source_run=local`\n' "$build_commit"
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
