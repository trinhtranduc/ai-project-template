---
name: debugging
description: >-
  Systematic bug diagnosis: reproduce, narrow, form one hypothesis at a time,
  prove it, fix the cause, add a regression check. Use when something fails,
  a test is red, behavior differs from spec, "why does this happen", flaky
  CI, or before touching code for any bug whose cause is not already known.
---

# Debugging

No fix before a reproduction. No second change before the first one is
measured. The output is a cause and a regression check, not a workaround.

## 1. Reproduce

- Get the exact input, environment, commit SHA, and the observed vs expected
  result. Quote the error text verbatim.
- Turn it into the smallest repeatable check: a failing test, a script under
  `scripts/`, a curl, or a recorded browser flow. Commit it (`fix/<n>-<slug>`).
- Cannot reproduce → say so, list what was tried, ask for the missing detail.
  Do not guess a fix.

## 2. Narrow

- Bisect the surface: which layer (UI, API, service, DB, infra)? Which commit
  (`git bisect` when the last-good version is known)?
- Read the code path end to end once; cite files and lines. Add temporary
  logging at the boundaries rather than everywhere.
- Check the boring causes first: env var, stale build or cache, migration not
  applied, wrong branch, timezone, float arithmetic, empty list.

## 3. Hypothesis → test

State one hypothesis: "X happens because Y." Design the cheapest experiment
that would disprove it. Run it. Record the result in the task. If disproved,
next hypothesis. Never stack two untested changes.

## 4. Fix the cause

- Fix where the invariant broke, not where the symptom surfaced.
- Do not edit the failing check to pass. Do not add `try/catch` that hides the
  error. Do not skip the test.
- If the true fix is out of scope, ship the smallest safe mitigation, open an
  issue for the cause, and say so in the PR.

## 5. Regression and closure

- The check from step 1 is now green and stays in the suite.
- Run every "Verifying your work" command; paste the output.
- Same class of bug twice → one sentence in `AGENTS.md` (`agent-memory`).
- Production impact → `incident-postmortem` for timeline and new `intent.md`.

## Output

```markdown
## Debug report
Symptom: …
Reproduction: <command or test>
Cause: <file:line> — <one sentence>
Fix: …
Regression check: <test or script>
Ruled out: …
```

## Flaky tests

Treat as a bug in the test or the system, never as noise. Find the shared
state, timing, or order dependency; do not add retries as the fix.
