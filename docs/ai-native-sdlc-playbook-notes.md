# AI-native SDLC playbook: lesson notes

Source: https://academy.claude.com/courses/ai-native-sdlc-playbook
(Anthropic Applied AI team, 14 lessons). Each play follows the same layout:
What changes -> Getting started (prerequisites, infrastructure) -> How to
execute -> What it looks like -> Governance -> How to measure (leading /
lagging). Templates are in `.agents/skills/sdlc/templates.md`.

## Introduction

- Traditional SDLC: six stages (plan, design, build, test, deploy, maintain),
  each owned by a different role, moved along by documents, tickets, sign-offs.
  Built for the era when writing code was the expensive part.
- Once agents write most of the diff: the bottleneck moves to plan, review,
  test and deploy (still human speed); line-by-line review stops matching
  reality; governance cost rises because exceptions route through committees.
- AI-native SDLC keeps the old control objectives but changes enforcement.
  The process becomes a loop with AI embedded at each point and humans "above
  the loop instigating, directing, and governing".
- Every stage ends by writing an artifact to version control (`intent.md`,
  `spec.md`, `plan.md`, diff and tests, PR with findings, incident record).
  The next stage begins by reading it. The chain of commits is the audit trail.
- Trigger chain: accepted `intent.md` -> requirements/design pass; approved
  `spec.md` -> plan mode; merged PR -> pipeline; breached control band ->
  new `intent.md`.
- Adoption: prompt each step by hand first; end state is each accepted
  artifact firing the next gate.

## Stage 1: Capture as intent.md

- Replaces backlog entry -> user story -> story points -> refinement, where
  ownership transfers at each handoff.
- Originator brainstorms with Claude in their own words; Claude asks the
  analyst questions (scope, users, constraints, success); result written with
  the org template; originator corrects; commit to a shared intent home.
- Intent home: `intent/` folder in the product repo for a single product; a
  separate repo only when intent spans many repositories. Non-Git users
  commit through a VCS connector.
- Product owner reviews and corrects before commit, regardless of origin.
- Governance: evidence is the committed file with author, timestamp,
  revision history; accept/reject recorded as merge or closing review.
- Measure: time from first conversation to committed `intent.md` (target:
  hours, not weeks); share accepted into Design; edits to `intent.md` after
  the first `spec.md` commit.

## Stage 2: Requirements and design

- Requirements and design happen in one prompted session constrained by
  skills (brand, security, compliance, UX), concerns flagged.
- Progression: run by hand -> org-level slash command -> non-interactive job
  fired by the intent merge that commits `spec.md` as a PR.
- Review: does the spec solve the stated problem, are open questions answered
  or carried forward. Work flagged concerns first with their policy owners.
- Commit `spec.md` beside `intent.md`. A human always decides whether to
  progress to build; higher-risk changes consult a tech lead.
- Front-end: mock the design in Claude Design from `intent.md`, export to
  Claude Code.
- Measure: `intent.md` commit to `spec.md` commit elapsed time; `spec.md`
  commits dated after the first `plan.md` commit (rework).

## Stage 3: Plan mode as the default starting point

- Start in plan mode; give `intent.md` and `spec.md`; ask for files, order,
  tests. Interrogate: what could break, riskiest step, rejected options.
- Iterate until a stranger could implement from the plan alone. Commit as
  `plan.md`; PR review checks the diff against it. Update `plan.md` in the
  same commit when implementation departs; a hook can enforce sync.
- Plan mode enforces design review before code because the agent cannot edit
  until the plan is accepted. Routine: engineer approves; higher-risk: tech
  lead or architect.
- Auto mode becomes the default for routine work once guardrails mature
  (tuned CLAUDE.md, policy skills, hooks, runnable tests). Shift from watching
  edits to reviewing artifacts after longer autonomous sessions.
- Legacy systems: name one source of truth per artifact. Options: repo is
  truth (legacy links to commits); legacy system is truth (agent reads and
  writes back via MCP in the same session); linkage as the minimum bar
  (record ID in the Markdown, commit SHA in the record).
- Measure: first-pass merge rate; plan approval to merge time; rework cycles;
  diff still matching `plan.md`.

## Stage 3: The CLAUDE.md

- `/init`, then cut to what a new joiner needs on day one: build/test/lint
  commands, conventions that matter, things Claude keeps getting wrong.
