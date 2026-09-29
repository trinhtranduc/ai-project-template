# Agent memory

Keep this file under a page. When the agent makes a mistake twice, add the
correction here. Read by Codex and Cursor directly, by Claude Code through
`CLAUDE.md`, by Copilot through `.github/copilot-instructions.md`.

## Commands

Fill these from the project manifest (`package.json`, `Makefile`, `pyproject.toml`):

- Dev: (e.g. `yarn dev`)
- Lint: (e.g. `yarn lint` — zero errors)
- Types: (e.g. `npx tsc --noEmit`)
- Test: (e.g. `yarn test` — or write "no unit suite yet")
- Build: (e.g. `yarn build`)

## Verifying your work

Run every command listed above that exists before reporting a task complete,
and paste the output. If a check fails, fix the code, not the check. For UI
changes, exercise the flow in the browser, not only a screenshot.

## Conventions

- Issue first, then branch `feat/<n>-<slug>` / `fix/<n>-<slug>`, then PR with
  `Closes #<n>`. Never commit to `main`. Never self-merge.
- Artifacts for a change live in `intent/<slug>/` (`intent.md`, `spec.md`,
  `plan.md`). Put `Issue: #<n>` on `intent.md`.
- Skills: read `SKILL.md`, do not paste skill bodies into code.

## Architecture

- (Where routes, domain, and adapters live. One short paragraph.)

## Things the agent gets wrong

- Do not bump dependency major versions unless the issue asks for it.
- Do not commit secrets, dumps with PII, or real connection strings.

## Skills (`.agents/skills/`)

One folder for every agent; `.claude/skills` and `.cursor/skills` are symlinks
to it. Add domain skills (React, ORM, SEO) per product below the SDLC set.

| Skill | When to use |
|-------|-------------|
| `sdlc` | Any non-trivial change: intent → spec → plan → build → PR (orchestrator) |
| `research` | Competitor URL, market, codebase archaeology |
| `spec-design` | Write `spec.md`: requirements, acceptance criteria, decisions |
| `git-workflow` | Issue, branch, commit message, PR body |
| `testing-strategy` | Cheapest proof, failing test first, browser checks |
| `debugging` | Cause unknown: reproduce, narrow, hypothesis, fix, regression |
| `security-review` | Auth, APIs, uploads, secrets, PII |
| `code-review` | Review a diff or PR against `REVIEW.md` |
| `ci-guardrails` | CI workflow, branch protection, agent hooks |
| `release-readiness` | Before production: migrate, env, rollback, smoke |
| `incident-postmortem` | After an outage; writes a new `intent.md` |
| `agent-memory` | Update this file or write a project skill |
