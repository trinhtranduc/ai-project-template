---
name: ai-native-sdlc
description: >-
  Run features, bug fixes, and incidents through the AI-native SDLC loop from
  Anthropic's "AI-native SDLC playbook" (Claude Academy): capture intent.md,
  produce spec.md, plan before coding (plan.md), build with a self-verifying
  feedback loop, review PRs with REVIEW.md passes, enforce gates with hooks,
  and close the loop by writing incidents back as intent.md. Use when starting
  any non-trivial change in any project, when the user mentions intent, spec,
  plan, PR review, hooks, evals, control bands, SDLC, or asks "how should we
  work on this".
---

# AI-native SDLC

Source: https://academy.claude.com/courses/ai-native-sdlc-playbook (14 lessons).
Core idea: code is no longer the bottleneck, so every stage ends by committing a
small Markdown artifact that the next stage reads. The chain of commits is the
audit trail; humans decide at the gates.

```
intent.md -> spec.md -> plan.md -> diff + checks -> PR + review findings -> incident -> intent.md
```

## Artifacts and where they live

| Artifact | Path | Who accepts |
|----------|------|-------------|
| `intent.md` | `intent/<slug>/intent.md` | product owner (user) |
| `spec.md` | `intent/<slug>/spec.md` | product owner, tech lead for higher-risk |
| `plan.md` | `intent/<slug>/plan.md` | engineer; tech lead for higher-risk |
| review policy | `REVIEW.md` at repo root | tech lead |
| agent memory | `AGENTS.md` or `CLAUDE.md` at repo root | code owners via PR |
| skills | `.agents/skills/<name>/SKILL.md` or `.cursor/skills/<name>/SKILL.md` | policy owner |
| issue templates | `.github/ISSUE_TEMPLATE/{feature,bug}.yml` | tech lead |
| PR template | `.github/pull_request_template.md` | tech lead |

Create `intent/<slug>/` if missing. One folder per change; keep all three files
together so "what was asked, what was decided, how it was built" sits in one place.

## Issue first, then work, then PR

Every non-trivial change is tracked by a GitHub issue before any file is edited.
The issue is the ticket; `intent.md` is the reasoning behind it; the PR closes it.

1. **Create the issue first** with `gh issue create`, using the matching template
   (`feature` or `bug`). Title in imperative form, body from `intent.md` (Problem,
   Proposed outcome, Constraints, Open questions). Add labels `type:feature` or
   `type:bug` plus `area:<module>` when the repo has them.
2. **Link both ways**: put `Issue: #<n>` on the second line of `intent.md`; the
   issue body links to `intent/<slug>/`.
3. **Branch off the issue**: `git checkout -b <type>/<n>-<slug>` (e.g.
   `feat/42-broker-filters`, `fix/57-rebate-rounding`). Never commit to `main`.
4. **Commits reference the issue**: `feat(brokers): add regulator filter (#42)`.
5. **Open the PR with the template**: `gh pr create --fill` then edit the body so it
   has `Closes #<n>`, the plan link, verification output, and the review passes.
   One issue per PR; if the work splits, open a second issue.
6. **Never self-merge**. The PR waits for a human approval, even when all checks
   are green.

If `gh` is not authenticated or the repo has no remote, create the issue text
locally as `intent/<slug>/issue.md` and tell the user to open it; do not skip
the step silently.

## First use in a project

Do this once, without asking, when the project has none of the files above:

1. Read `package.json`, `Makefile`, `pyproject.toml`, or equivalent to find the
   real lint, type-check, test, and build commands.
2. If `AGENTS.md`/`CLAUDE.md` is missing, create it from the shape in
   [templates.md](templates.md): Commands, Conventions, Architecture, Things
   the agent gets wrong. Keep it under a page.
3. Add a `## Verifying your work` section listing those commands with the
   expected healthy output. If there is no test suite, say so and name the
   checks that stand in for it.
4. Create `REVIEW.md` from [templates.md](templates.md), adjusting the
   "Do not report" paths to the project's generated folders.
5. Create `intent/` with a `.gitkeep`.
6. Create `.github/ISSUE_TEMPLATE/feature.yml`, `.github/ISSUE_TEMPLATE/bug.yml`,
   `.github/ISSUE_TEMPLATE/config.yml`, and `.github/pull_request_template.md`
   from [templates.md](templates.md).
7. If `gh auth status` succeeds, create the labels `type:feature`, `type:bug`,
   `type:chore`, `priority:high`, `priority:normal` with `gh label create`
   (ignore "already exists" errors).

Report what was created in one short list; do not ask for confirmation first.

## Workflow

Copy this checklist into the task and tick as you go:

```
- [ ] 0 Research intent/<slug>/research.md when studying a URL, competitor, or unknown domain (skill: research)
- [ ] 1 Intent   intent/<slug>/intent.md written in the user's own words, accepted
- [ ] 1b Issue   gh issue create from the template; Issue: #n added to intent.md
- [ ] 2 Spec     spec.md produced with project skills loaded, concerns flagged, accepted
- [ ] 3 Plan     plan.md: files, order, risks, proof; reviewed before any edit
- [ ] 3b Branch  git checkout -b <type>/<n>-<slug>
- [ ] 4 Build    implement; update plan.md in the same commit if it diverges
- [ ] 5 Verify   run every command in "Verifying your work"; paste the output
- [ ] 6 Review   self-review against REVIEW.md passes (bugs, security, compliance)
- [ ] 6b PR      gh pr create with the template; "Closes #n"; wait for human approval
- [ ] 7 Close    mistake seen twice -> AGENTS.md; incident -> new intent.md + eval
```

