---
name: landing
description: Build a landing page in three staged artifacts — value proposition, long-form copy (April Dunford's Sales Pitch framework), and a standalone Apple-inspired HTML file. Use `/landing vp` to discover positioning and produce `value-proposition.md`, `/landing copy` to turn it into `copywriting.md`, and `/landing html` to assemble `index.html`. Each step reads the previous artifact from the current working directory.
---

# Landing — Router

This skill builds a landing page in three stages. Each stage produces a file that feeds the next.

## Artifact pipeline

All artifacts land in the user's **current working directory** (CWD) with fixed filenames:

| Command | Reads (CWD) | Writes (CWD) |
|---|---|---|
| `/landing vp`   | user interview                               | `value-proposition.md` |
| `/landing copy` | `value-proposition.md`                       | `copywriting.md` |
| `/landing html` | `copywriting.md` + setup answers             | `index.html` |

If the required input file is missing from CWD, stop and offer the user two paths: (a) run the previous subcommand first, or (b) paste the content inline. Never invent input silently.

## Language rules (apply to every subcommand)

- **Chat**: reply in the user's language — always.
- **Artifact (the generated file)**: English by default. At the start of a session, if the user has not specified a language yet, ask once: *"Artifact language? (default: English)"*. If the user has already indicated a language (e.g., "rispondi in italiano", "artifact in spagnolo"), honor it without asking.
- The user can change artifact language any time during the session; honor the latest instruction.

## Routing

Parse the first argument after `/landing`:

- `vp` → read `vp/prompt.md` and follow it end-to-end.
- `copy` → read `copy/prompt.md`, `copy/questions.md`, `copy/template.md` and follow them end-to-end.
- `html` → read `html/prompt.md`, `html/mapping.md`, `html/rules.md`, `html/skeleton.html`, and the relevant files under `html/snippets/` (lazy-load: only the snippets matching sections present in `copywriting.md`). Follow `prompt.md` end-to-end.
- **no argument, or an unknown argument** → show this 3-line menu and ask which one to run:
  - `vp`   — discover positioning, point of view, target segment; write `value-proposition.md`
  - `copy` — turn the value proposition into long-form Dunford-style copy; write `copywriting.md`
  - `html` — assemble a standalone Apple-inspired landing page; write `index.html`

## Subcommand isolation

Each branch reads only its own folder. Do not pre-load other subcommands' files.

## Source of truth

The instructions inside each subcommand's `prompt.md` (and its sibling knowledge files) are the source of truth for that subcommand's behavior. This router file only dispatches — it does not override subcommand rules.
