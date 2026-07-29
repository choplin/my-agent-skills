---
name: lang-reference-sql
description: Use this skill when writing, reviewing, or refactoring SQL queries and SQL style. Apply it to keep queries structurally formatted, readable, and explicit, including when SQL is extracted into an infrastructure layer.
user-invocable: false
metadata:
  description-role: documentation
---

# SQL

## Query style

- Format queries by structure: list selected columns and place `FROM`, each
  `JOIN`, `WHERE`, each `AND`/`OR` group, and `ORDER BY` on separate logical
  lines.
- Prefer an explicit column list when mapping a result into a row or record.
- Preserve the repository's established SQL dialect, formatter, naming, and
  parameter-binding conventions when they are more specific.
- Keep query text readable enough that joins, predicates, ordering, and selected
  columns can be reviewed independently.
