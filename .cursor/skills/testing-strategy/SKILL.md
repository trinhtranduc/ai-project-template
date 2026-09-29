---
name: testing-strategy
description: >-
  Choose and add verification for a change: unit/integration/e2e, failing-test
  first for bugs, browser checks for UI, and CI commands from AGENTS.md. Use
  when writing tests, asking "how do we test this", reproducing a bug, adding
  Playwright/Jest/Vitest, or defining definition of done.
---

# Testing strategy

Always give the agent a check it can fail. Prefer the project's existing
runner. If `AGENTS.md` lists lint/tsc/build and no unit suite, those **are**
the loop until a suite exists — do not add Jest "for completeness" on a
one-line fix.

## Pick the cheapest proof

| Change | Proof |
|--------|--------|
| Pure function / money / dates | Unit test next to the module |
| API route | Integration or route handler test with mocked DB if that pattern exists; else curl against local server |
| Prisma schema | migrate in plan; do not test generated client |
| UI layout/flow | Browser: happy path + empty + error; screenshot vs mock |
| Bug | Failing check first, commit it, then fix code only |

## Bug-fix loop

1. Reproduce (browser, curl, or script).
2. Encode as a failing test **or** a small script under `scripts/` that exits
   non-zero. Commit that.
3. Fix production code until the check is green. Do not edit the test to pass.
4. Add a one-line note in the PR: how to re-run the check.

## UI

- Exercise the flow like a user (click, type, submit, navigate).
- One screenshot is not enough; confirm behavior.
- Related routes that share state must still work.
- Empty, error, and permission-denied if the change can hit them.
- Desktop and a mobile width when layout changed.

## What not to do

- Do not delete or skip a failing test to go green.
- Do not mock the unit under test so thoroughly that the test cannot fail.
- Do not add a heavy e2e framework unless the user asked or the repo already
  has it.

## Output in the PR / task

Paste the exact commands and their exit status from `Verifying your work`.
Name any new test file and what it covers in one sentence.
