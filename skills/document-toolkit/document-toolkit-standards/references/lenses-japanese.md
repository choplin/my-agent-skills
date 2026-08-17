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
