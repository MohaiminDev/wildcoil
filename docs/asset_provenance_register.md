# Wildcoil Asset Provenance Register

Track every non-trivial imported asset, tool dependency, plugin, font, audio pack, and code import here. If the source is unknown, the asset is not approved.

## Current State

As of 2026-03-05, no third-party art, audio, font, plugin, or engine-specific package has been approved for committed use in the public project docs. Record new items here before they become habitual dependencies.

## Register

| ID | Type | Description | Source / URL | Creator / Vendor | License | Phase used | Placeholder or permanent | Replacement needed for future open source? | Verified by | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ORIG-001 | Documentation | Project planning docs and prose in this repository | Local repository authorship | Project author | Repository license applies | Phase 0 | Permanent | No | TBD | Applies only to original written documentation |
| TMP-001 | Art | Graybox shapes, primitive materials, and temporary silhouettes authored in-engine | Self-authored at creation time | Project author | Original work | Phase 0-1 | Placeholder | No, unless external textures are added later | TBD | Safe default for early spikes |
| HOLD-001 | External asset intake placeholder | Any future third-party asset under consideration | Record before use | TBD | TBD | Any | Hold | Assume yes until verified otherwise | TBD | Do not commit unclear-source assets |

## Intake Rules

- Record the asset before or at the same time it enters the repo.
- Mark whether it is a placeholder or a permanent dependency.
- If future open-source release is uncertain, treat replacement as required until proven otherwise.
- Keep code dependencies that affect build or packaging visible here or in a linked dependency appendix later.
