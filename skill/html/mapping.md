# Mapping `copywriting.md` → Snippets

This document defines how to map sections from `copywriting.md` (produced by `/landing copy`) to the snippets under `snippets/`.

## Canonical section order (output)

The assembled page uses this order. Missing sections are simply skipped — never synthesized.

1. **nav** (always) — `snippets/nav.html`
2. **hero** (always) — `snippets/hero.html`
3. **problem** (if present) — `snippets/problem.html`  · bg: `#F5F5F7`
4. **features** (always) — `snippets/features.html`  · `id="how-it-works"`, bg: `#FFFFFF`
5. **stats** (if present) — `snippets/stats.html`  · bg: `#1D1D1F` (dark)
6. **testimonial** (if present) — `snippets/testimonial.html`  · bg: `#F5F5F7`
7. **integration** (if present) — `snippets/integration.html`  · bg: `#FFFFFF`
8. **faq** (if present) — `snippets/faq.html`  · bg: `#F5F5F7`
9. **conversion** (always) — `snippets/conversion.html`  · `id="convert"`, bg: `#FFFFFF`
10. **final-cta** (always) — `snippets/final-cta.html`  · bg: `#1D1D1F` (dark)
11. **footer** (always) — `snippets/footer.html`  · bg: `#1D1D1F` (dark)
12. **cookie-banner** (conditional) — `snippets/cookie-banner.html` · fixed bottom, z-index 200 · injected last in the body. See "cookie-banner" rule below.

## Section recognition rules

For each section below, if the pattern is present in `copywriting.md`, include the corresponding snippet.

### nav → `nav.html` (always)
- Always included. Brand name from the top of `copywriting.md`.

### hero → `hero.html` (always)
- Always included. Sources:
  - **Headline**: use the "Recommended primary headline" from the HERO SECTION. If absent, use Variant A.
  - **Subheadline**, **Primary CTA**, **Secondary CTA**, trust microcopy — all from HERO SECTION.
- Illustration: `.illustration-placeholder` on the right with a sector-appropriate FA icon (see icon table below).

### problem → `problem.html` (conditional)
- Include if `THE SETUP` section is present with pain-point bullets.
- Sources: section title + 3 pain bullets + illustration on the left (warning icon).

### features → `features.html` (always)
- Source: `VALUE PROPOSITION (Three Named Buckets)`.
- Grid of 3 cards, one per bucket. Card title = bucket theme name; card body = benefit.
- Stagger reveal (delay 0s, 0.08s, 0.16s).
- `id="how-it-works"` on the section (matches Secondary CTA anchor).

### stats → `stats.html` (conditional)
- Include only if explicit numeric metrics exist in `copywriting.md` (in `Proof` fields, `Stats` block, or similar). Do not fabricate.
- Dark background; numbers use gradient text; `data-target="N"` + `data-suffix="..."` on counters.

### testimonial → `testimonial.html` (conditional)
- Include only if a real testimonial (not a `TODO`) is present in the SOCIAL PROOF block.
- Verbatim quote, name, role, company.

### integration → `integration.html` (conditional)
- Include if the copy references specific systems, APIs, or compatibility (e.g. "works with SAP, Oracle, Slack…"). Otherwise skip.

### faq → `faq.html` (conditional)
- Include if OBJECTION HANDLING has at least one Q/A pair not already handled inline.
- `<details>/<summary>` accordion with rotating chevron.

### conversion → `conversion.html` (always)
- Always included with `id="convert"`.
- Placeholders: `{{CONVERSION_TITLE}}`, `{{CONVERSION_LEAD}}`, `{{CONVERSION_EMBED}}`.
- Title and lead come from `copywriting.md` and must match the **framing** recorded in the FINAL CTA block (`<!-- framing: booking -->` or `<!-- framing: contact -->`):
  - **Booking framing** → title e.g. *"Book a demo"*, lead pointing to the calendar.
  - **Contact framing** → title e.g. *"Let's talk"*, lead pointing to the form.
