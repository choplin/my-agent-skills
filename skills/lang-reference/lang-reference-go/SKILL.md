---
name: lang-reference-go
description: >-
  Go conventions for this codebase: error handling patterns, project layout,
  tooling preferences, and idiom.
user-invocable: false
metadata:
  description-role: documentation
---

# Go

## Package Management & Tooling

- Use `go mod` for dependency management
- Use the `go tool` mechanism (Go 1.24 and later) for installing and running development tools
- Use `gofumpt` for code formatting (stricter than gofmt)
- Use `golangci-lint` for comprehensive linting
- Use `go test` with table-driven tests
- Use `testify` for test assertions when needed

## Error Handling

- **Return errors; do not panic** — a panic crosses package boundaries as an
  unrecoverable crash, so it takes the caller's ability to decide away. The
  exception is a failure that makes the program meaningless to continue and
  that only the process owner can see: `main()` or `init()` refusing to start
  on a bad config, and a genuinely impossible state in code the caller cannot
  reach. A library returns an error there instead.
- Define custom error types instead of using `fmt.Errorf`
- Use `errors.As()` and `errors.Is()` for error checking
- Wrap errors with context when propagating

## Code Style & Conventions

- Follow Effective Go and Go Code Review Comments
- Naming conventions:
  - Use MixedCaps or mixedCaps, not underscores
  - Acronyms should be all caps (URL, HTTP, ID)
  - Interface names should end with `-er` suffix when appropriate
- Keep interfaces small and focused
- Prefer composition over inheritance

## Project Structure

- Use standard Go project layout:
  - `/cmd` for main applications
  - `/internal` for private application code
  - `/pkg` for public libraries (optional, use sparingly)
  - Keep `go.mod` at repository root
- One package per directory
- Package names should be lowercase, single-word

## Best Practices

- Avoid goroutine leaks with proper cancellation
- Benchmark performance-critical code