- Check in at repo root; changes reviewed like code by code owners.
- "When Claude makes a mistake twice, the correction goes into CLAUDE.md."
- Keep under a page; stale content wastes context.
- Measure: repeated mistakes CLAUDE.md should have caught; time to first
  merged PR for a new team member.

## Stage 3: Skills as institutional knowledge

- Pick one policy enforced inconsistently today. Write it from the policy
  owner's source of truth as `SKILL.md` (frontmatter says when it triggers,
  body says what to do). Ship in the repo or via a plugin.
- Test that it triggers by asking for the task in different ways.
- Policy changes -> skill changes -> policy owner signs off.
- A skill is an advisory control. Anything that must always hold needs a
  hook or a review pass behind it: "The skill makes violations rare and the
  hook makes them close to impossible."
- Build-phase hooks: block edits to protected paths, run formatter/lint after
  edits, keep credentials out of the diff, back non-negotiable skills. Keep
  them fast and scoped to the changed file; full test suite belongs at
  commit or PR. Human-approval hooks belong at deploy gates.
- Measure: policy approval to skill merge time; review findings citing the
  policy should fall toward zero.

## Stage 3: Parallel sessions and subagents

- Parallel session: another full instance in its own Git worktree
  (`claude --worktree <branch>`); sessions share nothing but the engineer.
- Subagent: scoped helper inside a session with its own context and tool
  limits, defined in `.claude/agents/*.md` (name, description, tools).
  Examples: code simplifier, verifier, researcher.
- Split work by files using `plan.md`; shared-file tasks run sequentially in
  one session. Start with two or three sessions; ceiling is review capacity.
- Permission settings tuned so sessions are not blocked on safe commands.
- Governance: controls come from repo configuration so they apply to all
  sessions; actions logged and attributed to the engineer.
- Measure: concurrent sessions per engineer while review quality holds;
  merged changes per engineer per week beside the rework rate.

## Stage 4: Give Claude a feedback loop

- Always give the agent a way to verify its own work: tests, build, or
  screenshot diff. Wrap multi-step checks in one command that exits non-zero.
- List each command in CLAUDE.md Commands with an example of healthy output.
- State a quantifiable target ("all tests in test_status.py pass").
- Bug fixes: reproduce as a failing test, confirm it fails for the expected
  reason, commit it, then fix without editing the test (hook enforces).
- UI: browser or screenshot tool plus the mock; implement, screenshot,
  compare, adjust; two or three rounds is normal.
- Verification is part of done; paste the output. Protect the loop: the agent
  must not weaken the check on the code it is fixing.
- Feedback loop runs throughout the task; the verifier subagent is a single
  fresh-context final check.
- Measure: first-pass CI success for agent-written changes; review time per
  PR; change failure rate.

## Stage 4: Continuous evals in CI

- Evals are the AI-native stage-gate QA: real tasks plus acceptance checks
  that run whenever agent configuration changes (CLAUDE.md, skills, hooks,
  model, prompts) and on a schedule.
- Collect 20 to 50 real tasks with expected outcomes; write each as prompt
  plus checks (tests pass, lint clean, behavior unchanged, policy followed).
- Gate configuration changes on the pass rate. Every production incident
  gets an eval owned by the team that had the incident.
- Live suite: retire cases that stop discriminating, add from monitoring.
- Measure: pass rate over time; incident to permanent eval time; regressions
  caught in CI vs found in production.

## Stage 5: AI in the PR review loop

- All PRs get identical review passes with severity-ranked findings; humans
  move up to intent and risk.
- Managed Code Review service is the fastest start; `claude-code-action` in
  your own CI when you need pipeline control or cloud routing.
- Tech lead writes `REVIEW.md` at repo root: passes (bugs, security,
  compliance against `spec.md`, `plan.md`, design principles), what counts
  as Important vs Nit, what to skip.
- Findings never approve or block by themselves; branch protection still
  requires a code owner. Tag `@claude` on a comment to have it fixed and
  pushed; teams wrap this in a slash command that sweeps unresolved comments
  and failing checks until the PR is green.
- Second-time findings go into CLAUDE.md as part of the review. Monthly the
  tech lead rates findings and caps nit volume; exclude generated paths and
  what CI already enforces.
- Governance: separation of duties preserved because the agent that wrote
  the code cannot approve it; the PR is the audit record.
- Measure: time to first review (minutes); comments resolved without a human
  touching the branch; defects caught before merge vs escaped.

## Stage 5: Hooks as approval gates

