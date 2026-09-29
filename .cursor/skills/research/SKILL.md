---
name: research
description: >-
  Research competitors, products, markets, APIs, and existing codebases before
  writing intent.md or spec.md. Catalog features, flows, pricing, SEO pages, and
  gaps. Use when the user shares a URL to study, asks for competitor analysis,
  feature inventory, market research, "how does X work", codebase archaeology,
  or "what should we build first".
---

# Research

Produce evidence, not opinions. Write findings to `intent/<slug>/research.md`
(create the folder if needed). Feed a short "so what" into `intent.md`; do not
skip research and jump to code when the user asked to study a product or market.

## When to stop gathering

Stop when you can answer: who the user is, the core loop, the 5–15 features that
matter, and what we would copy vs skip. Do not dump every nav link.

## Sources (use several)

1. **Live product**: browser for JS/Cloudflare sites; WebFetch/curl for public
   HTML. Homepage, pricing, signup, one detail page, footer, logged-out tools.
2. **Third-party**: reviews, docs, changelog, status page, App Store, GitHub.
3. **This repo**: `AGENTS.md`, routes, Prisma schema, existing `docs/research/`.
4. **SEO/keywords**: titles, H1s, calculator/tool URLs (each is often a landing
   page).

If a page is behind login, record what the public site advertises and mark
"needs account" instead of inventing dashboard features.

## Output: `research.md`

```markdown
# Research: <subject>
Date: <ISO date>
Sources: <URLs>

## One-line thesis
What this product is and how it makes money.

## Core loop
1. …
2. …

## Feature inventory
Grouped: marketing, directory/catalog, detail pages, tools, account/dashboard,
payments, content/SEO, i18n, trust. Bullet each feature with evidence (quote
or URL). Mark MVP / later / skip.

## Sample data
3–5 concrete examples (broker + rebate rate, price, payout method).

## Gaps vs this repo
What we already have, what is missing, risky copies (legal, IB contracts).

## Open questions
```

## Competitive table (when comparing 2+ products)

Columns: feature, competitor A, competitor B, us (now), recommend.
Lead with the recommendation, then the table.

## Codebase research

When the subject is "how does this repo do X": find the route, service, schema,
and one call chain. Cite files with line ranges. Do not re-read the whole tree
if a grep + 3 files answer it.

## Hand-off

- New product work → `ai-native-sdlc` (issue + `intent.md` from the thesis).
- Security-sensitive findings (tokens in HTML, IDOR in public API) →
  `security-review` immediately, do not wait for a feature PR.
