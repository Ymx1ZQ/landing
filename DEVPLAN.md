# DEVPLAN — `landing` skill

## Goal

Build a single Claude Code skill named `landing` exposing three subcommands (`vp`, `copy`, `html`) via runtime routing. Each subcommand produces a file artifact that feeds the next one, forming a pipeline: `value-proposition.md` → `copywriting.md` → `index.html`.

Ship with a local installer adapted from the existing `devplan` skill installer (same local/remote detection, same `--force` / `--help` flags), so the copy-based approach stays compatible with a future `curl .../install.sh | bash` one-liner.

## Non-goals (v0.1)

- Online raw-install hosting — structure compatible, not implemented.
- Symlink-based install.
- Multi-segment pitches — one pitch per run; user picks the primary segment.
- Copy A/B testing loop (generate, test, iterate) — we emit variants but no loop.
- Translation pipeline — we only declare language rules; user-driven override.

## File layout (final)

```
~/Documents/software/skills/landing/
├── DEVPLAN.md
├── README.md                         # overview + install
├── install.sh                        # local/remote installer (adapted from devplan)
└── skill/                            # lands at ~/.claude/skills/landing/
    ├── SKILL.md                      # entry point: frontmatter, routing, language rules
    ├── vp/
    │   └── prompt.md                 # Value Proposition Architect (positioning + POV)
    ├── copy/
    │   ├── prompt.md                 # Dunford copywriter + buckets + variants
    │   ├── questions.md              # discovery questions (PHASE 1 knowledge)
    │   └── template.md               # landing copy template (PHASE 2 knowledge)
    └── html/
        ├── prompt.md                 # HTML generator (assembly instructions)
        ├── mapping.md                # markdown → section mapping
        ├── rules.md                  # output rules + final checklist
        ├── skeleton.html             # full HTML shell: head, :root vars, CSS base, JS base
        └── snippets/
            ├── nav.html
            ├── hero.html
            ├── problem.html
            ├── features.html
            ├── stats.html
            ├── testimonial.html
            ├── integration.html
            ├── faq.html
            ├── calendly-real.html
            ├── calendly-mock.html
            ├── final-cta.html
            └── footer.html
```

Naming rationale:
- `prompt.md` per subcommand = the instructions Claude reads after routing.
- Knowledge files keep short domain names (`questions.md`, `template.md`, `mapping.md`, `rules.md`).
- `skeleton.html` + `snippets/` isolate reusable HTML so Claude assembles instead of reinventing CSS/JS.

## Artifact pipeline

All artifacts land in the user's current working directory (CWD) with fixed filenames:

| Subcommand | Reads | Writes |
|---|---|---|
| `/landing vp` | user interview | `value-proposition.md` |
| `/landing copy` | `value-proposition.md` (CWD) | `copywriting.md` |
| `/landing html` | `copywriting.md` (CWD) + setup answers | `index.html` |

If the expected input file is missing in CWD, the subcommand:
1. Tells the user it needs `<filename>`.
2. Offers two paths: (a) run the previous subcommand first, or (b) paste/point to the input inline.
3. Does not silently invent content.

## Runtime behavior

`SKILL.md` frontmatter declares name + description (trigger). Body contains:

1. **Language rules** (global):
   - Chat: always reply in the user's language.
   - Artifacts: English by default. Ask once per session *"Artifact language? (default: English)"* unless the user has already specified. User can override any time mid-session.

2. **Routing table** — reads the argument after `/landing`:
   - `vp` → read `vp/prompt.md`.
   - `copy` → read `copy/prompt.md`, `copy/questions.md`, `copy/template.md`.
   - `html` → read `html/prompt.md`, `html/mapping.md`, `html/rules.md`, `html/skeleton.html`, and the relevant `html/snippets/*.html` lazily as needed per section.
   - no arg / unknown arg → show a 3-line menu (one per subcommand) and ask which one.

3. **Subcommand isolation** — each branch reads only its own folder.

## Framework improvements vs. raw Dunford prompts

