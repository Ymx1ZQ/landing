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

**Deviations:** No git remote was configured at the time; commits stayed local and push steps were skipped.

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

### M9 — Sync source `vp/prompt.md` from installed orphan edits

**Why**: The installed copy at `~/.claude/skills/landing/vp/prompt.md` contains additions not present in the source tree — a "Public-voice guardrails" section in the interview (vendors NOT to mention, trigger event, recurring deliverables per tier, non-fit segments) and a matching "Public-Voice Guardrails" section in the output template. Those edits were made directly on the installed copy in a previous session (violating the "edit source, never installed" rule). They are well-formed, additive, and have already been used in production on the the pilot client value proposition — losing them via `./install.sh --force` would be a regression. The remaining M10-M13 milestones each end with `./install.sh --force`, so the source must be brought in line first.

**Approach**: Patch `skill/vp/prompt.md` to include exactly the orphan additions currently present in `~/.claude/skills/landing/vp/prompt.md` — same placement (Step 1 section F, output template after Constraints), same wording. After the patch, `diff source installed` must be empty. No other changes to the source. Extend `tests/test_vp.sh` with assertions for the new patterns so the regression is locked in going forward.

**Tasks**:
- [x] Add assertions in `tests/test_vp.sh` for the orphan patterns (`Public-voice guardrails`, `Vendors`, `Trigger event`, `Recurring deliverables`, `Non-fit segments`). Run and confirm RED.
- [x] Edit `skill/vp/prompt.md`: append section F "Public-voice guardrails" to Step 1 (after section E) — verbatim from installed copy.
- [x] Edit `skill/vp/prompt.md`: append the `Public-Voice Guardrails` section to the output template (after `## Constraints`) — verbatim from installed copy.
- [x] Run `bash tests/test_all.sh` and confirm green.
- [x] Run `diff ~/Documents/software/skills/landing/skill/vp/prompt.md ~/.claude/skills/landing/vp/prompt.md` — must be empty.
- [x] Run `./install.sh --force` to redeploy (idempotent at this point).
- [x] Commit: `M9: sync vp/prompt.md source from installed orphan edits ✅`.

**Done when**: `bash tests/test_all.sh` green; `diff source installed` is empty; subsequent milestones can safely run `./install.sh --force` without losing content.

**Notes**: This milestone exists only to repair a one-time drift; future development must go through source per CLAUDE.md skill-editing rules.

---

### M10 — JTBD 3-level in `vp/prompt.md` (Camcom W1 integration)

**Why**: The current `Problem` field captures the pain generically. Workshop 1 (Camcom) frames the customer pull as a Job To Be Done at three levels — Functional (the physical task), Emotional (how they want to feel), Social (how they want to be seen). The highest-level job is where the strongest pull sits and where the sharpest copy hooks live. The VP today does not surface emotional/social jobs explicitly, so they get reinvented (or lost) downstream in `/landing copy`.

**Approach**: Add a new interview block "Jobs to Be Done" inside Step 1 of `vp/prompt.md`, between "B. Positioning foundations" and "C. Segments". Three sub-fields: functional (required), emotional (optional, propose a default; user may skip), social (optional, same). Extend the output template with a `## Jobs to Be Done` section listing the three levels (omit lines whose value is empty — keeps the artifact tight when only functional is filled). Internal-check addition: in the VP one-liner generation step, instruct the AI to silently evaluate its own draft against three angles (outcome-led / mechanism-led / alternative-led) and pick the strongest — internal critique, no extra artifact for the user.

**Tasks**:
- [x] Edit `skill/vp/prompt.md`: add JTBD interview block (functional required + emotional/social optional, follow propose-default discipline already in the prompt).
- [x] Edit `skill/vp/prompt.md`: extend the output template with a `## Jobs to Be Done` section (3 sub-lines, omit empty ones).
- [x] Edit `skill/vp/prompt.md`: in the VP one-liner generation step, add the internal three-angle self-critique instruction (outcome-led / mechanism-led / alternative-led; pick strongest; no extra output).
- [x] Add assertions in `tests/test_vp.sh` for the new patterns (`Jobs to Be Done`, `functional`, `emotional`, `social`, three-angle wording).
- [x] Run `bash tests/test_all.sh` and confirm green.
- [x] Run `./install.sh --force` to redeploy.
- [x] Commit: `M10: JTBD 3-level in vp/prompt.md ✅`.

**Done when**: `bash tests/test_all.sh` green; the new JTBD section is present both in the interview block and the output template of `skill/vp/prompt.md`; `~/.claude/skills/landing/vp/prompt.md` reflects the source.

