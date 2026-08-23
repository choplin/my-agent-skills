# AI review rounds

Use this procedure when `code-review-session-import-ai` obtains or imports AI
findings. It preserves the provenance of each run without putting reviewer-specific
bookkeeping in `review.md`.

## Ledger

Keep `{review_dir}/sources/ai.json` in this shape:

```json
{
  "rounds": {
    "1": {
      "reviewer": "quick-code-review",
      "mode": "full",
      "scope": "current branch diff",
      "base_sha": null,
      "head_sha": "0123456789abcdef",
      "target_fingerprint": "sha256:123456",
      "context_fingerprint": "sha256:abcdef",
      "previous_round": null,
      "status": "completed",
      "reason": null,
      "new_items": [1, 2],
      "matched_items": []
    }
  },
  "items": {
    "1": {
      "round": "1",
      "location": "src/example.ts:42",
      "severity": "major",
      "confidence": "high"
    }
  }
}
```

Use the next positive integer key for every attempted round. Do not reuse keys.
Allowed values are:

- `mode`: `full`, `incremental`, `provided-findings`, or `skipped`;
- `status`: `running`, `completed`, `failed`, or `skipped`.

Record the exact scope description. Record `base_sha` and `head_sha` only when
they can be resolved reliably; use `null` rather than guessing. These revision
anchors do not fully identify a dirty working tree. Record a stable
`target_fingerprint` over the exact artifact bytes or diff reviewed, including
untracked files when they are in scope. Use `null` when the exact target cannot
be captured reliably. `new_items` lists items created by the round.
`matched_items` lists existing items that findings from this round duplicated.
Omit an unavailable finding metadata value by using `null`.

When non-code inputs can affect the review, record a stable
`context_fingerprint` over the applicable constraints, direct or imported PR
feedback, and terminal item decisions with their resolutions. Exclude open AI
findings produced by the current round: merely recording a finding must not make
an unchanged rerun look new. Use `null` when a stable fingerprint cannot be
produced. Hash the canonical empty input when no non-code inputs apply; an
unknown fingerprint cannot justify `skipped`.

Items created by a round use `Source: ai:round/{round}` in `review.md`. Legacy
items with `Source: ai` remain valid and are not rewritten.

## Select the mode

Compare the current target with the latest completed round for the same scope
and reviewer:

1. Use `provided-findings` when the caller supplied findings instead of invoking
   a reviewer.
2. Use `full` when the caller explicitly requests it.
3. Use `skipped` when non-null `target_fingerprint` and `context_fingerprint`
   values both match the previous round. Record the round and reason; do not
   invoke the reviewer.
4. Use `incremental` when the previous and current heads differ, the previous
   head is an ancestor of the current head, neither target includes uncommitted
   changes, and the selected reviewer can review the intervening change.
5. Use `full` otherwise, including when there is no comparable completed round,
   a revision or fingerprint is unknown, the target includes changed working-tree
   content, history was rewritten, review context changed, or the reviewer
   requires the whole current artifact.

Do not skip merely because the new diff is small. Never use revision equality
alone to skip: it does not identify working-tree content or a non-code artifact.

## Build iterative context

For `quick-code-review`, or a caller-named reviewer that accepts iterative
context, provide only the history needed for the current judgment:

- the current target and, for an incremental round, the change since the prior
  `head_sha`;
- existing AI items relevant to the changed code, including their status and
  recorded resolution;
- relevant imported PR feedback and replies when available;
- current constraints and non-goals.

Ask the reviewer to distinguish new defects, still-valid open findings, and
regressions of resolved findings. Do not re-report a skipped or postponed item
unless changed evidence invalidates the recorded decision. Dedupe remains a
post-review safeguard; history should prevent needless rediscovery before output.

For `artifact-review`, preserve its independent-pass contract. Prior unresolved
items may inform risk signals and Lens selection, but do not put prior reviewer
findings or preferred conclusions into blind reviewer briefs. Review the current
artifact through the selected Lenses and record the run as `full` unless its own
contract explicitly supports a narrower target.

## Finish the round

Write the round with `status: running` after deciding its mode so attempts are
observable. If a previous round remains `running`, mark it `failed` as an
abandoned attempt before allocating the next ID. Finish the current round as
follows:

- set `completed` after findings have been normalized, deduplicated, and written;
- set `failed` with a concise `reason` when review or ingestion cannot complete;
- set `skipped` with the decision reason when no review is run.

For each new item, persist its location, severity, and confidence in `items`.
This metadata is descriptive and must not change item status or gate the review.
Any future publisher can use it for deterministic line validation, filtering,
and stale-SHA checks without expanding the generic item model.
