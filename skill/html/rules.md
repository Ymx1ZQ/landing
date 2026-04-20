# Output Rules — `index.html`

These rules govern the final HTML output of `/landing html`. Read this file before assembling the page and run through the **Final Checklist** at the bottom before writing `index.html`.

## Invariants

1. **Output is a single standalone HTML file** — CSS inline in `<style>`, JS inline in `<script>`. Only external dependencies: Font Awesome CDN and (optionally) the Calendly widget script. Never reference external `<img src="https://...">` or remote stylesheets beyond those two.
2. **Fidelity to copy**: headlines, sub-copy, CTAs, metrics, testimonials, FAQ answers — all **verbatim** from `copywriting.md`. Do not paraphrase. Do not substitute generic placeholders. If the copy says "Book a Free Demo", the button says "Book a Free Demo".
3. **Every section of `copywriting.md` maps to its own HTML section.** Do not collapse sections.
4. **Never invent** metrics, clients, testimonials, or numbers that are not in the copy.
5. Always include `#calendly` and the final CTA, even if the copy doesn't mention them.
6. **Language**: the HTML must match the artifact language chosen via the router.

## Pre-compiled URL blocks (paste verbatim)

### Font Awesome CDN — always in `<head>`

```
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.2/css/all.min.css">
```

Do not reformat, do not wrap in markdown syntax, do not add brackets. That line is immutable.

### Calendly inline widget — paste verbatim, change only `ACCOUNT`, `EVENT`, and `primary_color`

```
<!-- Calendly inline widget begin -->
<div class="calendly-inline-widget"
     data-url="https://calendly.com/ACCOUNT/EVENT?background_color=ffffff&text_color=1d1d1f&primary_color=0071e3"
     style="min-width:320px;height:700px;"></div>
<script type="text/javascript" src="https://assets.calendly.com/assets/external/widget.js" async></script>
<!-- Calendly inline widget end -->
```

Only permitted substitutions:
- `ACCOUNT` → the Calendly account handle provided in FASE 0
- `EVENT` → the event name provided in FASE 0
- `0071e3` → the primary brand colour **without** the leading `#`

Everything else is immutable.

## URL hygiene (browser, not markdown parser)

The browser reads every `href="..."`, `src="..."`, and `data-url="..."` as a **raw string**. The characters `[` and `]` do not belong inside any real URL. Before writing the output, scan for `](http` anywhere in the file — if found, fix it. The only URL-bearing lines in the entire file are the Font Awesome CDN, the Calendly `data-url`, the Calendly `<script src="...">`, and any internal anchors (`href="#..."`).

## Illustrations

- Only `.illustration-placeholder` div + one Font Awesome icon. Never `<img src="https://...">` with an external URL. Never SVG inline (context explosion).
- CSS is already in `skeleton.html`. Do not duplicate it in snippets.

Placement:
- Hero — right column.
- Problem — left column.
- Integration — right column.
- Other sections — no placeholder.

## Dark-section colour rules

Sections with `bg: #1D1D1F` (stats, final-cta, footer) must use:

```css
h1, h2, h3     { color: #FFFFFF; }
p, li, span    { color: rgba(255,255,255,0.6); }
small, caption { color: rgba(255,255,255,0.35); }
```

Never use `var(--text-secondary)` (which is `#6E6E73`) on a dark background. It is unreadable.

## SEO / meta

The `<head>` must always include:

- `<title>{{TITLE}}</title>` — product name + short tagline (e.g. `VendorFlow AI — AI-powered vendor risk management`).
- `<meta name="description" content="{{META_DESCRIPTION}}">` — ≤ 160 characters, derived from the hero subheadline or the value proposition.
- `<meta property="og:title" content="...">` — same value as `<title>` or slightly shorter.
- `<meta property="og:description" content="...">` — same or same-as-description.
- `<meta property="og:type" content="website">`.

