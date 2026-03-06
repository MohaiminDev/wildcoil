from __future__ import annotations

import json
import os
import subprocess
from pathlib import Path
from typing import Mapping, Optional

import pytest


ROOT = Path(__file__).resolve().parents[1]
PROJECT_DIR = ROOT / "src" / "wildcoil"
GODOT_BIN = os.environ.get("GODOT_BIN", "godot")
RESULT_MARKER = "WILDCOIL_TEST_RESULTS "


def run_godot(
    *args: str, env: Optional[Mapping[str, str]] = None
) -> subprocess.CompletedProcess[str]:
    command = [GODOT_BIN, *args]
    runtime_env = os.environ.copy()
    if env:
        runtime_env.update(env)
    return subprocess.run(
        command,
        cwd=ROOT,
        capture_output=True,
        text=True,
        check=False,
        env=runtime_env,
    )


def parse_result_line(output: str) -> dict:
    for line in output.splitlines():
        if RESULT_MARKER in line:
            payload = line.split(RESULT_MARKER, 1)[1].strip()
            return json.loads(payload)
    raise AssertionError(f"Did not find {RESULT_MARKER!r} in output:\n{output}")


@pytest.fixture(scope="session", autouse=True)
def import_project() -> None:
    result = run_godot("--headless", "--path", str(PROJECT_DIR), "--import")
    if result.returncode != 0:
        raise AssertionError(
            "Godot project import failed.\n"
            f"stdout:\n{result.stdout}\n"
            f"stderr:\n{result.stderr}"
        )
