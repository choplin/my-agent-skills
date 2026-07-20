---
name: discuss-toolkit-focus
description: This skill should be used when a complex discussion (design, architecture, planning) has surfaced multiple discussion points (論点) at once, to course-correct into handling them one at a time — first summarize every point as a short labeled list, then present and resolve ONE point in detail before opening the next. Primary trigger is explicit user invocation ("/focus", "one at a time", "one point at a time", "一つずつ", "論点を整理して", "一気に出さないで", "全部並べないで") as a correction after the AI dumped several points; the AI should ALSO apply it autonomously when it is about to present two or more discussion points. Should NOT trigger for a single clear point (just answer it), for unclear intent that needs clarification first (use dig), or for a quick A-vs-B decision with clear context (use quick-chat).
user-invocable: true
---

# focus - One Discussion Point at a Time

Keep a complex discussion navigable by refusing to present many discussion
points at once. Summarize the whole landscape as a list, then drill into one
point at a time.

## Why This Skill Exists

In high-abstraction discussions (design, architecture, planning), the AI tends
to surface every open point it notices and throw them all at the user in a
single burst. The user cannot engage with all of them at once — the discussion
becomes impossible to follow and forward progress stalls. This skill enforces
the discipline of one point at a time so each point gets real attention and
gets resolved before the next opens.

**Definition — "discussion point" (論点)**: a single open question, decision,
or trade-off that needs the user's input to move forward. Two facets of the
*same* decision are one point; two independent decisions are two points.

## Invocation

### 1. Explicit user invocation (primary)

The user calls `/focus` (or says "一つずつ", "論点を整理して", "一気に出さないで")
— usually as a **course-correction** right after the AI presented several
points at once. Treat it as: "stop, give me the map, then take these one at a
time."

### 2. AI autonomous application (secondary)

Before presenting your reply, check: am I about to raise **two or more**
discussion points? If yes, apply this skill's procedure instead of dumping them.
Prevent the burst rather than waiting to be corrected.

Do not over-fire: a single point, a clarification interview (that is `dig`), or
a quick A-vs-B with clear context (that is `quick-chat`) do not need this.

## Procedure

### Step 1 — Show the whole landscape as a list

Enumerate every open point as a **short labeled list** — one brief label plus a
one-line gloss each. No full detail yet. This gives the user the whole map
without demanding they engage all of it at once.

```
論点は 3 つあります:
1. **認証方式** — セッション or トークンか
2. **エラー時の挙動** — 失敗をどこまでユーザーに見せるか
3. **保存先** — DB か外部ストレージか

まず論点1から詰めます。
```

### Step 2 — Pick which point to open first

- If order matters (one point blocks or reframes another), open the most
  **foundational / blocking** one first, and say why.
- If order is free, let the user choose which to tackle first.

### Step 3 — Present exactly ONE point in detail

For the current point only:
- Restate the point and the context that makes it a real decision.
- Lay out the concrete options / trade-offs.
- Give your recommendation with reasoning (do not hide behind a neutral menu —
  take a position).

If you use a structured question tool (e.g. `AskUserQuestion`), it must cover
**this one point only**, even though the tool can hold several questions.
Multiple facets of the *same* point are fine; a second, distinct point is not.

### Step 4 — Resolve or park, then move on

- Fully **resolve** the current point (user decides/confirms) or explicitly
  **park** it (agree to defer, and note what is still open) before opening the
  next.
- Re-show the remaining list as you advance so the user keeps the map:
  "論点1は解決。残りは 2, 3。次は論点2。"

## Anti-patterns

- **Dumping** — presenting all points with full detail in one message. This is
  the exact behavior this skill exists to stop.
- **Batching distinct points into one question** — one `AskUserQuestion` (or one
  paragraph) that asks about several unrelated decisions at once.
- **Silent term introduction** — opening a point built on a concept you have not
  defined. Define the term first (with one concrete example), then use it.
- **Opening the next point before closing the current one** — leaving a trail of
  half-discussed points.

## Relationship to Other Skills

- **dig** — clarifies *unclear intent* through a structured interview. focus
  assumes intent is clear enough; it manages the *pacing* of an already-framed
  discussion that has many points. Independent skills.
- **quick-chat** — a single fast judgment with clear context. If the discussion
  is really just one A-vs-B, use quick-chat, not focus.

## Success Criteria

- [ ] All open points were shown as a compact labeled list before any detail.
- [ ] Only one point was presented in detail at a time.
- [ ] Each point was resolved or explicitly parked before the next was opened.
- [ ] The remaining-points list was visible as the discussion advanced.
- [ ] No structured question mixed two distinct points in one round.