---

### M11 — USP Venn subtraction step in Positioning

**Why**: The current `vp/prompt.md` collects "Competitive alternatives" and "Unique attributes" but never forces the explicit subtraction `(A ∩ B) \ C` — i.e. "what customers want AND we do well AND competitors do not already do". Without that subtraction, the Unique-attributes list often contains commodity capabilities that competitors can match. The Venn check sharpens data we already collect, without introducing a parallel framework.

**Approach**: Do NOT add a separate `## USP` output section — it would duplicate `## Value delivered` and bloat the artifact. Instead, extend the existing Positioning interview with a **subtraction step** placed right after Unique attributes: ask the user to name 2-3 *direct competitors* by name for the chosen segment, then for each unique attribute force a binary "can the named competitor honestly claim the same?". Attributes that survive go into Value delivered as before; commodity attributes are dropped or rewritten. Add a single new field `USP statement` at the end of the Positioning output template — one sentence: "what customers want, that we deliver, that no named competitor delivers". This is the codified output of the subtraction.

**Tasks**:
- [x] Edit `skill/vp/prompt.md`: in the Positioning interview, add the subtraction step after Unique attributes (name 2-3 direct competitors; binary check per attribute; drop commodity).
- [x] Edit `skill/vp/prompt.md`: extend the Positioning output template with a `USP statement` line (single sentence) placed after `Value delivered`.
- [x] Edit `skill/vp/prompt.md`: clarify in the interview that "Competitive alternatives" are status-quo workarounds (often not direct competitors), while the subtraction step uses direct competitors — the two lists can differ.
- [x] Add assertions in `tests/test_vp.sh` for the new patterns (`USP statement`, `direct competitor`, subtraction wording).
- [x] Run `bash tests/test_all.sh` and confirm green.
- [x] Run `./install.sh --force` to redeploy.
- [x] Commit: `M11: USP Venn subtraction in vp/prompt.md ✅`.

**Done when**: tests green; the subtraction step is documented in the Positioning interview; the output template has a `USP statement` line after `Value delivered`.

---

### M12 — Enriched ICP in Primary Segment (Sponsor ≠ DM, Pains, Gains, Objections)

**Why**: The current "Primary Segment" captures who + why-first + other-segments-noted. It does not separate the **Sponsor** (the person who feels the pain daily) from the **Decision Maker** (who signs), nor does it capture explicit Pain/Gain/Objections — fields the downstream `/landing review` (M13) needs to anchor its critique to specific buyer concerns. The the pilot client session showed concretely that Sponsor (responsabile amministrativo / CFO) and DM (imprenditore) are often distinct in PMI; the copy needs to address both voices.

**Approach**: Inside the existing "C. Segments" interview block of `vp/prompt.md`, after the primary-segment pick, add five additional sub-fields scoped to the primary segment only: Sponsor (role + daily pain context), Decision Maker (role + signature authority), Top 3 Pains (specific, quantified when possible), Top 3 Gains (desired outcomes), Top 3 known Objections (verbatim phrases the buyer says to push back). Extend the output template's `## Primary Segment` section accordingly. Do NOT add "Channel" (marketing scope, out of positioning).

**Tasks**:
- [x] Edit `skill/vp/prompt.md`: extend Segments interview with Sponsor / Decision Maker / Top 3 Pains / Top 3 Gains / Top 3 Objections (each with example phrasings and propose-default discipline).
- [x] Edit `skill/vp/prompt.md`: extend the output template's `## Primary Segment` section with the five new sub-fields.
- [x] Add assertions in `tests/test_vp.sh` for the new patterns (`Sponsor`, `Decision Maker`, `Top 3 Pains`, `Top 3 Gains`, `Objections`).
- [x] Run `bash tests/test_all.sh` and confirm green.
- [x] Run `./install.sh --force` to redeploy.
- [x] Commit: `M12: enriched ICP (Sponsor/DM + Pains/Gains/Objections) ✅`.

**Done when**: tests green; the five new fields are documented in both the interview block and the output template; the deployed skill reflects the change.

---

### M13 — `/landing review` subcommand (4th stage of the pipeline)

**Why**: Once copy is generated by `/landing copy`, the user has no structured way to stress-test it through the eyes of the actual buyer. A free-form "review it for me" call relies on whatever lens the AI improvises. A dedicated subcommand that loads the enriched ICP from `value-proposition.md` and reads `copywriting.md` in role can deliver a sharper, repeatable critique — and surface specific objections the copy fails to address, anchored to concrete Pains/Gains/Objections from M12. Single lens = the Decision Maker of the primary segment, coherent with the skill's "one pitch = one segment" principle.

