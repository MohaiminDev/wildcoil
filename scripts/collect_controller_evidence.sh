#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEFAULT_EVIDENCE_DIR="$ROOT_DIR/docs/playtest-captures/controller"
SIGNED_PACKAGE_PATH="$ROOT_DIR/build/macos/Rift Road-signed-notarized.zip"
UNSIGNED_PACKAGE_PATH="$ROOT_DIR/build/macos/Rift Road.zip"
PACKET_SIGNED_PACKAGE_PATH="$ROOT_DIR/Rift Road-signed-notarized.zip"
PACKET_UNSIGNED_PACKAGE_PATH="$ROOT_DIR/Rift Road.zip"
PACKAGE_PATH="${RIFT_ROAD_PACKAGE_PATH:-}"
if [[ -z "$PACKAGE_PATH" ]]; then
  if [[ -f "$SIGNED_PACKAGE_PATH" ]]; then
    PACKAGE_PATH="$SIGNED_PACKAGE_PATH"
  elif [[ -f "$UNSIGNED_PACKAGE_PATH" ]]; then
    PACKAGE_PATH="$UNSIGNED_PACKAGE_PATH"
  elif [[ -f "$PACKET_SIGNED_PACKAGE_PATH" ]]; then
    PACKAGE_PATH="$PACKET_SIGNED_PACKAGE_PATH"
  elif [[ -f "$PACKET_UNSIGNED_PACKAGE_PATH" ]]; then
    PACKAGE_PATH="$PACKET_UNSIGNED_PACKAGE_PATH"
  else
    PACKAGE_PATH="$UNSIGNED_PACKAGE_PATH"
  fi
fi

usage() {
  cat <<'EOF'
Usage:
  bash scripts/collect_controller_evidence.sh --session-type controller \
    --controller-family "xbox" \
    --device-name "Xbox Wireless Controller" \
    --connection "Bluetooth" \
    --blockers "none" \
    --confirm-title --confirm-hero-select --confirm-movement \
    --confirm-attack --confirm-jump --confirm-special-ready \
    --confirm-special --confirm-dash --confirm-pause --confirm-cancel-back

  bash scripts/collect_controller_evidence.sh --session-type keyboard \
    --blockers "none" \
    --confirm-title --confirm-hero-select --confirm-movement \
    --confirm-attack --confirm-jump --confirm-special-ready \
    --confirm-special --confirm-dash --confirm-pause --confirm-cancel-back

This is a manual evidence collector. Run it only after a real exported-app
session, then paste the generated snippet into docs/controller_validation.md
and run:

  bash scripts/check_controller_evidence.sh

Options:
  --session-type controller|keyboard  Required.
  --controller-family VALUE           Required for controller sessions.
  --device-name VALUE                 Required for controller sessions.
  --connection VALUE                  Required for controller sessions.
  --blockers VALUE                    Required; use "none" only when true.
  --evidence-dir PATH                 Optional; default docs/playtest-captures/controller.
  --build VALUE                       Optional; defaults to current commit and package SHA-256.
  --session-label VALUE               Optional label used in the generated heading.
  --confirm-title                     Confirm title input worked.
  --confirm-hero-select               Confirm hero select input worked.
  --confirm-movement                  Confirm Stage 1 movement worked.
  --confirm-attack                    Confirm attack worked.
  --confirm-jump                      Confirm jump worked.
  --confirm-special-ready             Confirm luma/special meter was ready before testing special.
  --confirm-special                   Confirm special worked.
  --confirm-dash                      Confirm dash worked.
  --confirm-pause                     Confirm pause worked.
  --confirm-cancel-back               Confirm cancel/back worked.

Package default:
  Uses RIFT_ROAD_PACKAGE_PATH when set. Otherwise prefers
  build/macos/Rift Road-signed-notarized.zip or ./Rift Road-signed-notarized.zip
  when present, then falls back to the unsigned Rift Road.zip.
EOF
}

session_type=""
controller_family=""
device_name=""
connection=""
blockers_note=""
evidence_dir="$DEFAULT_EVIDENCE_DIR"
build_value=""
session_label=""

