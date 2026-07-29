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
- **NEVER use `any`** - use proper type definitions
- Prefer named exports over default exports
- Follow conventional project structure: `src/`, `tests/`, `dist/`
