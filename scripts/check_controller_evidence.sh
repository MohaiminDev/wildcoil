#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONTROLLER_DOC="${1:-"$ROOT_DIR/docs/controller_validation.md"}"

python3 - "$CONTROLLER_DOC" <<'PY'
import re
import sys
from pathlib import Path

doc_path = Path(sys.argv[1])
text = doc_path.read_text() if doc_path.exists() else ""

required_controller_families = 2
required_checks = [
    "Title: `pass`",
    "Hero select: `pass`",
    "Stage 1 movement: `pass`",
    "Attack: `pass`",
    "Jump: `pass`",
    "Special: `pass`",
    "Dash: `pass`",
    "Pause: `pass`",
    "Cancel/back: `pass`",
]

controller_families = set()
invalid_sessions = []

def has_marker(block, marker):
    return re.search(rf"(?m)^{re.escape(marker)}\s*$", block) is not None

for block in re.split(r"(?=### Controller Session:)", text):
    if not has_marker(block, "RIFT_ROAD_CONTROLLER_SESSION ok"):
        continue
    family_match = re.search(r"Controller family: `([^`]+)`", block)
    family = family_match.group(1).strip() if family_match else ""
    missing = [check for check in required_checks if check not in block]
    if not family or family.upper() == "TBD":
        invalid_sessions.append("controller session missing Controller family")
        continue
    if missing:
        invalid_sessions.append(f"{family} missing checks: {', '.join(missing)}")
        continue
    controller_families.add(family.lower())

keyboard_fallback_ok = False
keyboard_blockers = []
for block in re.split(r"(?=### Keyboard Fallback Session)", text):
    if not has_marker(block, "RIFT_ROAD_KEYBOARD_FALLBACK ok"):
        continue
    missing = [check for check in required_checks if check not in block]
    if missing:
        keyboard_blockers.append("keyboard fallback missing checks: " + ", ".join(missing))
    else:
        keyboard_fallback_ok = True

blockers = []
if len(controller_families) < required_controller_families:
    blockers.append(f"controller families {len(controller_families)}/{required_controller_families}")
if not keyboard_fallback_ok:
    blockers.append("keyboard fallback 0/1")
blockers.extend(invalid_sessions)
blockers.extend(keyboard_blockers)

summary = (
    f"controller_families={len(controller_families)}/{required_controller_families} "
    f"keyboard_fallback={1 if keyboard_fallback_ok else 0}/1 "
    f"doc={doc_path}"
)

if blockers:
    print("Controller evidence blockers:")
    for blocker in blockers:
        print(f"- {blocker}")
    print(f"RIFT_ROAD_CONTROLLER_EVIDENCE blocked {summary}")
    sys.exit(1)

print(f"RIFT_ROAD_CONTROLLER_EVIDENCE ok {summary}")
PY
