# Wildcoil Asset Provenance Register

Track every non-trivial imported asset, tool dependency, plugin, font, audio pack, and code import here. If the source is unknown, the asset is not approved.

## Current State

As of 2026-03-05, the production scaffold uses self-authored placeholder visuals plus the Godot 4.6.1 engine toolchain. No third-party art, audio, font, or plugin package is approved for committed use. Record new items here before they become habitual dependencies.

## Register

| ID | Type | Description | Source / URL | Creator / Vendor | License | Phase used | Placeholder or permanent | Replacement needed for future open source? | Verified by | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ORIG-001 | Documentation | Project planning docs and prose in this repository | Local repository authorship | Project author | Repository license applies | Phase 0 | Permanent | No | TBD | Applies only to original written documentation |
| TMP-001 | Art | Graybox shapes, primitive materials, and temporary silhouettes authored in-engine | Self-authored at creation time | Project author | Original work | Phase 0-1 | Placeholder | No, unless external textures are added later | TBD | Safe default for early spikes |
| TOOL-001 | Engine toolchain | Godot 4.6.1 editor plus official macOS export templates used for the production scaffold | https://godotengine.org/ and official export templates bundle | Godot contributors | MIT | Phase 0-Release | Tool dependency | No | TBD | Engine choice approved in Phase 0; keep version changes visible |
| ORIG-002 | Art / UI | Placeholder stage shapes, icon, HUD text, and graybox scene dressing in `src/wildcoil` | Local repository authorship | Project author | Original work | Phase 1 | Placeholder | No, unless replaced later by external assets | TBD | Covers the production scaffold visuals and icon added with P1-01 |
| HOLD-001 | External asset intake placeholder | Any future third-party asset under consideration | Record before use | TBD | TBD | Any | Hold | Assume yes until verified otherwise | TBD | Do not commit unclear-source assets |

## Intake Rules

- Record the asset before or at the same time it enters the repo.
- Mark whether it is a placeholder or a permanent dependency.
- If future open-source release is uncertain, treat replacement as required until proven otherwise.
- Keep code dependencies that affect build or packaging visible here or in a linked dependency appendix later.
