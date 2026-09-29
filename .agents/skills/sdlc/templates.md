# Templates (adapted from the AI-native SDLC playbook)

Adapt names and paths to this repo; keep the section structure.

## intent.md (Stage 1: Plan)

```markdown
# Intent: claims status self-service
Author: J. Ortiz (claims operations). Status: draft.
Issue: #42
## Problem
Customers phone the contact center to ask where their claim is.
Handlers spend roughly a third of call time on status-only queries.
## Proposed outcome
Customers see claim status, next step and expected date in the portal.
## Affected users and systems
Claims handlers, portal team, claims-core API.
## Constraints
No new PII in the portal session. Existing authentication only.
## Open questions
Do third-party loss adjusters need access too?
```

Add `Issue: #<n>` on the line after `Author:` once the GitHub issue exists.

## GitHub issue templates (Stage 1: Plan)

`.github/ISSUE_TEMPLATE/feature.yml`:

```yaml
name: Feature / intent
description: A new capability or change, written as intent (what, why, constraints)
title: "[Feature] "
labels: ["type:feature"]
body:
  - type: textarea
    id: problem
    attributes:
      label: Problem
      description: What can't users do today? Who is affected? Evidence if any.
    validations:
      required: true
  - type: textarea
    id: outcome
    attributes:
      label: Proposed outcome
      description: What does "better" look like? Not the implementation.
    validations:
      required: true
  - type: textarea
    id: scope
    attributes:
      label: Affected users and systems
      placeholder: e.g. public listing page, /api/public/items, admin CMS
  - type: textarea
    id: constraints
    attributes:
      label: Constraints
      placeholder: e.g. no new PII, existing auth only, must keep current URLs for SEO
  - type: textarea
    id: questions
    attributes:
      label: Open questions
  - type: input
    id: intent
    attributes:
      label: Intent folder
      description: Path to intent/<slug>/ once committed
      placeholder: intent/my-change/
  - type: checkboxes
    id: dod
    attributes:
      label: Definition of done
      options:
        - label: spec.md accepted by product owner
        - label: plan.md reviewed before code
        - label: all commands in "Verifying your work" pass
        - label: PR reviewed by a human and closes this issue
```

`.github/ISSUE_TEMPLATE/bug.yml`:

```yaml
name: Bug
description: Something behaves differently from spec or expectation
title: "[Bug] "
labels: ["type:bug"]
body:
  - type: textarea
    id: expected
    attributes:
      label: Expected behavior
    validations:
      required: true
  - type: textarea
    id: actual
    attributes:
      label: Actual behavior
      description: Include the exact error text, screenshot, or log line.
    validations:
      required: true
  - type: textarea
    id: repro
    attributes:
      label: Steps to reproduce
      placeholder: |
        1. Go to /items
        2. Filter by category "Books"
        3. See empty list although 5 items match
    validations:
      required: true
  - type: input
    id: env
    attributes:
      label: Environment
      placeholder: production / staging / local, browser, commit SHA
  - type: dropdown
    id: severity
    attributes:
      label: Severity
      options: [blocker, high, normal, low]
    validations:
      required: true
  - type: checkboxes
    id: dod
    attributes:
      label: Definition of done
      options:
        - label: failing check (test or script) reproduces the bug and is committed first
        - label: fix makes the check pass without editing the check
        - label: regression covered by an eval or test
```

`.github/ISSUE_TEMPLATE/config.yml`:

```yaml
blank_issues_enabled: false
contact_links:
  - name: Question or discussion
    url: https://github.com/OWNER/REPO/discussions
    about: Use Discussions for questions that are not a feature or a bug
```

## Pull request template (Stage 5: Deploy)

`.github/pull_request_template.md`:

~~~markdown
Closes #

## What and why

<!-- One paragraph. Link the intent: intent/<slug>/intent.md -->

## Plan

<!-- Link intent/<slug>/plan.md. If the diff departs from the plan, say where and why. -->

## Verification

<!-- Paste the output of every command in "Verifying your work" (lint, types, build, tests).
     For UI changes attach before/after screenshots. -->

```
$ 
```

## Review passes (self-review before requesting review)

- [ ] Bugs: edge cases and regressions checked
- [ ] Security: no secrets in diff, input validated, no PII in logs
- [ ] Compliance: diff matches spec.md and plan.md; AGENTS.md rules respected

## Risk and rollback

<!-- Migrations? Feature flag? How to roll back in one step? -->

## Notes for the reviewer

<!-- Where to look first, what you are unsure about. -->
~~~

## gh commands for the issue-first flow

