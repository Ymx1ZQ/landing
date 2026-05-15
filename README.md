# `landing` — Claude Code skill

Build a landing page in four staged artifacts: **value proposition → long-form copy → HTML → buyer-eyes review**. The first three form the build pipeline; the fourth stress-tests the copy through the Decision Maker's eyes. Each step reads the previous artifact(s), so you can iterate on positioning, copy, visuals, and review — independently.

The copy stage follows April Dunford's *Sales Pitch* framework (*Insight → Alternatives → Perfect World → Introduction → Differentiated Value → Proof → Ask*) with positioning foundations from *Obviously Awesome* layered on top. The VP stage adds Jobs To Be Done (Christensen, 3 levels), an explicit USP Venn subtraction step against named direct competitors, and an enriched ICP (Sponsor ≠ Decision Maker + Top 3 Pains / Gains / Objections).

## Install

### Local (from this repo)

```bash
bash install.sh
```

Use `--force` to overwrite an existing installation without a prompt.

### Remote (no clone)

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/OWNER/landing/main/install.sh)
```

Both modes land at `~/.claude/skills/landing/`. Restart Claude Code to pick up the skill.

## Usage

Run the four subcommands from your project directory. The first three form the build pipeline (run in order); the fourth is a review you can run any time you want a sanity check on the copy:

| Command           | Input (read from CWD)                        | Output (written to CWD) |
|-------------------|----------------------------------------------|-------------------------|
| `/landing vp`     | — (interactive interview)                    | `value-proposition.md`  |
| `/landing copy`   | `value-proposition.md`                       | `copywriting.md`        |
| `/landing html`   | `copywriting.md`                             | `index.html`            |
| `/landing review` | `value-proposition.md` + `copywriting.md`    | `copy-review.md`        |

`/landing` without arguments shows the menu.

### What each subcommand does

- **`/landing vp`** — conducts a positioning interview: Dunford's 5 foundations (competitive alternatives, unique attributes, value, target customer characteristics, market category), Jobs To Be Done (functional + optional emotional/social), USP subtraction against named direct competitors, segments with enriched ICP (Sponsor vs Decision Maker, Top 3 Pains/Gains/Objections), Point of View, and public-voice guardrails (vendors not to mention, trigger event, recurring deliverables per tier, non-fit segments). Writes a structured `value-proposition.md`.
- **`/landing copy`** — reads `value-proposition.md`, walks you through any remaining discovery gaps (alternatives, insight, social proof, offer), then produces `copywriting.md` with named value buckets, 2–3 hero headline variants, primary + secondary CTA, and contextual objection handling.
- **`/landing html`** — asks for setup (conversion mechanism, brand colour, tone, logo, GTM ID), then assembles `index.html` from a pre-built HTML skeleton + section snippets. CSS and JS are inline. Only external dependencies: Font Awesome CDN and (optionally) the embedded conversion widget.
- **`/landing review`** — reads `value-proposition.md` + `copywriting.md`, adopts the Decision Maker of the primary segment as a single lens, and produces `copy-review.md` with three sections: *What smells off* (verbatim quotes + reaction), *Why I'm not buying yet* (3-5 objections, each anchored to a Pain / Gain / known Objection from the VP), *What would convince me* (gap analysis + targeted rewrites for the most toxic lines). If the VP pre-dates the enriched ICP fields, the prompt collects them inline before generating — no need to re-run `/landing vp`.

### Language

- **Chat** replies are always in the user's language.
- **Artifact files** default to English. If you want the output in another language, tell the skill at any point ("rispondi in italiano", "artifact en español") and it will honour it.

## Repo layout

```
skill/                      # copied to ~/.claude/skills/landing/ by install.sh
├── SKILL.md                # router + language rules
├── vp/prompt.md            # positioning architect (Dunford + JTBD + USP Venn + enriched ICP)
├── copy/                   # Dunford copywriter
│   ├── prompt.md
│   ├── questions.md        # discovery questions
│   └── template.md         # output structure
├── html/                   # assembler
│   ├── prompt.md
│   ├── mapping.md          # markdown → snippet mapping
│   ├── rules.md            # output rules + final checklist
│   ├── skeleton.html       # HTML shell (head, CSS, JS)
│   └── snippets/           # 12 section snippets (nav, hero, …)
└── review/                 # buyer-eyes copy review
    └── prompt.md           # Decision Maker lens, three-section critique

install.sh                  # local + remote installer
tests/                      # bash test suite (runs structure, content, install)
DEVPLAN.md                  # planned work, milestone-by-milestone
```

## Tests

```bash
bash tests/test_all.sh    # runs all suites in order
```

Individual suites:

```bash
bash tests/test_structure.sh
bash tests/test_skill.sh
bash tests/test_vp.sh
bash tests/test_copy.sh
bash tests/test_review.sh
bash tests/test_html.sh
bash tests/test_install.sh
```