### 0. Research (when the problem is not already understood)

If the user gave a competitor URL, a "how does X work", or a green-field
feature: run the `research` skill first and write `research.md`. Intent is
the "so what", not a paste of the whole catalog.

### 1. Capture intent

Ask what the user cannot do today, who is affected, what better looks like,
what is out of scope. Ask the analyst questions (scope, users, constraints,
success). Then write `intent.md` with the template in [templates.md](templates.md).
No formal language required. The user corrects it before it is committed.

Skip the ceremony for trivial changes (typo, copy tweak, one-line fix): go
straight to step 4 and 5, but still open a `type:chore` issue and a PR so the
change has a ticket and a reviewer. Only direct commits to a personal scratch
branch are exempt.

### 2. Requirements and design

Read `intent.md` and produce `spec.md`. Load whichever project skills act as
policy (security, performance, design, accessibility, SEO). Flag every place a
policy cannot be satisfied or two policies conflict; the user resolves those
before engineering starts. Carry forward or answer the open questions from
`intent.md`.

### 3. Plan before code

Start in Plan mode. Produce `plan.md` naming the files that change, the order
of work, the risks, and the proof (which checks or screenshots prove it).
Interrogate the plan: what could this break, which step is riskiest, what
alternatives were rejected. Iterate until an engineer who never saw the
conversation could implement from `plan.md` alone. Only then edit files.

### 4. Build

- Split independent work by files; tasks that share files run sequentially.
- Use subagents for recurring jobs: a `verifier` that runs the app and reports
  without fixing, an `explore` researcher that keeps the main context clean.
- Respect the project's frozen areas and dependency rules in `AGENTS.md`.
- When implementation departs from `plan.md`, update `plan.md` in the same commit.

### 5. Feedback loop (definition of done)

Run every command listed under `## Verifying your work` in the project's
`AGENTS.md`/`CLAUDE.md`. If that section does not exist, derive the commands
from the project manifest and add the section (see "First use in a project").

For UI work also open the page in the browser tool, screenshot, compare with
the mock or the existing design, adjust; two or three rounds is normal.
State a quantifiable target before starting ("page renders N cards and lint
is clean"). Run all checks before reporting done and paste the output.

Bug fixes: reproduce as a failing check first (a test, a script, or a
recorded repro), commit it, then fix the code without weakening the check.
If a test fails, fix the code, not the test.

### 6. Review

Run the `code-review` skill (and `security-review` when the diff touches
auth, APIs, uploads, secrets, or PII). Before opening a PR, also run the
three passes from `REVIEW.md`:

- Bugs: logic errors, edge cases, regressions
- Security: injection, auth gaps, PII in logs, secrets in diff
- Compliance: diff matches `spec.md` and `plan.md`; project rules in `AGENTS.md`

Rank findings Important vs Nit; cap nits at five. Findings inform but never
replace human approval; the agent that wrote the code cannot approve it.

### 7. Close the loop

- Mistake made twice -> add the correction to `AGENTS.md` (keep it under a page).
- Policy enforced inconsistently -> write it as a project skill.
- Rule that must always hold -> back the skill with a hook (deterministic).
- Production incident -> write `intent/<slug>/intent.md` in the Stage 1 format
  with anomaly, evidence, proposed outcome, affected systems, open questions;
  add an eval so the regression stays covered.

## Controls: advisory vs deterministic

Skills and `AGENTS.md` make violations rare; hooks, permissions, branch
protection, and CI make them close to impossible. Anything that must always
hold needs the deterministic layer. Rules for hooks:

- Build-phase hooks are fast and scoped to the changed file (block edits to
  protected paths such as migrations, run lint after edits, keep credentials
  out of the diff).
- Human-approval hooks belong at deploy gates, not in the build loop.
- A block must explain itself and state the route to approval.
- The agent may act up to the production gate and cannot pass it. Anything it
  writes arrives as a PR; there is no route to `main`.

## Companion personal skills (`~/.cursor/skills/`)

Load the matching skill instead of improvising:

| Skill | Stage |
|-------|--------|
| `research` | Before intent: competitors, URLs, codebase archaeology |
| `testing-strategy` | Build/test: cheapest proof, failing test first, browser UI |
| `security-review` | Spec, build, PR: authz, secrets, PII, abuse |
| `code-review` | PR: bugs, compliance to plan, nits capped |
| `release-readiness` | Deploy: migrate, env, rollback, smoke |
| `incident-postmortem` | Maintain: timeline → new intent.md + regression check |

Project skills in `.agents/skills/` (performance, design, API security, Prisma,
SEO) still apply when writing code in that repo.

## Measure

Each play has a leading and a lagging indicator read from Git and PR history:
intent-to-spec time, first-pass merge rate, review time per PR, rework
commits to `spec.md` after `plan.md` exists, repeat incidents per class.

## Reference

- Verbatim templates (intent, spec prompt, plan, CLAUDE.md, REVIEW.md,
  verifier agent, hooks, evals workflow, bands.yaml, managed settings):
  [templates.md](templates.md)
- Lesson-by-lesson notes with rules, governance and metrics:
  [playbook-notes.md](playbook-notes.md)
