---
name: lang-reference-scala
description: >-
  Scala conventions for this codebase: coding style, project layout, and
  tooling preferences.
user-invocable: false
metadata:
  description-role: documentation
---

# Scala

- Use `sbt` or `mill` for build management
- Use `ScalaTest` or `munit` for testing
- Use `Scalafmt` for code formatting
- Use `scalafix` and `wartremover` for linting
- Follow Scala Style Guide
- Prefer immutable data structures
- Use for-comprehensions over nested maps/flatMaps
- Leverage type system and avoid runtime exceptions
