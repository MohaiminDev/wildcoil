# Wildcoil Godot Spike

Minimal Phase 0 micro-spike for the Godot comparison checklist.

## What It Covers

- run, jump, and dodge movement
- three-hit light combo and heavy finisher
- one telegraphed enemy with hit reactions and respawn
- keyboard controls plus controller action mapping
- autoplay and benchmark modes for unattended validation
- macOS export preset for an unsigned local `.app`

## Local Commands

Import the project:

```bash
godot --headless --path spikes/godot_wildcoil_spike --import
```

Run the project with autoplay benchmark:

```bash
godot --path spikes/godot_wildcoil_spike -- --autoplay --benchmark-spike
```

Run the exported macOS app with autoplay benchmark:

```bash
'spikes/godot_artifacts/WildcoilGodotSpike.app/Contents/MacOS/Wildcoil Godot Spike' -- --autoplay --benchmark-spike
```

Export the unsigned macOS build:

```bash
godot --headless --path spikes/godot_wildcoil_spike --export-release "macOS" ../godot_artifacts/WildcoilGodotSpike.app
```

## Export Template Setup

Godot 4.6.1 expects the macOS export template at:

`~/Library/Application Support/Godot/export_templates/4.6.1.stable/macos.zip`

The successful local setup used:

```bash
curl -L --fail -o /tmp/Godot_v4.6.1-stable_export_templates.tpz \
  https://github.com/godotengine/godot/releases/download/4.6.1-stable/Godot_v4.6.1-stable_export_templates.tpz
mkdir -p "$HOME/Library/Application Support/Godot/export_templates/4.6.1.stable"
unzip -j /tmp/Godot_v4.6.1-stable_export_templates.tpz 'templates/macos.zip' \
  -d "$HOME/Library/Application Support/Godot/export_templates/4.6.1.stable"
```
