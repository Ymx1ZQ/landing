#!/usr/bin/env bash
set -euo pipefail

# Test suite — verifies html/ contracts (M5).
# Run: bash tests/test_html.sh

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HTML_DIR="$REPO_ROOT/skill/html"
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

gf() {
    # fixed-string search (non-regex) — for exact matches
    local file="$1" pattern="$2" label="$3"
    if grep -qF "$pattern" "$file"; then
        echo "  PASS: $label"
        PASS=$((PASS + 1))
    else
        echo "  FAIL: $label — exact string not found in $(basename "$file"): $pattern"
        FAIL=$((FAIL + 1))
    fi
}

not_grep() {
    local file="$1" pattern="$2" label="$3"
    if ! grep -qE "$pattern" "$file"; then
        echo "  PASS: $label"
        PASS=$((PASS + 1))
    else
        echo "  FAIL: $label — unexpected pattern in $(basename "$file"): $pattern"
        FAIL=$((FAIL + 1))
    fi
}

echo "=== M5: html/prompt.md ==="

PROMPT="$HTML_DIR/prompt.md"
if [ ! -s "$PROMPT" ]; then echo "  FAIL: html/prompt.md empty"; FAIL=$((FAIL+1))
else
    g "$PROMPT" 'assembl(y|e)' "assembly model stated"
    g "$PROMPT" 'skeleton\.html' "references skeleton.html"
    g "$PROMPT" 'snippets?/' "references snippets directory"
    g "$PROMPT" 'copywriting\.md' "input: copywriting.md"
    g "$PROMPT" 'index\.html' "output: index.html"
    g "$PROMPT" '[Cc]urrent working directory|CWD|cwd' "references CWD"
    # FASE 0 setup questions
    g "$PROMPT" 'calendly' "FASE 0: Calendly"
    g "$PROMPT" 'color|colour' "FASE 0: color"
    g "$PROMPT" 'CTA' "FASE 0: CTA"
    g "$PROMPT" 'tone|tono' "FASE 0: tone"
    # Language delegation
    g "$PROMPT" 'SKILL\.md|router|language rules' "delegates language"
fi

echo ""
echo "=== M5: html/mapping.md ==="

MAPPING="$HTML_DIR/mapping.md"
if [ ! -s "$MAPPING" ]; then echo "  FAIL: html/mapping.md empty"; FAIL=$((FAIL+1))
else
    g "$MAPPING" 'snippet' "mentions snippets"
    g "$MAPPING" 'hero' "section: hero"
    g "$MAPPING" 'problem' "section: problem"
    g "$MAPPING" 'features?' "section: features"
    g "$MAPPING" 'stats' "section: stats"
    g "$MAPPING" 'testimonial' "section: testimonial"
    g "$MAPPING" 'faq' "section: faq"
    g "$MAPPING" 'calendly' "section: calendly"
    g "$MAPPING" 'final cta|cta finale' "section: final cta"
    g "$MAPPING" 'footer' "section: footer"
fi

echo ""
echo "=== M5: html/rules.md ==="

RULES="$HTML_DIR/rules.md"
if [ ! -s "$RULES" ]; then echo "  FAIL: html/rules.md empty"; FAIL=$((FAIL+1))
else
    gf "$RULES" 'https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.2/css/all.min.css' "Font Awesome CDN verbatim"
    g "$RULES" 'illustration-placeholder' "illustration-placeholder rule"
    g "$RULES" 'calendly' "Calendly rules"
    g "$RULES" 'dark[[:space:]-]*section' "dark section rules"
    g "$RULES" 'meta[[:space:]]*description|SEO|og:' "SEO / meta rules"
    g "$RULES" 'accessibilit|alt[[:space:]]*text|aria' "accessibility rules"
    g "$RULES" 'checklist' "final checklist"
fi

echo ""
echo "=== M5: html/skeleton.html ==="

