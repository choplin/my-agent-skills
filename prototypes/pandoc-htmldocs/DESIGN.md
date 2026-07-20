# Design: a deterministic HTML generator for understanding-html-docs

Status: **proposal** — feasibility validated by the prototype in this directory.

## Problem

Today an AI authors each `understanding-html-docs` page as freeform HTML against a
CSS class contract (`pdf-studio-site-page`, `understanding-explain-diff`). Two
costs:

- The AI writes the same structural boilerplate on every page (head skeleton,
  theme-boot key, asset link order, `header.site` / `main article`), and can get
  it subtly wrong. Nothing checks it.
- The class contract has to be re-read against every page by a human reviewer,
  including the *mechanical* part (invented class, inline style, unwrapped table).

## What the prototype establishes

A deterministic generator can own the mechanical layer. The AI writes a **semantic
intermediate representation** (Markdown + fenced divs); a pandoc **template** owns
the boilerplate; a Lua **filter** binds meaning → markup and validates the
vocabulary. Verified end-to-end:

- Regenerated 6 of the 7 reference (dogfood) pages as a linked static site from IR.
- Output is **visually indistinguishable** from the hand-authored reference.
- Structural diff vs the reference: only 3 cosmetic wrapper differences
  (`<section>` grouping, `pre.nohighlight` vs `pre>code.nohighlight`,
  `section.keypoints` vs `div.keypoints`) — none visible, none contract-violating.
  **Zero semantic differences** (no wrong variant, no unwrapped table, no invented
  class).
- Unknown callout variant → **hard error at generation** (exit 83, no output),
  where hand-authored HTML would render a silent unstyled box.
- `<table>` is **always** wrapped in `.tablewrap` by the filter (contract made
  structural, not review-caught).
- Consumer-specific vocabulary (color page's `swatch`/`ramp`) loads via a **context
  stylesheet + extra filter directives** — the "inject both the IR vocabulary and
  its rendering" model, working on a real page.

## Architecture

Three layers, mapped onto three pandoc mechanisms:

| Layer | Mechanism | Owns |
|---|---|---|
| Semantic IR (AI writes) | fenced divs / bracketed spans | *meaning only* |
| Structural boilerplate | `template.html` | head, theme-boot, asset order, chrome |
| Meaning → markup + validation | `filters/htmldocs.lua` | variant→class, tablewrap, `<p class>`, `<mark>`, consumer directives |

`base.css` / `base.js` are copied verbatim. Output is still a **no-build static
site** (double-click to open) — the build is at *authoring* time only.

## The IR dialect (frozen vocabulary)

| To express | IR |
|---|---|
| callout (note) | `::: {.callout}` |
| callout variant | `::: {.callout variant=tip\|warn\|danger\|key}` — unknown = hard error |
| callout lead-in | `[Label]{.label}` at paragraph start |
| keypoints | `::: {.keypoints}` + `### Title` + `- ` list |
| card / grid | `:::: {.card-grid}` › `::: {.card}` |
| chip / badge | `[text]{.chip}` / `[text]{.chip .accent}` / `[text]{.badge}` |
| lede / kicker / pullquote | `::: {.lede}` / `.kicker` / `.pullquote` → emitted as `<p class>` |
| aside | `::: {.aside}` |
| highlight | `[text]{.mark}` → `<mark>` |
| table | a plain Markdown table — filter auto-wraps in `.tablewrap` |
| code sample | ` ```{.nohighlight} ` fence |
| consumer axis | consumer registers a directive + a context stylesheet |

## Packaging as a skill

- Leaf skill (e.g. `understanding-html-docs-generate`) bundling `template.html`,
  `filters/htmldocs.lua`, `build.sh` / `build-site.sh`.
- Runtime: **pandoc**. Declared in a leaf `flake.nix`; resolved by a preflight
  (PATH → `nix run nixpkgs#pandoc` → fail). This follows the repo's runtime policy
  (`docs/skill-runtime-and-dependencies.md`): escalate by fit, declare, preflight.
- The reviewer **stays**. Determinism guarantees the IR→HTML mapping, not the
  meaning of the IR. Semantic review (`understanding-html-docs-review`) moves from
  the HTML to the compact IR, and its *mechanical* checks (class exists, table
  wrapped) become unnecessary because they are structurally impossible to fail.

## Tension with the current design (must be decided, not defaulted)

`understanding-html-docs/docs/components.md` lists two **standing prohibitions**:

> **No build step.** The runtime floor is shell + jq and the distribution model is
> *an agent copies files by instruction*… Reopen if the substrate ever needs to be
> tree-shaken per document.

> **No linter.** `check.sh` is deliberately absent… the errors that matter are
> well-formed, so a class check proves almost nothing.

This proposal **reverses "No build step" at authoring time** (it adds pandoc). It
does **not** violate "No linter" — the generator is not a linter, and the semantic
reviewer is retained; it only makes the *mechanical* errors unrepresentable. The
*output* stays no-build. Whether to reverse the authoring-time prohibition is a
decision for the maintainer, not a default.

## Decisions to make (parking lot)

- **D1 — Replace, or alongside?** Does the generator *replace* hand-authored HTML
  for consumers, or sit *alongside* it as an optional authoring path (hand-authoring
  stays the documented default)? *Recommend: alongside first* — lowest risk, lets one
  consumer adopt and prove value before touching the contract's "No build step".
- **D2 — Which consumers?** `pdf-studio-site-page` (multi-page, most boilerplate —
  biggest win) vs `understanding-explain-diff` (single-page inline, consumer axes —
  best test of directive injection). *Recommend: pdf-studio-site-page pilot.*
- **D3 — Escape hatch.** Keep `-f markdown-raw_html` (strict: author cannot inject
  raw HTML) or allow raw HTML passthrough? *Recommend: strict.*
- **D4 — IR classes: direct or validated names?** `::: {.callout .key}` (thin, no
  validation) vs `::: {.callout variant=key}` (filter validates, unknown = hard
  error). *Recommend: validated names* — the validation is the main structural win.
- **D5 — Byte-parity?** Close the 3 cosmetic wrapper deltas in the filter, or accept
  them? *Recommend: accept* — none are visible or contract-violating; the
  `<section>` wrapper is not even required by the contract.

## Recommended next steps (after D1–D2)

1. Move the prototype into a leaf skill with a preflight + `flake.nix`.
2. Freeze the IR dialect and split the filter into base + consumer modules.
3. Pilot on one consumer; run `understanding-html-docs-review` against the IR.
4. Measure: structural errors (target 0), reviewer surface, token delta.
