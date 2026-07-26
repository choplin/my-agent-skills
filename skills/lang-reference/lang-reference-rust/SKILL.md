---
name: lang-reference-rust
description: Use this skill when writing, reviewing, debugging, or refactoring Rust; when the user asks about Rust conventions, ownership, error handling, unsafe code, testing, Cargo tooling, or project setup; or when changes to Cargo.toml, crates, workspaces, or Rust APIs are required.
---

# Rust

## Crate boundaries

- Start with one package and organize it with modules. Do not create a workspace
  member merely because a module is large or represents a distinct concept.
- Keep library and binary targets in the same package when they share one
  dependency and release boundary.
- Split out a crate only when it needs independent publication or reuse, a
  different crate type or target, deliberate dependency or feature isolation,
  or a stable API boundary that must be enforced across packages.
- Before adding a workspace member, state which boundary requires a crate and
  why a module cannot enforce it. Account for the added manifests, dependency
  wiring, feature coordination, and CI surface.

## Defaults

- Use Rust 2024 for new projects unless compatibility requirements demand an
  older edition. Respect the repository's edition and MSRV in existing projects.
- Declare a supported MSRV with `rust-version` and check dependency compatibility
  against it.
- Run `cargo clippy --all-targets --all-features -- -D warnings` when all
  features can be enabled together; otherwise check each supported feature
  combination instead.
- Do not add `clone()`, allocation, `Box`, `Rc`, or `Arc` merely to silence
  ownership errors. Decide the intended ownership and sharing model first.
- Prefer enums and exhaustive matching for closed state spaces. Avoid Boolean
  parameters when named states make the call clearer.
- Avoid `unwrap`, `expect`, `panic!`, `todo!`, and unchecked indexing in
  recoverable production paths. Permit them in tests or proven invariants when
  the reason is local and evident.
- Do not discard errors with empty matches, `let _ =`, or unconditional fallback
  values unless ignoring the failure is explicitly part of the behavior.
- Keep each `unsafe` block minimal, document the safety invariants, and expose a
  safe API only after validating those invariants at its boundary.
- Do not hold a blocking lock guard across `.await`. Minimize other guards and
  mutable borrows that remain live across suspension points.
- Avoid unbounded task, thread, channel, or buffer growth.

## Tests

- Keep module-scoped unit tests beside the implementation in
  `#[cfg(test)] mod tests`. Test the module's behavior rather than private
  helpers in isolation.
- Keep unit tests inline by default. If a test module must be split into another
  file, give it an explicit source-related name: declare
  `#[cfg(test)] #[path = "foo_tests.rs"] mod tests;` in `src/foo.rs` and place
  the tests in `src/foo_tests.rs`. Retain access through `super`.
- Put tests in the top-level `tests/` directory only when they exercise the
  package through its public API or verify behavior across module boundaries.
  Remember that each integration test file is compiled as a separate crate.
- Do not mirror the `src/` tree under `tests/` or move tests there merely to
  shorten production files.
- For a binary package, expose testable behavior through the package's library
  target when integration tests need it; do not create another workspace member.

## Libraries

- Use `sqlx` for relational database access. Prefer its compile-time checked
  query macros when the schema can be made available to local development and CI.
- Use `tokio` when an asynchronous runtime is required.
- Use `reqwest` for HTTP clients.
- Use `serde` for serialization and deserialization.
- Use `thiserror` for specific, inspectable library and domain errors. Use
  `anyhow` for contextual error reporting at application boundaries.
- Use `clap` for command-line argument parsing.
- Use `log` as the lightweight logging facade. Let the executable choose and
  initialize the concrete logger implementation.
