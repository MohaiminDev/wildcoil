import subprocess


def test_run_and_check_scripts_exist(repo_root):
    for relative_path in [
        "scripts/run_game.sh",
        "scripts/check.sh",
        "scripts/package_macos.sh",
        "scripts/audit_macos_package.sh",
        "scripts/smoke_exported_macos_app.sh",
        "scripts/check_release_candidate.sh",
        "scripts/check_macos_signing_env.sh",
        "scripts/sign_notarize_macos.sh",
        "scripts/sample_exported_app_performance.sh",
        "scripts/prepare_known_tester_packet.sh",
        "scripts/check_playtest_evidence.sh",
        "scripts/check_second_machine_evidence.sh",
        "scripts/collect_second_machine_evidence.sh",
        "scripts/check_controller_evidence.sh",
        "scripts/collect_controller_evidence.sh",
        "scripts/smoke_exported_keyboard_fallback.sh",
        "scripts/smoke_exported_focus_resume.sh",
    ]:
        path = repo_root / relative_path
        assert path.exists()
        assert path.stat().st_mode & 0o111


def test_macos_package_audit_surfaces_release_gates(repo_root):
    script = (repo_root / "scripts" / "audit_macos_package.sh").read_text()
    docs = (repo_root / "docs" / "macos_build_and_distribution.md").read_text()

    assert "Rift Road.zip" in script
    assert "codesign" in script
    assert "spctl" in script
    assert "stapler" in script
    assert "notarization" in script
    assert "internal-only" in script
    assert "RIFT_ROAD_AUDIT_ARTIFACT_ONLY" in script
    assert "skipping Godot export preset signing/notarization checks" in script
    assert "scripts/audit_macos_package.sh" in docs
    assert "internal-only" in docs


def test_exported_app_smoke_script_captures_launched_viewport(repo_root):
    script = (repo_root / "scripts" / "smoke_exported_macos_app.sh").read_text()
    app_root = (repo_root / "src" / "wildcoil" / "scripts" / "app_root.gd").read_text()
    docs = (repo_root / "docs" / "macos_build_and_distribution.md").read_text()
    handoff = (
        repo_root
        / "docs"
        / "playtest-captures"
        / "stage1-marketability-handoff-2026-05-10.md"
    ).read_text()

    assert "Rift Road.zip" in script
    assert "open -n" in script
    assert "--rift-road-smoke-capture-dir=" in script
    assert "--rift-road-smoke-stage1" in script
    assert "stage1-exported-app-smoke-title.png" in script
    assert "stage1-exported-app-smoke-hero-select.png" in script
    assert "stage1-exported-app-smoke-gameplay.png" in script
    assert "HERO_SELECT_CAPTURE" in script
    assert "--rift-road-smoke-capture-dir=" in app_root
    assert "RenderingServer.frame_post_draw" in app_root
    assert "save_png" in app_root
    assert "stage1-exported-app-smoke-title.png" in script
    assert "stage1-exported-app-smoke-hero-select.png" in script
    assert "stage1-exported-app-smoke-gameplay.png" in script
    assert "SMOKE_HERO_SELECT_CAPTURE_NAME" in app_root
    assert app_root.index("_show_character_select()") < app_root.index("var hero_select_path")
    assert "RIFT_ROAD_EXPORTED_APP_SMOKE ok" in script
    assert "scripts/smoke_exported_macos_app.sh" in docs
    assert "RIFT_ROAD_EXPORTED_APP_SMOKE ok" in handoff


def test_exported_app_smoke_script_captures_opening_story_viewport(repo_root):
    script = (repo_root / "scripts" / "smoke_exported_macos_app.sh").read_text()
    app_root = (repo_root / "src" / "wildcoil" / "scripts" / "app_root.gd").read_text()
    handoff = (
        repo_root
        / "docs"
        / "playtest-captures"
        / "stage1-marketability-handoff-2026-05-10.md"
    ).read_text()
    audit = (repo_root / "docs" / "market-readiness-audit-2026-05-10.md").read_text()

    assert "stage1-exported-app-smoke-opening-story.png" in script
    assert "OPENING_STORY_CAPTURE" in script
    assert "opening_story_capture=" in script
    assert "SMOKE_OPENING_STORY_CAPTURE_NAME" in app_root
    assert "_show_opening_story_smoke_capture" in app_root
    assert app_root.index("_start_stage1_demo()") < app_root.index("var opening_story_path")
    assert "last_story_beat" in app_root
    assert "stage1-exported-app-smoke-opening-story.png" in handoff
    assert "stage1-exported-app-smoke-opening-story.png" in audit


def test_exported_app_focus_resume_smoke_records_artifacts(repo_root):
    script = (repo_root / "scripts" / "smoke_exported_focus_resume.sh").read_text()
    app_root = (repo_root / "src" / "wildcoil" / "scripts" / "app_root.gd").read_text()
    docs = (repo_root / "docs" / "macos_build_and_distribution.md").read_text()
    handoff = (
        repo_root
        / "docs"
        / "playtest-captures"
        / "stage1-marketability-handoff-2026-05-10.md"
    ).read_text()
    audit = (repo_root / "docs" / "market-readiness-audit-2026-05-10.md").read_text()

    assert "Rift Road.zip" in script
    assert "open -n" in script
    assert "--rift-road-focus-resume-smoke" in script
    assert "--rift-road-focus-resume-output=" in script
    assert "--rift-road-focus-resume-capture-dir=" in script
    assert "stage1-exported-app-focus-resume.json" in script
    assert "stage1-exported-app-focus-resume.png" in script
    assert "RIFT_ROAD_EXPORTED_FOCUS_RESUME ok" in script
    assert "FOCUS_RESUME_SMOKE_ARG" in app_root
    assert "FOCUS_RESUME_OUTPUT_PREFIX" in app_root
    assert "FOCUS_RESUME_CAPTURE_NAME" in app_root
    assert "_run_exported_focus_resume_smoke" in app_root
    assert "focus_pause" in app_root
    assert "audio" in app_root
    assert "scripts/smoke_exported_focus_resume.sh" in docs
    assert "RIFT_ROAD_EXPORTED_FOCUS_RESUME ok" in handoff
    assert "RIFT_ROAD_EXPORTED_FOCUS_RESUME ok" in audit


