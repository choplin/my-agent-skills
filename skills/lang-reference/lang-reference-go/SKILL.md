---
name: lang-reference-go
description: Use this skill when the user asks about Go coding conventions, best practices, error handling patterns, tooling preferences, or needs guidance on Go project setup.
user-invocable: false
metadata:
  description-role: documentation
---

# Go

## Package Management & Tooling

- Use `go mod` for dependency management
- Use Go 1.24's `go tool` for installing and running development tools
- Use `gofumpts` for code formatting (stricter than gofmt)
- Use `golangci-lint` for comprehensive linting
- Use `go test` with table-driven tests
- Use `testify` for test assertions when needed

## Error Handling

- **NEVER use panic** unless explicitly requested by user
- Define custom error types instead of using `fmt.Errorf`
- Use `errors.As()` and `errors.Is()` for error checking
- Always return errors instead of panicking
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

- Use goroutines and channels idiomatically
- Avoid goroutine leaks with proper cancellation
- Benchmark performance-critical code
- Write idiomatic Go code, not translations from other languages
