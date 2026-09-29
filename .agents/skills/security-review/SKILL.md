---
name: security-review
description: >-
  Review diffs, APIs, and auth for OWASP-style issues: injection, broken authz,
  secrets, PII in logs, CSRF, rate limits, insecure cookies, supply chain.
  Use when adding endpoints, auth, payments, file upload, webhooks, env vars,
  ORM or raw queries, or when the user asks for a security review, threat model,
  or "is this safe to ship".
---

# Security review

Advisory checklist for a change. Findings never approve the PR. If the project
has `.agents/skills/api-security-best-practices`, read that SKILL after this
one when implementing (not when only reviewing).

## Scope first

Name the trust boundary: public internet, logged-in user, admin, server-only.
List new routes, new tables, new env vars, new third-party calls.

## Passes (tag each finding)

### Authn / authz

- Mutations authenticate **inside** the handler/action, not only in middleware.
- Object-level authz: user A cannot read/write user B's rows (IDOR).
- Admin routes check role/permissions, not only "has a JWT".
- Customer JWT and admin JWT must not share the same secret if both exist.

### Input and data

- Validate body/query with a schema (Zod or equivalent); reject unknown fields
  on privileged APIs.
- Database: no raw SQL built by string concatenation; parameterized only.
- Rich text sanitized before store and before render.
- File upload: type/size allowlist, no user-controlled path, no public exec.

### Secrets and PII

- No secrets, connection strings, or password hashes in git, logs, or client
  bundles. `.env*` stays gitignored except `*.example` with placeholders.
- PII (email, phone, hashes) not in client error payloads or `console.log`.
- Tokens in `localStorage` are XSS-sensitive; note as follow-up if httpOnly
  cookies are the stated target.

### Abuse and privacy

- Public POST (leads, contact, login) has rate limiting.
- CORS is explicit, not `*`, for credentialed APIs.
- Webhooks verify signatures; ignore unauthenticated admin-shaped payloads.

### Headers and cookies

- Production cookies: `Secure`, `HttpOnly`, `SameSite` as appropriate.
- Security headers if the app sets them (CSP, HSTS) — do not invent a CSP
  that breaks the app; flag missing headers only.

## Severity

- **Important**: break authz, leak secrets/PII, unauthenticated mutation, RCE,
  SQLi. Must fix before merge.
- **Nit**: missing rate limit on a low-risk GET, verbose errors in dev, docs.
  Cap nits at five; count the rest.

## Output

```markdown
## Security review
Trust boundary: …
### Important
- [route/file] issue → fix
### Nits
- …
### Residual risk
What we are accepting (e.g. JWT in localStorage until dedicated task).
```

Do not write exploit payloads or attack reproduction steps. Describe the
weakness and the fix only.

## After the review

Important findings → issue `type:bug` + `priority:high` if not in the same PR.
Repeat class of bug twice → add a line to `AGENTS.md` or a project skill.
