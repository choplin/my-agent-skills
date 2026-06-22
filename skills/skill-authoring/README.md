# skill-authoring

Create high-quality skills that AI can use effectively through deep interview and concrete criteria extraction.

## Problem

Standard skill creation focuses on format and structure. Skills created this way often contain generic advice that AI cannot act on autonomously—they look correct but produce disappointing results.

## Solution

This plugin provides the **Three Principles** for effective skill authoring:

| Principle | Purpose | Key Element |
|-----------|---------|-------------|
| **Why & Concrete Criteria** | AI can make decisions | Specific rules with rationale |
| **Self-Complete** | AI can self-evaluate | Binary success checklist |
| **Clear Triggers** | AI activates correctly | Intent-based with exclusions |

## Components

### Skill: `skill-authoring`

Provides detailed guidance on the three principles. Triggers when you want to understand how to create effective skills.

**Trigger phrases:** "create a high-quality skill", "make skill effective", "skill isn't working", "AI doesn't follow the skill"

### Command: `/skill-authoring:create-skill`

Guided workflow for creating skills:

```
[Interview] → [Summary] → [Approval] → [Generation]
     ↑______________|
      (if rejected)
```

**Usage:**
```
/skill-authoring:create-skill code-review
/skill-authoring:create-skill
```

### Agent: `skill-quality-reviewer`

Evaluates existing skills against the three principles. Use after creating a skill or when a skill isn't producing expected results.

**Triggers automatically** after `/create-skill` or when you ask to review skill quality.

## Installation

Skills are distributed via the [vercel-labs/skills](https://github.com/vercel-labs/skills) CLI:

```bash
# install the skills in this group (skill-authoring + skill-quality-review)
npx skills add <owner>/my-claude-marketplace --skill 'skill-authoring' --skill 'skill-quality-review'
```

The Claude Code subagent that wraps `skill-quality-review` (`skill-quality-reviewer`)
is an agent-specific add-on under `opts/claude/`; install it with:

```bash
scripts/install-opts.sh claude
```

See [docs/skill-first-architecture.md](../../docs/skill-first-architecture.md) for the distribution model.

## Usage Examples

### Create a New Skill

```
/skill-authoring:create-skill

> What problem will this skill solve?
"I need to review PRs for logic errors before they reach production"

> Walk me through a concrete example...
[Interview continues through 4 rounds]

> Does this summary capture your intent?
"Yes, looks good"

[Skill generated with success checklist and clear triggers]
```

### Review an Existing Skill

```
"Can you review my documentation skill for quality?"

[skill-quality-reviewer evaluates against three principles]

# Skill Quality Review: documentation-writer

## Overall Assessment: Needs Improvement

### Principle 1: Why & Concrete Criteria
Score: Weak
- "Write clear documentation" lacks specific criteria
- Recommended: Define what "clear" means (sentence length, structure, etc.)

### Principle 2: Self-Complete
Score: Weak
- No success checklist exists
- Recommended checklist provided...
```

## Relationship with plugin-dev

This plugin **complements** `plugin-dev`:

| Aspect | plugin-dev | skill-authoring |
|--------|-----------|-----------------|
| Focus | Structure & format | Content & quality |
| Checks | File organization, word count | Concrete criteria, checklist |
| Interview | Basic requirements | Deep intent extraction |
| Success | Structural validation | Binary self-evaluation |

**Recommended workflow:**
1. `/skill-authoring:create-skill` → Deep interview and generation
2. `plugin-dev:skill-reviewer` → Structure validation
3. `skill-authoring:skill-quality-reviewer` → Three principles validation

## References

The skill includes detailed reference files:

- `references/interview-framework.md` - Deep interview methodology
- `references/success-criteria-patterns.md` - Checklist templates by domain
- `references/anti-patterns.md` - Common mistakes with fixes

## License

MIT
