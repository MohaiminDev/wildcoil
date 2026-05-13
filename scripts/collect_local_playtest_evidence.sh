#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEFAULT_EVIDENCE_DIR="$ROOT_DIR/docs/playtest-captures/local-playtests"

usage() {
  cat <<'EOF'
Usage:
  bash scripts/collect_local_playtest_evidence.sh \
    --confirm-local-source-session \
    --tester "local-dev" \
    --input-method "keyboard" \
    --route-result "Stage Clear" \
    --first-combat-time "00:24" \
    --wow-moment-time "02:10" \
    --session-result "cleared Stage 1 and returned to title" \
    --replay-desire "yes - would run another attempt" \
    --felt-good "movement and opening fight stayed readable" \
    --confusion-points "none" \
    --cheap-damage-reports "none" \
    --show-someone-moment "road collapse into the lower service lane" \
    --follow-up-action "record longer human video"

This is a local source-run playtest evidence collector. Use it after a real
session launched from source on this machine. Before the session, run:

  bash scripts/check_local_playability.sh

It writes a non-empty session note plus a paste-ready table row for
docs/local_playtest_log.md. This is source-run local playability evidence,
not public-playtest proof.

Options:
  --confirm-local-source-session  Required; use only after a real local source-run session.
  --date VALUE                    Optional; defaults to current UTC date.
  --tester VALUE                  Required.
  --input-method VALUE            Required.
  --route-result VALUE            Required; e.g. Stage Clear, fail/retry, returned to title.
  --first-combat-time VALUE       Required.
  --wow-moment-time VALUE         Required.
  --session-result VALUE          Required.
  --replay-desire VALUE           Required.
  --felt-good VALUE               Required; what felt responsive, readable, or satisfying.
  --confusion-points VALUE        Required; use "none" only when true.
  --cheap-damage-reports VALUE    Required; use "none" only when true.
  --show-someone-moment VALUE     Required; share-worthy moment, or "none".
  --follow-up-action VALUE        Required.
  --session-id VALUE              Optional; defaults to timestamped tester id.
  --evidence-dir PATH             Optional; default docs/playtest-captures/local-playtests.
EOF
}

date_value=""
tester=""
input_method=""
route_result=""
first_combat_time=""
wow_moment_time=""
session_result=""
replay_desire=""
felt_good=""
confusion_points=""
cheap_damage_reports=""
show_someone_moment=""
follow_up_action=""
session_id=""
evidence_dir="$DEFAULT_EVIDENCE_DIR"
confirm_local_source_session=0

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
    --confirm-local-source-session)
      confirm_local_source_session=1
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
    --input-method)
      input_method="$(parse_value "$1" "${2:-}")"
      shift 2
      ;;
    --route-result)
      route_result="$(parse_value "$1" "${2:-}")"
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
    --session-result)
      session_result="$(parse_value "$1" "${2:-}")"
      shift 2
      ;;
    --replay-desire)
      replay_desire="$(parse_value "$1" "${2:-}")"
      shift 2
      ;;
    --felt-good)
      felt_good="$(parse_value "$1" "${2:-}")"
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
    --show-someone-moment)
      show_someone_moment="$(parse_value "$1" "${2:-}")"
      shift 2
      ;;
    --follow-up-action)
      follow_up_action="$(parse_value "$1" "${2:-}")"
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

if [[ "$confirm_local_source_session" != "1" ]]; then
  add_blocker "Missing --confirm-local-source-session"
fi

require_field "--tester" "$tester"
require_field "--input-method" "$input_method"
require_field "--route-result" "$route_result"
require_field "--first-combat-time" "$first_combat_time"
require_field "--wow-moment-time" "$wow_moment_time"
require_field "--session-result" "$session_result"
require_field "--replay-desire" "$replay_desire"
require_field "--felt-good" "$felt_good"
require_field "--confusion-points" "$confusion_points"
require_field "--cheap-damage-reports" "$cheap_damage_reports"
require_field "--show-someone-moment" "$show_someone_moment"
require_field "--follow-up-action" "$follow_up_action"

