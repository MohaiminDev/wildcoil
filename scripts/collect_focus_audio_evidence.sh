#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEFAULT_EVIDENCE_DIR="$ROOT_DIR/docs/playtest-captures/focus-audio"
PACKAGE_PATH="$ROOT_DIR/build/macos/Rift Road.zip"

usage() {
  cat <<'EOF'
Usage:
  bash scripts/collect_focus_audio_evidence.sh \
    --output-device "Built-in speakers" \
    --blockers "none" \
    --confirm-focus-pause-overlay \
    --confirm-audio-before-focus-loss \
    --confirm-audio-quiet-during-focus-pause \
    --confirm-audio-after-resume \
    --confirm-resume-control

This is a manual evidence collector. Run it only after a human confirms real
audible output from the exported macOS app, then paste the generated snippet
into docs/focus_audio_validation.md and run:

  bash scripts/check_focus_audio_evidence.sh

Options:
  --output-device VALUE                      Required; real output device used.
  --blockers VALUE                           Required; use "none" only when true.
  --evidence-dir PATH                        Optional; default docs/playtest-captures/focus-audio.
  --build VALUE                              Optional; defaults to current commit and package SHA-256.
  --session-label VALUE                      Optional label used in the generated heading.
  --confirm-focus-pause-overlay              Confirm focus loss showed the pause overlay.
  --confirm-audio-before-focus-loss          Confirm audio was audible before focus loss.
  --confirm-audio-quiet-during-focus-pause   Confirm audio quieted/suspended while focus-paused.
  --confirm-audio-after-resume               Confirm audio returned after resume.
  --confirm-resume-control                   Confirm the player could resume control.
EOF
}

output_device=""
blockers_note=""
evidence_dir="$DEFAULT_EVIDENCE_DIR"
build_value=""
session_label=""

confirm_focus_pause_overlay=0
confirm_audio_before_focus_loss=0
confirm_audio_quiet_during_focus_pause=0
confirm_audio_after_resume=0
confirm_resume_control=0

parse_value() {
  local option_name="$1"
  local option_value="${2:-}"
  if [[ -z "$option_value" || "$option_value" == --* ]]; then
    printf 'ERROR: %s requires a value\n' "$option_name" >&2
    exit 2
  fi
  printf '%s' "$option_value"
}

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --help|-h)
      usage
      exit 0
      ;;
    --output-device)
      output_device="$(parse_value "$1" "${2:-}")"
      shift 2
      ;;
    --blockers)
      blockers_note="$(parse_value "$1" "${2:-}")"
      shift 2
      ;;
    --evidence-dir)
      evidence_dir="$(parse_value "$1" "${2:-}")"
      shift 2
      ;;
    --build)
      build_value="$(parse_value "$1" "${2:-}")"
      shift 2
      ;;
    --session-label)
      session_label="$(parse_value "$1" "${2:-}")"
      shift 2
      ;;
    --confirm-focus-pause-overlay)
      confirm_focus_pause_overlay=1
      shift
      ;;
    --confirm-audio-before-focus-loss)
      confirm_audio_before_focus_loss=1
      shift
      ;;
    --confirm-audio-quiet-during-focus-pause)
      confirm_audio_quiet_during_focus_pause=1
      shift
      ;;
    --confirm-audio-after-resume)
      confirm_audio_after_resume=1
      shift
      ;;
    --confirm-resume-control)
      confirm_resume_control=1
      shift
      ;;
    *)
      printf 'ERROR: Unknown option: %s\n' "$1" >&2
      exit 2
      ;;
  esac
done

collector_blockers=()

add_blocker() {
  collector_blockers+=("$1")
}

require_confirmation() {
  local option_name="$1"
  local confirmed="$2"
  if [[ "$confirmed" != "1" ]]; then
    add_blocker "Missing confirmation: $option_name"
  fi
}

if [[ -z "$output_device" ]]; then
  add_blocker "Missing --output-device"
fi

if [[ -z "$blockers_note" ]]; then
  add_blocker "Missing --blockers note; use \"none\" only when true"
fi

