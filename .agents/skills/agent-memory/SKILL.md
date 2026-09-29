---
name: agent-memory
description: >-
  Maintain AGENTS.md / CLAUDE.md and project skills: what belongs where, keep
  memory under a page, promote a repeated mistake to a rule, a rule enforced
  inconsistently to a skill, a rule that must always hold to a hook. Use when
  the agent repeats a mistake, when asked to "remember this", "add to
  AGENTS.md", write or update a skill, or during SDLC Stage 7 close-out.
---

# Agent memory and skills

`AGENTS.md` is read by every agent (Codex, Cursor, Claude Code via
`CLAUDE.md` → `@AGENTS.md`, Copilot via `.github/copilot-instructions.md`).
It is the day-one briefing, not a wiki. Skills hold procedures; hooks hold
laws.

## Where a fact goes

| Kind of knowledge | Home |
|-------------------|------|
| Commands, conventions, frozen areas, "gets wrong twice" | `AGENTS.md` (≤ 1 page) |
| A procedure applied the same way every time (review, release, API standard) | `.agents/skills/<name>/SKILL.md` |
| Long reference the skill needs sometimes (templates, checklists) | `.agents/skills/<name>/<file>.md`, linked from SKILL.md |
| A rule that must never be broken | Hook, CI, or branch protection (`ci-guardrails`) |
| Why a change was made | `intent/<slug>/` and the PR, never `AGENTS.md` |

Do not put in `AGENTS.md`: anything derivable from the code, git history, or a
manifest; one-off task context; long tables; secrets or hostnames.

## Updating AGENTS.md

1. Mistake seen twice → one sentence under "Things the agent gets wrong",
   phrased as an instruction with the reason: "Do not X; Y breaks because Z."
2. New command or verify step → "Commands" and "Verifying your work".
3. Keep it under a page. When adding a line, look for one to remove or move to
   a skill.
4. Change it in the same PR as the work that taught the lesson, so the diff
   explains itself. Code owners review it like code.

## Writing a project skill

```markdown
---
name: <kebab-case, matches folder>
description: >-
  What it does and when to use it, in the third person, with the trigger
  words a user would say. This line is what the agent matches on.
---
# Title
Short imperative steps. Tables for lookups. Link long material as
[file.md](file.md) rather than pasting it. Say what the output looks like.
```

- One skill per procedure; under ~150 lines; no project secrets.
- Skills live in `.agents/skills/`; `.claude/skills` and `.cursor/skills` are
  symlinks to it, so write once.
- If the same rule keeps being skipped even with the skill, it is not a
  knowledge problem; back it with a hook or CI (`ci-guardrails`).
- Personal skills (`~/.agents/skills`, symlinked into `~/.claude/skills` and
  `~/.cursor/skills` by `bootstrap.sh --personal-skills`) are for habits that
  cross repos; project policy stays in the repo.

## Reviewing memory drift

Once a quarter or after a big refactor: run `/init`-style discovery again,
compare with `AGENTS.md`, delete stale lines, confirm every command still
runs. Stale memory is worse than none because the agent trusts it.
