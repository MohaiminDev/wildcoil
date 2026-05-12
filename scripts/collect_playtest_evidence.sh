#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEFAULT_EVIDENCE_DIR="$ROOT_DIR/docs/playtest-captures/playtests"
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
  bash scripts/collect_playtest_evidence.sh \
    --confirm-external-session \
    --tester "tester-01" \
    --setup "machine=primary-mac; macOS 26.5; Apple Silicon" \
    --input-method "keyboard; controller-family=xbox" \
    --first-combat-time "00:24" \
    --wow-moment-time "02:10" \
    --replay-desire "yes - asked for another run" \
    --confusion-points "missed special meter once" \
    --cheap-damage-reports "none" \
    --quotes "The road collapse looked cool." \
    --follow-up-action "tighten boss warning"

This is a manual evidence collector for real external-style playtest sessions.
It writes a non-empty session note plus a paste-ready table row for
docs/playtest_log.md, then reminds you to run:

  bash scripts/check_playtest_evidence.sh

Options:
  --confirm-external-session      Required; use only after a real tester session.
  --date VALUE                    Optional; defaults to current UTC date.
  --tester VALUE                  Required.
  --setup VALUE                   Required; include machine=primary-mac or machine=second-mac.
  --input-method VALUE            Required; include controller-family=<family> when used.
  --first-combat-time VALUE       Required.
  --wow-moment-time VALUE         Required.
  --replay-desire VALUE           Required.
  --confusion-points VALUE        Required; use "none" only when true.
  --cheap-damage-reports VALUE    Required; use "none" only when true.
  --quotes VALUE                  Required; concise quote or observation.
  --follow-up-action VALUE        Required.
  --build VALUE                   Optional; defaults to current commit, package SHA-256, and package source. Custom values must include package_sha256=<sha> and package_source=Rift Road-signed-notarized.zip to pass the gate.
  --session-id VALUE              Optional; defaults to timestamped tester id.
  --evidence-dir PATH             Optional; default docs/playtest-captures/playtests.

Package default:
  Uses RIFT_ROAD_PACKAGE_PATH when set. Otherwise prefers
  build/macos/Rift Road-signed-notarized.zip or ./Rift Road-signed-notarized.zip
  when present, then falls back to the unsigned Rift Road.zip.
EOF
}

date_value=""
tester=""
setup=""
input_method=""
first_combat_time=""
wow_moment_time=""
replay_desire=""
confusion_points=""
cheap_damage_reports=""
quotes=""
follow_up_action=""
build_value=""
session_id=""
evidence_dir="$DEFAULT_EVIDENCE_DIR"
confirm_external_session=0

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
    --confirm-external-session)
      confirm_external_session=1
      shift
      ;;
    --date)
      date_value="$(parse_value "$1" "${2:-}")"
      shift 2
      ;;
    --tester)
      tester="$(parse_value "$1" "${2:-}")"
      shift 2
      ;;
    --setup)
      setup="$(parse_value "$1" "${2:-}")"
      shift 2
      ;;
    --input-method)
      input_method="$(parse_value "$1" "${2:-}")"
      shift 2
      ;;
    --first-combat-time)
      first_combat_time="$(parse_value "$1" "${2:-}")"
      shift 2
      ;;
    --wow-moment-time)
      wow_moment_time="$(parse_value "$1" "${2:-}")"
      shift 2
      ;;
    --replay-desire)
      replay_desire="$(parse_value "$1" "${2:-}")"
      shift 2
      ;;
    --confusion-points)
      confusion_points="$(parse_value "$1" "${2:-}")"
      shift 2
      ;;
    --cheap-damage-reports)
      cheap_damage_reports="$(parse_value "$1" "${2:-}")"
      shift 2
      ;;
    --quotes)
      quotes="$(parse_value "$1" "${2:-}")"
      shift 2
      ;;
    --follow-up-action)
      follow_up_action="$(parse_value "$1" "${2:-}")"
      shift 2
      ;;
    --build)
      build_value="$(parse_value "$1" "${2:-}")"
      shift 2
      ;;
    --session-id)
      session_id="$(parse_value "$1" "${2:-}")"
      shift 2
      ;;
    --evidence-dir)
      evidence_dir="$(parse_value "$1" "${2:-}")"
      shift 2
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

require_field() {
  local option_name="$1"
  local option_value="$2"
  local uppercase_value
  uppercase_value="$(printf '%s' "$option_value" | tr '[:lower:]' '[:upper:]')"
  if [[ -z "$option_value" || "$uppercase_value" == "TBD" ]]; then
    add_blocker "Missing $option_name"
  fi
}

if [[ "$confirm_external_session" != "1" ]]; then
  add_blocker "Missing --confirm-external-session"
fi