require_confirmation "--confirm-focus-pause-overlay" "$confirm_focus_pause_overlay"
require_confirmation "--confirm-audio-before-focus-loss" "$confirm_audio_before_focus_loss"
require_confirmation "--confirm-audio-quiet-during-focus-pause" "$confirm_audio_quiet_during_focus_pause"
require_confirmation "--confirm-audio-after-resume" "$confirm_audio_after_resume"
require_confirmation "--confirm-resume-control" "$confirm_resume_control"

if [[ ! -f "$PACKAGE_PATH" ]]; then
  add_blocker "Package not found: $PACKAGE_PATH"
fi

if [[ "${#collector_blockers[@]}" -gt 0 ]]; then
  printf 'Focus/audio evidence collector blockers:\n'
  for blocker in "${collector_blockers[@]}"; do
    printf -- '- %s\n' "$blocker"
  done
  printf 'RIFT_ROAD_FOCUS_AUDIO_COLLECTOR blocked\n'
  exit 1
fi

build_commit="$(git -C "$ROOT_DIR" rev-parse --short HEAD 2>/dev/null || printf 'unknown')"
package_sha256="$(shasum -a 256 "$PACKAGE_PATH" | awk '{print $1}')"
if [[ -z "$build_value" ]]; then
  build_value="commit=${build_commit} package_sha256=${package_sha256}"
fi

slugify() {
  printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//'
}

timestamp="$(date -u +"%Y%m%d-%H%M%S")"
device_slug="$(slugify "$output_device")"
[[ -n "$device_slug" ]] || device_slug="audio-output"
evidence_path="$evidence_dir/${timestamp}-focus-audio-${device_slug}.md"
snippet_path="$evidence_dir/${timestamp}-focus-audio-${device_slug}-focus-audio-validation-snippet.md"
mkdir -p "$evidence_dir"

if [[ "$evidence_path" == "$ROOT_DIR/"* ]]; then
  evidence_ref="${evidence_path#"$ROOT_DIR/"}"
else
  evidence_ref="$evidence_path"
fi

if [[ -z "$session_label" ]]; then
  session_label="${output_device} - ${timestamp}"
fi

{
  printf '# Rift Road Focus Audio Evidence\n\n'
  printf '## Manual Session\n\n'
  printf -- '- Build: `%s`\n' "$build_value"
  printf -- '- Output device: `%s`\n' "$output_device"
  printf -- '- Focus pause overlay: `pass`\n'
  printf -- '- Audio before focus loss: `pass`\n'
  printf -- '- Audio quiet during focus pause: `pass`\n'
  printf -- '- Audio after resume: `pass`\n'
  printf -- '- Resume control: `pass`\n'
  printf -- '- Blockers: `%s`\n\n' "$blockers_note"
  printf '## Next Step\n\n'
  printf 'Paste the generated snippet into `docs/focus_audio_validation.md`, then run `bash scripts/check_focus_audio_evidence.sh`.\n'
} > "$evidence_path"

{
  printf '### Focus Audio Session: `%s`\n\n' "$session_label"
  printf 'RIFT_ROAD_FOCUS_AUDIO_SESSION ok\n\n'
  printf -- '- Build: `%s`\n' "$build_value"
  printf -- '- Output device: `%s`\n' "$output_device"
  printf -- '- Evidence capture: `%s`\n' "$evidence_ref"
  printf -- '- Focus pause overlay: `pass`\n'
  printf -- '- Audio before focus loss: `pass`\n'
  printf -- '- Audio quiet during focus pause: `pass`\n'
  printf -- '- Audio after resume: `pass`\n'
  printf -- '- Resume control: `pass`\n'
  printf -- '- Blockers: `%s`\n' "$blockers_note"
} > "$snippet_path"

printf 'Evidence note: %s\n' "$evidence_path"
printf 'Focus/audio validation snippet: %s\n' "$snippet_path"
printf 'Paste snippet into docs/focus_audio_validation.md, then run: bash scripts/check_focus_audio_evidence.sh\n'
printf 'RIFT_ROAD_FOCUS_AUDIO_COLLECTOR ok evidence=%s snippet=%s\n' "$evidence_path" "$snippet_path"
