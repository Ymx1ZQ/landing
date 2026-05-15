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

for name in nav hero problem features stats testimonial integration faq conversion final-cta footer; do
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

# conversion.html contracts
g "$HTML_DIR/snippets/conversion.html" 'CONVERSION_EMBED' "conversion: embed placeholder"
g "$HTML_DIR/snippets/conversion.html" 'CONVERSION_TITLE' "conversion: title placeholder"
g "$HTML_DIR/snippets/conversion.html" 'id="convert"' "conversion: section id=convert"

# Removed snippets must no longer exist
for old in calendly-real calendly-mock; do
    if [ -f "$HTML_DIR/snippets/$old.html" ]; then
        echo "  FAIL: obsolete $old.html still present"
        FAIL=$((FAIL + 1))
    else
        echo "  PASS: obsolete $old.html removed"
        PASS=$((PASS + 1))
    fi
done

# Anchor rename: snippets point to #convert, not #calendly
for snip in nav hero final-cta; do
    if grep -qF '#calendly' "$HTML_DIR/snippets/$snip.html"; then
        echo "  FAIL: $snip.html still references obsolete #calendly anchor"
        FAIL=$((FAIL + 1))
    else
        echo "  PASS: $snip.html has no #calendly anchor"
        PASS=$((PASS + 1))
    fi
    if grep -qF '#convert' "$HTML_DIR/snippets/$snip.html"; then
        echo "  PASS: $snip.html uses #convert anchor"
        PASS=$((PASS + 1))
    else
        echo "  FAIL: $snip.html missing #convert anchor"
        FAIL=$((FAIL + 1))
    fi
done

# Skeleton: GTM marker blocks (wrap with {{#GTM_HEAD}} / {{/GTM_HEAD}} and body pair)
if grep -qE '\{\{#GTM_HEAD\}\}' "$SKEL" && grep -qE '\{\{/GTM_HEAD\}\}' "$SKEL"; then
    echo "  PASS: skeleton has GTM_HEAD marker block"
    PASS=$((PASS + 1))
else
    echo "  FAIL: skeleton missing GTM_HEAD marker block"
    FAIL=$((FAIL + 1))
fi
if grep -qE '\{\{#GTM_BODY\}\}' "$SKEL" && grep -qE '\{\{/GTM_BODY\}\}' "$SKEL"; then
    echo "  PASS: skeleton has GTM_BODY marker block"
    PASS=$((PASS + 1))
else
    echo "  FAIL: skeleton missing GTM_BODY marker block"
    FAIL=$((FAIL + 1))
fi

# html/prompt.md must cover GTM + conversion embed + detection logic
g "$PROMPT" 'GTM|Google Tag Manager' "prompt: covers GTM"
g "$PROMPT" 'conversion embed|embed' "prompt: covers conversion embed"
g "$PROMPT" 'calendly\.com|savvycal|cal\.com' "prompt: detection — booking URL"
g "$PROMPT" 'form|iframe|HTML' "prompt: detection — pasted HTML"

# rules.md must include the GTM pre-compiled blocks
g "$RULES" 'GTM|Google Tag Manager' "rules: covers GTM"
g "$RULES" 'googletagmanager\.com' "rules: GTM loader URL"

# M14 — FASE 0 expansion + footer/conversion placeholders + href guard
g "$PROMPT" '[Pp]rivacy.*URL|URL.*[Pp]rivacy'                  "M14 prompt: FASE 0 privacy URL"
g "$PROMPT" '[Tt]erms.*URL|URL.*[Tt]erms'                       "M14 prompt: FASE 0 terms URL"
g "$PROMPT" '[Cc]ontact.*email|email.*[Cc]ontact'               "M14 prompt: FASE 0 contact email"
g "$HTML_DIR/snippets/footer.html"     'PRIVACY_LINK'           "M14 footer: PRIVACY_LINK placeholder"
g "$HTML_DIR/snippets/footer.html"     'TERMS_LINK'             "M14 footer: TERMS_LINK placeholder"
g "$HTML_DIR/snippets/footer.html"     'CONTACT_LINK'           "M14 footer: CONTACT_LINK placeholder"
g "$HTML_DIR/snippets/conversion.html" 'CONVERSION_FALLBACK'    "M14 conversion: CONVERSION_FALLBACK placeholder"
g "$RULES" 'disabled-link|aria-disabled'                        "M14 rules: disabled-link / aria-disabled guard"
g "$RULES" 'data-todo'                                          "M14 rules: data-todo guard"
g "$SKEL"  'disabled-link'                                      "M14 skeleton: .disabled-link CSS"
g "$SKEL"  'calendly-fallback'                                  "M14 skeleton: .calendly-fallback CSS"

# M15 — Cookie consent banner
g "$PROMPT" '[Cc]ookie.*banner|[Cc]ookie.*consent'              "M15 prompt: FASE 0 cookie banner"
[ -f "$HTML_DIR/snippets/cookie-banner.html" ] && { echo "  PASS: M15 snippet cookie-banner.html exists"; PASS=$((PASS+1)); } || { echo "  FAIL: M15 snippet cookie-banner.html missing"; FAIL=$((FAIL+1)); }
g "$HTML_DIR/snippets/cookie-banner.html" 'cookie-banner'       "M15 cookie-banner: .cookie-banner class"
g "$HTML_DIR/snippets/cookie-banner.html" 'cookie-accept'       "M15 cookie-banner: accept button"
g "$HTML_DIR/snippets/cookie-banner.html" 'cookie-reject'       "M15 cookie-banner: reject button"
g "$SKEL"   'cookie-banner'                                     "M15 skeleton: .cookie-banner CSS"
g "$SKEL"   'cookie-btn-accept|cookie-btn-reject'               "M15 skeleton: .cookie-btn-* CSS"
g "$SKEL"   'landing_cookie_consent_v1|cookie_consent_v1'        "M15 skeleton: localStorage key"
g "$SKEL"   'loadThirdPartyEmbeds|data-embed-url'               "M15 skeleton: consent gate JS hook"
g "$RULES"  'cookie-banner|cookie consent|cookie banner'        "M15 rules: cookie banner section"
g "$MAPPING" 'cookie-banner'                                    "M15 mapping: cookie-banner row"

# M16 — Open Graph image + Twitter card + canonical URL
g "$SKEL"  'og:image'                                           "M16 skeleton: og:image"
g "$SKEL"  'og:url'                                             "M16 skeleton: og:url"
g "$SKEL"  'twitter:card'                                       "M16 skeleton: twitter:card"
g "$SKEL"  'twitter:image|TWITTER_IMAGE'                        "M16 skeleton: twitter:image"
g "$PROMPT" 'canonical|og:url|landing.*URL'                     "M16 prompt: FASE 0 canonical URL"
g "$PROMPT" 'Open Graph|og:image|OG image'                      "M16 prompt: FASE 0 OG image"
g "$RULES"  'og:image'                                          "M16 rules: og:image mandatory"

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
[ "$FAIL" -eq 0 ]
