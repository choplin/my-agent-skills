---
title: "Skill metadata Schema"
date: 2026-07-29
---

# Skill `metadata` Schema

`metadata` is a free key/value map defined by the [Agent Skills](https://agentskills.io)
specification. This repository uses it as the record of truth for
repository-wide facts about each skill.

Keeping these facts inside the specification, rather than in an agent-specific
frontmatter field, means they survive distribution to any agent. Any
agent-specific field (see [Claude Code fields](#claude-code-fields)) is derived
from `metadata`, never the other way round.

## Rules

- **One key, one repository-wide decision.** A key exists only when a decision
  record defines its values and how to assign them.
- **A key states a fact about the skill it sits in**, and one that cannot be
  computed from another key.

## Keys

| Key | Values | Defined by |
|---|---|---|
| `invocation` | `named` / `autonomous` / `invoked` / `delegated` | [below](#invocation) |

---

## `invocation`

How a skill is started. This decides what the skill's `description` is *for*,
and therefore how it must be written.

### Why it matters

A `description` carries two jobs that pull in opposite directions:

1. **Trigger** — preloaded at startup so the model can decide whether the skill
   applies. Costs context for every skill, on every session.
2. **Documentation** — shown to a user who is choosing a skill by name.

Job 1 is only worth paying for when the model actually has to make that
decision from context. A skill the user reaches by name, or that a caller names
explicitly, needs no trigger at all — and writing one wastes listing budget that
the skills which *do* need a trigger are competing for.

### Values

Two axes: whether the user has a direct entry point, and how the model reaches
the skill.

| Value | User entry | Model reaches it | `description` is |
|---|---|---|---|
| `named` | ✔ | not at all | documentation |
| `autonomous` | ✔ | by discovering it from context | **a trigger** |
| `invoked` | ✔ | because a caller names it | documentation |
| `delegated` | ✘ | because a caller names it | documentation |

**Only `autonomous` descriptions are triggers.** They are the only ones that
need positive trigger phrasing, the only ones competing for listing budget, and
the only ones worth measuring with a trigger eval. Every other value's
description should read as documentation.

The fifth cell — no user entry point, discovered from context — has no members.
If a skill ever needs it, it needs a new value rather than being forced into
`delegated`, because its description would have to work as a trigger.

### Decision procedure

Apply in order. The first rule that matches decides.

**1. Is there a user entry point?**

> Without a calling skill's execution context, does invoking this skill alone
> produce a meaningful result, and is there a real situation where the user
> types `/name`?

**No → `delegated`.** Indicators: the skill defines shared models, schemas, or
resources rather than a procedure; it is one phase of an orchestrator that
always runs before it; its own body says it is not invoked on its own.

**2. Must the model discover it from context?**

Either of these makes it `autonomous`:

- **Standard (規範型)** — the user is asking for something else and this skill
  governs *how* that work is done. If it fails to fire, the model answers anyway
  with its bare ability and the result degrades **silently**.
- **Detector (察知型)** — the situation that should trigger it is one the user
  does not recognize or verbalize.

The question that decides this step is **"if the skill fails to fire, does the
user notice?"** A silent degradation means the model must carry the decision; a
visible miss means the user can simply invoke it by name.

**3. Does a caller name it programmatically?**

> Does another skill's body, `CLAUDE.md`/`AGENTS.md`, or a subagent definition
> instruct the model to run this skill as part of its own procedure?

Only genuine invocation counts:

| Counts | Does not count |
|---|---|
| `delegate to X`, `call X`, `apply the X skill`, `hand off to X`, a routing table row the skill acts on | `propose X`, `offer X`, `Run X to …` printed for the user, `unlike X`, `that is X's job` |

**Yes → `invoked`.**

**4. Otherwise → `named`.**

Step 2 outranks step 3 on purpose: a standard that a caller also names still
needs its trigger, because the caller is not the only path to it.

### Claude Code fields

`disable-model-invocation` and `user-invocable` are Claude Code extensions
derived from `invocation`. They carry less information than the key does —
`autonomous` and `invoked` map to the same frontmatter — which is why the
record of truth is `metadata`.

| `invocation` | Claude Code frontmatter |
|---|---|
| `named` | `disable-model-invocation: true` |
| `autonomous` | *(none — default)* |
| `invoked` | *(none — default)* |
| `delegated` | `user-invocable: false` |

`user-invocable: true` is never written: the default already allows user
invocation, so the field would state nothing.

### The constraint that shapes this

`disable-model-invocation: true` does not merely stop the model from picking a
skill up on its own. Per the [Claude Code docs](https://code.claude.com/docs/en/skills):

> By default, Claude can invoke any skill that doesn't have
> `disable-model-invocation: true` set.

> The `user-invocable` field only controls menu visibility, not Skill tool
> access. Use `disable-model-invocation: true` to block programmatic invocation.

So a `named` skill **cannot be invoked from another skill's body**. Since this
repository shares behavior by delegating to skills by name, that is what forces
step 3 to exist: a skill whose ideal mode is `named` becomes `invoked` the
moment any caller names it.

Two consequences worth stating explicitly:

- **Side effects are not a reason to choose `named`.** `git-helpers-commit` has
  side effects, but `AGENTS.md` requires the model to invoke it for every
  commit. Blocking a risky skill is the job of a `Skill(name)` deny rule in
  permissions, not of the invocation mode.
- **`delegated` does not suppress model invocation.** `user-invocable: false`
  hides the menu entry and nothing else.

### Boundary judgements

**A skill can be `autonomous` and still be user-invocable.** `autonomous` is the
default frontmatter, which leaves both entry points open; only `named` closes
the model's. A description that asks for autonomous application while the skill
is also reachable by name is not a contradiction —
`discuss-toolkit-one-point` is exactly this, and it is `autonomous` by step 2
(detector).

**A heavyweight orchestrator is `named` only until something calls it.**
`exec-plan` and `orchestration-toolkit-execute` take over the session, so a
false positive is expensive and step 2 does not apply — but `linear-start`'s
hand-off table invokes both, so they are `invoked`. The same holds for
`orchestration-toolkit-orchestrate`.

**A `-base` skill is `delegated`, not `autonomous`.** Shared-resource skills are
reached because a caller names them. If one appears to need context discovery,
check whether its description is claiming a role the skill was not meant to
have, before giving it a trigger.