def test_exported_app_smoke_script_captures_stage_clear_viewport(repo_root):
    script = (repo_root / "scripts" / "smoke_exported_macos_app.sh").read_text()
    app_root = (repo_root / "src" / "wildcoil" / "scripts" / "app_root.gd").read_text()
    handoff = (
        repo_root
        / "docs"
        / "playtest-captures"
        / "stage1-marketability-handoff-2026-05-10.md"
    ).read_text()
    audit = (repo_root / "docs" / "market-readiness-audit-2026-05-10.md").read_text()

    assert "stage1-exported-app-smoke-stage-clear.png" in script
    assert "STAGE_CLEAR_CAPTURE" in script
    assert "stage_clear_capture=" in script
    assert "SMOKE_STAGE_CLEAR_CAPTURE_NAME" in app_root
    assert "_fast_forward_stage1_smoke_to_stage_clear" in app_root
    assert "mode != \"stage_clear\"" in app_root
    assert "stage1-exported-app-smoke-stage-clear.png" in handoff
    assert "stage1-exported-app-smoke-stage-clear.png" in audit


def test_exported_app_smoke_script_captures_post_intro_combat_viewport(repo_root):
    script = (repo_root / "scripts" / "smoke_exported_macos_app.sh").read_text()
    app_root = (repo_root / "src" / "wildcoil" / "scripts" / "app_root.gd").read_text()
    handoff = (
        repo_root
        / "docs"
        / "playtest-captures"
        / "stage1-marketability-handoff-2026-05-10.md"
    ).read_text()
    audit = (repo_root / "docs" / "market-readiness-audit-2026-05-10.md").read_text()

    assert "stage1-exported-app-smoke-combat.png" in script
    assert "COMBAT_CAPTURE" in script
    assert "combat_capture=" in script
    assert "SMOKE_COMBAT_CAPTURE_NAME" in app_root
    assert "_show_combat_action_smoke_capture" in app_root
    combat_capture_section = app_root[
        app_root.index("func _show_combat_action_smoke_capture"):
        app_root.index("func _fast_forward_stage1_smoke_to_stage_clear")
    ]
    assert "create_timer" in combat_capture_section
    assert "mode != \"stage\"" in app_root
    assert "stage1-exported-app-smoke-combat.png" in handoff
    assert "stage1-exported-app-smoke-combat.png" in audit


def test_exported_app_smoke_script_captures_road_collapse_viewport(repo_root):
    script = (repo_root / "scripts" / "smoke_exported_macos_app.sh").read_text()
    app_root = (repo_root / "src" / "wildcoil" / "scripts" / "app_root.gd").read_text()
    handoff = (
        repo_root
        / "docs"
        / "playtest-captures"
        / "stage1-marketability-handoff-2026-05-10.md"
    ).read_text()
    audit = (repo_root / "docs" / "market-readiness-audit-2026-05-10.md").read_text()

    assert "stage1-exported-app-smoke-road-collapse.png" in script
    assert "ROAD_COLLAPSE_CAPTURE" in script
    assert "road_collapse_capture=" in script
    assert "SMOKE_ROAD_COLLAPSE_CAPTURE_NAME" in app_root
    assert "_show_road_collapse_smoke_capture" in app_root
    assert "road_collapse_triggered" in app_root
    assert "stage1-exported-app-smoke-road-collapse.png" in handoff
    assert "stage1-exported-app-smoke-road-collapse.png" in audit


def test_exported_app_smoke_script_captures_brask_intro_viewport(repo_root):
    script = (repo_root / "scripts" / "smoke_exported_macos_app.sh").read_text()
    app_root = (repo_root / "src" / "wildcoil" / "scripts" / "app_root.gd").read_text()
    handoff = (
        repo_root
        / "docs"
        / "playtest-captures"
        / "stage1-marketability-handoff-2026-05-10.md"
    ).read_text()
    audit = (repo_root / "docs" / "market-readiness-audit-2026-05-10.md").read_text()

    assert "stage1-exported-app-smoke-brask-intro.png" in script
    assert "BRASK_INTRO_CAPTURE" in script
    assert "brask_intro_capture=" in script
    assert "SMOKE_BRASK_INTRO_CAPTURE_NAME" in app_root
    assert "_show_brask_intro_smoke_capture" in app_root
    assert "boss_started" in app_root
    assert "stage1-exported-app-smoke-brask-intro.png" in handoff
    assert "stage1-exported-app-smoke-brask-intro.png" in audit


def test_exported_app_smoke_script_captures_pickup_clarity_viewport(repo_root):
    script = (repo_root / "scripts" / "smoke_exported_macos_app.sh").read_text()
    app_root = (repo_root / "src" / "wildcoil" / "scripts" / "app_root.gd").read_text()
    handoff = (
        repo_root
        / "docs"
        / "playtest-captures"
        / "stage1-marketability-handoff-2026-05-10.md"
    ).read_text()
    audit = (repo_root / "docs" / "market-readiness-audit-2026-05-10.md").read_text()

    assert "stage1-exported-app-smoke-pickups.png" in script
    assert "PICKUP_CAPTURE" in script
    assert "pickup_capture=" in script
    assert "SMOKE_PICKUP_CAPTURE_NAME" in app_root
    assert "_show_pickup_smoke_capture" in app_root
    assert "spawn_pickup(\"glowfruit\"" in app_root
    assert "spawn_pickup(\"luma_shard\"" in app_root
    assert "stage1-exported-app-smoke-pickups.png" in handoff
    assert "stage1-exported-app-smoke-pickups.png" in audit


