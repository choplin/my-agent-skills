---
name: discuss-toolkit-name-project
description: This skill should be used when the user needs help naming a project, product, or service. Triggers on phrases like "name this project", "what should I call", "suggest a name", "find a good name", or when discussing project/product naming. Should NOT trigger for renaming variables or files in code (that's refactoring).
allowed-tools: WebSearch
---

# Name Project

Help find the perfect name for a project by first understanding intent through dig skill, then generating and validating candidates.

## Process

### 1. Intent Clarification (via dig skill)

Before generating names, invoke the dig skill to understand:

- **Core value**: What problem does the project solve? What's its primary purpose?
- **Target audience**: Who will use this? What do they care about?
- **Naming priorities**: What matters more?
  - Memorable vs Descriptive
  - Short vs Unique
  - Professional vs Playful
  - Domain availability vs Perfect fit
- **Constraints**: Any words to avoid? Industry context? International considerations?

Do NOT proceed to name generation until dig skill confirms user intent is clear.

### 2. Name Generation Strategy

Based on clarified intent:

- **Single word**: Use wordplay, puns, or creative variations to avoid conflicts
- **Two words**: Combine complementary concepts for clarity and uniqueness
- Match naming style to priorities identified in step 1
- Generate 3-5 candidates that align with user's stated criteria

### 3. Conflict Checking

For each candidate:
- Search existing projects, domains, and trademarks
- Check GitHub repositories and package registries
- Verify social media handle availability
- Flag any major naming conflicts

### 4. Candidate Presentation

For each name candidate, provide:

- The underlying concept and wordplay
- How it addresses user's stated priorities from step 1
- Conflict check results
- Availability assessment
- Trade-offs (if any)

## Success Criteria

- [ ] User intent was clarified before generating names
- [ ] Generated names align with user's stated priorities
- [ ] Conflict checking was performed for presented candidates
- [ ] User understands trade-offs of each option