```bash
# 1. issue (body from intent.md)
gh issue create --title "Add category filter to item list" \
  --label "type:feature" --body-file intent/item-filters/intent.md

# 2. branch named after the issue number
git checkout -b feat/42-item-filters

# 3. commits reference the issue
git commit -m "feat(items): add category filter (#42)"

# 4. PR from the template; edit body to add "Closes #42"
git push -u origin HEAD
gh pr create --fill --label "type:feature"

# 5. labels, one-time per repo
for l in "type:feature:0E8A16" "type:bug:D73A4A" "type:chore:BFD4F2" \
         "priority:high:B60205" "priority:normal:C5DEF5"; do
  gh label create "${l%:*}" --color "${l##*:}" 2>/dev/null || true
done
```

Branch prefixes: `feat/`, `fix/`, `chore/`, `docs/`. Commit style:
`type(scope): summary (#issue)`.

## Prompt that produces spec.md (Stage 2: Design)

```
Read the attached intent.md and produce a requirements and design spec for integrating it into our existing codebase. Apply the skills available to you so the plan conforms to our brand guidelines, security policies and UX standards. Document the spec fully as spec.md, ready to hand to the engineering team. Describe clearly any areas of concern, especially where you cannot satisfy contradicting policies.
```

The course gives no fixed `spec.md` layout. A spec is acceptable when it:
solves the stated problem, answers or carries forward every open question
from `intent.md`, conforms to the loaded policy skills, and lists flagged
concerns (including contradicting policies) at the top.

## plan.md (Stage 3: Build)

```markdown
# Plan: claims status self-service (from intent.md 2026-06-02)

## Files that change

portal/src/claims/StatusPanel.tsx (new), claims-api/routes/status.py, claims-api/tests/test_status.py

## Order of work

1. Add the status endpoint behind existing auth.
2. Panel against the endpoint.
3. Wire into the portal nav.

## Risks

The claims-core API rate-limits at 50 rps; the panel must cache.

## Proof

test_status.py covers the four claim states; screenshot matches the approved mock.
```

## CLAUDE.md / AGENTS.md shape

```markdown
# Payments service
## Commands
- Build: make build
- Test: make test (unit), make itest (integration, needs docker)
- Lint: make lint (runs in CI; fix before pushing)
## Conventions
- Java 21, Spring Boot 3. No new Lombok.
- Money is always BigDecimal, never double.
- Every endpoint needs an integration test in src/itest.
## Architecture
- api/ holds REST controllers, core/ holds domain logic,
  adapters/ talks to external systems.
- Kafka events are defined in schemas/; never edit generated classes.
## Things Claude gets wrong
- Do not bump dependency versions; the platform team owns them.
- The legacy v1/ package is frozen; changes go in v2/.
```

Verification block to add:

```markdown
## Verifying your work

- Build: make build (must finish with "Build succeeded")
- Test: make test (all green; never skip or delete a failing test)
- Lint: make lint (zero warnings)

Run all three before reporting any task complete, and paste the output.
If a test fails, fix the code, not the test.
```

Rules: run `/init` once, cut to what a new joiner needs on day one, keep under
a page, check in at repo root, "when Claude makes a mistake twice, the
correction goes into CLAUDE.md".

## Skill (Stage 3: Build)

```markdown
---
name: secure-api-review
description: Apply the API security standard. Use whenever creating or
  modifying an external-facing endpoint, reviewing API code, or
  generating an OpenAPI spec.
---
# Secure API review
When you create or change an API endpoint:
1. Authentication: every endpoint requires the gateway JWT;
   no anonymous routes outside /health.
2. Input validation: validate request bodies against the OpenAPI
   schema and reject unknown fields.
3. Audit: every state-changing endpoint emits an audit event with
   actor, action, entity and timestamp.
4. Data classification: fields tagged pii in the schema must never
   appear in logs or error messages.
Run scripts/check-endpoints.sh and include its output in your summary.
```

Rule of thumb: write a skill for institutional knowledge that must be
applied consistently; don't write a skill for things that belong in
CLAUDE.md or a prompt. A skill is advisory; back it with a hook when the
policy must always hold.

## Subagent: .claude/agents/verifier.md (Stage 3: Build)

```markdown
---
name: verifier
description: Runs the app and checks the change works before the session reports done
tools: Bash, Read
---
Start the app with make run. Exercise the changed behavior and the two
nearest neighboring flows. Report what you ran, what you saw, and any
behavior that does not match plan.md. Do not fix anything; report only.
```

Parallel sessions: `claude --worktree feature-auth` in one terminal,
`claude --worktree fix-rate-limit` in another. Two or three sessions is a
sensible start; add only while review keeps up.

