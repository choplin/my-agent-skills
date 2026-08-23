# `code.security-regression`

## Objective

Find newly reachable security failures introduced or materially worsened by the
code change.

## Required inputs

- the diff and relevant trust boundaries
- authentication, authorization, validation, secret, and dependency contracts
- callers and deployment assumptions needed to establish reachability

## Checks

- Trace untrusted data from entry points to privileged operations and sensitive
  sinks.
- Check authentication and authorization at the operation and object boundary,
  including alternate paths and fallback behavior.
- Inspect parsing, escaping, serialization, path handling, command execution, and
  query construction where inputs cross trust boundaries.
- Find secrets, credentials, sensitive data, or diagnostic output exposed by the
  changed path.
- Check whether dependency or configuration changes weaken a security invariant
  or create an unsafe default.
- Establish the attacker-controlled input and reachable consequence for every
  candidate finding.

## Non-goals

- Do not report speculative hardening without a reachable abuse path.
- Do not demand a security architecture redesign unrelated to the change.
- Do not treat an intentionally accepted and explicitly bounded risk as a defect
  without evidence that the boundary fails.

## Severity guidance

Use blocker for a broadly reachable compromise of authorization, confidentiality,
or integrity. Use major for a practical exploit with material impact and minor
for a tightly bounded exposure that still warrants remediation.