confirm_title=0
confirm_hero_select=0
confirm_movement=0
confirm_attack=0
confirm_jump=0
confirm_special_ready=0
confirm_special=0
confirm_dash=0
confirm_pause=0
confirm_cancel_back=0

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
    --session-type)
      session_type="$(parse_value "$1" "${2:-}")"
      shift 2
      ;;
    --controller-family)
      controller_family="$(parse_value "$1" "${2:-}")"
      shift 2
      ;;
    --device-name)
      device_name="$(parse_value "$1" "${2:-}")"
      shift 2
      ;;
    --connection)
      connection="$(parse_value "$1" "${2:-}")"
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
    --confirm-title)
      confirm_title=1
      shift
      ;;
    --confirm-hero-select)
      confirm_hero_select=1
      shift
      ;;
    --confirm-movement)
      confirm_movement=1
      shift
      ;;
    --confirm-attack)
      confirm_attack=1
      shift
      ;;
    --confirm-jump)
      confirm_jump=1
      shift
      ;;
    --confirm-special-ready)
      confirm_special_ready=1
      shift
      ;;
    --confirm-special)
      confirm_special=1
      shift
      ;;
    --confirm-dash)
      confirm_dash=1
      shift
      ;;
    --confirm-pause)
      confirm_pause=1
      shift
      ;;
    --confirm-cancel-back)
      confirm_cancel_back=1
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

if [[ "$session_type" != "controller" && "$session_type" != "keyboard" ]]; then
  add_blocker "Missing --session-type controller|keyboard"
fi

if [[ "$session_type" == "controller" ]]; then
  [[ -n "$controller_family" ]] || add_blocker "Missing --controller-family for controller session"
  [[ -n "$device_name" ]] || add_blocker "Missing --device-name for controller session"
  [[ -n "$connection" ]] || add_blocker "Missing --connection for controller session"
fi

if [[ -z "$blockers_note" ]]; then
  add_blocker "Missing --blockers note; use \"none\" only when true"
fi

require_confirmation "--confirm-title" "$confirm_title"
require_confirmation "--confirm-hero-select" "$confirm_hero_select"
require_confirmation "--confirm-movement" "$confirm_movement"
require_confirmation "--confirm-attack" "$confirm_attack"
require_confirmation "--confirm-jump" "$confirm_jump"
require_confirmation "--confirm-special-ready" "$confirm_special_ready"
require_confirmation "--confirm-special" "$confirm_special"
require_confirmation "--confirm-dash" "$confirm_dash"
require_confirmation "--confirm-pause" "$confirm_pause"
require_confirmation "--confirm-cancel-back" "$confirm_cancel_back"

if [[ ! -f "$PACKAGE_PATH" ]]; then
  add_blocker "Package not found: $PACKAGE_PATH"
fi

if [[ "${#collector_blockers[@]}" -gt 0 ]]; then
  printf 'Controller evidence collector blockers:\n'
  for blocker in "${collector_blockers[@]}"; do
    printf -- '- %s\n' "$blocker"
  done
  printf 'RIFT_ROAD_CONTROLLER_EVIDENCE_COLLECTOR blocked\n'
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

session_subject="keyboard"
if [[ "$session_type" == "controller" ]]; then
  session_subject="$controller_family"
fi
subject_slug="$(slugify "$session_subject")"
[[ -n "$subject_slug" ]] || subject_slug="$session_type"
timestamp="$(date -u +"%Y%m%d-%H%M%S")"
evidence_path="$evidence_dir/${timestamp}-${session_type}-${subject_slug}.md"
snippet_path="$evidence_dir/${timestamp}-${session_type}-${subject_slug}-controller-validation-snippet.md"
mkdir -p "$evidence_dir"

if [[ "$evidence_path" == "$ROOT_DIR/"* ]]; then
  evidence_ref="${evidence_path#"$ROOT_DIR/"}"
else
  evidence_ref="$evidence_path"
fi

if [[ -z "$session_label" ]]; then
  if [[ "$session_type" == "controller" ]]; then
    session_label="$controller_family - $device_name"
  else
    session_label="Manual keyboard fallback - $timestamp"
  fi
fi

