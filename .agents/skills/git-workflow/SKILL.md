---
name: git-workflow
description: >-
  Issue-first Git flow for agents: create the GitHub issue, branch
  <type>/<n>-<slug>, conventional commits that reference the issue, PR body
  from the template with "Closes #n", and never self-merge. Use when asked
  to commit, push, open a PR, name a branch, write a commit message, or when
  starting any change that has no issue yet.
---

# Git workflow

Every change has a ticket, a branch named after it, and a PR a human merges.
No commits to `main`. No force-push to shared branches. No self-merge.

## Issue

```bash
gh issue create --title "<imperative summary>" --label "type:feature" \
  --body-file intent/<slug>/intent.md          # or --template bug
```

Labels: `type:feature | type:bug | type:chore`, `priority:high | priority:normal`.
Put `Issue: #<n>` on the second line of `intent.md`. If `gh` is not logged in
or there is no remote, write `intent/<slug>/issue.md` and say so; do not skip.

## Branch

`<type>/<n>-<slug>` with `type` ∈ `feat | fix | chore | docs | refactor`.
Example: `feat/42-item-filters`. Start from an up-to-date `main`.

```bash
git fetch origin && git switch -c feat/42-item-filters origin/main
```

## Commits

Format: `type(scope): summary (#n)`. Imperative, ≤ 72 chars, body explains why
when the diff does not. One logical change per commit; a failing test for a bug
is its own commit before the fix.

- Stage explicitly (`git add <paths>`); never `git add -A` blind. Check
  `git status` for `.env*`, dumps, keys, and generated noise before staging.
- Do not amend or rebase commits that are already pushed to a shared branch.
- Never bypass hooks (`--no-verify`) unless the user asked and knows why.

## Pull request

```bash
git push -u origin HEAD
gh pr create --fill --label "type:feature"   # then edit body to the template
```

The body follows `.github/pull_request_template.md`:

- `Closes #<n>` on the first line.
- What and why, link to `intent/<slug>/intent.md`.
- Plan link; where the diff departs from `plan.md` and why.
- Verification: paste the output of every "Verifying your work" command.
- Review passes ticked after actually doing them (`code-review` skill).
- Risk and rollback in one paragraph.

One issue per PR. If the work splits, open a second issue and PR. Keep the PR
small enough to review in one sitting; stack PRs rather than growing one.

## After opening

- Wait for a human approval. The agent that wrote the code cannot approve or
  merge it, even with green checks.
- Address review comments in new commits (no force-push), reply on each thread.
- When merged, delete the branch and close the loop in `AGENTS.md` if a mistake
  repeated (`agent-memory` skill).

## Trivial changes

Typo, copy tweak, one-line fix: still an issue (`type:chore`) and a PR. Only a
personal scratch branch is exempt.
