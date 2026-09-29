---
name: ci-guardrails
description: >-
  Set up the deterministic layer that skills cannot guarantee: CI workflows
  that run the "Verifying your work" commands, PR policy checks, branch
  protection, and agent hooks that block protected paths or secrets. Use when
  adding GitHub Actions, "protect main", "run lint in CI", pre-commit hooks,
  Claude Code or Cursor hooks, or when a rule must always hold.
---

# CI and guardrails

Skills and `AGENTS.md` are advisory. Anything that must always hold gets a
hook, a CI check, or branch protection. Add the cheapest one that enforces it.

## Ladder

| Rule | Enforce with |
|------|--------------|
| Lint / types / tests pass | CI workflow on `pull_request` (required check) |
| PR closes an issue, branch named after it | `.github/workflows/pr-policy.yml` (shipped by this template) |
| No commits to `main`, human approval | Branch protection: require PR, 1 review, no self-approval, status checks |
| No secrets in diff | Secret scanning + `gitleaks` in CI; pre-commit hook locally |
| Protected paths (migrations, generated code) | Agent PreToolUse hook that blocks edits; CODEOWNERS for review |
| Production deploy needs approval | Environment protection rule in GitHub; hook that blocks `deploy … production` without `RELEASE_APPROVAL` |

## CI workflow skeleton

Fill the steps from the `Commands` section of `AGENTS.md`; do not invent tools
the repo does not use.

```yaml
name: CI
on:
  pull_request:
  push:
    branches: [main]
jobs:
  verify:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      # Node example — replace with the project's real setup
      - uses: actions/setup-node@v4
        with: { node-version: 22, cache: npm }
      - run: npm ci
      - run: npm run lint
      - run: npx tsc --noEmit
      - run: npm test -- --ci
      - run: npm run build
```

Python: `astral-sh/setup-uv` → `uv sync` → `uv run ruff check` → `uv run pytest`.
Keep one job per concern only when they are slow enough to parallelize.

## Branch protection (one-time, needs admin)

```bash
gh api -X PUT repos/{owner}/{repo}/branches/main/protection \
  -F required_pull_request_reviews[required_approving_review_count]=1 \
  -F required_status_checks[strict]=true \
  -F required_status_checks[contexts][]=verify \
  -F required_status_checks[contexts][]=pr-policy \
  -F enforce_admins=true -F restrictions=null
```

Or Settings → Branches → Add rule. Tick "Dismiss stale approvals" and
"Require conversation resolution".

## Agent hooks

Claude Code: `.claude/settings.json` `hooks.PreToolUse`; stdin is JSON with
`tool_input`; `exit 2` blocks and sends stderr to the agent. Cursor:
`.cursor/hooks.json` with the same shape (`beforeShellExecution`,
`beforeReadFile`). Keep hooks fast, scoped, and self-explaining.

```bash
#!/usr/bin/env bash
# .claude/hooks/protect-paths.sh — block edits to migrations without approval
path=$(jq -r '.tool_input.file_path // empty')
case "$path" in
  */migrations/*|*/gen/*)
    [[ -n "${ALLOW_PROTECTED:-}" ]] && exit 0
    echo "Blocked: $path is protected. Ask a maintainer; set ALLOW_PROTECTED=1 once approved." >&2
    exit 2 ;;
esac
exit 0
```

Rules: build-phase hooks stay under a second and touch only the changed file;
human-approval hooks belong at deploy gates; every block states the route to
approval.

## Pre-commit (local, optional)

`pre-commit` or `lefthook` running lint, formatter, and `gitleaks protect`.
Never make the hook the only enforcement; CI must repeat it.

## Output

List what was added (file, trigger, what it blocks), what still needs an admin
(branch protection, secrets), and how to test each check fails on purpose.
