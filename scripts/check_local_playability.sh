#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT_DIR"

bash "$ROOT_DIR/scripts/check_godot_version.sh"

python3 -m pytest \
  tests/test_runtime_smoke.py::test_godot_project_launches_headlessly \
  tests/test_runtime_smoke.py::test_stage_one_title_to_victory_flow \
  tests/test_runtime_smoke.py::test_stage_one_restart_and_return_to_title_flow \
  tests/test_runtime_smoke.py::test_keyboard_fallback_title_to_stage_and_action_flow \
  tests/test_runtime_smoke.py::test_keyboard_text_confirm_event_starts_stage_one \
  tests/test_runtime_smoke.py::test_stage_one_focus_loss_pauses_and_resumes \
  tests/test_runtime_smoke.py::test_stage_one_performance_sample_stays_within_budget \
  -q

printf 'RIFT_ROAD_LOCAL_PLAYABILITY ok scope=source-run machine=local\n'
