# ai-council

Skills for putting a question to several AI systems at once and reading their
answers against each other, so a decision rests on more than one model's blind
spots.

## Skills

| Skill | Description |
|-------|-------------|
| `ai-council` | Poll several model families on one question, blind, and report them side by side |
| `adversarial-panel` | Multi-round adversarial mutual review: panelists critique each other and the facilitator adjudicates |
| `codex-cli` | The calls and constraints that apply when an agent drives Codex as a panelist |
| `fugu-cli` | What differs when the panelist is Fugu (Sakana AI) via `codex-fugu` |

`ai-council` is the one-shot form: every panelist answers independently and
never sees another's answer, which is what makes agreement between them mean
something. `adversarial-panel` is the contested form: panelists read each
other's answers and attack them across rounds. Reach for it when the question is
high-stakes enough that a single blind pass would leave the disagreement
unexamined.

`codex-cli` and `fugu-cli` are applied by the two above when a panelist is
CLI-backed. They are not invoked on their own.

## Who sits on the panel

Nothing here fixes a roster. `ai-council` asks which systems to seat before
consulting any of them, because a list written into a skill file goes stale on a
rename, an added model family, or a machine where one of them is not installed —
and the failure is quiet, since the report still reads like a full council.

Seat one panelist per **model family**; a second voice from a family already
seated adds cost, not evidence. The usual candidates are the host model itself
and whichever CLI-backed models are installed.

## Prerequisites

Only needed for the CLI-backed panelists. A council can convene without them, on
a smaller panel.

**Codex (OpenAI)**

```bash
npm install -g @openai/codex
codex login          # or: export OPENAI_API_KEY="..."
```

**Fugu (Sakana AI)** runs through the Codex interface. Install its setup
separately and verify with `codex-fugu --status`.

**Host command sandbox.** Codex reaches for the macOS SystemConfiguration API,
which some agent hosts block by default — the call then fails before it reaches
the network ([sandbox-runtime#30](https://github.com/anthropic-experimental/sandbox-runtime/issues/30)).
If your host sandboxes commands, `codex` and `codex-fugu` need an exemption. The
`codex-cli` skill carries the detail an agent needs at call time.

## Safety

**The panel reads; it never writes.** Consultations run `codex exec` under
`-s read-only`, so Codex cannot modify the working tree. (`codex review` takes
no sandbox flag — it is a review path, not an agent loop.) A panelist that edits
files has exceeded its mandate, and the skills say so explicitly.

**Answers stay attributed.** Each opinion is labeled with the model family and
vendor that produced it. Two panelists' words are never merged, and the host
model's answer is never presented as a vendor's.

**Named files leave the machine.** Codex reads the paths it is given and sends
them, with the prompt, to a third-party service. Before pointing a panelist at
anything that may hold credentials, keys, or customer data, confirm with the
user.

## Installation

Install these skills through the repository's `skills add` workflow documented
in the root README.
