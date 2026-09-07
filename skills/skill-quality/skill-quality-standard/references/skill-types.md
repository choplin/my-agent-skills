# Skill type lenses

Read this when a skill's value source or primary role is unclear, or when
reviewing the coverage and boundaries of a larger skill library. These lenses
support judgment; they are not required metadata or an exhaustive taxonomy.

## Classify the source of value

Anthropic distinguishes two broad kinds of skills:

- **Capability uplift** helps the model perform something it otherwise cannot do
  or cannot do consistently. Its value should be reconsidered as the base model
  improves.
- **Encoded preference** records a workflow or practice whose individual actions
  the model can already perform. Its value comes from fidelity to the users'
  preferred way of working.

This standard generalizes the second name to **encoded intent** so it also covers
required practices, policies, contracts, and safety constraints. Treat capability
uplift and encoded intent as non-exclusive sources of value, not skill types that
must partition a library.

This distinction is orthogonal to the standard's role lens. Either source may
provide guidance, coordinate a workflow, perform a task, or combine
those roles. Use it to ask why the skill exists before deciding how much control
its content needs.

Source: [Improving skill-creator: Test, measure, and refine Agent Skills](https://claude.com/blog/improving-skill-creator-test-measure-and-refine-agent-skills).

## Use domain categories to inspect a library

After cataloguing its internal skills, Anthropic observed nine useful clusters:

- library and API reference;
- product verification;
- data fetching and analysis;
- business process and team automation;
- code scaffolding and templates;
- code quality and review;
- CI/CD and deployment;
- runbooks;
- infrastructure operations.

These categories describe common subject areas rather than prescribing a skill's
instruction form. Use them to notice library gaps and skills that combine too
many unrelated concerns. Do not require every skill to adopt one category: the
article presents the list as a practical, non-definitive framework.

The same experience report reinforces several classification consequences:

- skills are folders of instructions, scripts, assets, and data, so classify
  their parts rather than treating the Markdown body as the whole capability;
- knowledge-oriented skills should contribute information that changes the
  model's default reasoning;
- reusable instructions should avoid railroading the model and preserve room to
  adapt;
- scripts are valuable when they let the model compose stable operations instead
  of reconstructing boilerplate;
- verification, destructive operations, and external schemas justify stronger
  controls than open-ended analysis or judgment.

Source: [Lessons from building Claude Code: How we use skills](https://claude.com/blog/lessons-from-building-claude-code-how-we-use-skills).
