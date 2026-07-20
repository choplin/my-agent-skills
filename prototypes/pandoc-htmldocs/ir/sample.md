---
title: Components — pandoc generator demo
site-name: understanding-html-docs
---

::: {.kicker}
COMPONENTS
:::

# Components

::: {.lede}
The parts you opt into by **naming a meaning**, never a look. The intermediate
representation carries only the meaning; the generator binds it to presentation.
:::

## Callout — a message box that means something

The variant fixes the meaning, and the meaning fixes the color and the icon.
The author writes `variant=danger` because the thing is dangerous — red is the
consequence, not the instruction.

::: {.callout}
General supporting information. The bare callout is the note (information) variant.
:::

::: {.callout variant=tip}
Advice worth following. Prefer the semantic name over reaching for a color.
:::

::: {.callout variant=warn}
Something to be careful about — a caveat that can bite if ignored.
:::

::: {.callout variant=danger}
A hazard. This deletes data and cannot be undone.
:::

::: {.callout variant=key}
[The key insight:]{.label} a component binds a meaning to a presentation, so the
generator can be deterministic while the meaning stays the author's to choose.
:::

## Keypoints — what a section boils down to

::: {.keypoints}
### What this boils down to

- The AI writes a semantic IR, not HTML.
- A pandoc template owns 100% of the structural boilerplate.
- A Lua filter binds each meaning to its markup — and rejects unknown variants.
:::