def test_exported_app_smoke_script_captures_game_over_viewport(repo_root):
    script = (repo_root / "scripts" / "smoke_exported_macos_app.sh").read_text()
    app_root = (repo_root / "src" / "wildcoil" / "scripts" / "app_root.gd").read_text()
    handoff = (
        repo_root
        / "docs"
        / "playtest-captures"
        / "stage1-marketability-handoff-2026-05-10.md"
    ).read_text()
    audit = (repo_root / "docs" / "market-readiness-audit-2026-05-10.md").read_text()

    assert "stage1-exported-app-smoke-game-over.png" in script
    assert "GAME_OVER_CAPTURE" in script
    assert "game_over_capture=" in script
    assert "SMOKE_GAME_OVER_CAPTURE_NAME" in app_root
    assert "_show_game_over_smoke_capture" in app_root
    assert "mode != \"game_over\"" in app_root
    assert "stage1-exported-app-smoke-game-over.png" in handoff
    assert "stage1-exported-app-smoke-game-over.png" in audit


def test_exported_app_smoke_script_captures_retry_gameplay_viewport(repo_root):
    script = (repo_root / "scripts" / "smoke_exported_macos_app.sh").read_text()
    app_root = (repo_root / "src" / "wildcoil" / "scripts" / "app_root.gd").read_text()
    handoff = (
        repo_root
        / "docs"
        / "playtest-captures"
        / "stage1-marketability-handoff-2026-05-10.md"
    ).read_text()
    audit = (repo_root / "docs" / "market-readiness-audit-2026-05-10.md").read_text()

    assert "stage1-exported-app-smoke-retry-gameplay.png" in script
    assert "RETRY_GAMEPLAY_CAPTURE" in script
    assert "retry_gameplay_capture=" in script
    assert "SMOKE_RETRY_GAMEPLAY_CAPTURE_NAME" in app_root
    assert "_show_retry_gameplay_smoke_capture" in app_root
    assert "mode != \"stage\"" in app_root
    assert "stage1-exported-app-smoke-retry-gameplay.png" in handoff
    assert "stage1-exported-app-smoke-retry-gameplay.png" in audit


def test_exported_app_keyboard_fallback_smoke_records_input_artifacts(repo_root):
    script = (repo_root / "scripts" / "smoke_exported_keyboard_fallback.sh").read_text()
    app_root = (repo_root / "src" / "wildcoil" / "scripts" / "app_root.gd").read_text()
    docs = (repo_root / "docs" / "macos_build_and_distribution.md").read_text()
    handoff = (
        repo_root
        / "docs"
        / "playtest-captures"
        / "stage1-marketability-handoff-2026-05-10.md"
    ).read_text()
    audit = (repo_root / "docs" / "market-readiness-audit-2026-05-10.md").read_text()

    assert "Rift Road.zip" in script
    assert "open -n" in script
    assert "--rift-road-keyboard-fallback-smoke" in script
    assert "--rift-road-keyboard-fallback-output=" in script
    assert "--rift-road-keyboard-fallback-capture-dir=" in script
    assert "stage1-exported-app-keyboard-fallback.json" in script
    assert "stage1-exported-app-keyboard-fallback.png" in script
    assert "RIFT_ROAD_EXPORTED_KEYBOARD_FALLBACK ok" in script
    assert "KEYBOARD_FALLBACK_SMOKE_ARG" in app_root
    assert "_run_exported_keyboard_fallback_smoke" in app_root
    assert "RIFT_ROAD_EXPORTED_KEYBOARD_FALLBACK" in app_root
    assert "scripts/smoke_exported_keyboard_fallback.sh" in docs
    assert "stage1-exported-app-keyboard-fallback.json" in handoff
    assert "stage1-exported-app-keyboard-fallback.json" in audit


def test_public_playtest_gate_packet_defines_evidence_thresholds(repo_root):
    packet_path = repo_root / "docs" / "public_playtest_gate.md"
    packet = packet_path.read_text()
    audit = (repo_root / "docs" / "market-readiness-audit-2026-05-10.md").read_text()
    playtest_log = (repo_root / "docs" / "playtest_log.md").read_text()

    assert "build/macos/Rift Road.zip" in packet
    assert "RIFT_ROAD_PACKAGE_AUDIT internal-only" in packet
    assert "scripts/smoke_exported_macos_app.sh" in packet
    assert "5 to 8 external sessions" in packet
    assert "title -> hero select -> Stage 1" in packet
    assert "clear/fail/retry" in packet
    assert "replay intent" in packet
    assert "willingness to pay" in packet
    assert "Do not claim marketable" in packet
    assert "docs/public_playtest_gate.md" in audit
    assert "docs/public_playtest_gate.md" in playtest_log


def test_release_candidate_gate_combines_automated_and_manual_blockers(repo_root):
    script = (repo_root / "scripts" / "check_release_candidate.sh").read_text()
    docs = (repo_root / "docs" / "macos_build_and_distribution.md").read_text()
    audit = (repo_root / "docs" / "market-readiness-audit-2026-05-10.md").read_text()

    assert "scripts/check.sh" in script
    assert "scripts/package_macos.sh" in script
    assert "scripts/check_macos_signing_env.sh" in script
    assert "scripts/audit_macos_package.sh" in script
    assert "scripts/smoke_exported_macos_app.sh" in script
    assert "scripts/smoke_exported_keyboard_fallback.sh" in script
    assert "scripts/smoke_exported_focus_resume.sh" in script
    assert "scripts/sample_exported_app_performance.sh" in script
    assert "scripts/check_playtest_evidence.sh" in script
    assert "scripts/check_second_machine_evidence.sh" in script
    assert "scripts/check_controller_evidence.sh" in script
    assert "stage1_performance_sample" in script
    assert "RIFT_ROAD_PACKAGE_AUDIT release-candidate" in script
    assert "RIFT_ROAD_PLAYTEST_EVIDENCE public-playtest-candidate" in script
    assert "RIFT_ROAD_SECOND_MACHINE_EVIDENCE ok" in script
    assert "RIFT_ROAD_CONTROLLER_EVIDENCE ok" in script
    assert "RIFT_ROAD_EXPORTED_KEYBOARD_FALLBACK ok" in script
    assert "RIFT_ROAD_EXPORTED_FOCUS_RESUME ok" in script
    assert "Public playtest or release-candidate proof" in script
    assert "Player love / commercial viability" in script
    assert "RIFT_ROAD_RELEASE_GATE blocked" in script
    assert "scripts/check_release_candidate.sh" in docs
    assert "scripts/check_release_candidate.sh" in audit


