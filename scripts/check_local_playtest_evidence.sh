#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOCAL_PLAYTEST_LOG="${1:-"$ROOT_DIR/docs/local_playtest_log.md"}"

python3 - "$LOCAL_PLAYTEST_LOG" "$ROOT_DIR" <<'PY'
import re
import sys
from pathlib import Path

log_path = Path(sys.argv[1])
root_path = Path(sys.argv[2])
text = log_path.read_text()

required_sessions = 1
required_evidence_captures = 1


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


session_rows = []
for line in text.splitlines():
    if not line.startswith("|"):
        continue
    cells = [cell.strip() for cell in line.strip().strip("|").split("|")]
    if len(cells) < 15:
        continue
    if cells[0].lower() == "date" or is_separator(cells):
        continue
    if cells[0].upper() == "TBD" or cells[3].upper() == "TBD":
        continue
    session_rows.append(cells)

completed_sessions = len(session_rows)
evidence_capture_count = 0
blocker_rows = []
required_observation_fields = [
    (4, "Input method"),
    (5, "Route result"),
    (6, "First-combat time"),
    (7, "Wow-moment time"),
    (8, "Session result"),
    (9, "Replay desire"),
    (10, "Felt good"),
    (11, "Show-someone moment"),
    (12, "Confusion points"),
    (13, "Cheap-damage reports"),
    (14, "Follow-up action"),
]
milestone_time_limits = [
    (6, "First-combat time", 30),
    (7, "Wow-moment time", 180),
]

for cells in session_rows:
    date = cells[0]
    build = clean_cell(cells[1])
    evidence_capture = cells[2]
    tester = cells[3]

    if "source_run=local" not in build:
        blocker_rows.append(f"{date} {tester}: Build missing source_run=local")
    if "RIFT_ROAD_LOCAL_PLAYABILITY_ok" not in build:
        blocker_rows.append(
            f"{date} {tester}: Build missing local_playability=RIFT_ROAD_LOCAL_PLAYABILITY_ok"
        )

    evidence_value, evidence_path = resolve_evidence_path(evidence_capture)
    if evidence_path is None or not evidence_path.is_file() or evidence_path.stat().st_size == 0:
        blocker_rows.append(
            f"{date} {tester}: missing or empty evidence capture {evidence_value or 'TBD'}"
        )
    else:
        evidence_capture_count += 1

    for cell_index, label in required_observation_fields:
        if is_placeholder(cells[cell_index]):
            blocker_rows.append(f"{date} {tester}: missing local session field: {label}")

    for cell_index, label, max_seconds in milestone_time_limits:
        if is_placeholder(cells[cell_index]):
            continue
        milestone_seconds = parse_milestone_seconds(cells[cell_index])
        if milestone_seconds is None:
            blocker_rows.append(f"{date} {tester}: invalid milestone time: {label}")
        elif milestone_seconds > max_seconds:
            blocker_rows.append(f"{date} {tester}: {label} exceeds {max_seconds} seconds")

    blocker_text = " ".join(
        [
            clean_cell(cells[5]).lower(),
            clean_cell(cells[8]).lower(),
            clean_cell(cells[12]).lower(),
            clean_cell(cells[13]).lower(),
            clean_cell(cells[14]).lower(),
        ]
    )
    if any(
        token in blocker_text
        for token in ["blocker", "cannot launch", "cannot move", "crash", "softlock"]
    ):
        blocker_rows.append(f"{date} {tester}: blocking local session outcome")

blockers = []
if completed_sessions < required_sessions:
    blockers.append(f"completed sessions {completed_sessions}/{required_sessions}")
if evidence_capture_count < required_evidence_captures:
    blockers.append(f"evidence captures {evidence_capture_count}/{required_evidence_captures}")
if blocker_rows:
    blockers.append("blocking local session rows: " + "; ".join(blocker_rows))

summary = (
    f"sessions={completed_sessions}/{required_sessions} "
    f"evidence_captures={evidence_capture_count}/{max(completed_sessions, required_evidence_captures)} "
    f"log={log_path}"
)

if blockers:
    print("Local playtest evidence blockers:")
    for blocker in blockers:
        print(f"- {blocker}")
    print(f"RIFT_ROAD_LOCAL_PLAYTEST_EVIDENCE blocked {summary}")
    sys.exit(1)

print(f"RIFT_ROAD_LOCAL_PLAYTEST_EVIDENCE source-run-session {summary}")
PY