- `{{CONVERSION_EMBED}}` is built in the `/landing html` prompt's detection logic:
  - Booking URL (Calendly / SavvyCal / Cal.com) → the vendor's verbatim inline-widget block, colours adapted.
  - Raw HTML (form / iframe / vendor embed) → pasted verbatim.
  - Empty → visual mock, re-labelled per the framing.

### final-cta → `final-cta.html` (always)
- Source: `FINAL CTA` block in `copywriting.md`.
- Dark background with radial glow. Button points to `#calendly`.

### footer → `footer.html` (always)
- Brand name + copyright year + Privacy / Terms / Contact link row.
- The three link placeholders (`{{PRIVACY_LINK}}`, `{{TERMS_LINK}}`, `{{CONTACT_LINK}}`) are filled per FASE 0 Q7-Q9 — see `rules.md` "Footer link rules (M14)". **Never emit bare `href="#"`.**

### cookie-banner → `cookie-banner.html` (conditional)
- Include if FASE 0 Q10 = yes (default when the conversion embed is third-party: Calendly, SavvyCal, Cal.com, HubSpot, Tally, Typeform, or any HTML containing `<script src="https://`).
- Inject immediately before `</body>`, after `{{SECTIONS}}` (the banner is fixed-position; its DOM order is flexible).
- When included, the conversion embed must use the consent-gate pattern (placeholder + `<div id="calendly-slot" data-embed-url="...">`) — see `rules.md` "Cookie consent banner (M15)".

## Icon mapping (sector hints)

Use these Font Awesome 6 icons where the snippet has `{{..._ICON}}` placeholders. Pick the icon that matches the product's sector.

| Sector | Icons |
|---|---|
| SaaS / AI / Tech | `fa-robot`, `fa-microchip`, `fa-bolt-lightning`, `fa-chart-line`, `fa-share-nodes` |
| Finance / Compliance / Legal | `fa-shield-halved`, `fa-file-invoice`, `fa-scale-balanced`, `fa-building-columns`, `fa-file-circle-check` |
| HR / People / Recruiting | `fa-users`, `fa-user-tie`, `fa-handshake`, `fa-user-check` |
| Healthcare | `fa-heart-pulse`, `fa-hospital`, `fa-stethoscope`, `fa-pills` |
| E-commerce / Logistics | `fa-cart-shopping`, `fa-truck`, `fa-tags`, `fa-box` |
| Marketing / Growth | `fa-bullhorn`, `fa-chart-pie`, `fa-arrow-trend-up`, `fa-star` |
| Security / Privacy | `fa-lock`, `fa-shield`, `fa-key`, `fa-user-shield` |
| Scheduling | `fa-calendar-check`, `fa-clock`, `fa-calendar-days` |

Default (unclear sector): `fa-bolt-lightning` for hero badge, `fa-chart-line` for hero illustration, generic icons per section.

## Fidelity rule (cannot be violated)

| ❌ Wrong | ✅ Right |
|---|---|
| Brand "StartupGen" when the copy says "VendorFlow AI" | Always use the exact brand name |
| A generic H1 replacing the copywriting H1 | Verbatim from `copywriting.md` |
| CTA "Request demo" when the copy says "Request a Free Demo" | Verbatim CTA text |
| Collapsing "Problem" and "Setup" into one section | Every section gets its own snippet |
| Inventing a testimonial that is not in the copy | Use only what is in `copywriting.md` |

Every `##` (or clearly named block) in `copywriting.md` corresponds to a distinct HTML section — never collapse.

## Fallback rules

- If a section exists in the copy but lacks enough content to fill its placeholders, leave the placeholder as a clear `TODO` in the HTML comment (`<!-- TODO: fill Xyz -->`) so the user can complete it before publishing. Do not invent.
- `calendly` section is added **always**, even if not mentioned in the copy.
- `final-cta` and `footer` are always added.
- `stats`, `testimonial`, `integration`, `faq`, `problem` are conditional.
