# `landing` — Claude Code skill

Build a landing page in four staged artifacts: **value proposition → long-form copy → HTML → buyer-eyes review**. The first three form the build pipeline; the fourth stress-tests the copy through the Decision Maker's eyes. Each step reads the previous artifact(s), so you can iterate on positioning, copy, visuals, and review — independently.

The copy stage follows April Dunford's *Sales Pitch* framework (*Insight → Alternatives → Perfect World → Introduction → Differentiated Value → Proof → Ask*) with positioning foundations from *Obviously Awesome* layered on top. The VP stage adds Jobs To Be Done (Christensen, 3 levels), an explicit USP Venn subtraction step against named direct competitors, and an enriched ICP (Sponsor ≠ Decision Maker + Top 3 Pains / Gains / Objections).

## Install

`skill/` is the whole skill: one flat folder that follows the common `SKILL.md` layout. The installed skill is named `landing` (the `name:` in `skill/SKILL.md`), so copy `skill/` to a folder called `landing` where your assistant reads skills.

```bash
git clone https://github.com/OWNER/landing.git
cp -r landing/skill ~/.claude/skills/landing            # Claude Code
cp -r landing/skill ~/.gemini/skills/landing            # Gemini CLI
cp -r landing/skill ~/.config/opencode/skills/landing   # opencode
```

For Codex, its skill installer takes the GitHub path directly; pin a tag or a commit instead of `main`, because a moving branch changes the instructions the assistant follows:

```
$skill-installer install OWNER/landing/tree/<tag-or-commit>/skill
```

A manual Codex copy goes in `~/.agents/skills/landing`. Keep one active copy per assistant, and restart the assistant to pick up the skill.

**Update.** Save any local edits, then replace the whole installed folder with the new one. `diff -r landing/skill <installed folder>` shows whether a copy has drifted from the source.

**Not provided.** There is no installer script, no remote one-liner and no target wrappers; earlier versions had them.

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
skill/                      # copied to a folder named landing in the assistant's skills directory
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

tests/                      # bash test suite (runs structure and content suites)
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
```
