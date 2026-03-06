# Wildcoil Tester Feedback Intake

Use this guide after sending a tester the live prerelease at [`v0.1.0-tester`](https://github.com/MohaiminDev/wildcoil/releases/tag/v0.1.0-tester).

## Preferred Intake Path

1. Ask the tester to use the GitHub `Tester Feedback` issue form.
2. If they reply outside GitHub, copy the same fields into a local summary.
3. After each report, add the durable findings to [`docs/playtest_log.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/playtest_log.md).
4. If the report changes project risk, update [`docs/risk_register.md`](/Users/himu/Desktop/career/personal_projects/wildcoil/docs/risk_register.md) in the same follow-up commit.

## Minimum Fields To Capture

- Build tag or asset name used
- Mac model and macOS version
- Input method used
- Whether launch or install was confusing
- Whether first combat felt fast and readable
- Any repeated cheap-damage or clarity problem
- Performance or audio issues
- Whether the tester wanted another run
- What game the tester compared Wildcoil to first

## Triage Rules

- Log repeated install or launch friction under packaging risk.
- Log repeated controller complaints under input risk.
- Log repeated readability or cheap-damage complaints under combat or readability risk.
- Log repeated “this feels like another game” feedback under originality risk.
- If three or more testers hit the same blocker, create a follow-up task before adding new scope.

## Notes For Internal Summaries

- Keep direct quotes short and selective.
- Prefer one session note per tester rather than mixing reports together.
- Record whether the tester used keyboard or a specific controller model.
- Mark clearly when a session is partial, for example install-only or launch-only.
