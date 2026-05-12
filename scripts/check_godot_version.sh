#!/usr/bin/env bash
set -euo pipefail

GODOT_BIN="${GODOT_BIN:-godot}"
# Rift Road currently targets Godot 4.6.x stable.
EXPECTED_VERSION="4.6.x-stable"

fail() {
  local actual="${1:-unavailable}"
  printf 'RIFT_ROAD_GODOT_VERSION blocked expected=%s actual=%s\n' "$EXPECTED_VERSION" "$actual" >&2
  exit 1
}

version_output=""
if ! version_output="$("$GODOT_BIN" --version 2>&1)"; then
  fail "$version_output"
fi

version_line="${version_output%%$'\n'*}"

case "$version_line" in
  4.6.*.stable*|4.6.stable*)
    printf 'RIFT_ROAD_GODOT_VERSION ok version=%s expected=%s\n' "$version_line" "$EXPECTED_VERSION"
    ;;
  *)
    fail "$version_line"
    ;;
esac