def test_macos_signing_preflight_defines_non_secret_release_inputs(repo_root):
    script = (repo_root / "scripts" / "check_macos_signing_env.sh").read_text()
    macos_docs = (repo_root / "docs" / "macos_build_and_distribution.md").read_text()
    security_docs = (repo_root / "docs" / "SECURITY.md").read_text()
    audit = (repo_root / "docs" / "market-readiness-audit-2026-05-10.md").read_text()
    example_env = (repo_root / "docs" / "macos_release_inputs.example.env").read_text()

    assert "RIFT_ROAD_APPLE_TEAM_ID" in script
    assert "RIFT_ROAD_DEVELOPER_ID_APPLICATION" in script
    assert "RIFT_ROAD_NOTARY_KEYCHAIN_PROFILE" in script
    assert "security find-identity" in script
    assert "xcrun" in script
    assert "notarytool" in script
    assert "RIFT_ROAD_SIGNING_PREFLIGHT blocked" in script
    assert "codesign/apple_team_id" in script
    assert "notarization/notarization=0" in script
    assert "scripts/check_macos_signing_env.sh" in macos_docs
    assert "scripts/check_macos_signing_env.sh" in security_docs
    assert "scripts/check_macos_signing_env.sh" in audit
    assert "docs/macos_release_inputs.example.env" in macos_docs
    assert "docs/macos_release_inputs.example.env" in security_docs
    assert "RIFT_ROAD_APPLE_TEAM_ID" in example_env
    assert "RIFT_ROAD_DEVELOPER_ID_APPLICATION" in example_env
    assert "RIFT_ROAD_NOTARY_KEYCHAIN_PROFILE" in example_env
    assert "Do not commit real values" in example_env


def test_macos_sign_notarize_script_defines_release_artifact_path(repo_root):
    script_path = repo_root / "scripts" / "sign_notarize_macos.sh"
    script = script_path.read_text()
    docs = (repo_root / "docs" / "macos_build_and_distribution.md").read_text()
    public_gate = (repo_root / "docs" / "public_playtest_gate.md").read_text()
    example_env = (repo_root / "docs" / "macos_release_inputs.example.env").read_text()
    audit = (repo_root / "docs" / "market-readiness-audit-2026-05-10.md").read_text()

    assert "RIFT_ROAD_APPLE_TEAM_ID" in script
    assert "RIFT_ROAD_DEVELOPER_ID_APPLICATION" in script
    assert "RIFT_ROAD_NOTARY_KEYCHAIN_PROFILE" in script
    assert "codesign --force --deep --options runtime --timestamp --sign" in script
    assert "xcrun notarytool submit" in script
    assert "--keychain-profile" in script
    assert "--team-id" in script
    assert "--wait" in script
    assert "stapler staple" in script
    assert "stapler validate" in script
    assert "spctl -a -vv --type execute" in script
    assert "RIFT_ROAD_RELEASE_SIGNING blocked" in script
    assert "RIFT_ROAD_RELEASE_SIGNING ok" in script
    assert "Rift Road-signed-notarized.zip" in script
    assert "scripts/audit_macos_package.sh" in script
    assert "RIFT_ROAD_AUDIT_ARTIFACT_ONLY=1" in script
    assert "scripts/sign_notarize_macos.sh" in docs
    assert "scripts/sign_notarize_macos.sh" in public_gate
    assert "scripts/sign_notarize_macos.sh" in example_env
    assert "scripts/sign_notarize_macos.sh" in audit

    help_result = subprocess.run(
        ["bash", str(script_path), "--help"],
        cwd=repo_root,
        capture_output=True,
        text=True,
        check=False,
    )
    assert help_result.returncode == 0
    assert "RIFT_ROAD_DEVELOPER_ID_APPLICATION" in help_result.stdout

    blocked_result = subprocess.run(
        [
            "bash",
            "-c",
            "unset RIFT_ROAD_APPLE_TEAM_ID RIFT_ROAD_DEVELOPER_ID_APPLICATION RIFT_ROAD_NOTARY_KEYCHAIN_PROFILE; bash scripts/sign_notarize_macos.sh",
        ],
        cwd=repo_root,
        capture_output=True,
        text=True,
        check=False,
    )
    assert blocked_result.returncode == 1
    blocked_output = blocked_result.stdout + blocked_result.stderr
    assert "RIFT_ROAD_RELEASE_SIGNING blocked" in blocked_output
    assert "RIFT_ROAD_APPLE_TEAM_ID" in blocked_output


def test_exported_app_performance_sampler_records_rendered_metrics(repo_root):
    script = (repo_root / "scripts" / "sample_exported_app_performance.sh").read_text()
    app_root = (repo_root / "src" / "wildcoil" / "scripts" / "app_root.gd").read_text()
    perf_docs = (repo_root / "docs" / "performance_budget.md").read_text()
    audit = (repo_root / "docs" / "market-readiness-audit-2026-05-10.md").read_text()

    assert "--rift-road-render-perf-sample" in script
    assert "--rift-road-render-perf-output=" in script
    assert "RIFT_ROAD_EXPORTED_PERF stage1" in script
    assert "stage1-exported-performance.json" in script
    assert "python3" in script
    assert "--rift-road-render-perf-sample" in app_root
    assert "_finish_render_perf_sample" in app_root
    assert "JSON.stringify" in app_root
    assert "RIFT_ROAD_EXPORTED_PERF stage1" in app_root
    assert "scripts/sample_exported_app_performance.sh" in perf_docs
    assert "scripts/sample_exported_app_performance.sh" in audit


def test_exported_app_performance_sampler_discards_startup_warmup(repo_root):
    app_root = (repo_root / "src" / "wildcoil" / "scripts" / "app_root.gd").read_text()
    perf_docs = (repo_root / "docs" / "performance_budget.md").read_text()

    assert "RENDER_PERF_WARMUP_FRAMES" in app_root
    assert "render_perf_warmup_frames_remaining" in app_root
    assert "render_perf_warmup_frames_remaining -= 1" in app_root
    assert "render_perf_frame_ms.append" in app_root
    assert app_root.index("render_perf_warmup_frames_remaining -= 1") < app_root.index("render_perf_frame_ms.append")
    assert '"warmup_frames"' in app_root
    assert "startup/render warmup frames" in perf_docs


