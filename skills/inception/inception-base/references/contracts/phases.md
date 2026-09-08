# Inception Phase Map

The thinking graph moves through five in-loop phases. The orchestrator estimates
the current phase and proposes each transition; the user approves it. Detailed
methods live only in the corresponding phase skills.

| Phase | `session.phase` | Phase skill | Transition when ready |
| --- | --- | --- | --- |
| 構想 / Framing | `framing` | `inception-framing` | propose `inception-diverge` |
| 発散 / Diverge | `diverge` | `inception-diverge` | propose `inception-structure` |
| 構造化 / Structure | `structure` | `inception-structure` | propose `inception-deepen` |
| 深掘り / Deepen | `deepen` | `inception-deepen` | propose `inception-converge` (or return to `inception-diverge` when new breadth is needed) |
| 収束 / Converge | `converge` | `inception-converge` | after the user confirms done-enough, propose `inception-finalize` |

## Terminal exit: 確定 / Finalize

`inception-finalize` is not a sixth phase. It moves a confirmed footing out of
the transient graph into durable memory, hands concrete actions to the chosen
tracker, and retires the graph. Reopening starts a fresh session or edits the
durable note; it does not resume rendering the retired graph.
