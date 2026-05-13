#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLAYTEST_LOG="${1:-"$ROOT_DIR/docs/playtest_log.md"}"

python3 - "$PLAYTEST_LOG" "$ROOT_DIR" <<'PY'
import math
import re
import sys
from pathlib import Path

log_path = Path(sys.argv[1])
root_path = Path(sys.argv[2])
text = log_path.read_text()

required_sessions = 5
required_second_mac_sessions = 1
required_controller_families = 2
# Evidence capture is a required session-table column; every counted row must
# point at a real non-empty note, screenshot, or video file.


def is_separator(cells):
    return all(re.fullmatch(r":?-{3,}:?", cell.strip()) for cell in cells)


def clean_cell(value):
    value = value.strip()
    if value.startswith("`") and value.endswith("`"):
        value = value[1:-1]
    link_match = re.fullmatch(r"\[[^\]]+\]\(([^)]+)\)", value)
    if link_match:
        value = link_match.group(1)
    return value.strip()


def is_placeholder(value):
    value = clean_cell(value)
    return not value or value.upper() == "TBD"


def parse_milestone_seconds(value):
    value = clean_cell(value)
    match = re.fullmatch(r"(\d+):([0-5]\d)", value)
    if not match:
        return None
    minutes = int(match.group(1))
    seconds = int(match.group(2))
    return minutes * 60 + seconds


def has_cheap_damage_report(value):
    value = clean_cell(value).lower()
    if not value or value == "tbd":
        return False
    no_report_values = {"none", "no", "n/a", "na", "not observed", "none observed"}
    return value not in no_report_values


def resolve_evidence_path(value):
    value = clean_cell(value)
    if not value or value.upper() == "TBD":
        return value, None
    path = Path(value)
    if path.is_absolute():
        return value, path
    root_relative = root_path / path
    if root_relative.exists():
        return value, root_relative
    return value, log_path.parent / path


def signed_package_source_issue(build):
    if "package_source=" not in build:
        return "Build missing signed package_source"
    source_value = build.split("package_source=", 1)[1]
    if "Rift Road-signed-notarized.zip" not in source_value:
        return "Build missing signed package_source"
    return ""


session_rows = []
for line in text.splitlines():
    if not line.startswith("|"):
        continue
    cells = [cell.strip() for cell in line.strip().strip("|").split("|")]
    if len(cells) < 13:
        continue
    if cells[0].lower() == "date" or is_separator(cells):
        continue
    if cells[0].upper() == "TBD" or cells[3].upper() == "TBD":
        continue
    session_rows.append(cells)

completed_sessions = len(session_rows)
second_mac_sessions = 0
controller_families = set()
replay_intent_sessions = 0
blocker_rows = []
evidence_capture_count = 0
cheap_damage_report_rows = 0
required_session_observation_fields = [
    (6, "First-combat time"),
    (7, "Wow-moment time"),
    (8, "Replay desire"),
    (9, "Confusion points"),
    (10, "Cheap-damage reports"),
    (11, "Key quotes / observations"),
    (12, "Follow-up action"),
]
milestone_time_limits = [
    (6, "First-combat time", 30),
    (7, "Wow-moment time", 180),
]

for cells in session_rows:
    build = clean_cell(cells[1])
    evidence_capture = cells[2]
    tester = cells[3]
    setup = clean_cell(cells[4]).lower()
    input_method = clean_cell(cells[5]).lower()
    replay_desire = cells[8].lower()
    confusion = cells[9].lower()
    cheap_damage = cells[10].lower()
    follow_up = cells[12].lower()

    for cell_index, label in required_session_observation_fields:
        if is_placeholder(cells[cell_index]):
            blocker_rows.append(
                f"{cells[0]} {tester}: missing session observation: {label}"
            )

    if "machine=primary-mac" not in setup and "machine=second-mac" not in setup:
        blocker_rows.append(
            f"{cells[0]} {tester}: Setup missing machine=primary-mac or machine=second-mac"
        )
    if is_placeholder(cells[5]):
        blocker_rows.append(f"{cells[0]} {tester}: Input method missing")

    for cell_index, label, max_seconds in milestone_time_limits:
        if is_placeholder(cells[cell_index]):
            continue
        milestone_seconds = parse_milestone_seconds(cells[cell_index])
        if milestone_seconds is None:
            blocker_rows.append(
                f"{cells[0]} {tester}: invalid milestone time: {label}"
            )
        elif milestone_seconds > max_seconds:
            blocker_rows.append(
                f"{cells[0]} {tester}: {label} exceeds {max_seconds} seconds"
            )

    evidence_value, evidence_path = resolve_evidence_path(evidence_capture)
    if evidence_path is None or not evidence_path.is_file() or evidence_path.stat().st_size == 0:
        blocker_rows.append(
            f"{cells[0]} {tester}: missing or empty evidence capture {evidence_value or 'TBD'}"
        )
    else:
        evidence_capture_count += 1

    if not build or build.upper() == "TBD" or "package_sha256=" not in build:
        blocker_rows.append(f"{cells[0]} {tester}: Build missing package_sha256")
    else:
        if not re.search(r"(?:^|\s)package_sha256=[0-9a-fA-F]{64}(?:\s|$)", build):
            blocker_rows.append(f"{cells[0]} {tester}: Build has invalid package_sha256")
        source_issue = signed_package_source_issue(build)
        if source_issue:
            blocker_rows.append(f"{cells[0]} {tester}: {source_issue}")

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

    if has_cheap_damage_report(cells[10]):
        cheap_damage_report_rows += 1

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
if cheap_damage_report_rows > 1:
    blockers.append(f"cheap-damage report rows {cheap_damage_report_rows}/1")
if blocker_rows:
    blockers.append("blocking session rows: " + "; ".join(blocker_rows))

summary = (
    f"sessions={completed_sessions}/{required_sessions} "
    f"evidence_captures={evidence_capture_count}/{completed_sessions} "
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