def test_exported_app_performance_sampler_normalizes_launched_app_paths(repo_root):
    script = (repo_root / "scripts" / "sample_exported_app_performance.sh").read_text()

    assert 'PACKAGE_PATH="$(cd "$(dirname "$PACKAGE_PATH")" && pwd -P)/$(basename "$PACKAGE_PATH")"' in script
    assert 'OUTPUT_DIR="$(cd "$OUTPUT_DIR" && pwd -P)"' in script
    assert script.index('OUTPUT_DIR="$(cd "$OUTPUT_DIR" && pwd -P)"') < script.index('OUTPUT_JSON="$OUTPUT_DIR/stage1-exported-performance.json"')


def test_exported_app_performance_sampler_supports_window_size_mode(repo_root):
    script = (repo_root / "scripts" / "sample_exported_app_performance.sh").read_text()
    app_root = (repo_root / "src" / "wildcoil" / "scripts" / "app_root.gd").read_text()
    perf_docs = (repo_root / "docs" / "performance_budget.md").read_text()

    assert "RIFT_ROAD_PERF_WINDOW_SIZE" in script
    assert "RIFT_ROAD_PERF_WINDOW_MODE" in script
    assert "--rift-road-render-perf-window-size=" in script
    assert "--rift-road-render-perf-window-mode=" in script
    assert "WINDOW_SIZE_ARG" in script
    assert "WINDOW_MODE_ARG" in script
    assert "RIFT_ROAD_PERF_WINDOW_SIZE=1920x1080" in perf_docs
    assert "windowed 1080p" in perf_docs
    assert "RENDER_PERF_WINDOW_SIZE_PREFIX" in app_root
    assert "RENDER_PERF_WINDOW_MODE_PREFIX" in app_root
    assert "_configure_render_perf_window" in app_root
    assert "DisplayServer.window_set_size" in app_root
    assert '"window_size"' in app_root
    assert '"window_mode"' in app_root


def test_exported_app_performance_docs_track_fullscreen_sample(repo_root):
    perf_docs = (repo_root / "docs" / "performance_budget.md").read_text()
    packet = (repo_root / "docs" / "public_playtest_gate.md").read_text()
    audit = (repo_root / "docs" / "market-readiness-audit-2026-05-10.md").read_text()
    handoff = (
        repo_root
        / "docs"
        / "playtest-captures"
        / "stage1-marketability-handoff-2026-05-10.md"
    ).read_text()

    assert "RIFT_ROAD_PERF_WINDOW_MODE=fullscreen" in perf_docs
    assert "exported-app-performance-fullscreen-latest" in perf_docs
    assert "window_mode=fullscreen" in perf_docs
    assert "fullscreen exported-app performance sample command" in packet
    assert "exported-app-performance-fullscreen-latest" in packet
    assert "local fullscreen exported-app result" in audit
    assert "fullscreen exported-app performance" in handoff


def test_performance_docs_record_local_apple_silicon_host(repo_root):
    host_profile_path = (
        repo_root
        / "docs"
        / "playtest-captures"
        / "performance-host-latest"
        / "host-profile.md"
    )
    perf_docs = (repo_root / "docs" / "performance_budget.md").read_text()
    audit = (repo_root / "docs" / "market-readiness-audit-2026-05-10.md").read_text()
    handoff = (
        repo_root
        / "docs"
        / "playtest-captures"
        / "stage1-marketability-handoff-2026-05-10.md"
    ).read_text()

    assert host_profile_path.exists()
    host_profile = host_profile_path.read_text()
    assert "Architecture: `arm64`" in host_profile
    assert "CPU: `Apple M1`" in host_profile
    assert "Model: `iMac21,2`" in host_profile
    assert "Memory: `16 GB`" in host_profile
    assert "macOS: `26.5`" in host_profile
    assert "performance-host-latest/host-profile.md" in perf_docs
    assert "local Apple Silicon Mac A" in perf_docs
    assert "not second-machine proof" in perf_docs
    assert "local Apple Silicon Mac A" in audit
    assert "local Apple Silicon Mac A" in handoff


def test_known_tester_packet_script_collects_internal_build_evidence(repo_root):
    script = (repo_root / "scripts" / "prepare_known_tester_packet.sh").read_text()
    packet = (repo_root / "docs" / "public_playtest_gate.md").read_text()
    macos_docs = (repo_root / "docs" / "macos_build_and_distribution.md").read_text()
    handoff = (
        repo_root
        / "docs"
        / "playtest-captures"
        / "stage1-marketability-handoff-2026-05-10.md"
    ).read_text()
    tracker = (repo_root / "to-do.md").read_text()

    assert "RIFT_ROAD_KNOWN_TESTER_PACKET" in script
    assert "build/known-tester-packet/latest" in script
    assert "manifest.md" in script
    assert "internal-only" in script
    assert "scripts/check.sh" in script
    assert "scripts/package_macos.sh" in script
    assert "scripts/check_macos_signing_env.sh" in script
    assert "scripts/audit_macos_package.sh" in script
    assert "scripts/smoke_exported_macos_app.sh" in script
    assert "scripts/smoke_exported_keyboard_fallback.sh" in script
    assert "scripts/smoke_exported_focus_resume.sh" in script
    assert "scripts/sample_exported_app_performance.sh" in script
    assert "Rift Road.zip" in script
    assert "docs/public_playtest_gate.md" in script
    assert "exported-app-smoke-latest" in script
    assert "keyboard-fallback-latest" in script
    assert "focus-resume-latest" in script
    assert "exported-app-performance-latest" in script
    assert "exported-app-performance-fullscreen-latest" in script
    assert "performance-host-latest" in script
    assert "git -C \"$ROOT_DIR\" rev-parse --short HEAD" in script
    assert "shasum -a 256 \"$PACKAGE_PATH\"" in script
    assert "printf '-" not in script
    assert "printf -- '- Package: `Rift Road.zip`\\n'" in script
    assert "printf -- '- Build commit: `%s`\\n' \"$BUILD_COMMIT\"" in script
    assert "printf -- '- Package SHA256: `%s`\\n' \"$PACKAGE_SHA256\"" in script
    assert "printf -- '- `logs/check.log`\\n'" in script
    assert "printf -- '- `logs/exported_app_keyboard_fallback.log`\\n'" in script
    assert "printf -- '- `logs/exported_app_focus_resume.log`\\n'" in script
    assert "printf -- '- `evidence/keyboard-fallback-latest/`\\n'" in script
    assert "printf -- '- `evidence/focus-resume-latest/`\\n'" in script
    assert "scripts/prepare_known_tester_packet.sh" in packet
    assert "scripts/prepare_known_tester_packet.sh" in macos_docs
    assert "known-tester packet" in handoff
    assert "### [RR-PROD-27] Add known-tester packet command" in tracker


