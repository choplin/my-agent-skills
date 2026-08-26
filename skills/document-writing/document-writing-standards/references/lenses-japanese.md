# Japanese Lenses

Layer: **japanese** (phase 4, alongside expression). These lenses apply only to
documents written in Japanese. Determine that by reading the document.

Findings here are `content_impact: none`. They are the cheapest lenses in the
catalog to run and the easiest to apply, because every rule is mechanical.

---

## `ja.notation`

```yaml
lens: ja.notation
layer: japanese
packing_group: japanese
objective: Find punctuation, emphasis, and markup that violate the notation
  conventions for Japanese technical prose.
checks:
  - Dashes used in Japanese running text or headings.
  - Nakaguro used for coordination.
  - Bold and kagi-kakko used interchangeably.
  - Headings packing two elements around a rule character.
  - Term-definition lists separated by a rule instead of a full-width colon.
  - Code, diffs, logs, and configuration fragments not in code blocks.
```

### Rules

- **No dashes in Japanese running text or headings.** This covers the em dash
  `—`, the horizontal bar `―`, and the doubled 「——」. Rewrite by function:
  - Apposition or insertion (「A——挿入——B」) becomes parentheses（）.
  - Restatement or elaboration (「A——B」) becomes two sentences, or one clause
    joined with a comma.
  - Out of scope: the en dash `–` for ranges, English compounds such as
    `Curry–Howard`, code blocks, and bibliographic entries.
- **No nakaguro（・）for coordination.** Use と, や, or a list. Inside a single
  proper noun it is fine.
- **Bold and kagi-kakko have different jobs.** Bold marks a term at the point
  where the document defines or introduces it. 「」 marks an already-introduced
  term being referred to, a quotation, or a byname. First definition in bold,
  every later mention in 「」.
- **Do not pack two elements into a heading with a rule character.** 「種別──主題」
  「主題──概念」 become a single natural phrase: drop to one element, or join
  with a particle or a comma. A column heading is not a bare genre label
  either — 「基礎」「補足」 become 「同値関係としての分類」「ループ不変条件と帰納法」.
- **Term-definition lists use a full-width colon**: 「**用語**：説明」. Not a rule
  character, not a hyphen.
- **Fragments of code, diffs, logs, and configuration go in code blocks.**
- **Footnotes use the `[^ラベル]` form.** (What belongs in a footnote is
  `prose.sentence-load`.)

### Severity

`minor` throughout, except a heading whose two packed elements make the subject
unidentifiable, which is `major` and also a `structure.document-shape` finding.

---

## `ja.syntax`

```yaml
lens: ja.syntax
layer: japanese
packing_group: japanese
objective: Find Japanese sentences whose grammatical relations are needlessly
  obscured by noun-heavy or indirect syntax, forcing the reader to recast the
  sentence to determine who does what or which words belong together.
checks:
  - Abstract or inanimate subjects paired with an active transitive predicate
    where the basis of an inference or the actual actor disappears.
  - Nested adnominal clauses that postpone the head noun while the reader holds
    several subjects and predicates.
  - Actions frozen into nominalizations or chains of noun modifiers so that
    their actors and relations become unclear.
  - Analytic constructions used where an ordinary Japanese predicate would
    preserve the same proposition more directly.
  - Translated focus frames that postpone the proposition into 「こと」 or
    「もの」 where ordinary Japanese word order would carry the licensed focus.
non_goals:
  - Do not infer a defect from suspected translation or machine authorship.
  - Do not ban a phrase or construction by form or frequency alone.
  - Do not rewrite an inanimate subject, nominalization, or analytic form that
    is conventional in the field and leaves the relation unambiguous.
  - Passive voice and missing actors are prose.voice unless the problem is the
    Japanese sentence construction itself.
  - Whether focus is licensed at all is reference.discourse-grounding. This
    lens judges its Japanese realization only after that test passes.
```

### Rules

