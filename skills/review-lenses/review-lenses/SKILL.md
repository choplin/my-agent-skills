---
name: review-lenses
description: >-
  Owns the shared finding policy, Lens selection index, and individual Lens
  definitions used by review workflows. Provides the single source of truth for
  baseline code review and risk-selected artifact review procedures.
user-invocable: false
metadata:
  description-role: documentation
---

# Review Lens resources

This skill is the shared review-policy and Lens library. It does not run a
review, choose a target, assign reviewers, aggregate findings, or return a
verdict. Calling review skills own those workflows.

Resolve every path below relative to this skill's installed directory.

## Common finding policy

Read [references/finding-policy.md](references/finding-policy.md) before running
any Lens. It defines the evidence and actionability threshold, exclusions,
severity meanings, and the boundary between findings, observations, and
residual risk.

## Selecting Lenses

Read [references/lens-index.md](references/lens-index.md) when the caller must
select Lenses from target kind, scope, risk signals, or reviewer budget. The
index owns selection and packing metadata and links every Lens definition.

After selection, read only the linked definition files for the selected Lens
IDs. Do not load definitions for unselected Lenses; keeping those procedures out
of reviewer context is the reason the catalog is split.

## Baseline code review

An ordinary code-change review always applies these four Lenses:

- `code.functional-correctness` —
  `references/lens-code-functional-correctness.md`
- `code.security-regression` —
  `references/lens-code-security-regression.md`
- `code.performance-regression` —
  `references/lens-code-performance-regression.md`
- `code.maintainability-risk` —
  `references/lens-code-maintainability-risk.md`

Bundle them into one reviewer for a quick review. Assign them to separate fresh
reviewers when a rigorous artifact review has enough capacity. Both modes apply
the same `references/finding-policy.md`; presentation and aggregation may differ.

## Resource contract

- `finding-policy.md` decides what qualifies for reporting; Lens files decide
  what to inspect.
- `lens-index.md` is the sole owner of scope, mandatory conditions, triggers,
  effort, packing groups, and Lens-to-file mappings.
- Individual Lens files own objective, required inputs, checks, non-goals, and
  severity guidance. Do not duplicate selection metadata in them.
- A caller-supplied or custom Lens uses the same execution fields and common
  finding policy but remains with its caller unless the index's promotion rule
  is met.

## Success criteria

- [ ] The caller loaded the common finding policy.
- [ ] Selection-based review loaded the index before choosing Lens IDs.
- [ ] Every reviewer received only its assigned Lens definition or an explicitly
      packed compatible set.
- [ ] Baseline code review used all four canonical code Lens files.
- [ ] No caller reconstructed or copied a Lens definition into its own skill.
