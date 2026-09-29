# AI project template

Skeleton for new repositories so Cursor/Claude follow the same SDLC: **issue first**,
then `intent.md` → `spec.md` → `plan.md` → code → PR (`Closes #n`).

Skills come from [The AI-native SDLC playbook](https://academy.claude.com/courses/ai-native-sdlc-playbook).

## What you get

| Path | Role |
|------|------|
| `AGENTS.md` / `CLAUDE.md` | Agent memory: commands, conventions, verify loop |
| `REVIEW.md` | PR review passes (bugs, security, compliance) |
| `intent/` | One folder per change (`intent.md`, `spec.md`, `plan.md`) |
| `.github/ISSUE_TEMPLATE/` | Feature + bug templates |
| `.github/pull_request_template.md` | PR body with `Closes #` |
| `.cursor/skills/` | `ai-native-sdlc`, `research`, `security-review`, `code-review`, `testing-strategy`, `release-readiness`, `incident-postmortem` |
| `scripts/bootstrap.sh` | Copy this format into another repo |

## New GitHub repo (use as template)

On GitHub: this repository → **Use this template**. Then clone and fill `AGENTS.md` Commands from `package.json` / `Makefile`.

Mark the repo as a template: Settings → Template repository.

## Existing repo

```bash
git clone git@github.com:trinhtranduc/ai-project-template.git
chmod +x ai-project-template/scripts/bootstrap.sh
./ai-project-template/scripts/bootstrap.sh /path/to/your-app
# overwrite existing files:
./ai-project-template/scripts/bootstrap.sh /path/to/your-app --force
# also install skills for every project on this machine:
./ai-project-template/scripts/bootstrap.sh /path/to/your-app --personal-skills
```

`--personal-skills` copies `.cursor/skills/*` to `~/.cursor/skills/` so new
workspaces pick them up without copying into each repo.

## After bootstrap

1. Put real lint / type / test / build commands in `AGENTS.md`.
2. `gh label` types are created when `gh` is logged in and `origin` is GitHub.
3. Do not start a feature without an issue. Branch: `feat/<n>-<slug>`.

## Skill map

| Skill | Use when |
|-------|----------|
| `ai-native-sdlc` | Any non-trivial change (orchestrator) |
| `research` | Competitor URL, market, codebase archaeology |
| `security-review` | Auth, APIs, uploads, secrets, PII |
| `code-review` | Review a diff or PR |
| `testing-strategy` | How to prove the change |
| `release-readiness` | Before production |
| `incident-postmortem` | After an outage; writes a new `intent.md` |
