# Agent memory

Keep this file under a page. When the agent makes a mistake twice, add the
correction here.

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
- Personal/project skills: read `SKILL.md`, do not paste skill bodies into code.

## Architecture

- (Where routes, domain, and adapters live. One short paragraph.)

## Things the agent gets wrong

- Do not bump dependency major versions unless the issue asks for it.
- Do not commit secrets, dumps with PII, or real connection strings.

## Project skills (`.cursor/skills/` or `.agents/skills/`)

Bootstrap copies SDLC skills into `.cursor/skills/`. Add domain skills
(React, Prisma, SEO) per product. Table:

| Skill | When to use |
|-------|-------------|
| (filled by bootstrap or the first session) | |
