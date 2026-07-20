#!/usr/bin/env bash
# Deterministic HTML generator: semantic IR (Markdown + fenced divs) -> a
# understanding-html-docs page, via a pandoc template + Lua filter.
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
assets_src="$here/../../skills/understanding/understanding-html-docs/assets"
out="$here/out"

# input IR (default: the sample); output name derived from it
src="${1:-$here/ir/sample.md}"
page="$(basename "${src%.md}").html"

# how to invoke pandoc: a real binary on PATH, else through the flake.
if command -v pandoc >/dev/null 2>&1; then
  PANDOC=(pandoc)
else
  PANDOC=(nix run nixpkgs#pandoc --)
fi

mkdir -p "$out/assets"
# structural boilerplate the AI never touches: base assets copied verbatim.
cp "$assets_src/base.css" "$assets_src/base.js" "$out/assets/"
# consumer context stylesheets (e.g. color.css), if any
[ -d "$here/context" ] && cp "$here/context/"*.css "$out/assets/" 2>/dev/null || true

# -f markdown-raw_html closes the escape hatch: the AUTHOR cannot inject raw
# HTML (invented classes / inline style), but the trusted filter still emits it.
"${PANDOC[@]}" "$src" \
  --template "$here/template.html" \
  --lua-filter "$here/filters/htmldocs.lua" \
  -f markdown-raw_html \
  -o "$out/$page"

echo "wrote $out/$page"
