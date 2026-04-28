#!/usr/bin/env python3
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
MAX_AGENTS_LINES = 150

REQUIRED_FILES = [
    "AGENTS.md",
    "ARCHITECTURE.md",
    "docs/DESIGN.md",
    "docs/FRONTEND.md",
    "docs/PLANS.md",
    "docs/PRODUCT_SENSE.md",
    "docs/QUALITY_SCORE.md",
    "docs/RELIABILITY.md",
    "docs/SECURITY.md",
    "docs/design-docs/core-beliefs.md",
    "docs/design-docs/index.md",
    "docs/exec-plans/active/agent-first-repo-migration.md",
    "docs/exec-plans/completed/index.md",
    "docs/exec-plans/tech-debt-tracker.md",
    "docs/generated/index.md",
    "docs/product-specs/index.md",
    "docs/references/index.md",
]

REQUIRED_DIRS = [
    "docs",
    "docs/design-docs",
    "docs/exec-plans",
    "docs/exec-plans/active",
    "docs/exec-plans/completed",
    "docs/generated",
    "docs/product-specs",
    "docs/references",
]


def main() -> int:
    failures = []

    for relative_path in REQUIRED_DIRS:
        path = ROOT / relative_path
        if not path.is_dir():
            failures.append(f"missing directory: {relative_path}")

    for relative_path in REQUIRED_FILES:
        path = ROOT / relative_path
        if not path.is_file():
            failures.append(f"missing file: {relative_path}")

    agents_path = ROOT / "AGENTS.md"
    if agents_path.exists():
        line_count = len(agents_path.read_text().splitlines())
        if line_count > MAX_AGENTS_LINES:
            failures.append(f"AGENTS.md has {line_count} lines; max is {MAX_AGENTS_LINES}")

    if failures:
        print("agent docs check failed:")
        for failure in failures:
            print(f"- {failure}")
        return 1

    print("agent docs check passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
