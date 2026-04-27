def test_run_and_check_scripts_exist(repo_root):
    for relative_path in ["scripts/run_game.sh", "scripts/check.sh", "scripts/package_macos.sh"]:
        path = repo_root / relative_path
        assert path.exists()
        assert path.stat().st_mode & 0o111


def test_tracker_names_next_runtime_task(repo_root):
    tracker = (repo_root / "to-do.md").read_text()

    assert "### [RR-P1-01] Scaffold the production Godot project" in tracker
    assert "### [RR-P1-10] Package and validate the macOS prototype" in tracker

