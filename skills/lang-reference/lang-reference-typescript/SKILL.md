---
name: lang-reference-typescript
description: Use this skill when the user asks about TypeScript coding conventions, best practices, tooling preferences, or needs guidance on TypeScript project setup.
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