if [[ "${#collector_blockers[@]}" -gt 0 ]]; then
  printf 'Local playtest evidence collector blockers:\n'
  for blocker in "${collector_blockers[@]}"; do
    printf -- '- %s\n' "$blocker"
  done
  printf 'RIFT_ROAD_LOCAL_PLAYTEST_COLLECTOR blocked\n'
  exit 1
fi

build_commit="$(git -C "$ROOT_DIR" rev-parse --short HEAD 2>/dev/null || printf 'unknown')"
branch_name="$(git -C "$ROOT_DIR" branch --show-current 2>/dev/null || printf 'unknown')"
build_value="commit=${build_commit} source_run=local local_playability=RIFT_ROAD_LOCAL_PLAYABILITY_ok"

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
row_path="$evidence_dir/${session_id}-local-playtest-log-row.md"

if [[ "$evidence_path" == "$ROOT_DIR/"* ]]; then
  evidence_ref="${evidence_path#"$ROOT_DIR/"}"
else
  evidence_ref="$evidence_path"
fi

table_row="| ${date_value} | ${build_value} | ${evidence_ref} | ${tester} | ${input_method} | ${route_result} | ${first_combat_time} | ${wow_moment_time} | ${session_result} | ${replay_desire} | ${felt_good} | ${show_someone_moment} | ${confusion_points} | ${cheap_damage_reports} | ${follow_up_action} |"

{
  printf '# Rift Road Local Source-Run Playtest Evidence\n\n'
  printf 'This note is source-run local playability evidence, not public-playtest proof.\n\n'
  printf '## Session Capture Table Row\n\n'
  printf '%s\n\n' "$table_row"
  printf '## Session Notes\n\n'
  printf '### Session ID: `%s`\n\n' "$session_id"
  printf -- '- Build identifier: `%s`\n' "$build_value"
  printf -- '- Evidence capture: `%s`\n' "$evidence_ref"
  printf -- '- Local gate expected before play: `bash scripts/check_local_playability.sh`\n'
  printf -- '- Engine / branch: `Godot 4.6.x / %s`\n' "$branch_name"
  printf -- '- Tester: `%s`\n' "$tester"
  printf -- '- Input method: `%s`\n' "$input_method"
  printf -- '- Route result: `%s`\n' "$route_result"
  printf -- '- First-combat time: `%s`\n' "$first_combat_time"
  printf -- '- Wow-moment time: `%s`\n' "$wow_moment_time"
  printf -- '- Session result: `%s`\n' "$session_result"
  printf -- '- Replay desire: `%s`\n' "$replay_desire"
  printf -- '- What felt good: `%s`\n' "$felt_good"
  printf -- '- Show-someone moment: `%s`\n' "$show_someone_moment"
  printf -- '- What confused the tester: `%s`\n' "$confusion_points"
  printf -- '- Where the tester took damage unfairly: `%s`\n' "$cheap_damage_reports"
  printf -- '- Highest-priority fix: `%s`\n\n' "$follow_up_action"
  printf '## Next Step\n\n'
  printf 'Paste the table row into `docs/local_playtest_log.md`. Keep public-playtest or release-candidate claims gated by `docs/public_playtest_gate.md`.\n'
} > "$evidence_path"

{
  printf '# Local Playtest Log Row\n\n'
  printf '%s\n' "$table_row"
} > "$row_path"

printf 'Evidence note: %s\n' "$evidence_path"
printf 'Local-playtest-log row: %s\n' "$row_path"
printf 'Paste row into docs/local_playtest_log.md after reviewing the note.\n'
printf 'RIFT_ROAD_LOCAL_PLAYTEST_COLLECTOR ok evidence=%s row=%s\n' "$evidence_path" "$row_path"