Do not synthesize false metadata — extract from the copy.

## Accessibility

- Every `<img>` (if any — rare, illustration-placeholders don't need it) has `alt`.
- Every icon-only button or interactive icon has `aria-label`.
- Every `.illustration-placeholder` has `aria-hidden="true"` (decorative).
- Colour contrast: the dark-section rules above already guarantee AA contrast for body text on dark backgrounds. For primary-on-primary combinations (e.g. white button on the dark final CTA), keep the contrast ≥ 4.5:1.
- `@media (prefers-reduced-motion: reduce)` must disable all animations (reveal, float, counter). The skeleton CSS already wires this.
- Focus states on interactive elements: keep the default `:focus-visible` outline or provide a custom one; never `outline: none` without a replacement.

## Final checklist (run before writing `index.html`)

### Fidelity
- [ ] Brand name verbatim in nav, hero, footer.
- [ ] H1 and hero sub verbatim from `copywriting.md`.
- [ ] Primary CTA text verbatim.
- [ ] Every `##` section in the copy present as its own HTML section.
- [ ] Stats/metrics: only those explicitly in the copy.
- [ ] Testimonials: only those explicitly in the copy (not TODO placeholders).
- [ ] FAQ: all Q/A present in the copy (none invented).

### Structure
- [ ] `<!DOCTYPE html>` first line, nothing before.
- [ ] `<meta charset>` and `<meta viewport>`.
- [ ] `<title>` and `<meta name="description">` populated from the copy.
- [ ] `og:title`, `og:description`, `og:type` populated.
- [ ] Font Awesome CDN in `<head>` with the exact URL from the pre-compiled block.
- [ ] All CSS inlined in `<style>` inside `<head>`; `:root` vars set.
- [ ] All JS inlined in `<script>` before `</body>`.

### Design
- [ ] Section alternation: white → gray → white → dark → gray → white → gray → white → dark → dark.
- [ ] Sticky nav with `backdrop-filter: blur`.
- [ ] Pill-shaped buttons (`border-radius: 999px`).

### Dark sections
- [ ] No `var(--text-secondary)` on dark backgrounds.
- [ ] Stats counters: text `rgba(255,255,255,0.5)` on labels.
- [ ] Final CTA: `h2 { color: #fff }`, `p { color: rgba(255,255,255,0.6) }`, microcopy `rgba(255,255,255,0.35)`.

### URL hygiene
- [ ] No `](http` in the file.
- [ ] Font Awesome href verbatim from the pre-compiled block.
- [ ] Calendly `data-url` verbatim from the pre-compiled block (only ACCOUNT/EVENT/primary_color changed).
- [ ] Calendly `<script src>` verbatim.
- [ ] All anchor links resolve to existing section `id`s.

### Icons & illustrations
- [ ] FA icon in logo/nav.
- [ ] FA icons in every feature card, stats row, FAQ chevron, and CTAs.
- [ ] Only `.illustration-placeholder` with FA icons — no external `<img>`, no inline SVG.

### Animations
- [ ] `.reveal` class on target elements + IntersectionObserver in JS.
- [ ] Stagger via `transition-delay` on grid items.
- [ ] `data-target` and `data-suffix` on stat counters, animated by JS.
- [ ] `.floating` on the hero illustration only.
- [ ] `@media (prefers-reduced-motion: reduce)` disables all of the above.

### Calendly
- [ ] `<section id="calendly">` present.
- [ ] All CTAs resolve to `href="#calendly"`.
- [ ] Real widget with adapted colours (if URL provided) OR mock (if not).

### Accessibility & responsive
- [ ] `aria-label` on icon-only buttons.
- [ ] `aria-hidden="true"` on decorative `.illustration-placeholder` divs.
- [ ] Mobile media queries at `max-width: 768px`.
- [ ] `lang` attribute on `<html>` matches the artifact language.
- [ ] No obvious HTML syntax errors.
