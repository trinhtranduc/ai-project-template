---
name: incident-postmortem
description: >-
  Turn an outage, data leak, or production bug into intent.md, a timeline, and
  a regression check. Use after incidents, 5xx spikes, failed deploys, leaked
  secrets, "postmortem", "what went wrong", or when closing the SDLC loop from
  production.
---

# Incident postmortem

Detection stays factual. Do not blame. Restart the SDLC with a new `intent.md`.

## Capture

1. Timeline (UTC): detect → mitigate → recover.
2. User impact: who, how many, for how long.
3. Trigger: deploy SHA, migrate, traffic, config.
4. Why the existing checks missed it.

## Immediate

- Mitigate first if still on fire (rollback, rotate secrets, disable route).
- Rotated secrets: treat old values as burned; never recommit them.

## Artifacts

Write `intent/<slug>/intent.md`:

- Problem = anomaly + evidence (log line, status code, screenshot).
- Proposed outcome = user-visible recovery + how we prevent repeats.
- Affected systems = services, tables, third parties.
- Constraints = do not hide the incident; do not weaken tests to go green.
- Open questions = still unknown.

Then: GitHub issue `type:bug` `priority:high`, branch `fix/<n>-<slug>`.

## Prevent repeats

- Add a failing check or eval that would have caught this.
- If the same class happened twice, add a sentence to `AGENTS.md`.
- If policy must always hold, propose a hook (do not add noisy hooks in the
  incident PR unless the user asked).

## Output

```markdown
## Incident
Severity: …
Timeline: …
Mitigation: …
Root cause (best current): …
Follow-up issue: #
```