- A hook runs before the agent acts and can allow, ask, or block. Leadership
  with change management and compliance lists the gates that must survive
  (change sign-off, release authorization, protected paths); the platform
  engineer expresses each as a hook.
- Team hooks in `.claude/settings.json`; non-negotiable hooks in managed
  settings that engineers cannot switch off.
- A block explains itself and names the route to approval.
- Managed settings cover: `permissions.deny` (secrets, arbitrary egress),
  `permissions.allow` (safe inner loop), `disableBypassPermissionsMode` +
  `allowManagedPermissionRulesOnly`, OS `sandbox` with domain allowlist and
  credential denies, `allowManagedHooksOnly`, `disableSideloadFlags`,
  `strictKnownMarketplaces`, `allowManagedMcpServersOnly`,
  `requiredMinimumVersion`.
- Measure: time waiting on each gate (every hook decision is in the
  OpenTelemetry export); gate violations reaching production before/after.

## Stage 5: CI/CD integration and deployment

- Prerequisites: PR review loop and hooks, "because the gates must exist
  before automation accelerates anything through them".
- Start with read-only judgment steps via `claude -p` (triage failed build,
  summarize flaky test, draft changelog). Then write steps behind existing
  gates (fix lint, update generated docs, address `@claude` comments); all
  arrive as PRs through branch protection with no route to `main`.
- Sandboxed execution: containers, network policy, short-lived scoped
  tokens, no standing production credentials.
- Expose deploy, status, rollback as MCP tools scoped per environment.
- Tier autonomy: dev deploys freely; production is prepared by the agent and
  authorized by the release manager with a hook enforcing the gate.
- Rollback is the most rehearsed path: one command, exercised in staging.
- Governing principle: "the agent may act up to the production gate and
  cannot pass it."
- Measure: pipeline failures triaged without paging a human; DORA metrics.

## Stage 6: Closing the loop on metrics

- Maintain runs headless with a deterministic confidence gate between
  stages. A trigger (control-band breach, ticket, channel message, schedule)
  invokes Claude without a person in the path.
- Pick one metric with a stable rolling baseline (CI failure rate,
  post-deploy 5xx, PR cycle time). Detection script: mean and standard
  deviation over a rolling window with Western Electric rules; version
  controlled, unit tested, no model involved.
- Tiers in `bands.yaml`: 1σ log; 2σ diagnose read-only; 3σ propose via PR
  into the review gate or a pre-approved runbook.
- Agent writes the diagnosis as `intent.md` (anomaly and evidence, proposed
  outcome, affected systems, open questions). Service owner triages: fix now,
  schedule, dismiss; dismissals tune the bands. Shipped fix -> new eval.
- Claude Tag (Slack/Teams) gives incidents a first responder under its own
  identity, verifies recovery via MCP, writes the post-mortem to a
  version-controlled lessons file; larger work becomes `intent.md`.
- Measure: breach to `intent.md` in triage queue; findings that become merged
  fixes; repeat incidents of the same class.

## Resources (rollout order)

- Admin setup: https://code.claude.com/docs/en/admin-setup
- Settings: https://code.claude.com/docs/en/settings
- Server-managed settings: https://code.claude.com/docs/en/server-managed-settings
- Permissions: https://code.claude.com/docs/en/permissions
- Sandboxing: https://code.claude.com/docs/en/sandboxing
- Hooks: https://code.claude.com/docs/en/hooks-guide and https://code.claude.com/docs/en/hooks
- Skills: https://code.claude.com/docs/en/skills
- Plugin marketplaces: https://code.claude.com/docs/en/plugin-marketplaces
- Managed MCP: https://code.claude.com/docs/en/managed-mcp
- Enterprise deployment: https://code.claude.com/docs/en/third-party-integrations
- Network config: https://code.claude.com/docs/en/network-config
- Monitoring: https://code.claude.com/docs/en/monitoring-usage and https://code.claude.com/docs/en/analytics
- Compliance API: https://platform.claude.com/docs/en/manage-claude/compliance-api
- Security model: https://code.claude.com/docs/en/security
- Sub-agents: https://code.claude.com/docs/en/sub-agents
- Code Review: https://code.claude.com/docs/en/code-review
- Agent SDK: https://code.claude.com/docs/en/agent-sdk/overview
- Steering guide (skills vs CLAUDE.md vs hooks): https://claude.com/blog/steering-claude-code-skills-hooks-rules-subagents-and-more
