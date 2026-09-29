---
name: code-review
description: >-
  Review a diff or PR for bugs, regressions, API contracts, and match to
  spec.md/plan.md. Use when reviewing pull requests, examining uncommitted
  changes, before opening a PR, or when the user asks for a code review,
  "look at this diff", or Bugbot-style review.
---

# Code review

Load `REVIEW.md` at repo root if it exists. Use the three passes below even if
it does not. Do not approve or merge; a human does that.

If `security-review` applies (auth, APIs, uploads, secrets), run that skill as
the Security pass instead of a shallow glance.

## Passes

Tag every finding with one pass.

### Bugs

- Wrong condition, off-by-one, null/undefined, race, stale closure.
- Locale/routing: links and APIs respect i18n, not hardcoded `/en` only.
- Error paths: user-visible message vs leaked internals.
- Data: empty list, pagination, timezone, money/decimal (never float).

### Security

Delegate to `security-review`. Summarize Important items here in one line each.

### Compliance

- Diff matches `intent/<slug>/spec.md` and `plan.md` if they exist.
- `AGENTS.md` rules (Prisma version, verify commands, deferred follow-ups).
- No drive-by refactors, dependency bumps, or unrelated files.
- UI: verify in the browser when layout or user-visible behavior changed.

## Ranking

- **Important**: wrong behavior, data loss, leak, policy breach, broken build.
- **Nit**: naming, extra comment, style CI already covers. Max five nits;
  summarize the rest as a count. Skip generated files and what CI already
  enforces.

## Output

```markdown
## Code review
Scope: <files or PR URL>
### Important
- Pass / file: …
### Nits (N)
- …
### Matches plan
Yes / no — where it diverges.
```

## Same-PR fixes

If the user asked to review **and** fix: fix Important items, re-run
`Verifying your work`, do not expand scope. Leave nits unless asked.
