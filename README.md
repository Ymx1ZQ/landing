# `landing` — Claude Code skill

Build a landing page in three staged artifacts: **value proposition → long-form copy → HTML**. Each step reads the previous artifact, so you can iterate on positioning, then copy, then visuals — independently.

The copy stage follows April Dunford's *Sales Pitch* framework (*Insight → Alternatives → Perfect World → Introduction → Differentiated Value → Proof → Ask*) with positioning foundations from *Obviously Awesome* layered on top.

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

Run the three subcommands in order, from your project directory:

| Command           | Input (read from CWD)       | Output (written to CWD) |
|-------------------|-----------------------------|-------------------------|
| `/landing vp`     | — (interactive interview)   | `value-proposition.md`  |
| `/landing copy`   | `value-proposition.md`      | `copywriting.md`        |
| `/landing html`   | `copywriting.md`            | `index.html`            |

`/landing` without arguments shows the menu.

### What each subcommand does

- **`/landing vp`** — conducts a short positioning interview: Dunford's 5 foundations (competitive alternatives, unique attributes, value, target customer characteristics, market category), segments, Point of View. Writes a structured `value-proposition.md`.
- **`/landing copy`** — reads `value-proposition.md`, walks you through any remaining discovery gaps (alternatives, insight, social proof, offer), then produces `copywriting.md` with named value buckets, 2–3 hero headline variants, primary + secondary CTA, and contextual objection handling.
- **`/landing html`** — asks for setup (Calendly, brand colour, tone, logo), then assembles `index.html` from a pre-built HTML skeleton + section snippets. CSS and JS are inline. Only external dependencies: Font Awesome CDN and (optionally) the Calendly widget.

### Language

- **Chat** replies are always in the user's language.
- **Artifact files** default to English. If you want the output in another language, tell the skill at any point ("rispondi in italiano", "artifact en español") and it will honour it.

## Repo layout

```
skill/                      # copied to ~/.claude/skills/landing/ by install.sh
├── SKILL.md                # router + language rules
├── vp/prompt.md            # positioning architect
├── copy/                   # Dunford copywriter
│   ├── prompt.md
│   ├── questions.md        # discovery questions
│   └── template.md         # output structure
└── html/                   # assembler
    ├── prompt.md
    ├── mapping.md          # markdown → snippet mapping
    ├── rules.md            # output rules + final checklist
    ├── skeleton.html       # HTML shell (head, CSS, JS)
    └── snippets/           # 12 section snippets (nav, hero, …)

install.sh                  # local + remote installer
tests/                      # bash test suite (runs structure, content, install)
DEVPLAN.md                  # planned work, milestone-by-milestone
```

## Tests

```bash
bash tests/test_structure.sh
bash tests/test_skill.sh
bash tests/test_vp.sh
bash tests/test_copy.sh
bash tests/test_html.sh
bash tests/test_install.sh
```
