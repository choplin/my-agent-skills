#!/usr/bin/env bash
# Build the whole multi-page site: every ir/*.md -> out/*.html, sharing one set
# of assets. Inter-page nav is just links authored in the IR (index lists the
# pages; each page's header links home) — no nav-manifest needed for this site.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"

for md in "$here"/ir/*.md; do
  "$here/build.sh" "$md"
done

echo
echo "Site built under $here/out :"
ls -1 "$here/out"/*.html | sed "s#$here/out/#  #"
