---
name: spec-design
description: >-
  Turn an accepted intent.md into spec.md: requirements, acceptance criteria,
  design decisions (ADR-lite), data and API changes, and flagged policy
  conflicts. Use when the user says "write the spec", "design this",
  "requirements", "how should this work", or when the SDLC loop reaches
  Stage 2 after intent.md is accepted.
---

# Spec and design

Input: `intent/<slug>/intent.md` (accepted). Output: `intent/<slug>/spec.md`.
A spec is a decision record, not a restatement of the intent. Load the project
policy skills first (security, performance, design, accessibility, SEO) and
`AGENTS.md`; every requirement must be satisfiable under them or flagged.

## Before writing

1. Read `intent.md`, `AGENTS.md`, and any `research.md` in the same folder.
2. Find the code the change touches: routes, services, schema, one call chain.
   Cite files. Do not design against an imagined codebase.
3. List every open question from `intent.md`. Each one is answered in the spec
   or carried forward under "Open questions" with who decides.

## spec.md layout

```markdown
# Spec: <slug>
Intent: intent/<slug>/intent.md · Issue: #<n> · Status: draft | accepted

## Concerns (read first)
Policy conflicts, unsatisfiable constraints, scope the spec deliberately cuts.
Empty section = "none found", say so explicitly.

## Goal and non-goals
One paragraph each. Non-goals stop scope creep in plan.md.

## Requirements
R1, R2 … Each testable. "Users can filter by category" not "filtering is better".

## Acceptance criteria
Given / When / Then per requirement. These become the tests and the smoke check.

## Design
- Data: tables, columns, migrations (additive first; expand-then-contract).
- API / routes: method, path, auth, request and response shape, errors.
- UI: screens and states (empty, loading, error, permission denied).
- Integration points: third parties, queues, cron, feature flags.

## Decisions (ADR-lite)
| Decision | Options considered | Chosen | Why |
Keep only decisions someone could reasonably have made differently.

## Security and privacy
Trust boundary, new PII, authz per route. Run `security-review` on this section
when the change touches auth, uploads, payments, or personal data.

## Risks and rollout
What could break, how it is flagged or staged, how to roll back.

## Open questions
Question → owner → blocks (plan | build | release).
```

## Rules

- Prefer the smallest design that meets every requirement. Name rejected
  alternatives in one line each.
- Do not write code, file lists, or step order here; that is `plan.md`.
- If two policies conflict, present both options with the trade-off and stop.
  The product owner or tech lead resolves; the spec records the resolution.
- Higher-risk changes (auth, money, migrations that drop or rename, public
  APIs) need a tech-lead accept before `plan.md` starts. Say so at the top.

## Hand-off

Spec accepted → `sdlc` Stage 3 (`plan.md`). If acceptance edits the
spec after `plan.md` exists, update both in the same commit and note the
rework; the playbook tracks that as a lagging metric.