**Approach**: Add a new subcommand `/landing review`. Folder layout: `skill/review/prompt.md` (single self-contained file, sibling-folder isolation per current skill convention). Reads `value-proposition.md` + `copywriting.md` from CWD. Writes `copy-review.md` to CWD with three sections: **What smells off** (verbatim copy quotes + buyer's reaction), **Why I'm not buying yet** (3-5 explicit objections), **What would convince me** (gap analysis + 2-3 targeted rewrite candidates for the most toxic lines). Every objection raised must be anchored to a specific Pain / Gain / known Objection from the VP — if it cannot be anchored, drop or sharpen. Tone: severe and lucid, not constructive-at-all-costs; if the copy holds, say so. Graceful inline ICP-collection: if `value-proposition.md` lacks the M12 fields (Sponsor / Pains / Gains / Objections), the prompt collects them inline in a short interview before generating — does NOT ask the user to re-run `/landing vp`. Update `skill/SKILL.md` router to add the fourth pipeline row, the fourth dispatch line, and the fourth menu entry.

**Tasks**:
- [x] Create `skill/review/` folder.
- [x] Write `skill/review/prompt.md`: load instructions (read `value-proposition.md` + `copywriting.md` from CWD); graceful inline ICP-collection when VP pre-M12; three-section output spec (What smells off / Why I'm not buying yet / What would convince me + rewrites); single-lens enforcement (DM only); objection-anchoring rule (each objection links to a Pain / Gain / known Objection from VP, otherwise drop); output filename `copy-review.md` in CWD; language follows SKILL.md.
- [x] Edit `skill/SKILL.md`: add `/landing review` row to the pipeline table (Reads: `value-proposition.md` + `copywriting.md`; Writes: `copy-review.md`); add `review` to the routing dispatch list; extend the 3-line menu to 4 lines.
- [x] Create `tests/test_review.sh`: structural assertions on `skill/review/prompt.md` (filename declared; three sections referenced; single-lens enforced; objection-anchoring rule present; graceful inline-collection for missing ICP present). Mirror the `assert_grep` style of `tests/test_vp.sh`.
- [x] Edit `tests/test_all.sh`: add `run test_review.sh` after `run test_copy.sh`.
- [x] Edit `tests/test_skill.sh`: add assertions for the 4th routing line and the 4-entry menu.
- [x] Edit `tests/test_install.sh`: add a check that `~/.claude/skills/landing/review/prompt.md` is present after install.
- [x] Run `bash tests/test_all.sh` and confirm green.
- [x] Run `./install.sh --force` to redeploy.
- [x] Commit: `M13: /landing review subcommand ✅`.

**Done when**: `bash tests/test_all.sh` green (now 7 suites including `test_review.sh`); `~/.claude/skills/landing/review/prompt.md` deployed; the installed `SKILL.md` lists 4 subcommands in the pipeline table and the menu.

**Notes**:
- Downstream `copy/prompt.md` is intentionally not updated in this plan to consume the enriched ICP — separate future work. Existing `value-proposition.md` files (pre-M12) remain valid input for `/landing copy` (graceful absence of new fields).
- The review critiques `copywriting.md` only; reviewing `index.html` is out of scope (HTML is a rendering of the same copy — critique the source, not the rendering).
- The `value-proposition.md` already generated for the pilot client (under `<client-site-dir>/`) is pre-M12 — after this plan ships it can either be retrofitted by hand or regenerated via `/landing vp`. Not blocking; out of scope of these milestones.

### M14 — Footer URLs / Conversion fallback / `href="#"` guard

**Why**: A UX review of the first landing produced by `/landing html` (the pilot client) flagged a class of preventable errors that the skill should catch upstream:
1. `footer.html` ships with `href="#"` on Privacy / Terms / Contact — clicking them scrolls to top, which is embarrassing on a landing that talks GDPR.
2. The Calendly embed has no textual fallback if blocked by ad-blocker / corporate firewall / JS off — the visitor sees empty space.
3. The contact email is hard-coded as an `<a href="#">` placeholder in some snippet variants.
These are fixable in the skill source so every future landing starts safe.

**Approach**: Extend FASE 0 in `html/prompt.md` with three new questions (privacy URL, terms URL, contact email). Modify `footer.html` to use `{{PRIVACY_URL}}` / `{{TERMS_URL}}` / `{{CONTACT_EMAIL}}` placeholders. Modify `conversion.html` to append a textual fallback row using `{{CONTACT_EMAIL}}`. When a URL is empty the link renders disabled-styled ("Privacy (in arrivo)") with `aria-disabled="true"`; when contact email is empty, fall back to a TODO comment. Add a strict rule in `rules.md`: no `href="#"` in the output unless paired with `data-todo`.

**Tasks**:
- [x] Edit `skill/html/prompt.md` FASE 0: add Q7 (privacy URL), Q8 (terms URL), Q9 (contact email).
- [x] Edit `skill/html/snippets/footer.html`: replace the 3 hardcoded `href="#"` with `{{PRIVACY_URL}}` / `{{TERMS_URL}}` / `{{CONTACT_EMAIL}}` placeholders; the contact link uses `mailto:`.
- [x] Edit `skill/html/snippets/conversion.html`: append `<div class="calendly-fallback">Non vedi il calendario? Scrivici a {{CONTACT_EMAIL}}</div>` after the embed.
- [x] Edit `skill/html/skeleton.html`: add CSS class `.calendly-fallback` (centered, secondary color) and `.disabled-link` styling for empty Privacy/Terms.
- [x] Edit `skill/html/rules.md`: add hard rule "no `href=\"#\"` in output unless paired with `data-todo`; empty Privacy/Terms render as `aria-disabled` placeholder, never as live `#` links".
- [x] Edit `tests/test_html.sh` (snippets pass): assert footer.html and conversion.html contain the new placeholders.
- [x] Edit `tests/test_install.sh`: no new files, just verify install still passes.
- [x] Run `bash tests/test_all.sh` and confirm green.
- [x] Run `./install.sh --force`.
- [x] Commit: `M14: footer URLs + conversion fallback + href guard ✅`.

**Done when**: `bash tests/test_all.sh` green; future `/landing html` runs ask the user for privacy/terms/contact email in FASE 0 and emit safe placeholders if not provided.

---

### M15 — Cookie consent banner snippet + FASE 0 question

**Why**: Same UX review: the the pilot client landing was missing a cookie consent banner despite embedding Calendly (third-party cookies). A landing that sells GDPR cannot itself be GDPR-naive. The skill should default to including a minimal, honest banner when a third-party embed is detected.

**Approach**: New snippet `cookie-banner.html` — a bottom-fixed minimal banner with two buttons ("Solo essenziali" / "Accetta tutti"), localStorage-backed consent memory, exposed `loadThirdPartyEmbeds()` JS hook the conversion embed can call. CSS + the JS consent controller go in `skeleton.html` (global). FASE 0 asks whether to include the banner; default is ON when the conversion input is a third-party booking URL or embed snippet. Disclaimer in the prompt: this banner is "not-completely-out-of-law" baseline, not iubenda/cookiebot enterprise-grade.

**Tasks**:
- [x] Create `skill/html/snippets/cookie-banner.html` with the markup (rejected/accept buttons, role=dialog).
- [x] Edit `skill/html/skeleton.html`: add `.cookie-banner` CSS classes; add the consent controller JS at the end of the existing `<script>` block (localStorage key + `loadThirdPartyEmbeds()` hook).
- [x] Edit `skill/html/snippets/conversion.html`: when the embed is third-party (Calendly etc.), render the `data-url` inside a `<div id="calendly-slot">` placeholder + a visible "Calendly placeholder" block; load the actual widget only after consent via the hook.
- [x] Edit `skill/html/prompt.md` FASE 0: add Q10 (cookie banner: yes/no, default yes if third-party embed).
- [x] Edit `skill/html/mapping.md`: add `cookie-banner` to the always-included list when Q10=yes; include after `<body>` open.
- [x] Edit `skill/html/rules.md`: add rule "if conversion embed is third-party (Calendly/SavvyCal/Cal.com/HubSpot/Tally/Typeform) and cookie banner is OFF, emit `<!-- WARN: third-party embed without cookie banner -->`".
- [x] Edit `tests/test_structure.sh`: add `assert_file "$SKILL/html/snippets/cookie-banner.html"`.
- [x] Edit `tests/test_install.sh`: add `assert_file "$TARGET/html/snippets/cookie-banner.html"`.
- [x] Edit `tests/test_html.sh`: assert skeleton contains cookie banner CSS class names and consent controller; assert cookie-banner snippet has both action buttons.
- [x] Run `bash tests/test_all.sh` and confirm green.
- [x] Run `./install.sh --force`.
- [x] Commit: `M15: cookie consent banner snippet + third-party guard ✅`.

**Done when**: `bash tests/test_all.sh` green; the skill emits a cookie banner by default when a third-party booking embed is present, and Calendly loads only after consent.

---

### M16 — Open Graph image + Twitter card + canonical URL

**Why**: The first the pilot client landing shipped without `og:image`, `og:url`, or any `twitter:card` tags. Sharing the link on LinkedIn/Discord/Slack/WhatsApp produces a barebones preview without an image — particularly bad when the whole product story is "we live inside the chats". The skill should require an OG image and canonical URL in FASE 0.

**Approach**: Extend skeleton `<head>` with `{{OG_IMAGE}}`, `{{OG_URL}}`, `{{TWITTER_CARD}}`, `{{TWITTER_IMAGE}}` placeholders. FASE 0 asks for the canonical URL of the landing and the OG image path. If no OG image is given, fallback to the wide brand logo (when available) and emit a `<!-- TODO: og:image dovrebbe essere 1200x630 -->` warning comment in the HTML.

**Tasks**:
- [ ] Edit `skill/html/skeleton.html` `<head>`: add `<meta property="og:image">`, `<meta property="og:url">`, `<meta name="twitter:card" content="summary_large_image">`, `<meta name="twitter:image">`, `<meta name="twitter:title">`, `<meta name="twitter:description">` with their placeholders.
- [x] Edit `skill/html/prompt.md` FASE 0: add Q11 (canonical URL) and Q12 (OG image path; default fallback to brand logo).
- [x] Edit `skill/html/rules.md`: SEO/meta section — list og:image, og:url, twitter:card as mandatory; document fallback behavior.
- [x] Edit `tests/test_html.sh`: assert skeleton contains `og:image`, `og:url`, `twitter:card` placeholder names.
- [x] Run `bash tests/test_all.sh` and confirm green.
- [x] Run `./install.sh --force`.
- [x] Commit: `M16: OG image + twitter card + canonical URL in skeleton ✅`.

**Done when**: `bash tests/test_all.sh` green; the skeleton always emits a full set of social meta tags, and link previews on social platforms show an image.

---

### M17 — Copy quality rules: verbosity limits + CTA differentiation

**Why**: The the pilot client copy needed a second-review pass to cut wall-of-text and one round of patching to differentiate the final CTA wording from the primary CTA. Both classes of error can be prevented at copy generation time.

**Approach**: Add hard character-budget guidance in `copy/prompt.md`: hero subheadline ≤ 280 chars, feature card body ≤ 360 chars, FAQ answer ≤ 700 chars, body paragraphs in narrative sections ≤ 600 chars each. Add a "CTA differentiation" rule: when FINAL CTA and a conversion embed both appear on the page, FINAL CTA button text must differ from the hero primary CTA (avoid back-to-back "Book a demo" / "Book a demo"). Both rules are guidance for the generator, enforced as a self-check before writing `copywriting.md`.

**Tasks**:
- [x] Edit `skill/copy/prompt.md`: add a new section "Length budgets (self-check before writing)" listing the character limits per field.
- [x] Edit `skill/copy/prompt.md`: add a new rule "CTA differentiation: FINAL CTA button text MUST differ visually from the hero primary CTA" with examples.
- [x] Edit `skill/copy/template.md`: add an inline comment near FINAL CTA reminding the writer that the button wording must differ from the hero primary.
- [x] Edit `tests/test_copy.sh`: assert the new rules are present (grep for "Length budgets", "CTA differentiation").
- [x] Run `bash tests/test_all.sh` and confirm green.
- [x] Run `./install.sh --force`.
- [x] Commit: `M17: copy length budgets + CTA differentiation rule ✅`.

**Done when**: `bash tests/test_all.sh` green; future `/landing copy` runs produce copy that respects the budgets and differentiates the final CTA from the hero primary.

---

### M18 — Devplan hygiene pass (forge-flow Comments + Milestone state markers compliance) ✅

**Why**: forge-flow's Comments directive keeps prose off closed task boxes; the Milestone state markers directive keeps `🔄`/`- [~]` for active work only. M1 carried a stray note outside any Deviations block.

**Approach**: Grep all source files for comment-hygiene violations (incident narrative, markdown/emoji in inline comments, restated test assertions) — repo came back clean. Audit DEVPLAN.md for dangling markers, stray prose under checked tasks, oversized Notes/Deviations, and size-budget overruns; move the one stray M1 note into a bounded Deviations block.

**Tasks**:
- [x] Grep `.sh`/`.py`/`.ts`/`.js` etc. for comment-hygiene violations — none found.
- [x] Move M1's stray prose note into a `**Deviations:**` block.

**Done when**: no prose sits outside a Deviations/Notes block under a completed task list, and no dangling `🔄`/`- [~]` markers remain.