## REVIEW.md (Stage 5: Deploy)

```markdown
# Review instructions
## Passes
Run three passes and tag each finding with its pass:
- Bugs: logic errors, broken edge cases, subtle regressions
- Security: injection risks, authentication gaps, PII in logs
- Compliance: the change matches spec.md, plan.md and our design principles
## What Important means here
Reserve Important for findings that would break behavior, leak data
or breach a policy. Style and naming are nits.
## Cap the nits
Report at most five nits per review; summarize the rest as a count.
## Do not report
Generated files under src/gen/ and anything CI already enforces.
```

## Hook as approval gate (Stage 5: Deploy)

`.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          { "type": "command",
            "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/production-gate.sh" }
        ]
      }
    ]
  }
}
```

`.claude/hooks/production-gate.sh`:

```bash
#!/bin/bash
# Production deploys require a named release authorization
cmd=$(jq -r '.tool_input.command' < /dev/stdin)
if [[ "$cmd" == *"deploy"* && "$cmd" == *"production"* ]]; then
  if [ -z "$RELEASE_APPROVAL" ]; then
    echo "Production deploys need a release authorization." >&2
    exit 2   # exit 2 blocks the action; the message goes to Claude
  fi
fi
exit 0
```

Mechanics: tool input arrives as JSON on stdin; `exit 2` blocks and sends
stderr to the agent; `exit 0` allows. Team hooks live in `.claude/settings.json`
in Git; non-negotiable hooks live in managed settings.

## Continuous evals: .github/workflows/agent-evals.yml (Stage 4: Test)

```yaml
name: Agent evals
on:
  pull_request:
    paths: ['CLAUDE.md', '.claude/**']
  schedule:
    - cron: '0 2 * * *'
jobs:
  evals:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm install -g @anthropic-ai/claude-code
      - name: Run eval suite
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
        run: |
          for eval in evals/*.json; do
            claude -p "$(jq -r '.prompt' $eval)" \
              --allowedTools "Read,Edit,Bash(make test)" \
              --output-format json > result.json
            ./evals/check.sh "$eval" result.json
          done
```

Start with 20 to 50 real tasks, each with its acceptance checks. Every
production incident becomes a permanent eval.

## Pipeline step: triage a failed build (Stage 5: Deploy)

```yaml
- name: Triage failed build
  if: failure()
  run: >
    claude -p "Read the build log at out/build.log. Identify the most
    likely cause, say whether the failure looks flaky or real, and write a
    three-line summary for the PR thread." >> triage.md
```

## Control bands: bands.yaml (Stage 6: Maintain)

```yaml
metric: ci_test_failure_rate
baseline: rolling_30d
rules: western_electric
tiers:
  1sigma: { action: log }
  2sigma: { action: diagnose,
            tools: "Read,Grep,Bash(gh run view *)" }
  3sigma: { action: propose,
            routes: [pull_request, runbook:rollback-deploy] }
```

Detection is deterministic (mean and standard deviation over a rolling
window, Western Electric rules); no model involved. 1σ logs, 2σ diagnoses
read-only, 3σ may propose via PR or a pre-approved runbook only.

## Managed settings for a regulated enterprise (Stage 5: Deploy)

```json
{
  "permissions": {
    "deny": [
      "Read(.env*)", "Read(./secrets/**)",
      "WebFetch", "Bash(curl *)", "Bash(wget *)"
    ],
    "allow": [
      "Bash(git *)", "Bash(make build)",
      "Bash(make test)", "Bash(make lint)"
    ],
    "disableBypassPermissionsMode": "disable"
  },
  "allowManagedPermissionRulesOnly": true,
  "sandbox": {
    "enabled": true,
    "failIfUnavailable": true,
    "allowUnsandboxedCommands": false,
    "network": { "allowedDomains": ["git.internal.example.com", "registry.npmjs.org"] },
    "credentials": {
      "files": [
        { "path": "~/.ssh", "mode": "deny" },
        { "path": "~/.aws/credentials", "mode": "deny" }
      ],
      "envVars": [ { "name": "GITHUB_TOKEN", "mode": "deny" } ]
    }
  },
  "allowManagedHooksOnly": true,
  "disableSideloadFlags": true,
  "allowManagedMcpServersOnly": true,
  "strictKnownMarketplaces": [
    { "source": "github", "repo": "example-corp/approved-plugins" }
  ],
  "requiredMinimumVersion": "2.1.193"
}
```

Treat as a starting point; each deny rule removes a capability and the
right balance depends on the repo's data classification.