The original prompts were ported from earlier gems. These improvements, based on Dunford's positioning work plus conversion-copy hygiene, are folded into the ports:

### vp/prompt.md — new elements
- **Positioning foundations section** (from Dunford's "Obviously Awesome"): competitive alternatives, unique attributes, value, target customer characteristics, market category. Produced *before* the one-line VP.
- **Segments discovery**: explicit question "are there multiple segments?" — if yes, pick the primary; other segments are noted for future runs.
- **Point of View (POV)**: industry-level thesis, not just a tactical insight. Dedicated section in the output.
- Output template updated to include: Positioning, POV, Segment, then existing VP + Problem/Solution/Benefits/Users/MVP/Constraints.

### copy/prompt.md — new elements
- **Value buckets must be named** (not just 3 loose features): each of the 3 Pillars gets a theme name + 1-3 features grouped under it.
- **Specificity push**: prompt forces numeric/concrete claims where plausible ("Save 4 hours/week" not "Save time"). If no numbers exist, use concrete scenarios instead of vague benefits.
- **Headline variants**: output 2-3 hero headline options with a short rationale for each (A/B test-ready).
- **Contextual objection handling**: objections are surfaced near the relevant CTA/pricing/feature, not only in a bottom-page FAQ block.
- **CTA hierarchy**: primary + secondary CTA on the hero (e.g., "Book demo" + "See how it works"). FINAL CTA stays single.
- Language rule pointer: removes hardcoded `Respond in English` — delegated to `SKILL.md`.

### html/prompt.md — new elements
- **Assembly model, not free generation**: instructions explicitly tell Claude to load `skeleton.html`, then the matching `snippets/*.html` for each section present in `copywriting.md`, then fill placeholders with copy.
- **Meta/SEO block**: `<title>`, `<meta description>`, `<meta property="og:title">`, `<meta property="og:description">`, `<meta property="og:type" content="website">` in the skeleton — always populated from the copy.
- **Accessibility checklist** promoted to output rules: alt text on icon-placeholders, aria-label on CTAs, color contrast check for dark sections.
- FASE 0 setup questions (Calendly, primary color, CTA text, tone, theme) preserved — they fire first regardless of chat language.

## Milestones

### M1 — Scaffold directory structure ✅
- [x] Create `skill/` with subfolders `vp/`, `copy/`, `html/`, `html/snippets/`.
- [x] Create empty placeholder files per the layout.
- [x] Verify tree matches.

Note: no git remote configured — commits stay local. Push steps will be skipped; user can add a remote later.

### M2 — `SKILL.md` (routing + language rules) ✅
- [x] Frontmatter: `name: landing`, `description: <trigger covering vp/copy/html pipeline>`.
- [x] Language rules block.
- [x] Routing table with 3 branches + menu fallback.
- [x] Note on artifact pipeline (input filename expected in CWD per step).
- [x] Keep short — heavy content lives in subcommand prompts.

### M3 — `vp/prompt.md` ✅
- [x] Port the inline "Value Proposition Architect" prompt as the base.
- [x] Add **Positioning Foundations** interview block (5 fields).
- [x] Add **Segments** discovery (multi-segment → pick primary).
- [x] Add **Point of View** block.
- [x] Rewrite the output template to include: Positioning, POV, Segment(s), VP, Problem, Solution, Benefits, Target Users, MVP Scope, Constraints.
- [x] Enforce filename: output must be `value-proposition.md` in CWD.
- [x] Remove hardcoded Italian chat references → point to SKILL.md.
- [x] Remove external pipeline references (standalone skill).

### M4 — `copy/` (Dunford landing copy) ✅
- [x] `prompt.md`: port `landing-bot/system_prompt.md` — Dunford narrative (Insight → Alternatives → Perfect World → Introduction → Differentiated Value → Proof → Ask), PHASE 1/2 process.
- [x] `prompt.md`: add **named value buckets** rule (3 themed pillars, 1-3 features each).
- [x] `prompt.md`: add **specificity** rule (numeric claims when plausible).
- [x] `prompt.md`: add **headline variants** requirement (2-3 options + rationale).
- [x] `prompt.md`: add **contextual objections** + **CTA hierarchy** rules.
- [x] `prompt.md`: declare input = `value-proposition.md` in CWD; output = `copywriting.md` in CWD.
- [x] `prompt.md`: delegate language to SKILL.md.
- [x] `questions.md`: port `landing-bot/questions.md` (5 discovery questions) + add segment-confirmation question.
- [x] `template.md`: port `landing-bot/template.md` (HERO → SETUP → SHIFT → SOLUTION → VALUE PROPOSITION → SOCIAL PROOF → FAQ → FINAL CTA); update pillars to named buckets; add headline-variants block; add secondary CTA slot on hero.

### M5 — `html/` (assembly-based HTML generator) ✅
- [x] `prompt.md`: rewrite as assembly instructions — load `skeleton.html`, select matching `snippets/*.html`, fill placeholders from `copywriting.md`.
- [x] `prompt.md`: declare input = `copywriting.md` in CWD + FASE 0 setup answers; output = `index.html` in CWD.
- [x] `prompt.md`: preserve FASE 0 setup questions (Calendly, primary color, CTA text, tone, existing site/logo — 5 original questions).
- [x] `mapping.md`: port `landing-html-gen/mapping-markdown-to-sections.md` — update to reference snippets explicitly.
- [x] `rules.md`: port `landing-html-gen/output-rules.md` — add SEO/meta checklist, accessibility checklist.
- [x] `skeleton.html`: write the full HTML shell — `<head>` with meta/SEO placeholders, `<style>` with `:root` variables, base typography, section alternation CSS, `.illustration-placeholder` CSS, dark-section rules, `<script>` with smooth scroll, counter animation, reveal on scroll, nav-scroll class toggle.
- [x] `snippets/*.html`: write one file per section with `{{PLACEHOLDER}}` markers for copy. Each snippet is self-contained (no cross-references).

### M6 — `install.sh` + `README.md` ✅
- [x] Adapt `devplan/install.sh` to a single-target install: source `skill/` → dest `~/.claude/skills/landing/`.
- [x] Keep local/remote detection, `--force`, `--help`.
- [x] Print post-install summary with the three `/landing <cmd>` invocations and the pipeline order.
- [x] `README.md`: overview, install command, pipeline explanation (`vp → copy → html`), language rule summary.

### M7 — Smoke test ✅ (automated portion)
- [x] `bash install.sh --force` → `~/.claude/skills/landing/` populated with SKILL.md + all subcommand files + 12 snippets (verified).
- [x] `tests/test_all.sh` → all 6 suites green (26+19+24+39+58+37 = 203 assertions).
- [ ] **Manual smoke (user-side)**: fresh Claude Code session in a test CWD — run `/landing vp`, then `/landing copy`, then `/landing html`; open `index.html` in a browser; also run `/landing copy` in an empty dir to confirm graceful missing-input handling. The automated suite cannot exercise these paths.

## Out of scope for future versions

- Online one-liner install (requires hosted repo — infra, not code).
- Multi-segment pitch bundle (one run → N segment-specific pitches).
- Copy A/B loop (generate → user-picks → iterate).
- Automated artifact translation.
- Versioning / update detection in installer.
- Brand asset ingestion (logo extraction, palette auto-detect from URL).

---

# v0.2 milestones (append)

### M8 — GTM placeholder + user-provided conversion embed with framing-aware copy ✅

**Why**: v0.1 hard-wires the conversion section to Calendly (real or mock). Real landings use varied mechanisms — booking tools, contact forms, HubSpot embeds, Typeform, Tally. Also, every production landing needs Google Tag Manager. Both additions need to plug in without adding complexity.

**Approach**: one configurable slot — the user pastes a URL or an HTML snippet, the skill renders it. Copy framing is decided upstream in `/landing copy` (binary: *booking* vs *contact*) so the hero/final/conversion section speaks the right language.

**GTM**: standard two-snippet pattern with one `{{GTM_ID}}`. Both blocks omitted entirely if no ID is provided — never render a mock / fake GTM.

**Tasks**

- [ ] **copy/prompt.md** — add a PHASE 1 question: "Is the primary conversion a *scheduled call* (Calendly / SavvyCal / Cal.com / similar) or a *contact form* (Formspree / HubSpot / Typeform / Tally / custom backend)?". Binary answer drives copy choices throughout the artifact:
  - Booking → "Book a demo", "Pick a time that works", "See the product live"
  - Contact → "Get in touch", "We'll reply within 24h", "Tell us about your use case"
- [ ] **copy/questions.md** — add Q7 "Conversion mechanism" with the same binary + suggestion format.
- [ ] **copy/template.md** — hero Primary CTA / FINAL CTA button now carries a `<!-- framing: booking | contact -->` hint and guidance copy that reflects the mechanism. Keep it a single slot — don't duplicate the section.
- [ ] **html/prompt.md** — rewrite FASE 0 question #1 from "do you have a Calendly?" to:
  > **Conversion embed**: paste the URL or HTML for your conversion widget.
  > Examples: `https://calendly.com/you/demo`, a Formspree `<form>` snippet, a Typeform/Tally `<iframe>`, or leave empty for a visual mock.
- [ ] **html/prompt.md** — add FASE 0 question for **GTM ID** (`GTM-XXXXXXX`, optional).
- [ ] **html/prompt.md** — add detection logic:
  - Input matches `^https://(calendly|savvycal|cal)\.com/` → wrap in the Calendly-style widget snippet (generic booking widget), substitute color.
  - Input contains `<` (form/iframe/embed HTML) → paste verbatim inside the wrapper (never reformat).
  - Empty → use mock.
- [ ] **html/snippets/conversion.html** — NEW. Single flexible snippet replacing `calendly-real.html` + `calendly-mock.html`. Placeholders:
  - `{{CONVERSION_TITLE}}`, `{{CONVERSION_LEAD}}` (copy, framing-aware)
  - `{{CONVERSION_EMBED}}` (the pasted widget / iframe / form, or the mock block)
  - Section id stays `calendly` for backward compatibility of existing `#calendly` anchors — or rename anchors to `contact` / `book`? **Decision**: rename to `id="convert"` and update all snippet anchors (`nav.html`, `hero.html`, `final-cta.html`) to point to `#convert`. `#calendly` as an id is now semantically wrong.
- [ ] **html/snippets/** — delete `calendly-real.html` and `calendly-mock.html` (subsumed by `conversion.html`).
- [ ] **html/skeleton.html** — add GTM placeholders:
  - In `<head>`, right after `<title>` block: the GTM `<script>` loader wrapped in `{{#GTM_HEAD}} ... {{/GTM_HEAD}}` markers (remove block entirely if no ID).
  - Right after `<body>`: the `<noscript><iframe ...>` GTM fallback wrapped in `{{#GTM_BODY}} ... {{/GTM_BODY}}` markers.
- [ ] **html/mapping.md** — replace `calendly-real | calendly-mock` rows with single `conversion.html` row; document framing-aware copy; document GTM conditional.
- [ ] **html/rules.md** — add the GTM pre-compiled verbatim blocks (head + body) with `{{GTM_ID}}`; add URL-hygiene check for the GTM iframe src; update the final checklist.
- [ ] **tests/test_html.sh** — update snippet enumeration (drop calendly-real/mock, add conversion.html). Add checks: skeleton contains GTM marker patterns; snippets use `#convert` anchor; conversion.html has `{{CONVERSION_EMBED}}`.
- [ ] **tests/test_copy.sh** — add contract: prompt + questions cover the booking-vs-contact binary; template carries the framing hint.
- [ ] **Smoke** — re-run `bash tests/test_all.sh`; run a real install; spot-check an `index.html` with a Calendly URL, a form HTML, and empty (mock), with and without a GTM ID.
