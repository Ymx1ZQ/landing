#!/usr/bin/env bash
set -euo pipefail

# Test suite — verifies copy/ contracts (M4).
# Run: bash tests/test_copy.sh

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROMPT="$REPO_ROOT/skill/copy/prompt.md"
QUESTIONS="$REPO_ROOT/skill/copy/questions.md"
TEMPLATE="$REPO_ROOT/skill/copy/template.md"
PASS=0
FAIL=0

g() {
    local file="$1" pattern="$2" label="$3"
    if grep -qiE "$pattern" "$file"; then
        echo "  PASS: $label"
        PASS=$((PASS + 1))
    else
        echo "  FAIL: $label — pattern not found in $(basename "$file"): $pattern"
        FAIL=$((FAIL + 1))
    fi
}

echo "=== M4: copy/prompt.md ==="

if [ ! -s "$PROMPT" ]; then echo "  FAIL: copy/prompt.md empty"; FAIL=$((FAIL+1))
else
    # Dunford narrative
    g "$PROMPT" 'Insight'                 "narrative: Insight"
    g "$PROMPT" 'Alternatives?'           "narrative: Alternatives"
    g "$PROMPT" 'Perfect World'           "narrative: Perfect World"
    g "$PROMPT" 'Introduction'            "narrative: Introduction"
    g "$PROMPT" 'Differentiated Value|Value'  "narrative: Differentiated Value"
    g "$PROMPT" 'Proof'                   "narrative: Proof"
    g "$PROMPT" '\bAsk\b|the Ask'         "narrative: The Ask"
    # Process
    g "$PROMPT" 'PHASE 1|Phase 1|phase 1' "process: PHASE 1"
    g "$PROMPT" 'PHASE 2|Phase 2|phase 2' "process: PHASE 2"
    # New rules
    g "$PROMPT" 'value buckets?|named.*bucket|theme(d)? bucket' "rule: named value buckets"
    g "$PROMPT" 'specific(ity)?|numeric|concrete' "rule: specificity / numeric claims"
    g "$PROMPT" 'headline.*(variant|option|alternative)' "rule: headline variants"
    g "$PROMPT" 'objection' "rule: objection handling"
    g "$PROMPT" '(primary|secondary).*CTA|CTA.*hierarchy' "rule: CTA hierarchy"
    # Booking vs contact framing
    g "$PROMPT" 'booking|scheduled call' "rule: booking framing"
    g "$PROMPT" 'contact form|contact|reply|get back' "rule: contact framing"
    g "$PROMPT" 'conversion mechanism|framing' "rule: conversion mechanism / framing"
    # I/O
    g "$PROMPT" 'value-proposition\.md' "input: value-proposition.md"
    g "$PROMPT" 'copywriting\.md' "output: copywriting.md"
    g "$PROMPT" '[Cc]urrent working directory|CWD|cwd' "references CWD"
    # Knowledge file references
    g "$PROMPT" 'questions\.md' "references questions.md"
    g "$PROMPT" 'template\.md' "references template.md"
    # Language delegation
    g "$PROMPT" 'SKILL\.md|router|language rules' "delegates language"
    # M17 — Length budgets + CTA differentiation
    g "$PROMPT" '[Ll]ength budgets?'                       "M17 prompt: length budgets section"
    g "$PROMPT" 'CTA differentiation|differ.*Hero.*[Pp]rimary' "M17 prompt: CTA differentiation rule"
fi

echo ""
echo "=== M4: copy/questions.md ==="

if [ ! -s "$QUESTIONS" ]; then echo "  FAIL: questions.md empty"; FAIL=$((FAIL+1))
else
    # At least 7 numbered questions (5 original + segment + conversion mechanism)
    count=$(grep -cE '^###[[:space:]]+[0-9]+\.' "$QUESTIONS" || true)
    if [ "$count" -ge 7 ]; then
        echo "  PASS: at least 7 numbered discovery questions ($count)"
        PASS=$((PASS + 1))
    else
        echo "  FAIL: expected >=7 numbered questions, found $count"
        FAIL=$((FAIL + 1))
    fi
    g "$QUESTIONS" 'alternatives?|status quo|enemy' "covers: alternatives / status quo"
    g "$QUESTIONS" 'insight|shift' "covers: insight"
    g "$QUESTIONS" '(feature|benefit).*value|value.*(feature|benefit)' "covers: feature → value"
    g "$QUESTIONS" 'proof|social proof|testimonial|logo|numbers' "covers: social proof"
    g "$QUESTIONS" 'CTA|call to action|offer' "covers: CTA / offer"
    g "$QUESTIONS" 'segment' "covers: segment confirmation"
    g "$QUESTIONS" 'booking|scheduled call|calendly' "covers: booking option"
    g "$QUESTIONS" 'contact form|formspree|hubspot|typeform|tally' "covers: contact option"
fi

echo ""
echo "=== M8: copy/template.md (framing hint) ==="
if [ -s "$TEMPLATE" ]; then
    g "$TEMPLATE" 'framing|booking|contact' "template: framing hint in CTA section"
fi

echo ""
echo "=== M4: copy/template.md ==="

if [ ! -s "$TEMPLATE" ]; then echo "  FAIL: template.md empty"; FAIL=$((FAIL+1))
else
    # Required sections
    g "$TEMPLATE" 'HERO' "section: HERO"
    g "$TEMPLATE" 'SETUP' "section: SETUP"
    g "$TEMPLATE" 'SHIFT' "section: SHIFT"
    g "$TEMPLATE" 'SOLUTION' "section: SOLUTION"
    g "$TEMPLATE" 'VALUE PROPOSITION' "section: VALUE PROPOSITION"
    g "$TEMPLATE" 'SOCIAL PROOF' "section: SOCIAL PROOF"
    g "$TEMPLATE" 'FAQ|OBJECTION' "section: FAQ/OBJECTION"
    g "$TEMPLATE" 'FINAL CTA' "section: FINAL CTA"
    # 3 named value buckets
    bucket_count=$(grep -cE '(Bucket|Pillar)[[:space:]]*[0-9]' "$TEMPLATE" || true)
    if [ "$bucket_count" -ge 3 ]; then
        echo "  PASS: template has 3 named value buckets/pillars ($bucket_count)"
        PASS=$((PASS + 1))
    else
        echo "  FAIL: expected >=3 named buckets/pillars, found $bucket_count"
        FAIL=$((FAIL + 1))
    fi
    # Hero: primary + secondary CTA
    g "$TEMPLATE" 'Primary CTA' "hero: primary CTA"
    g "$TEMPLATE" 'Secondary CTA' "hero: secondary CTA"
    # Headline variants
    g "$TEMPLATE" '(Variant|Option).*[AB1]|[Hh]eadline.*[Vv]ariants?' "template: headline variants block"
fi

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
[ "$FAIL" -eq 0 ]
