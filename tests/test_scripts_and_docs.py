def test_run_and_check_scripts_exist(repo_root):
    for relative_path in ["scripts/run_game.sh", "scripts/check.sh", "scripts/package_macos.sh"]:
        path = repo_root / relative_path
        assert path.exists()
        assert path.stat().st_mode & 0o111


def test_tracker_names_next_runtime_task(repo_root):
    tracker = (repo_root / "to-do.md").read_text()

    assert "Production Vertical Slice" in tracker
    assert "docs/design-docs/stage1-visual-north-star.md" in tracker
    assert "### [RR-PROD-01] Lock Stage 1 production north star" in tracker
    assert "### [RR-PROD-10] Capture proof for handoff" in tracker
    assert "### [RR-BASELINE-01] Current playable prototype baseline" in tracker
