# pandoc-htmldocs — feasibility prototype

Proof that the `understanding-html-docs` design system can be driven by a
**deterministic generator**: the AI writes only a semantic intermediate
representation (Markdown + fenced divs), and a pandoc template + Lua filter
bind that meaning to the exact markup contract.

## The three-layer split

| Layer | File | Owns |
|---|---|---|
| Semantic IR (AI writes) | `ir/sample.md` | *meaning only* — `::: {.callout variant=key}` |
| Structural boilerplate | `template.html` | head skeleton, theme-boot key, asset order, `header.site`, `main article` |
| Meaning → markup rule | `filters/htmldocs.lua` | variant→class, `<p class>` components, **vocabulary validation** |

`base.css` / `base.js` are copied verbatim — never authored, never edited.

## Run

```sh
./build.sh        # pandoc on PATH, else `nix run nixpkgs#pandoc`
```

Output: `out/index.html` (a no-build static page, openable directly).

## What it demonstrates

1. **Structural contract is 100% deterministic.** The generated head/asset-order/
   theme-boot match the reference site byte-for-contract; the AI cannot get them
   subtly wrong because it never writes them.
2. **Unknown variants hard-fail at generation.** `variant=warning` (the contract
   forbids it — must be `warn`/`danger`) aborts the build with a non-zero exit and
   no output file. Hand-authored `<div class="callout warning">` would render as a
   silent unstyled box. The *structural* error class becomes loud.
3. **The escape hatch is a one-flag lever.** `-f markdown-raw_html` forbids the
   author from injecting raw HTML (invented classes / inline style) while the
   trusted filter still emits HTML.

## What it does NOT change

The **semantic** judgment stays the author's and still needs a human reviewer:
whether a passage *is* a hazard (`danger`) vs the key point (`key`) is a reading
task no generator can decide. Determinism guarantees the IR→HTML mapping, not the
correctness of the IR's meaning. Review moves from the HTML to the compact IR — it
does not disappear.