def test_known_tester_packet_includes_manual_gate_checklists(repo_root):
    script = (repo_root / "scripts" / "prepare_known_tester_packet.sh").read_text()
    packet = (repo_root / "docs" / "public_playtest_gate.md").read_text()
    handoff = (
        repo_root
        / "docs"
        / "playtest-captures"
        / "stage1-marketability-handoff-2026-05-10.md"
    ).read_text()
    tracker = (repo_root / "to-do.md").read_text()

    assert "docs/controller_validation.md" in script
    assert "docs/second_machine_validation.md" in script
    assert "Controller validation checklist" in script
    assert "Second-machine validation checklist" in script
    assert "docs/controller_validation.md" in packet
    assert "docs/second_machine_validation.md" in packet
    assert "controller and second-machine checklists" in handoff
    assert "### [RR-PROD-37] Bundle manual-gate checklists in tester packet" in tracker


def test_playtest_evidence_gate_blocks_without_external_sessions(repo_root):
    script_path = repo_root / "scripts" / "check_playtest_evidence.sh"
    script = script_path.read_text()
    packet = (repo_root / "docs" / "public_playtest_gate.md").read_text()
    playtest_log = (repo_root / "docs" / "playtest_log.md").read_text()
    audit = (repo_root / "docs" / "market-readiness-audit-2026-05-10.md").read_text()

    assert "RIFT_ROAD_PLAYTEST_EVIDENCE blocked" in script
    assert "RIFT_ROAD_PLAYTEST_EVIDENCE public-playtest-candidate" in script
    assert "controller-family=" in script
    assert "machine=second-mac" in script
    assert "scripts/check_playtest_evidence.sh" in packet
    assert "scripts/check_playtest_evidence.sh" in playtest_log
    assert "scripts/check_playtest_evidence.sh" in audit

    result = subprocess.run(
        ["bash", str(script_path)],
        cwd=repo_root,
        capture_output=True,
        text=True,
        check=False,
    )

    assert result.returncode == 1
    output = result.stdout + result.stderr
    assert "RIFT_ROAD_PLAYTEST_EVIDENCE blocked" in output
    assert "sessions=0/5" in output
    assert "second_mac=0/1" in output
    assert "controller_families=0/2" in output


def test_second_machine_evidence_gate_blocks_without_clean_machine_proof(repo_root):
    script_path = repo_root / "scripts" / "check_second_machine_evidence.sh"
    script = script_path.read_text()
    docs = (repo_root / "docs" / "second_machine_validation.md").read_text()
    packet = (repo_root / "docs" / "public_playtest_gate.md").read_text()
    audit = (repo_root / "docs" / "market-readiness-audit-2026-05-10.md").read_text()

    assert "RIFT_ROAD_SECOND_MACHINE_EVIDENCE blocked" in script
    assert "RIFT_ROAD_SECOND_MACHINE_EVIDENCE ok" in script
    assert "stage1-second-machine-title.png" in script
    assert "stage1-second-machine-gameplay.png" in script
    assert "RIFT_ROAD_SECOND_MACHINE_INSTALL ok" in script
    assert "docs/playtest-captures/second-machine-latest" in docs
    assert "scripts/check_second_machine_evidence.sh" in docs
    assert "scripts/check_second_machine_evidence.sh" in packet
    assert "scripts/check_second_machine_evidence.sh" in audit

    result = subprocess.run(
        ["bash", str(script_path)],
        cwd=repo_root,
        capture_output=True,
        text=True,
        check=False,
    )

    assert result.returncode == 1
    output = result.stdout + result.stderr
    assert "RIFT_ROAD_SECOND_MACHINE_EVIDENCE blocked" in output
    assert "second-machine-latest/host-profile.md" in output
    assert "second-machine-latest/install-smoke.md" in output


def test_second_machine_evidence_collector_is_bundled_for_known_testers(repo_root):
    script_path = repo_root / "scripts" / "collect_second_machine_evidence.sh"
    script = script_path.read_text()
    packet_script = (repo_root / "scripts" / "prepare_known_tester_packet.sh").read_text()
    docs = (repo_root / "docs" / "second_machine_validation.md").read_text()
    public_gate = (repo_root / "docs" / "public_playtest_gate.md").read_text()
    handoff = (
        repo_root
        / "docs"
        / "playtest-captures"
        / "stage1-marketability-handoff-2026-05-10.md"
    ).read_text()

    assert "RIFT_ROAD_SECOND_MACHINE_LABEL" in script
    assert "Apple Silicon Mac B" in script
    assert "scripts/audit_macos_package.sh" in script
    assert "scripts/smoke_exported_macos_app.sh" in script
    assert "stage1-second-machine-title.png" in script
    assert "stage1-second-machine-gameplay.png" in script
    assert "RIFT_ROAD_SECOND_MACHINE_INSTALL ok" in script
    assert "RIFT_ROAD_SECOND_MACHINE_COLLECTOR" in script
    assert "scripts/collect_second_machine_evidence.sh" in packet_script
    assert "scripts/audit_macos_package.sh" in packet_script
    assert "scripts/smoke_exported_macos_app.sh" in packet_script
    assert "Second-machine evidence collector" in packet_script
    assert "scripts/collect_second_machine_evidence.sh" in docs
    assert "scripts/collect_second_machine_evidence.sh" in public_gate
    assert "second-machine evidence collector" in handoff

    result = subprocess.run(
        ["bash", str(script_path), "--help"],
        cwd=repo_root,
        capture_output=True,
        text=True,
        check=False,
    )

    assert result.returncode == 0
    assert "RIFT_ROAD_SECOND_MACHINE_LABEL" in result.stdout
    assert "Apple Silicon Mac B" in result.stdout


