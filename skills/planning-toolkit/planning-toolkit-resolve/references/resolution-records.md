# Resolution Records

Use these formats for durable findings, decisions, downstream application, and
the final readiness report. Supply complete caller-owned Markdown and let
`workflow-adapter-markdown` preserve provider metadata and conventions.

## Research result

Record the full durable result through `workflow-adapter-markdown` and a
proportional completion summary on the tracker research Issue.

```markdown
# <Research Question>

## Conclusion

<direct answer and confidence>

## Evidence

- <primary source, repository fact, or reproducible experiment>

## Constraints

- <fact downstream work must respect>

## Options Ruled Out

- <option> — <evidence-based reason>

## Implications

- Decision: <affected decision and supplied input>
- Implementation: <affected issue and required change>

## Remaining Uncertainty

- <non-blocking uncertainty, or "None">
```

Do not write a conclusion stronger than the evidence. Keep source URLs and
citations in the durable finding when external research was required.

## AI-owned decision record

```markdown
# Decision: <one binding choice>

## Outcome

<chosen option>

## Inputs

- <completed research finding or established constraint>

## Options Considered

| Option | Consequence | Disposition |
|---|---|---|
| ... | ... | Chosen / Rejected |

## Rationale

<why this best satisfies the Outcome Contract and evidence>

## Downstream Effects

- <implementation issue>: <what must change>

## Scope Effect

None / <local effect> / Planning invalidated because <reason>
```

## Human decision packet

Present only viable choices. Preserve one decision per issue even when several
packets are discussed in one batch.

```markdown
## Decision: <question>

Why it blocks implementation:
<specific consequence>

Evidence:
- ...

| Option | Outcome consequence | Reversal cost | Risk |
|---|---|---|---|
| A | ... | ... | ... |
| B | ... | ... | ... |

Recommendation:
<option and evidence-based reason>

Decision needed:
<the exact choice the user must make>
```

After the user decides, persist the normal decision record with the user as
authority. Do not leave the chat answer as the only record.

## Tracker completion note

```markdown
## Resolution

Result:
<finding or binding decision>

Evidence / rationale:
<proportional summary>

Durable record:
<durable note locator>

Downstream impact:
- <issue>: <update required or applied>

Deviation from planned approach:
None / <what changed and why>
```

The tracker may contain its own internal Issue references. Do not copy tracker
IDs or URLs into durable Markdown notes.

## Impact application checklist

For each affected implementation issue:

```markdown
- [ ] Completed blocker is named under Inputs
- [ ] What & Why reflects the resolved route
- [ ] Where names current areas or entry points
- [ ] Acceptance is observable and no longer conditional
- [ ] Verification is executable or concretely inspectable
- [ ] Constraints include the binding decision
- [ ] Out of Scope still protects the scope cut
- [ ] Atomic size remains valid
- [ ] Milestone and dependency relations are correct
- [ ] Status is Backlog until self-complete, then Todo
```

## Final readiness report

```markdown
Readiness: READY / READY_AFTER_RESOLUTION / BLOCKED

Research resolved:
- <question> → <conclusion>

Decisions settled:
- <decision> → <outcome> (<AI / human / external authority>)

Implementation graph changes:
- Updated:
- Split:
- Added:
- Canceled:

First unblocked Todo work:
- ...

Remaining blockers:
- None / <blocker, owner, and next action>

Durable records:
- Durable Markdown:
- Tracker Project:

Next route:
- READY → execution may start; hand the named work to the executor
- READY_AFTER_RESOLUTION → continue resolution frontier
- BLOCKED → obtain input or return to planning-toolkit-plan
```
