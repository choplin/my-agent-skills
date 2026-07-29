---
name: app-reference-backend
description: >-
  Conventions for backend applications: choosing an implementation language
  and runtime, deciding whether to split services, and defining database
  integration tests.
user-invocable: false
metadata:
  description-role: documentation
---

# Backend Apps

## Choose the implementation language

- Recommend Rust for a new backend when no stronger ecosystem constraint favors
  another language. Apply `lang-reference-rust` after selecting Rust.
- Treat Rust as a recommendation, not a requirement. Choose another language
  when required SDKs or frameworks, an existing runtime and shared codebase,
  deployment-platform support, operational tooling, or team capability gives it
  a concrete advantage. State that advantage.
- Do not add another backend language solely for local convenience or a small
  reduction in implementation effort.

## Choose deployment boundaries

- Start with one deployable backend and organize it as a modular monolith.
- Split out a service only when it needs an independent deployment, scaling or
  failure boundary, security boundary, or clearly owned data lifecycle.
- Do not create a service merely because a domain concept or module is distinct.
  State why an in-process boundary is insufficient before adding a network
  boundary.

## Test database behavior

- Test SQL, migrations, and transaction behavior against the supported database
  engine rather than replacing database semantics with mocks.
