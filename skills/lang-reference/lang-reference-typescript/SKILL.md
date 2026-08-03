---
name: lang-reference-typescript
description: >-
  TypeScript conventions for this codebase: coding style, project layout, and
  tooling preferences.
user-invocable: false
metadata:
  description-role: documentation
---

# TypeScript

- Use `pnpm` as preferred package manager (over npm/yarn)
- Use `Bun` for CLI tool development
- Use `Vite` as bundler
- Use `Biome` for linting and formatting (over ESLint + Prettier)
- Configure strict TypeScript settings in `tsconfig.json`
- Prefer TypeScript over JavaScript
- **Do not reach for `any`** — it disables checking for every value that flows
  out of it, so one `any` silently un-types the code downstream. When a value
  genuinely arrives untyped (a JSON boundary, a third-party module with no
  types), use `unknown` and narrow it, which keeps the check at the boundary
  where it belongs.
- Prefer named exports over default exports
- Follow conventional project structure: `src/`, `tests/`, `dist/`
