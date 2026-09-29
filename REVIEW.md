# Review instructions

## Passes

Run three passes and tag each finding with its pass:

- Bugs: logic errors, broken edge cases, subtle regressions
- Security: injection risks, authentication gaps, PII in logs, secrets in the diff
- Compliance: the change matches `spec.md`, `plan.md`, and `AGENTS.md`

## What Important means here

Reserve Important for findings that would break behavior, leak data, or breach
a policy. Style and naming are nits.

## Cap the nits

Report at most five nits per review; summarize the rest as a count.

## Do not report

Generated files (e.g. `src/gen/`, Prisma client, lockfile-only noise) and
anything CI already enforces.
