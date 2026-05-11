#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLAYTEST_LOG="${1:-"$ROOT_DIR/docs/playtest_log.md"}"

python3 - "$PLAYTEST_LOG" <<'PY'
import math
import re
import sys
from pathlib import Path

log_path = Path(sys.argv[1])
text = log_path.read_text()

required_sessions = 5
required_second_mac_sessions = 1
required_controller_families = 2


def is_separator(cells):
    return all(re.fullmatch(r":?-{3,}:?", cell.strip()) for cell in cells)


session_rows = []
for line in text.splitlines():
    if not line.startswith("|"):
        continue
    cells = [cell.strip() for cell in line.strip().strip("|").split("|")]
    if len(cells) < 12:
        continue
    if cells[0].lower() == "date" or is_separator(cells):
        continue
    if cells[0].upper() == "TBD" or cells[2].upper() == "TBD":
        continue
    session_rows.append(cells)

completed_sessions = len(session_rows)
second_mac_sessions = 0
controller_families = set()
replay_intent_sessions = 0
blocker_rows = []

for cells in session_rows:
    setup = cells[3].lower()
    input_method = cells[4].lower()
    replay_desire = cells[7].lower()
    confusion = cells[8].lower()
    cheap_damage = cells[9].lower()
    follow_up = cells[11].lower()

    # Session table convention: setup includes machine=primary-mac or machine=second-mac.
    if "machine=second-mac" in setup:
        second_mac_sessions += 1

    # Session table convention: input method includes controller-family=<family-name>.
    for match in re.finditer(r"controller-family=([a-z0-9._ -]+)", input_method):
        family = re.split(r"[,;/)]", match.group(1), maxsplit=1)[0].strip()
        if family:
            controller_families.add(family)

    if any(token in replay_desire for token in ["yes", "asked", "another", "replay", "again", "wants"]):
        replay_intent_sessions += 1

    blocker_text = " ".join([confusion, cheap_damage, follow_up])
    if any(token in blocker_text for token in ["blocker", "cannot launch", "cannot move", "crash", "softlock"]):
        blocker_rows.append(cells[0])

required_replay_intent_sessions = max(3, math.floor(completed_sessions / 2) + 1)

blockers = []
if completed_sessions < required_sessions:
    blockers.append(f"completed sessions {completed_sessions}/{required_sessions}")
if second_mac_sessions < required_second_mac_sessions:
    blockers.append(f"second-Mac sessions {second_mac_sessions}/{required_second_mac_sessions}")
if len(controller_families) < required_controller_families:
    blockers.append(f"controller families {len(controller_families)}/{required_controller_families}")
if replay_intent_sessions < required_replay_intent_sessions:
    blockers.append(f"replay-intent sessions {replay_intent_sessions}/{required_replay_intent_sessions}")
if blocker_rows:
    blockers.append("blocking session rows: " + ", ".join(blocker_rows))

summary = (
    f"sessions={completed_sessions}/{required_sessions} "
    f"second_mac={second_mac_sessions}/{required_second_mac_sessions} "
    f"controller_families={len(controller_families)}/{required_controller_families} "
    f"replay_intent={replay_intent_sessions}/{required_replay_intent_sessions} "
    f"log={log_path}"
)

if blockers:
    print("Playtest evidence blockers:")
    for blocker in blockers:
        print(f"- {blocker}")
    print(f"RIFT_ROAD_PLAYTEST_EVIDENCE blocked {summary}")
    sys.exit(1)

print(f"RIFT_ROAD_PLAYTEST_EVIDENCE public-playtest-candidate {summary}")
PY