def test_controller_evidence_gate_blocks_without_physical_controller_sessions(repo_root):
    script_path = repo_root / "scripts" / "check_controller_evidence.sh"
    script = script_path.read_text()
    docs = (repo_root / "docs" / "controller_validation.md").read_text()
    macos_docs = (repo_root / "docs" / "macos_build_and_distribution.md").read_text()
    audit = (repo_root / "docs" / "market-readiness-audit-2026-05-10.md").read_text()

    assert "RIFT_ROAD_CONTROLLER_EVIDENCE blocked" in script
    assert "RIFT_ROAD_CONTROLLER_EVIDENCE ok" in script
    assert "RIFT_ROAD_CONTROLLER_SESSION ok" in script
    assert "RIFT_ROAD_KEYBOARD_FALLBACK ok" in script
    assert "Hero select: `pass`" in script
    assert "Cancel/back: `pass`" in script
    assert "docs/controller_validation.md" in docs
    assert "scripts/check_controller_evidence.sh" in docs
    assert "scripts/check_controller_evidence.sh" in macos_docs
    assert "scripts/check_controller_evidence.sh" in audit

    result = subprocess.run(
        ["bash", str(script_path)],
        cwd=repo_root,
        capture_output=True,
        text=True,
        check=False,
    )

    assert result.returncode == 1
    output = result.stdout + result.stderr
    assert "RIFT_ROAD_CONTROLLER_EVIDENCE blocked" in output
    assert "controller_families=0/2" in output
    assert "keyboard_fallback=0/1" in output
    assert "controller session missing Controller family" not in output
    assert "keyboard fallback missing checks" not in output


def test_controller_evidence_collector_scaffolds_real_manual_sessions(repo_root):
    script_path = repo_root / "scripts" / "collect_controller_evidence.sh"
    script = script_path.read_text()
    docs = (repo_root / "docs" / "controller_validation.md").read_text()
    packet_script = (repo_root / "scripts" / "prepare_known_tester_packet.sh").read_text()
    public_gate = (repo_root / "docs" / "public_playtest_gate.md").read_text()
    handoff = (
        repo_root
        / "docs"
        / "playtest-captures"
        / "stage1-marketability-handoff-2026-05-10.md"
    ).read_text()
    audit = (repo_root / "docs" / "market-readiness-audit-2026-05-10.md").read_text()

    assert "RIFT_ROAD_CONTROLLER_EVIDENCE_COLLECTOR blocked" in script
    assert "RIFT_ROAD_CONTROLLER_EVIDENCE_COLLECTOR ok" in script
    assert "--session-type" in script
    assert "--controller-family" in script
    assert "--device-name" in script
    assert "--connection" in script
    assert "--confirm-title" in script
    assert "--confirm-cancel-back" in script
    assert "docs/playtest-captures/controller" in script
    assert "RIFT_ROAD_CONTROLLER_SESSION ok" in script
    assert "RIFT_ROAD_KEYBOARD_FALLBACK ok" in script
    assert "Title: `pass`" in script
    assert "Hero select: `pass`" in script
    assert "Stage 1 movement: `pass`" in script
    assert "Cancel/back: `pass`" in script
    assert "scripts/check_controller_evidence.sh" in script
    assert "scripts/collect_controller_evidence.sh" in docs
    assert "scripts/collect_controller_evidence.sh" in packet_script
    assert "Controller evidence collector" in packet_script
    assert "scripts/collect_controller_evidence.sh" in public_gate
    assert "controller evidence collector" in handoff
    assert "scripts/collect_controller_evidence.sh" in audit

    help_result = subprocess.run(
        ["bash", str(script_path), "--help"],
        cwd=repo_root,
        capture_output=True,
        text=True,
        check=False,
    )
    assert help_result.returncode == 0
    assert "--session-type controller" in help_result.stdout
    assert "--session-type keyboard" in help_result.stdout

    blocked_result = subprocess.run(
        ["bash", str(script_path)],
        cwd=repo_root,
        capture_output=True,
        text=True,
        check=False,
    )
    assert blocked_result.returncode == 1
    blocked_output = blocked_result.stdout + blocked_result.stderr
    assert "RIFT_ROAD_CONTROLLER_EVIDENCE_COLLECTOR blocked" in blocked_output
    assert "Missing --session-type controller|keyboard" in blocked_output


def test_controller_evidence_gate_rejects_placeholder_session_metadata(
    repo_root, tmp_path
):
    script_path = repo_root / "scripts" / "check_controller_evidence.sh"
    fake_doc = tmp_path / "controller_validation.md"
    fake_doc.write_text(
        """
# Controller Validation

### Controller Session: `Placeholder Pad One`

RIFT_ROAD_CONTROLLER_SESSION ok

- Build: `TBD`
- Controller family: `arcade-pad`
- Device name: `TBD`
- Connection: `TBD`
- Evidence capture: `TBD`
- Title: `pass`
- Hero select: `pass`
- Stage 1 movement: `pass`
- Attack: `pass`
- Jump: `pass`
- Special: `pass`
- Dash: `pass`
- Pause: `pass`
- Cancel/back: `pass`
- Blockers: `TBD`

### Controller Session: `Placeholder Pad Two`

RIFT_ROAD_CONTROLLER_SESSION ok

- Build: `TBD`
- Controller family: `console-pad`
- Device name: `TBD`
- Connection: `TBD`
- Evidence capture: `TBD`
- Title: `pass`
- Hero select: `pass`
- Stage 1 movement: `pass`
- Attack: `pass`
- Jump: `pass`
- Special: `pass`
- Dash: `pass`
- Pause: `pass`
- Cancel/back: `pass`
- Blockers: `TBD`

### Keyboard Fallback Session

RIFT_ROAD_KEYBOARD_FALLBACK ok

- Build: `TBD`
- Evidence capture: `TBD`
- Title: `pass`
- Hero select: `pass`
- Stage 1 movement: `pass`
- Attack: `pass`
- Jump: `pass`
- Special: `pass`
- Dash: `pass`
- Pause: `pass`
- Cancel/back: `pass`
- Blockers: `TBD`
""".strip()
    )

    result = subprocess.run(
        ["bash", str(script_path), str(fake_doc)],
        cwd=repo_root,
        capture_output=True,
        text=True,
        check=False,
    )

    assert result.returncode == 1
    output = result.stdout + result.stderr
    assert "RIFT_ROAD_CONTROLLER_EVIDENCE blocked" in output
    assert "placeholder metadata" in output
    assert "Device name" in output
    assert "Evidence capture" in output


