#!/usr/bin/env bash
# Rebuild the self-hosted front-end assets that replace Wowchemy 4.8's CDN and Google Fonts requests.
#
# Wowchemy 4.8 loads its libraries from cdnjs and its fonts from Google Fonts, which sends every
# visitor's IP address to third parties. It switches to local mode when both
#   static/css/vendor/main.min.css and static/js/vendor/main.min.js
# exist (see layouts/partials/site_head.html and site_js.html of the theme module).
# Text fonts come from data/fonts/minimal_local.toml (no Google Fonts URL) and assets/scss/custom.scss.
#
# Versions match data/assets.toml of the pinned Wowchemy module; academicons is 1.9.1 because
# 1.9.0 is not on npm. Run from anywhere: scripts/build_vendor_assets.sh (needs npm and tar).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

PKGS=(
  jquery@3.5.1
  imagesloaded@4.1.4
  isotope-layout@3.0.6
  @fancyapps/fancybox@3.5.7
  instant.page@5.1.0
  @highlightjs/cdn-assets@10.2.0
  fuse.js@3.2.1
  mark.js@8.11.1
  lazysizes@5.2.2
  @fortawesome/fontawesome-free@5.14.0
  academicons@1.9.1
  @fontsource/montserrat@5.3.0
  @fontsource/roboto@5.3.0
  @fontsource/roboto-mono@5.3.0
)

cd "$TMP"
for p in "${PKGS[@]}"; do
  tgz="$(npm pack --silent "$p" | tail -1)"
  name="$(basename "$tgz" .tgz)"
  mkdir -p "$name"
  tar xzf "$tgz" -C "$name"
done

P() { echo "$TMP/$1/package/$2"; }

JS_OUT="$ROOT/static/js/vendor/main.min.js"
CSS_OUT="$ROOT/static/css/vendor/main.min.css"
mkdir -p "$(dirname "$JS_OUT")" "$(dirname "$CSS_OUT")" \
  "$ROOT/static/css/webfonts" "$ROOT/static/css/fonts" "$ROOT/static/fonts"

# JavaScript bundle, in the order the theme loads the CDN scripts.
{
  echo "/*! Self-hosted vendor bundle for Wowchemy 4.8 (built by scripts/build_vendor_assets.sh). Components keep their own license headers. */"
  for f in \
    "$(P jquery-3.5.1 dist/jquery.min.js)" \
    "$(P imagesloaded-4.1.4 imagesloaded.pkgd.min.js)" \
    "$(P isotope-layout-3.0.6 dist/isotope.pkgd.min.js)" \
    "$(P fancyapps-fancybox-3.5.7 dist/jquery.fancybox.min.js)"; do
    cat "$f"; printf '\n;\n'
  done
  # instant.page is published with top-level let/const; wrap it so it cannot clash with other scripts.
  printf '(function(){\n'; cat "$(P instant.page-5.1.0 instantpage.js)"; printf '\n})();\n'
  for f in \
    "$(P highlightjs-cdn-assets-10.2.0 highlight.min.js)" \
    "$(P highlightjs-cdn-assets-10.2.0 languages/r.min.js)" \
    "$(P fuse.js-3.2.1 dist/fuse.min.js)" \
    "$(P mark.js-8.11.1 dist/jquery.mark.min.js)" \
    "$(P lazysizes-5.2.2 lazysizes.min.js)"; do
    cat "$f"; printf '\n;\n'
  done
} > "$JS_OUT"

# CSS bundle. Relative font URLs resolve to /css/fonts/ (Academicons) and /css/webfonts/ (Font Awesome).
{
  echo "/*! Self-hosted vendor bundle for Wowchemy 4.8 (built by scripts/build_vendor_assets.sh). Components keep their own license headers. */"
  cat "$(P academicons-1.9.1 css/academicons.min.css)"; echo
  cat "$(P fortawesome-fontawesome-free-5.14.0 css/all.min.css)"; echo
  cat "$(P fancyapps-fancybox-3.5.7 dist/jquery.fancybox.min.css)"; echo
} > "$CSS_OUT"

# Code highlighting styles; layouts/partials/custom_head.html links them as hl-light / hl-dark.
cp "$(P highlightjs-cdn-assets-10.2.0 styles/github.min.css)" "$ROOT/static/css/vendor/hl-github.min.css"
cp "$(P highlightjs-cdn-assets-10.2.0 styles/dracula.min.css)" "$ROOT/static/css/vendor/hl-dracula.min.css"

# Icon fonts: only the formats modern browsers pick from the src lists (woff2 for Font Awesome, ttf for Academicons).
cp "$(P fortawesome-fontawesome-free-5.14.0 webfonts/fa-brands-400.woff2)" \
   "$(P fortawesome-fontawesome-free-5.14.0 webfonts/fa-regular-400.woff2)" \
   "$(P fortawesome-fontawesome-free-5.14.0 webfonts/fa-solid-900.woff2)" "$ROOT/static/css/webfonts/"
cp "$(P academicons-1.9.1 fonts/academicons.ttf)" "$ROOT/static/css/fonts/"

# Text fonts (latin and latin-ext subsets) referenced by assets/scss/custom.scss.
for f in \
  montserrat-latin-400-normal montserrat-latin-ext-400-normal \
  montserrat-latin-700-normal montserrat-latin-ext-700-normal; do
  cp "$(P fontsource-montserrat-5.3.0 files/$f.woff2)" "$ROOT/static/fonts/"
done
for f in \
  roboto-latin-400-normal roboto-latin-ext-400-normal \
  roboto-latin-400-italic roboto-latin-ext-400-italic \
  roboto-latin-700-normal roboto-latin-ext-700-normal; do
  cp "$(P fontsource-roboto-5.3.0 files/$f.woff2)" "$ROOT/static/fonts/"
done
for f in roboto-mono-latin-400-normal roboto-mono-latin-ext-400-normal; do
  cp "$(P fontsource-roboto-mono-5.3.0 files/$f.woff2)" "$ROOT/static/fonts/"
done
# One OFL text with the copyright lines of all three font families.
{
  for d in fontsource-montserrat-5.3.0 fontsource-roboto-5.3.0 fontsource-roboto-mono-5.3.0; do
    sed -n '1p' "$(P "$d" LICENSE)"
  done
  sed -n '2,$p' "$(P fontsource-montserrat-5.3.0 LICENSE)"
} > "$ROOT/static/fonts/OFL.txt"

echo "Vendor assets written to static/css, static/js/vendor and static/fonts."