SKEL="$HTML_DIR/skeleton.html"
if [ ! -s "$SKEL" ]; then echo "  FAIL: skeleton.html empty"; FAIL=$((FAIL+1))
else
    g "$SKEL" '<!DOCTYPE html>' "doctype"
    g "$SKEL" '<html[^>]*lang' "html lang attribute"
    g "$SKEL" '<head>' "head element"
    g "$SKEL" '<body>' "body element"
    gf "$SKEL" 'https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.2/css/all.min.css' "Font Awesome CDN verbatim"
    # Meta/SEO placeholders
    g "$SKEL" '\{\{TITLE\}\}|<title>\{\{' "title placeholder"
    g "$SKEL" '\{\{META_DESCRIPTION\}\}|name="description"' "meta description"
    g "$SKEL" 'og:title|og:description' "open graph tags"
    # CSS core
    g "$SKEL" ':root[[:space:]]*\{' ":root CSS block"
    if grep -qF -- '--primary' "$SKEL"; then
        echo "  PASS: CSS var --primary"
        PASS=$((PASS + 1))
    else
        echo "  FAIL: CSS var --primary not found"
        FAIL=$((FAIL + 1))
    fi
    g "$SKEL" 'illustration-placeholder' ".illustration-placeholder class"
    g "$SKEL" 'prefers-reduced-motion' "reduced-motion media query"
    # JS core
    g "$SKEL" 'IntersectionObserver' "reveal observer"
    g "$SKEL" 'data-target' "counter animation hook"
    # Sections placeholder
    g "$SKEL" '\{\{SECTIONS\}\}|\{\{CONTENT\}\}' "sections placeholder"
    # URL hygiene — no [ or ] inside href=" or data-url=" or src="
    if grep -Eo '(href|src|data-url)="[^"]*\[[^"]*"' "$SKEL" | head -1 | grep -q '.'; then
        echo "  FAIL: bracket character found inside URL attribute"
        FAIL=$((FAIL + 1))
    else
        echo "  PASS: no brackets inside URL attributes"
        PASS=$((PASS + 1))
    fi
fi

echo ""
echo "=== M5: html/snippets/*.html ==="

for name in nav hero problem features stats testimonial integration faq calendly-real calendly-mock final-cta footer; do
    f="$HTML_DIR/snippets/$name.html"
    if [ ! -s "$f" ]; then
        echo "  FAIL: snippet $name.html is empty"
        FAIL=$((FAIL + 1))
        continue
    fi
    # Must contain at least one {{PLACEHOLDER}} OR be a complete static snippet (calendly-mock/footer may be more static)
    if grep -qE '\{\{[A-Z_0-9]+\}\}' "$f"; then
        echo "  PASS: $name.html has {{PLACEHOLDER}} markers"
        PASS=$((PASS + 1))
    elif [ "$name" = "calendly-mock" ]; then
        echo "  PASS: $name.html (static mock, no placeholders required)"
        PASS=$((PASS + 1))
    else
        echo "  FAIL: $name.html has no {{PLACEHOLDER}} markers"
        FAIL=$((FAIL + 1))
    fi
    # URL hygiene — no [ or ] inside href=" or src=" or data-url="
    if grep -Eo '(href|src|data-url)="[^"]*\[[^"]*"' "$f" | head -1 | grep -q '.'; then
        echo "  FAIL: $name.html has bracket in URL attribute"
        FAIL=$((FAIL + 1))
    fi
    # No external <img src="http...">
    if grep -qE '<img[^>]+src="https?://' "$f"; then
        echo "  FAIL: $name.html contains <img> with external URL (disallowed)"
        FAIL=$((FAIL + 1))
    fi
done

# Calendly-real must contain the exact widget URL template
g "$HTML_DIR/snippets/calendly-real.html" 'calendly-inline-widget' "calendly-real: inline widget class"
gf "$HTML_DIR/snippets/calendly-real.html" 'https://assets.calendly.com/assets/external/widget.js' "calendly-real: widget.js CDN"

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
[ "$FAIL" -eq 0 ]
