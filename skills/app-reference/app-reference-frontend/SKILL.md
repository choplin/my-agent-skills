---
name: app-reference-frontend
description: Use this skill when designing, implementing, or reviewing a web frontend; choosing between server-driven HTML and a client-side application; selecting htmx, CSS frameworks, or UI libraries; or deciding frontend state, rendering, and test boundaries.
user-invocable: false
metadata:
  description-role: documentation
---

# Frontend Apps

## Choose the interaction model

- Preserve an established frontend architecture unless the task requires changing
  it.
- Recommend server-rendered HTML with `htmx` when the server owns authoritative
  state and interactions map naturally to HTTP requests and HTML fragment
  responses.
- Treat `htmx` as a recommendation, not a requirement. Choose another approach
  when the application needs substantial offline or client-owned state, rich
  local editing, graphics-heavy interaction, or latency-sensitive realtime
  behavior. State which requirement drives the alternative.
- Do not introduce a client application framework for isolated interactivity
  that browser APIs or `htmx` can express directly.
- Give each DOM subtree one rendering owner. Do not let `htmx` and a client-side
  renderer both mutate the same subtree.

## Use htmx coherently

- Return HTML fragments from htmx endpoints. Do not create a parallel JSON API
  solely to reconstruct the same markup in the browser.
- Keep business state and validation authoritative on the server. Keep only
  transient presentation state in the browser unless the selected architecture
  explicitly requires otherwise.
- Make each fragment response include the complete state of its swap target,
  including validation and error states.

## Choose styling

- Recommend Tailwind CSS with `daisyUI` for general application interfaces where
  its components and themes reduce custom design work.
- Treat `daisyUI` as a recommendation, not a requirement. Choose another system
  when the product has an established design system, a strongly bespoke visual
  identity, or constraints that make Tailwind's build pipeline unsuitable.
- Prefer daisyUI component classes and theme tokens before accumulating
  per-instance utility overrides.

## Test the selected boundary

- Test server-rendered pages and fragments at the HTTP or handler boundary.
- Use browser tests for behavior that depends on htmx swaps, browser state, or
  interaction across multiple requests.
