# AI round ledger

`{review_dir}/sources/ai.json` records the provenance of every AI review run,
keeping reviewer-specific bookkeeping out of `review.md`. Every skill that reads
or writes AI rounds conforms to this shape:

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