def test_controller_evidence_gate_rejects_missing_evidence_files(
    repo_root, tmp_path
):
    script_path = repo_root / "scripts" / "check_controller_evidence.sh"
    fake_doc = tmp_path / "controller_validation.md"
    fake_doc.write_text(
        """
# Controller Validation

### Controller Session: `Arcade Pad`

RIFT_ROAD_CONTROLLER_SESSION ok

- Build: `759cb78`
- Controller family: `arcade-pad`
- Device name: `Example Arcade Pad`
- Connection: `usb`
- Evidence capture: `docs/playtest-captures/controller/missing-arcade-pad.mov`
- Title: `pass`
- Hero select: `pass`
- Stage 1 movement: `pass`
- Attack: `pass`
- Jump: `pass`
- Special: `pass`
- Dash: `pass`
- Pause: `pass`
- Cancel/back: `pass`
- Blockers: `none`

### Controller Session: `Console Pad`

RIFT_ROAD_CONTROLLER_SESSION ok

- Build: `759cb78`
- Controller family: `console-pad`
- Device name: `Example Console Pad`
- Connection: `bluetooth`
- Evidence capture: `docs/playtest-captures/controller/missing-console-pad.mov`
- Title: `pass`
- Hero select: `pass`
- Stage 1 movement: `pass`
- Attack: `pass`
- Jump: `pass`
- Special: `pass`
- Dash: `pass`
- Pause: `pass`
- Cancel/back: `pass`
- Blockers: `none`

### Keyboard Fallback Session

RIFT_ROAD_KEYBOARD_FALLBACK ok

- Build: `759cb78`
- Evidence capture: `docs/playtest-captures/controller/missing-keyboard.mov`
- Title: `pass`
- Hero select: `pass`
- Stage 1 movement: `pass`
- Attack: `pass`
- Jump: `pass`
- Special: `pass`
- Dash: `pass`
- Pause: `pass`
- Cancel/back: `pass`
- Blockers: `none`
""".strip()
    )

    result = subprocess.run(
        ["bash", str(script_path), str(fake_doc)],
        cwd=repo_root,
        capture_output=True,
        text=True,
        check=False,
    )

    assert result.returncode == 1
    output = result.stdout + result.stderr
    assert "RIFT_ROAD_CONTROLLER_EVIDENCE blocked" in output
    assert "missing evidence file" in output
    assert "missing-arcade-pad.mov" in output
    assert "missing-keyboard.mov" in output


def test_controller_evidence_gate_accepts_complete_session_metadata(
    repo_root, tmp_path
):
    script_path = repo_root / "scripts" / "check_controller_evidence.sh"
    fake_doc = tmp_path / "controller_validation.md"
    arcade_evidence = tmp_path / "example-arcade-pad.mov"
    console_evidence = tmp_path / "example-console-pad.mov"
    keyboard_evidence = tmp_path / "example-keyboard.mov"
    for evidence_path in [arcade_evidence, console_evidence, keyboard_evidence]:
        evidence_path.write_bytes(b"evidence")
    fake_doc.write_text(
        f"""
# Controller Validation

### Controller Session: `Arcade Pad`

RIFT_ROAD_CONTROLLER_SESSION ok

- Build: `759cb78`
- Controller family: `arcade-pad`
- Device name: `Example Arcade Pad`
- Connection: `usb`
- Evidence capture: `{arcade_evidence}`
- Title: `pass`
- Hero select: `pass`
- Stage 1 movement: `pass`
- Attack: `pass`
- Jump: `pass`
- Special: `pass`
- Dash: `pass`
- Pause: `pass`
- Cancel/back: `pass`
- Blockers: `none`

### Controller Session: `Console Pad`

RIFT_ROAD_CONTROLLER_SESSION ok

- Build: `759cb78`
- Controller family: `console-pad`
- Device name: `Example Console Pad`
- Connection: `bluetooth`
- Evidence capture: `{console_evidence}`
- Title: `pass`
- Hero select: `pass`
- Stage 1 movement: `pass`
- Attack: `pass`
- Jump: `pass`
- Special: `pass`
- Dash: `pass`
- Pause: `pass`
- Cancel/back: `pass`
- Blockers: `none`

### Keyboard Fallback Session

RIFT_ROAD_KEYBOARD_FALLBACK ok

- Build: `759cb78`
- Evidence capture: `{keyboard_evidence}`
- Title: `pass`
- Hero select: `pass`
- Stage 1 movement: `pass`
- Attack: `pass`
- Jump: `pass`
- Special: `pass`
- Dash: `pass`
- Pause: `pass`
- Cancel/back: `pass`
- Blockers: `none`
""".strip()
    )

    result = subprocess.run(
        ["bash", str(script_path), str(fake_doc)],
        cwd=repo_root,
        capture_output=True,
        text=True,
        check=False,
    )

    assert result.returncode == 0
    output = result.stdout + result.stderr
    assert "RIFT_ROAD_CONTROLLER_EVIDENCE ok" in output
    assert "controller_families=2/2" in output
    assert "keyboard_fallback=1/1" in output


def test_tracker_names_next_runtime_task(repo_root):
    tracker = (repo_root / "to-do.md").read_text()

    assert "Production Vertical Slice" in tracker
    assert "docs/design-docs/stage1-visual-north-star.md" in tracker
    assert "### [RR-PROD-01] Lock Stage 1 production north star" in tracker
    assert "### [RR-PROD-10] Capture proof for handoff" in tracker
    assert "### [RR-BASELINE-01] Current playable prototype baseline" in tracker
