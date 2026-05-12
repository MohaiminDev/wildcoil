#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FOCUS_AUDIO_DOC="${1:-"$ROOT_DIR/docs/focus_audio_validation.md"}"

python3 - "$FOCUS_AUDIO_DOC" "$ROOT_DIR" <<'PY'
import re
import sys
from pathlib import Path

doc_path = Path(sys.argv[1])
root_dir = Path(sys.argv[2])
text = doc_path.read_text() if doc_path.exists() else ""

required_sessions = 1
required_checks = [
    "Focus pause overlay: `pass`",
    "Audio before focus loss: `pass`",
    "Audio quiet during focus pause: `pass`",
    "Audio after resume: `pass`",
    "Resume control: `pass`",
]
required_metadata = [
    "Build",
    "Output device",
    "Evidence capture",
    "Blockers",
]


def has_marker(block, marker):
    return re.search(rf"(?m)^{re.escape(marker)}\s*$", block) is not None


def metadata_values_and_issues(block):
    values = {}
    missing = []
    placeholders = []
    for label in required_metadata:
        match = re.search(rf"(?m)^- {re.escape(label)}: `([^`]+)`\s*$", block)
        if not match:
            missing.append(label)
            continue
        value = match.group(1).strip()
        values[label] = value
        if not value or value.upper() == "TBD":
            placeholders.append(label)

    issues = []
    if missing:
        issues.append("missing metadata: " + ", ".join(missing))
    if placeholders:
        issues.append("placeholder metadata: " + ", ".join(placeholders))
    blockers_value = values.get("Blockers", "").strip().lower()
    if blockers_value and blockers_value not in {"none", "no blockers"}:
        issues.append("Blockers must be `none` or `no blockers` for an ok session")
    return values, issues


def evidence_capture_issues(values):
    capture = values.get("Evidence capture", "")
    if not capture or capture.upper() == "TBD":
        return []
    capture_path = Path(capture)
    if not capture_path.is_absolute():
        capture_path = root_dir / capture_path
    if not capture_path.exists() or not capture_path.is_file():
        return [f"missing evidence file: {capture}"]
    if capture_path.stat().st_size <= 0:
        return [f"empty evidence file: {capture}"]
    return []


valid_sessions = 0
invalid_sessions = []
for block in re.split(r"(?=### Focus Audio Session:)", text):
    if not has_marker(block, "RIFT_ROAD_FOCUS_AUDIO_SESSION ok"):
        continue
    missing = [check for check in required_checks if check not in block]
    if missing:
        invalid_sessions.append("focus audio session missing checks: " + ", ".join(missing))
        continue
    values, metadata_blockers = metadata_values_and_issues(block)
    metadata_blockers.extend(evidence_capture_issues(values))
    if metadata_blockers:
        invalid_sessions.extend(f"focus audio session {issue}" for issue in metadata_blockers)
        continue
    valid_sessions += 1

blockers = []
if valid_sessions < required_sessions:
    blockers.append(f"focus audio sessions {valid_sessions}/{required_sessions}")
blockers.extend(invalid_sessions)

summary = f"focus_audio_sessions={valid_sessions}/{required_sessions} doc={doc_path}"

if blockers:
    print("Focus audio evidence blockers:")
    for blocker in blockers:
        print(f"- {blocker}")
    print(f"RIFT_ROAD_FOCUS_AUDIO_EVIDENCE blocked {summary}")
    sys.exit(1)

print(f"RIFT_ROAD_FOCUS_AUDIO_EVIDENCE ok {summary}")
PY