- **State the relation, not an abstract actor.** When an inanimate or abstract
  subject is made to perform an inference, expose the actual relation with a
  form such as 「〜から分かる」 or name the person making the judgment. Keep an
  inanimate subject where it is conventional and the predicate describes what
  the object actually does.
- **Release the head noun early.** If the reader must retain more than one
  subject-predicate relation before reaching a noun, split the modifiers into
  sentences or make the noun the topic. Length alone is not a finding.
- **Open nominalized actions into clauses.** Replace stacked サ変 nouns and
  chains of 「の」 with verbs when the stack hides who acts or how the actions
  relate. A repeated particle is a place to inspect, not a threshold.
- **Prefer the ordinary predicate.** Replace forms such as
  「〜することができる」「〜することによって」「意味を持つ」 only where a
  shorter inflected verb, conditional, or existential form states exactly the
  same thing. Preserve possibility, means, possession, and emphasis when they
  are part of the proposition.
- **Join stock claim-and-reason frames.** Where 「それは〜。なぜなら〜」 merely
  separates a claim from its reason, write the causal relation directly. Keep
  the frame when the separation creates a real contrast or answers a question
  already active in the text.
- **Do not calque focus into an empty nominal.** Once focus is licensed, name
  the focused proposition directly. Rewrite forms such as
  「データが示したのは、そのことだ」 or 「これが意味するのは、そういうことだ」
  with a predicate that states what the data supports or what the fact means.
  Keep a nominal focus form where its contrasted candidates are named and the
  construction is natural in context.

### Examples

- Before: 「この結果は、従来の前提が誤っていたことを示している。」
- After: 「この結果から、従来の前提が誤っていたと分かる。」
- Before: 「多くの企業が導入を進めているが十分な効果を実感できていないという
  課題を抱える技術である。」
- After: 「多くの企業がこの技術を導入している。しかし、十分な効果を実感できた
  企業は少ない。」
- Before: 「本機能の導入の目的は、運用コストの削減の実現にある。」
- After: 「本機能を導入する目的は、運用コストを削減することにある。」
- Before: 「情報を整理することによって、判断を速めることができる。」
- After: 「情報を整理すると、判断を速められる。」
- Before: 「ログが示しているのは、そのことだ。」
- After: 「ログにも、同じタイムアウトが記録されていた。」
- Keep: 「この関数は入力値を正規化する。」 The inanimate subject names
  something that actually performs the operation.
- Keep: 「管理者だけが設定を変更できる。」 Possibility is part of the
  permission being specified.

### Severity

`major` where the reader must re-read to recover the actor, predicate, or
modifier boundary. `minor` where the relation is clear but an indirect
construction adds local processing cost.

---

## `ja.diction`

```yaml
lens: ja.diction
layer: japanese
packing_group: japanese
objective: Find word choices and sentence endings that break the register or
  the flow of Japanese technical prose.
checks:
  - i-adjectives terminated with です.
  - Mixed である体 and ですます体.
  - Sino-Japanese words chosen by surface resemblance rather than established
    usage.
  - Person names inconsistently romanized or transliterated.
non_goals:
  - Choosing between competing terms for one concept is
    terminology.consistency. This lens covers the word's register and form.
```

### Rules

- **No i-adjective plus です**（「難しいです」「多いです」）. Treat an occurrence as a
  symptom rather than a surface defect: an i-adjective needs a bare terminal
  ending only when the sentence is isolated from what surrounds it. In
  connected prose the sentence continues (「〜は難しく、…」) or is received by
  「〜でしょう」「〜である」. Do not patch the ending — rewrite the passage around
  it. ナ-adjective plus です（「重要です」）is out of scope.
- **One style throughout.** である体 and ですます体 do not mix within a document,
  except where a quotation or a marked aside justifies it.
- **Do not assign a Sino-Japanese word by intuition.** Use the term established
  in the field. Push notification is 配信, not 配送.
- **Person names in their original spelling** (Lehman, Bainbridge), except for
  historical figures and eponymous concepts whose katakana form is the
  established Japanese name.

### Severity

`major` for mixed style across a document. `minor` for individual endings and
word choices.
