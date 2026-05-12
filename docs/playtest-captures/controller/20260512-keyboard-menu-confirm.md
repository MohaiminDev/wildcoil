# Rift Road Keyboard Menu Confirm Evidence

- Captured UTC: `2026-05-12 21:16:07 UTC`
- Session type: `keyboard menu confirm`
- Build: `pre-commit RR-PROD-80 workspace; package_sha256=a15b510a771c9a66f190a8385982bf290794659d5e4bc01e010b2b4153894328`
- Package: `build/macos/Rift Road.zip`
- Input source: `Computer Use keyboard input against the launched exported macOS app`
- Scope: `title -> hero select -> capability preview -> Stage 1 start`
- Title: `pass`
- Hero select: `pass`
- Capability preview cancel/back: `pass`
- Text-style J starts Stage 1: `pass`
- Blockers: `not a full manual keyboard fallback row; Stage 1 action-key hold behavior and physical controller-family sessions still need real manual evidence`

## Notes

The first launched-app pass showed that printable text-style `j` input could select title/hero menu text paths but did not start Stage 1 from the hero capability preview. The runtime now normalizes menu key events through `keycode`, `physical_keycode`, and selected printable `unicode` values before matching menu actions. After rebuilding `build/macos/Rift Road.zip`, the launched exported app accepted `j` from the capability preview and entered Stage 1 as Raya.
