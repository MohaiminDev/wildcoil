import os
import subprocess
from pathlib import Path

import pytest


REPO_ROOT = Path(__file__).resolve().parents[1]
PROJECT_ROOT = REPO_ROOT / "src" / "wildcoil"


@pytest.fixture
def repo_root() -> Path:
    return REPO_ROOT


@pytest.fixture
def project_root() -> Path:
    return PROJECT_ROOT


@pytest.fixture
def godot_bin() -> str:
    return os.environ.get("GODOT_BIN", "godot")


@pytest.fixture
def godot_runner(godot_bin, tmp_path):
    def run_godot(*args: str, timeout: int = 20) -> subprocess.CompletedProcess[str]:
        log_path = tmp_path / "godot.log"
        return subprocess.run(
            [godot_bin, "--path", str(PROJECT_ROOT), "--log-file", str(log_path), *args],
            cwd=REPO_ROOT,
            text=True,
            capture_output=True,
            timeout=timeout,
            check=False,
        )

    return run_godot
