---
name: repository-context-base
description: >-
  The shared placement and lifecycle model for context produced while working
  in a repository: canonical user and developer documentation, AGENTS.md,
  CHANGELOG.md, self-contained tracker records, work-tagged tentative knowledge
  notes, and durable local knowledge. Applies whenever
  repository-context workflows decide which file or store should own
  information or distill working context when work closes.
---

# Repository Context Base

Apply this model before another `repository-context-*` skill chooses or changes
a durable artifact. This skill owns the placement and lifecycle model; caller
skills own the content and mechanics of their document.

## Precedence

Apply rules in this order:

1. explicit repository instructions;
2. established repository and organization conventions;
3. the existing canonical artifact for the subject;
4. this skill's defaults.

Use these defaults only for gaps. Do not replace a familiar existing structure
with the names below merely to standardize it.

## Placement axes

Classify information before choosing its home:

| Axis | Question |
|---|---|
| Reader | Is this for product users, repository developers, agents working in the repository, or only the user and their agents? |
| Certainty | Is it tentative or established? |
| Lifetime | Does it live for one finite work item, track the current product or implementation, or remain useful long term? |
| Purpose | Does it help someone use the product, understand the codebase, perform a change, or preserve knowledge? |
| Mode | Does it explain what exists and why, or prescribe what someone must do? |

The last distinction separates explanatory architecture from operational rules:
describe the current dependency direction and its rationale in the Architecture
Guide; put an instruction an agent must obey in `AGENTS.md`, linking to the
explanation when useful.

## Destinations

| Destination | Owns | Default policy |
|---|---|---|
| Root `README.md` | The product's user-facing entrance: what it is, why it matters, and the shortest path to first success | Keep it focused and route readers to the documentation site for detail. Apply `repository-context-readme` for creation or substantial revision. |
| Documentation site source | Detailed user documentation after first success | Introduce it when the README can no longer carry the detail clearly. Keep its source in the same repository by default, follow the site's established layout, and avoid prescribing a directory name here. |
| Developer documentation (`docs/` by default) | The context repository developers need to understand, implement, verify, and safely change the product | Keep it distinct from product-user documentation. Give it one overview that establishes the mental model, then link to independently useful detail rather than turning the overview into an exhaustive reference. Follow an existing developer-documentation location when the repository has one. |
| `docs/architecture.md` | The current codebase structure, concepts, ownership, relationships, design philosophy, and the reasons the present architecture takes its shape | Keep it explanatory rather than imperative. Apply `repository-context-codebase`; follow an existing architecture entry point when the repository already has one. |
| `docs/decision-log.md` | A chronological index of design decisions: what was decided or changed, when, and what current document owns the resulting rule | Keep entries concise and link to the canonical current design document and relevant tracker or change when useful. Use it to reveal how the design accumulated, not as the source of current design truth or as a general work diary. Follow an existing decision-log location and format when present. |
| `AGENTS.md` | Stable instructions agents must follow while working in the repository | Keep actionable rules, constraints, required checks, and prohibitions here. Do not use it as the codebase explanation. |
| `CHANGELOG.md` | User-visible release outcomes | Maintain it as a near-default repository document. Follow the repository's existing changelog convention; otherwise use Keep a Changelog categories and record final outcomes rather than work narration. |
| ADR | The context, alternatives, and outcome of a design decision whose history has clear shared value | Do not introduce ADRs from the start by default. Add one only when preserving the decision itself is clearly worth its maintenance cost, and follow the repository's chosen ADR location and format. |
| Work tracker | All context a fresh executor needs to carry one finite work item from open to close, plus its progress and completion record | Keep the work self-contained even when this duplicates canonical context elsewhere. The duplication serves execution; it does not replace current repository documentation. |
| Tentative durable knowledge | Discussion, hypotheses, investigation paths, interim findings, and provisional conclusions from one sequence of work | Group the sequence with a temporary work tag and distill it when that work closes. |
| Durable local knowledge | Long-lived knowledge useful to the user or their agents but not valuable enough to share with product users or repository developers | Keep local research and history here only after the shared-value decision below. |

Other files and document types are outside this default set. Honor them when an
existing repository convention uses them, but do not introduce them from this
base.

Within canonical repository documentation, give each settled claim one
authoritative home. Other documents may summarize it at the depth their readers
need, but should link to that home instead of reproducing its full detail. This
does not prohibit deliberate execution-context duplication in a work tracker.

## Tentative work tags

Tag every tentative durable note from the same finite sequence of work with the
same `work-<stable-identifier>` tag so the selected provider's distillation
operation can identify the cohort later.

- When the work has a tracker Issue, normalize its provider and complete locator
  into `work-<provider>-<locator>`.
- Without an Issue, choose a concise stable slug for the work:
  `work-repository-context-design`.

The work tag is a temporary cohort selector, not a maturity state or a reserved
provider axis. Keep ordinary topic metadata and links according to the selected
provider. Delegate note access to `workflow-adapter-markdown` and reworking to
the provider's distillation operation; do not reproduce their mechanics here.

## Distill at work completion

Select the tentative cohort by its work tag, then decide each useful outcome in
this order:

1. **Shared value** — if product users or repository developers should know it,
   put the verified result in the appropriate repository destination above.
2. **Local long-term value** — if it lacks shared value but will help the user
   or their agents later, distill it into durable local knowledge.
3. **No continuing value** — do not retain it merely because it was captured.

Shared value includes user guidance and limitations, user-visible changes,
current architecture and its rationale, agent-facing rules, and design history
that has earned an ADR. Do not promote an unverified conclusion into current
repository documentation; leave it tentative until it can be resolved.

Remove the work tag from every note whose distillation is complete, including a
note being archived. Leave it only on unresolved notes that remain tentative.
The sequence is fully distilled when no note retains its work tag.

## Family ownership

- `repository-context-readme` owns the main product README and its reader
  journey.
- `repository-context-codebase` owns the living Architecture Guide.
- `repository-context-pen-design` owns editable visual design after a calling
  documentation workflow fixes the audience, message, evidence, and placement.

If a required sibling, workflow adapter, or provider operation is unavailable,
stop before changing its canonical artifact rather than reconstructing its
workflow here.
