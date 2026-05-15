#!/usr/bin/env bash
set -euo pipefail

# Test suite — verifies review/prompt.md contracts (M13).
# Run: bash tests/test_review.sh

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROMPT="$REPO_ROOT/skill/review/prompt.md"
PASS=0
FAIL=0

assert_grep() {
    local pattern="$1" label="$2"
    if grep -qiE "$pattern" "$PROMPT"; then
        echo "  PASS: $label"
        PASS=$((PASS + 1))
    else
        echo "  FAIL: $label — pattern not found: $pattern"
        FAIL=$((FAIL + 1))
    fi
}

echo "=== M13: review/prompt.md ==="

if [ ! -s "$PROMPT" ]; then
    echo "  FAIL: review/prompt.md empty or missing"
    FAIL=$((FAIL + 1))
    echo "=== Results: $PASS passed, $FAIL failed ==="
    exit 1
fi

# Inputs
assert_grep 'value-proposition\.md' "input: value-proposition.md"
assert_grep 'copywriting\.md' "input: copywriting.md"
assert_grep '[Cc]urrent working directory|CWD|cwd' "references CWD"

# Output
assert_grep 'copy-review\.md' "output filename copy-review.md"

# Three output sections (literal headings the prompt must produce)
assert_grep 'What smells off|smells off' "section 1: What smells off"
assert_grep "Why I'?m not buying|not buying yet|not buying" "section 2: Why I'm not buying yet"
assert_grep 'What would convince me|would convince me' "section 3: What would convince me"
assert_grep 'rewrite' "section 3: rewrite candidates"

# Single-lens enforcement (Decision Maker only)
assert_grep 'single lens|one lens|Decision Maker.*lens|lens.*Decision Maker' "lens: single Decision Maker"
assert_grep 'one pitch.*one segment|primary segment' "lens: primary segment alignment"

# Objection anchoring rule — each objection must link to a Pain / Gain / known Objection
assert_grep 'anchor.*Pain|anchored.*Pain|Pain.*anchor' "rule: objection anchored to Pain"
assert_grep 'drop.*sharpen|sharpen.*drop|cannot be anchored' "rule: drop / sharpen unanchored objections"

# Graceful inline ICP collection when VP pre-M12 (no Sponsor/Pains/Gains/Objections in VP)
assert_grep 'inline|collect.*inline|short interview' "graceful: inline collection when VP lacks ICP"
assert_grep 'does NOT ask|do not ask.*re-?run|without re-?running' "graceful: does not require re-running /landing vp"

# Tone discipline
assert_grep 'severe|lucid|not constructive-at-all-costs|holds.*say so' "tone: severe and lucid"

# Language delegation
assert_grep 'SKILL\.md|router|language rules' "delegates language to SKILL.md"

# index.html must be explicitly out of scope (review critiques copywriting.md, not the rendering)
assert_grep "[Dd]on'?t review.*index\.html|index\.html.*out of scope|out of scope.*index\.html|critique the source.*not the rendering" "out of scope: index.html explicitly excluded"

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
[ "$FAIL" -eq 0 ]