require_field "--tester" "$tester"
require_field "--setup" "$setup"
require_field "--input-method" "$input_method"
require_field "--first-combat-time" "$first_combat_time"
require_field "--wow-moment-time" "$wow_moment_time"
require_field "--replay-desire" "$replay_desire"
require_field "--confusion-points" "$confusion_points"
require_field "--cheap-damage-reports" "$cheap_damage_reports"
require_field "--quotes" "$quotes"
require_field "--follow-up-action" "$follow_up_action"

if [[ -n "$setup" && "$setup" != *"machine="* ]]; then
  add_blocker "Setup must include machine=primary-mac or machine=second-mac"
fi

if [[ ! -f "$PACKAGE_PATH" ]]; then
  add_blocker "Package not found: $PACKAGE_PATH"
fi

if [[ "${#collector_blockers[@]}" -gt 0 ]]; then
  printf 'Playtest evidence collector blockers:\n'
  for blocker in "${collector_blockers[@]}"; do
    printf -- '- %s\n' "$blocker"
  done
  printf 'RIFT_ROAD_PLAYTEST_COLLECTOR blocked\n'
  exit 1
fi

build_commit="$(git -C "$ROOT_DIR" rev-parse --short HEAD 2>/dev/null || printf 'unknown')"
package_sha256="$(shasum -a 256 "$PACKAGE_PATH" | awk '{print $1}')"
package_source="$PACKAGE_PATH"
if [[ "$package_source" == "$ROOT_DIR/"* ]]; then
  package_source="${package_source#"$ROOT_DIR/"}"
fi
if [[ -z "$build_value" ]]; then
  build_value="commit=${build_commit} package_sha256=${package_sha256} package_source=${package_source}"
fi

if [[ -z "$date_value" ]]; then
  date_value="$(date -u +"%Y-%m-%d")"
fi

slugify() {
  printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//'
}

timestamp="$(date -u +"%Y%m%d-%H%M%S")"
tester_slug="$(slugify "$tester")"
[[ -n "$tester_slug" ]] || tester_slug="tester"
if [[ -z "$session_id" ]]; then
  session_id="${date_value}-${tester_slug}-${timestamp}"
fi

mkdir -p "$evidence_dir"
evidence_path="$evidence_dir/${session_id}.md"
row_path="$evidence_dir/${session_id}-playtest-log-row.md"

if [[ "$evidence_path" == "$ROOT_DIR/"* ]]; then
  evidence_ref="${evidence_path#"$ROOT_DIR/"}"
else
  evidence_ref="$evidence_path"
fi

table_row="| ${date_value} | ${build_value} | ${evidence_ref} | ${tester} | ${setup} | ${input_method} | ${first_combat_time} | ${wow_moment_time} | ${replay_desire} | ${confusion_points} | ${cheap_damage_reports} | ${quotes} | ${follow_up_action} |"

{
  printf '# Rift Road Playtest Evidence\n\n'
  printf '## Session Capture Table Row\n\n'
  printf '%s\n\n' "$table_row"
  printf '## Session Notes\n\n'
  printf '### Session ID: `%s`\n\n' "$session_id"
  printf -- '- Build identifier: `%s`\n' "$build_value"
  printf -- '- Evidence capture: `%s`\n' "$evidence_ref"
  printf -- '- Package: `%s`\n' "$PACKAGE_PATH"
  printf -- '- Engine / branch: `Godot 4.6.1 / codex/stage1-visual-north-star`\n'
  printf -- '- Tester: `%s`\n' "$tester"
  printf -- '- Hardware: `%s`\n' "$setup"
  printf -- '- Controller type: `%s`\n' "$input_method"
  printf -- '- First-combat time: `%s`\n' "$first_combat_time"
  printf -- '- Wow-moment time: `%s`\n' "$wow_moment_time"
  printf -- '- Replay desire: `%s`\n' "$replay_desire"
  printf -- '- What confused the tester: `%s`\n' "$confusion_points"
  printf -- '- Where the tester took damage unfairly: `%s`\n' "$cheap_damage_reports"
  printf -- '- Key quotes / observations: `%s`\n' "$quotes"
  printf -- '- Highest-priority fix: `%s`\n\n' "$follow_up_action"
  printf '## Next Step\n\n'
  printf 'Paste the table row into `docs/playtest_log.md`, add any richer notes below the table, then run `bash scripts/check_playtest_evidence.sh`.\n'
} > "$evidence_path"

{
  printf '# Playtest Log Row\n\n'
  printf '%s\n' "$table_row"
} > "$row_path"

printf 'Evidence note: %s\n' "$evidence_path"
printf 'Playtest-log row: %s\n' "$row_path"
printf 'Paste row into docs/playtest_log.md, then run: bash scripts/check_playtest_evidence.sh\n'
printf 'RIFT_ROAD_PLAYTEST_COLLECTOR ok evidence=%s row=%s\n' "$evidence_path" "$row_path"
