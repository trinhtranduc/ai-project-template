---
name: release-readiness
description: >-
  Check a change or environment is safe to deploy: migrations, env vars, rollback,
  secrets not in git, production gate, smoke after ship. Use before production
  deploy, hosted go-live, "can we ship", release checklist, or
  tagging a version.
---

# Release readiness

The agent prepares the release; a human authorizes production. Do not push to
`main` or run production deploy commands unless the user explicitly asked and
a release approval exists.

## Checklist (copy and tick)

```
- [ ] Intent/issue/PR linked (Closes #n)
- [ ] Verifying your work commands green (paste output)
- [ ] Migrations reviewed; expand-then-contract if breaking
- [ ] New env vars documented in .env.example only (placeholders)
- [ ] No real secrets in the diff or docs
- [ ] Rollback: one paragraph (revert PR / migrate down / flag off)
- [ ] Smoke: which URL and what to click after deploy
- [ ] Observability: what log/metric shows it worked
```

## Database

- Prefer additive migrations. Do not drop columns in the same release that
  still reads them.
- ORM / migration tool: stay on the version pinned in the manifest; do not
  jump a major because a skill mentioned it.

## Env and hosts

- Production `DATABASE_URL` / JWT / third-party keys live in the host's
  secret store, not in git.
- Pooled vs direct DB URL: migrations use the direct connection when the
  project distinguishes them.

## After deploy (when user asked to ship)

- Hit the smoke URL.
- Confirm one write path if the release includes one (form, login).
- If 5xx or migrate failed: rollback first, then `incident-postmortem`.

## Output

A short go/no-go: **Ship** or **Block** with the unchecked items only.
