---
name: pr-description
description: Use this skill when writing or revising the description/body of a non-trivial pull request, so reviewers can follow the purpose, design, and where each design choice lands in the code. Triggers on phrases like "PRの説明を書いて", "PR本文を書いて", "PR descriptionを書いて", "大きいPRのまとめ", "write a PR description", "draft the PR body", or when the draft-pr skill delegates body authoring for a large change.
allowed-tools: Bash(git *), Bash(gh *), Read, Glob, Grep
user-invocable: true
---

# Writing a Review-Friendly PR Description

The goal is not to list what changed — `git diff` already does that. The goal is to give a reviewer the **shortest path to a confident review**: why this PR exists, what approach was chosen, and where in the code each piece of that approach lives.

## Language

- Write the PR title and body in **English** by default
- Only switch language if the user explicitly requests it

## When to use this skill

Use this skill for PRs that are *non-trivial* to review. Heuristics — any one is enough:

- Touches **3 or more files** with meaningful logic changes (excluding generated files, lockfiles, snapshots, mass renames)
- Crosses **2 or more modules / layers** (e.g. API + DB, frontend + backend)
- Introduces or removes an **abstraction, public interface, or data shape**
- Encodes a **design choice with viable alternatives** that a reviewer would reasonably ask about
- Has a **non-obvious motivation** (incident, compliance, perf regression, deprecation)

For small, single-concern PRs (typo fix, dependency bump, one-line bugfix, isolated test), a Summary of 1–3 bullets is enough — **do not invoke this skill**.

If unsure, ask the user. Do not pad a small PR into a long description.

## Process

### 1. Gather the raw material

Before writing anything, collect:

```bash
# Branch state vs. base
git log --oneline <base>..HEAD
git diff --stat <base>..HEAD
git diff <base>..HEAD            # only the parts you actually need
```

Also read, if present:

- Linked spec / plan / design doc (look under `.claude/dev-workflow/`, `docs/`, issue links in commits)
- Linked issue / ticket (commit trailers, branch name)
- The repo's PR template (see §4)

If a commit references an incident, ticket, or ADR, **open it** and capture the motivation in your own words. Do not just link and hope.

### 2. Build the three load-bearing answers

Before drafting, write one or two sentences for each of these. If you cannot, you do not yet understand the PR well enough to describe it.

| Question | What the reviewer needs |
|----------|-------------------------|
| **Why** does this PR exist? | The problem, the trigger, the constraint. Not "to add X" — *why* X is needed now. |
| **How** was it solved (the design)? | The approach, the key decisions, what was rejected and why. |
| **Where** does each design choice live in the diff? | The mapping from idea → file/module. This is the part reviewers cannot recover from `git diff`. |

These three become the spine of the description.

### 3. Description structure

When no template applies (template handling — §4), use this structure. Drop sections that genuinely have nothing to say; do not pad.

```markdown
## Why

<1–3 short paragraphs. State the problem and the trigger. Link issue/incident/spec if any.
If there is a deadline, constraint, or external driver, name it.>

## Approach

<The design in prose, not bullets-of-files. Cover:
 - The shape of the solution (the idea, in 2–4 sentences)
 - Key decisions and the alternatives you considered/rejected, with the reason
 - Trade-offs the reviewer should evaluate (perf, complexity, migration risk, lock-in)
 - Anything intentionally out of scope>

## How it lands in the code

<A short map from design → code. One line per piece. Examples:
 - `internal/auth/session.go` — new token storage interface; replaces in-memory map
 - `internal/auth/session_redis.go` — Redis-backed implementation
 - `cmd/api/main.go` — wires the Redis client; reads `SESSION_BACKEND` env
 - `migrations/0042_*.sql` — adds the `sessions` table (Postgres fallback path)

Order entries so the reviewer can read the diff top-down and the explanation stays linear.
Call out files that look scary but are mechanical (renames, generated, formatting).>

## Suggested review order

<Optional but valuable for PRs >~300 lines. Example:
 1. `session.go` — interface contract
 2. `session_redis.go` — main implementation
 3. `main.go` — wiring
 4. tests
 5. migrations & generated files (skim only)>

## Verification

<How you convinced yourself it works. Be concrete:
 - Unit/integration tests added (and what they cover, not just "added tests")
 - Manual steps run (commands, URLs, fixtures)
 - What you did NOT test, and why that is acceptable>

## Risks & follow-ups

<Optional. Known limitations, deferred work, feature flags, rollout plan, rollback plan.
If a flag/gate is introduced, name the key and the ramp/cleanup expectation.>
```

### 4. Repository PR template

If the repository has a PR template (`.github/pull_request_template.md` or variants — same lookup as `draft-pr`):

- **Use the template's section layout as-is.** Do not delete, reorder, or rename its sections.
- Fill each section with content shaped by §2 and the guidance in §3. Examples:
  - Template's "Summary" section → write the **Why + one-sentence Approach**, not a bullet list of changed files.
  - Template's "Changes" / "What changed" → write the **design → code mapping** from §3, not a regurgitation of the diff.
  - Template's "Test Plan" / "How to verify" → write the **Verification** content from §3.
- If a template section has no relevant content, write `N/A` and keep it.
- If a load-bearing piece (e.g. design rationale) has no obvious home in the template, append a `## Design notes` section at the end rather than dropping it.

### 5. Title

- Conventional commit format: `type(scope): description` (English by default)
- The title is a headline, not a summary — keep under ~70 chars
- Detail belongs in the body, never in the title

### 6. Self-check before posting

Re-read the draft from a reviewer's perspective who has never seen the branch. Verify:

- [ ] Reading **only the Why** tells the reviewer whether they should care about this PR.
- [ ] Reading **only the Approach** lets them predict what the diff broadly looks like.
- [ ] The **design → code map** lets them open the right file first.
- [ ] No section restates `git diff` (file lists, hunk counts, "renamed X to Y in 12 places") without adding meaning.
- [ ] Decisions are stated with their **reason**, not just the outcome.
- [ ] Nothing claims work that was not actually done (tests "added" must exist; "tested manually" must be true).
- [ ] No conversational filler ("As discussed earlier…", "Per the previous session…") — the PR must stand alone.

## Anti-patterns to avoid

- **Commit log dump.** Reviewers can read `git log`. Copy-pasting commit subjects as the description adds nothing.
- **File-by-file walkthrough as the whole description.** A code map is useful *after* the design is explained, not in place of it.
- **"This PR adds X" with no Why.** "Adds Redis-backed sessions" is a title, not a description.
- **Vague approach.** "Refactored auth for clarity" — refactored *how*, and what does clarity mean here?
- **Hidden trade-offs.** If you chose A over B, say so. Reviewers will ask anyway; pre-empt it.
- **Padding small PRs.** A 5-line bugfix does not need a Design section. Use the §1 heuristics — when in doubt, stay short.
- **Tense / scope slip.** Describe what *this PR* does, not the broader initiative. Link out for the initiative.

## Interaction with other skills

- `draft-pr` handles **push + `gh pr create --draft`**. When the change is large (per §1 heuristics), `draft-pr` should call this skill to author the body before creating the PR.
- For revising an existing PR's body, run this skill against the current branch and update via `gh pr edit --body-file <file>` (or `--body`). Confirm with the user before overwriting an existing description that has reviewer comments referencing it.
