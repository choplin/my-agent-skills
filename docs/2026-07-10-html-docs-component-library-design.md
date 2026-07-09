---
title: "understanding-html-docs as a Component Library — Design Rationale"
date: 2026-07-10
type: decision
status: accepted
tags:
  - understanding-html-docs
  - design-system
  - explain-diff
  - pdf-studio
  - agent-skills
  - design-rationale
summary: >
  Turn understanding-html-docs (base) into an opt-in component library — a
  lightweight, document-focused design system — so that consuming skills define
  content, not design. Records the principle (base owns design / skill owns
  content), the three-tier component model with a core + opt-in packaging, the
  per-component third-party distribution policy, and the promotion criterion for
  growing the small-UI catalog. Implementation (moving code) is deferred to
  follow-up issues; this document is the decision record only.
---

# understanding-html-docs as a Component Library — Design Rationale

This is the durable record of *why* `understanding-html-docs` (the base skill
shared by explanation-document skills) is being reshaped into an opt-in
**component library**. It is layered so the upper sections survive code churn:
the principle and the model are near-invariant; the promotion candidates and
concrete file names are confined to the lower sections.

**Scope of this decision:** the deliverable is the decision itself. No large code
move happens here — only this ADR and a matching wording update to the base
skill's Principles. The actual component extraction and catalog growth are
carved into follow-up issues (see *Follow-up work*).

## Motivation

`understanding-html-docs` today ships two files (`base.css`, `base.js`) that
consumers copy verbatim, then each consumer adds its own context stylesheet and
markup. That leaves two problems:

1. **Third-party integration knowledge is re-derived per skill.** The operational
   knowledge for heavy renderers (diff2html CDN links + render script + the
   "keep every excerpt a valid unified diff" escaping rules; mermaid init) lives
   only inside `understanding-explain-diff`. A second skill that wants diffs or
   diagrams has nowhere to inherit it from and must reconstruct it. The
   divergence was visible historically: pdf-studio's generate-site had at one
   point written a "no external URLs / fully self-contained" rule that
   contradicted the base's "online is fine for the context layer" stance. (That
   specific contradiction has since been corrected on the pdf-studio side, but it
   is the exact failure mode this consolidation prevents from recurring.)

2. **There is no design-system layer between "foundation" and "the consumer's
   own components."** Generic document-reading UI patterns (a key-points box, an
   eyebrow/kicker, a lede, card grids) get re-invented in each consumer's context
   stylesheet instead of being a shared vocabulary. The base is a foundation, not
   yet a *design system*.

The goal: base becomes the single source of truth for **how an explanation
document looks and how its rendering engines are wired**; each consuming skill
defines only **what the document says**. Content-only consumers are more
mechanical and can run on a cheaper model; design is reviewed in one place.

## Decision 1 — base owns design; the skill owns content

**Principle (accepted):** `understanding-html-docs` is an *opt-in component
library* — its own design system. It owns the visual language, the interaction
kit, and the wiring of any rendering engine a document needs. A consuming skill
owns content: which material appears and what it means.

**The boundary,** stated as a rule and pinned with the borderline cases that
prompted it:

- Base owns **how it looks and how the engine is wired**: component CSS, the
  progressive-enhancement kit, a diagram engine's *palette hook* (so diagrams
  inherit the document's colors), and the escaping/validity rules a renderer
  needs to not break.
