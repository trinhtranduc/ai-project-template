# AI project template

Skeleton for new repositories so every coding agent (Claude Code, Cursor, Codex,
Copilot) follows the same SDLC: **issue first**, then `intent.md` → `spec.md` →
`plan.md` → code → PR (`Closes #n`), reviewed and merged by a human.

Based on [The AI-native SDLC playbook](https://academy.claude.com/courses/ai-native-sdlc-playbook);
lesson notes in [`docs/`](docs/ai-native-sdlc-playbook-notes.md).

## What you get

| Path | Role |
|------|------|
| `AGENTS.md` / `CLAUDE.md` | Agent memory: commands, conventions, verify loop, skill map |
| `REVIEW.md` | PR review passes (bugs, security, compliance) |
| `intent/` | One folder per change (`intent.md`, `spec.md`, `plan.md`) |
| `.agents/skills/` | 12 SDLC skills, written once (see [Skill map](#skill-map)) |
| `.claude/skills`, `.cursor/skills` | Symlinks to `.agents/skills` so Claude Code and Cursor see the same set |
| `.github/ISSUE_TEMPLATE/` | Feature + bug templates |
| `.github/pull_request_template.md` | PR body with `Closes #` |
| `.github/workflows/pr-policy.yml` | CI check: PR closes an issue, branch named `<type>/<n>-<slug>` |
| `.github/copilot-instructions.md` | Points Copilot at `AGENTS.md` |
| `scripts/bootstrap.sh` | Copy this format into another repo |

## How each agent picks it up

| Agent | Memory | Skills |
|-------|--------|--------|
| Claude Code | `CLAUDE.md` → `@AGENTS.md` | `.claude/skills` (symlink) |
| Cursor | `AGENTS.md` | `.cursor/skills` (symlink) |
| Codex CLI | `AGENTS.md` | `.agents/skills` |
| GitHub Copilot | `.github/copilot-instructions.md` → `AGENTS.md` | reads `SKILL.md` on request |

Symlinks need Developer Mode or `core.symlinks=true` on Windows; on Linux and
macOS they just work.

## New GitHub repo (use as template)

On GitHub: this repository → **Use this template**. Then clone and fill
`AGENTS.md` Commands from `package.json` / `Makefile`.

Mark the repo as a template: Settings → Template repository.

## Existing repo

```bash
git clone git@github.com:trinhtranduc/ai-project-template.git
./ai-project-template/scripts/bootstrap.sh /path/to/your-app
# overwrite existing files and skills:
./ai-project-template/scripts/bootstrap.sh /path/to/your-app --force
# also install skills for every project on this machine:
./ai-project-template/scripts/bootstrap.sh /path/to/your-app --personal-skills
```

Bootstrap never touches files that already exist unless `--force`. If the
target already has a real `.claude/skills` or `.cursor/skills` folder, each
template skill is linked into it individually instead of replacing the folder.

`--personal-skills` copies the skills to `~/.agents/skills/` and links them into
`~/.claude/skills/` and `~/.cursor/skills/` so new workspaces pick them up
without copying into each repo.

## After bootstrap

1. Put real lint / type / test / build commands in `AGENTS.md`.
2. `gh label` types are created when `gh` is logged in and `origin` is GitHub.
3. Protect `main` and make `pr-policy` a required check (`ci-guardrails` skill).
4. Do not start a feature without an issue. Branch: `feat/<n>-<slug>`.

## Skill map

| Skill | Use when |
|-------|----------|
| `sdlc` | Any non-trivial change (orchestrator for the whole loop) |
| `research` | Competitor URL, market, codebase archaeology |
| `spec-design` | Turn `intent.md` into `spec.md`: requirements, acceptance criteria, decisions |
| `git-workflow` | Issue, branch, commit message, PR body, never self-merge |
| `testing-strategy` | How to prove the change |
| `debugging` | Cause unknown: reproduce, narrow, hypothesis, fix, regression |
| `security-review` | Auth, APIs, uploads, secrets, PII |
| `code-review` | Review a diff or PR |
| `ci-guardrails` | CI workflow, branch protection, agent hooks (the deterministic layer) |
| `release-readiness` | Before production |
| `incident-postmortem` | After an outage; writes a new `intent.md` |
| `agent-memory` | Update `AGENTS.md`, write or refresh a project skill |

Skills are advisory. Anything that must always hold needs a hook, a CI check, or
branch protection; `ci-guardrails` has the templates.
