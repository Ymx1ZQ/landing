#!/usr/bin/env bash
set -euo pipefail

# Test suite — verifies vp/prompt.md contracts (M3).
# Run: bash tests/test_vp.sh

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROMPT="$REPO_ROOT/skill/vp/prompt.md"
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

assert_nogrep() {
    local pattern="$1" label="$2"
    if ! grep -qE "$pattern" "$PROMPT"; then
        echo "  PASS: $label"
        PASS=$((PASS + 1))
    else
        echo "  FAIL: $label — unexpected pattern present: $pattern"
        FAIL=$((FAIL + 1))
    fi
}

echo "=== M3: vp/prompt.md ==="

if [ ! -s "$PROMPT" ]; then
    echo "  FAIL: vp/prompt.md empty or missing"
    FAIL=$((FAIL + 1))
    echo "=== Results: $PASS passed, $FAIL failed ==="
    exit 1
fi

# Workflow steps
assert_grep 'interview|discovery|ask' "workflow: interview step"
assert_grep 'confirm|summarize|summary' "workflow: confirmation step"
assert_grep 'generate|output|produce' "workflow: generation step"

# Positioning foundations (Dunford — all 5)
assert_grep 'competitive alternatives?' "foundation: competitive alternatives"
assert_grep 'unique attributes?' "foundation: unique attributes"
assert_grep 'value' "foundation: value"
assert_grep 'target customer (characteristics|profile|criteria)' "foundation: target customer characteristics"
assert_grep '(market )?categor(y|ies)' "foundation: market category"

# Segments
assert_grep 'segment' "segments discovery"
assert_grep '(multi|multiple|several).*segment|primary segment|pick.*segment' "multi-segment pick primary"

# Point of View
assert_grep 'point of view|POV|thesis' "point of view"

# Output filename
assert_grep 'value-proposition\.md' "output filename value-proposition.md"

# Output template — required sections
assert_grep '# 1\. Value Proposition|Value Proposition' "template: VP heading"
assert_grep 'Positioning' "template: Positioning"
assert_grep 'Point of View|POV' "template: POV"
assert_grep 'Segment' "template: Segment"
assert_grep 'Problem' "template: Problem"
assert_grep 'Solution' "template: Solution"
assert_grep 'Key Benefits|Benefits' "template: Benefits"
assert_grep 'Target Users|Users' "template: Users"
assert_grep 'MVP' "template: MVP"
assert_grep 'Constraints' "template: Constraints"

# Language delegation (not hard-coded Italian)
assert_grep 'SKILL\.md|router|language rules' "delegates language to SKILL.md"

# Must NOT reference retired S02-S10 pipeline
assert_nogrep 'S0[2-9]|S10' "no references to S02-S10 pipeline"

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
[ "$FAIL" -eq 0 ]