- The consumer owns **what it means**: which diffs to show and the narrative
  around them, a domain-specific semantic axis (e.g. explain-diff's risk axis),
  and any component that encodes that consumer's domain.
- Borderline rulings: mermaid **palette hook → base**; the **meaning** of a
  risk/change axis → **consumer**; the diff2html presentation CSS (`.diff-source`
  / `.diff-render` tweaks) → **base** (it is presentation of a base-owned
  component, not content).

**Promotion criterion** (the operational form of the boundary — decides where a
component lives): a UI component belongs in **base** when it is a *generic
document-reading pattern* reusable across document types; it stays in the
**consumer** when it encodes *that consumer's domain*.

## Decision 2 — three-tier component model, core + opt-in packaging

This is the central design judgement. Replace "copy two files verbatim" with a
catalog organised on a **cost axis**, because the only place a real opt-in
mechanism earns its keep is where inclusion has a cost (a network-loaded engine).

| Tier | What | Cost | "Opt-in" means |
|---|---|---|---|
| **0 — Foundation** | typography, layout, tables, the two-layer color model | always, zero | none — applied automatically via element selectors |
| **1 — UI components + PE/navigation** | pure-CSS components (callout, chip, pullquote, key-points, kicker, lede, card grid, badge, aside …) **and** the offline PE kit (theme toggle, reading progress, TOC / sidebar index, back-to-top) | bundled, offline, no third party | just use the class / author the semantic HTML the kit wires from |
| **2 — Heavy components** | third-party rendering engines: diff, diagram, math | a network-loaded engine + integration knowledge | a real bundle, copied only when used, so an unused engine is never loaded |

Key consequence: **the "don't load what you don't use" machinery is needed only
for Tier 2.** Tier 0/1 are offline and effectively free, so they need no
gating — a consumer that renders no diffs simply never touches the `diff`
component and never ships diff2html. This directly satisfies the original
requirement ("a consumer that emits no diffs does not carry diff2html").

Tier 1 is the **lightweight, document-focused design system** — the thing base is
becoming, not just a foundation with heavy add-ons bolted on. It is grown by
promoting generic patterns out of consumers (per the Decision 1 criterion).

### Packaging & layout

- **Core (always copied):** `assets/base.css` + `assets/base.js`. Foundation +
  Tier 1 UI/PE. Offline, no network dependency. Unchanged in substance.
- **Opt-in components (Tier 2):** one self-contained bundle per component under
  `assets/components/<name>/`, each carrying its own asset file(s) and an
  `include.md` that documents exactly how a consumer wires it in — the CDN
  `<link>`/`<script>` (version-pinned), the init/render script, and the
  renderer's escaping/validity rules. A consuming skill's generation step:
  copy the core always; then for each needed component, copy that component's
  file(s) and follow its `include.md`.
- Consumers delegate by reference ("to render diffs, include the `diff`
  component per understanding-html-docs") instead of re-deriving the integration.

## Decision 3 — third-party distribution: CDN by default, vendor as opt-in

Decided **per component, on the base side**:

- Heavy rendering engines (diff2html, mermaid) default to **CDN**, version-pinned
  and documented in the component's `include.md`. **Vendoring** (shipping the
  engine locally) is the opt-in exception for a consumer that needs full offline
  rendering.
- The base substrate (`base.css` / `base.js`) is **always vendored / offline**.

**Corrected "works offline" wording** (the base previously implied the whole
output always works offline): the **substrate is offline** — typography, color,
layout, and the PE kit render with no network. **Tier 2 components assume an
online viewer** — only the diff/diagram/math *rendering* needs the network. This
is now stated precisely rather than as an absolute.

## Sidebar index (navigation layout mode)

Requested during design and accepted as a first-class Tier 1 navigation feature.
The PE kit already builds a table of contents with scroll-spy, but only as a
bottom-sliding overlay panel triggered by a floating `☰` button (`base.js`). Add
a **responsive layout mode**: on wide viewports render the same TOC data as a
**persistent sidebar index** column alongside the article (docs-site style);
collapse to the existing overlay panel on narrow viewports. The TOC-building and
scroll-spy logic is shared — only presentation/layout branches. It stays in the
offline substrate (no third party), so it is Tier 1, not Tier 2.

## Follow-up work (implementation, out of scope here)

Carved into separate issues in the same project so this ADR closes on the
decision alone:

1. **(impl) Extract the `diff` and `diagram` Tier 2 components into base.** Move
   diff2html + mermaid integration (CSS tweaks, CDN snippet, mermaid init +
   palette hook, escaping rules) from `understanding-explain-diff` into
   `assets/components/diff/` and `assets/components/diagram/` with `include.md`
   each; reduce explain-diff to content-only, delegating to those components.
2. **(impl) Grow the Tier 1 UI catalog** by promoting generic document-UI
   patterns into `base.css` per the Decision 1 criterion (candidates:
   key-points box, kicker, lede, card / card-grid, badge, aside), leaving
   consumer-domain components in place (pdf-studio's player, chapnav, index
   filter; explain-diff's risk axis).
3. **(impl) Add the sidebar-index layout mode** to `base.css` / `base.js`.

Each follow-up is a normal PR-sized deliverable and is verified in its own right.

## Rejected alternatives

- **Adopt an external CSS framework (Tailwind, Pico, etc.).** Rejected: the base
  is deliberately a self-contained, copy-a-file substrate with a bespoke
  two-layer color model; a framework would fight the "no build step, agent copies
  files" model and dilute the color semantics.
- **A build/manifest step that assembles the chosen components.** Rejected: this
  repo's runtime floor is shell + jq and its distribution model is "an agent
  copies files by instruction"; a build tool is disproportionate. The
  `core + per-component bundle + include.md` model achieves opt-in with plain
  file copies.
- **Treat every component (including small UI) as a gated opt-in bundle.**
  Rejected: pure-CSS UI has no marginal cost, so gating it adds machinery for no
  benefit. Only Tier 2's network cost justifies the opt-in mechanism.
- **Keep third-party integration knowledge in each consumer.** Rejected: that is
  the status quo whose re-derivation and drift (the pdf-studio "no external URLs"
  episode) motivated this work.

## Concrete files (semi-stable)

- Base skill: `skills/understanding/understanding-html-docs/SKILL.md`,
  `.../assets/base.css`, `.../assets/base.js`; new `.../assets/components/<name>/`.
- Consumer with the current implicit pattern:
  `skills/understanding/understanding-explain-diff/SKILL.md` (diff2html CDN +
  mermaid init in `<head>`; "assumes an online viewer" note).
- pdf-studio context layer that already layers on the base:
  `skills/pdf-studio/pdf-studio-site-base/` (`assets/pdf-studio.css` / `.js`).