write_controller_snippet() {
  {
    printf '### Controller Session: `%s`\n\n' "$session_label"
    printf 'RIFT_ROAD_CONTROLLER_SESSION ok\n\n'
    printf -- '- Build: `%s`\n' "$build_value"
    printf -- '- Controller family: `%s`\n' "$controller_family"
    printf -- '- Device name: `%s`\n' "$device_name"
    printf -- '- Connection: `%s`\n' "$connection"
    printf -- '- Evidence capture: `%s`\n' "$evidence_ref"
    printf -- '- Title: `pass`\n'
    printf -- '- Hero select: `pass`\n'
    printf -- '- Stage 1 movement: `pass`\n'
    printf -- '- Attack: `pass`\n'
    printf -- '- Jump: `pass`\n'
    printf -- '- Special meter ready: `pass`\n'
    printf -- '- Special: `pass`\n'
    printf -- '- Dash: `pass`\n'
    printf -- '- Pause: `pass`\n'
    printf -- '- Cancel/back: `pass`\n'
    printf -- '- Blockers: `%s`\n' "$blockers_note"
  } > "$snippet_path"
}

write_keyboard_snippet() {
  {
    printf '### Keyboard Fallback Session\n\n'
    printf 'RIFT_ROAD_KEYBOARD_FALLBACK ok\n\n'
    printf -- '- Build: `%s`\n' "$build_value"
    printf -- '- Evidence capture: `%s`\n' "$evidence_ref"
    printf -- '- Title: `pass`\n'
    printf -- '- Hero select: `pass`\n'
    printf -- '- Stage 1 movement: `pass`\n'
    printf -- '- Attack: `pass`\n'
    printf -- '- Jump: `pass`\n'
    printf -- '- Special meter ready: `pass`\n'
    printf -- '- Special: `pass`\n'
    printf -- '- Dash: `pass`\n'
    printf -- '- Pause: `pass`\n'
    printf -- '- Cancel/back: `pass`\n'
    printf -- '- Blockers: `%s`\n' "$blockers_note"
  } > "$snippet_path"
}

if [[ "$session_type" == "controller" ]]; then
  write_controller_snippet
else
  write_keyboard_snippet
fi

{
  printf '# Rift Road Controller Evidence Capture\n\n'
  printf -- '- Captured UTC: `%s`\n' "$timestamp"
  printf -- '- Session type: `%s`\n' "$session_type"
  printf -- '- Build: `%s`\n' "$build_value"
  printf -- '- Package: `%s`\n' "$PACKAGE_PATH"
  printf -- '- Package SHA256: `%s`\n' "$package_sha256"
  if [[ "$session_type" == "controller" ]]; then
    printf -- '- Controller family: `%s`\n' "$controller_family"
    printf -- '- Device name: `%s`\n' "$device_name"
    printf -- '- Connection: `%s`\n' "$connection"
  fi
  printf -- '- Blockers: `%s`\n\n' "$blockers_note"
  printf '## Manual Confirmations\n\n'
  printf -- '- Title: `pass`\n'
  printf -- '- Hero select: `pass`\n'
  printf -- '- Stage 1 movement: `pass`\n'
  printf -- '- Attack: `pass`\n'
  printf -- '- Jump: `pass`\n'
  printf -- '- Special meter ready: `pass`\n'
  printf -- '- Special: `pass`\n'
  printf -- '- Dash: `pass`\n'
  printf -- '- Pause: `pass`\n'
  printf -- '- Cancel/back: `pass`\n\n'
  printf '## Controller Validation Snippet\n\n'
  cat "$snippet_path"
  printf '\n\n## Next Step\n\n'
  printf 'Paste the snippet above into `docs/controller_validation.md`, then run `bash scripts/check_controller_evidence.sh`.\n'
} > "$evidence_path"

printf 'Evidence capture: %s\n' "$evidence_path"
printf 'Controller-validation snippet: %s\n' "$snippet_path"
printf 'Paste snippet into docs/controller_validation.md, then run: bash scripts/check_controller_evidence.sh\n'
printf 'RIFT_ROAD_CONTROLLER_EVIDENCE_COLLECTOR ok evidence=%s snippet=%s\n' "$evidence_path" "$snippet_path"
