#!/usr/bin/env bash
# inception.sh — interpret an inception thinking graph (graph.json) as a graph.
#
# The graph is the single source of truth; this CLI gives the agent graph-shaped
# views so it does not have to traverse raw JSON in its head. It is READ-ONLY
# except for `init` and `render`: to change the graph, edit graph.json directly,
# then re-run `render`.
#
# Dependencies: bash + jq only (no Python), to stay agent-agnostic.
#
# Usage:
#   inception.sh init   <dir> [topic]      Create <dir>/graph.json skeleton
#   inception.sh tree   <graph.json>       Print the issue tree, indented
#   inception.sh open   <graph.json>       List open nodes grouped by nextMove
#   inception.sh next   <graph.json>       Foundational open nodes to discuss next
#   inception.sh check  <graph.json>       Structural lint (dup ids, dangling refs)
#   inception.sh render <graph.json> <dir> Regenerate the 4 markdown projections

set -euo pipefail

die() { printf 'inception: %s\n' "$1" >&2; exit 1; }
need_jq() { command -v jq >/dev/null 2>&1 || die "jq is required but not found"; }

cmd_init() {
  local dir="${1:-}"; local topic="${2:-}"
  [ -n "$dir" ] || die "init: missing <dir>"
  mkdir -p "$dir"
  local f="$dir/graph.json"
  [ -e "$f" ] && die "init: $f already exists"
  jq -n --arg topic "$topic" '{
    session: {
      topic: $topic, summary: "", background: "", problem: "", purpose: "",
      centralQuestion: "", targetUsers: "", valueProposition: "", goal: "",
      nonGoals: "", phase: "framing"
    },
    nodes: []
  }' > "$f"
  printf 'created %s\n' "$f"
}

cmd_tree() {
  local f="${1:?tree: missing <graph.json>}"
  jq -r '
    .nodes as $all
    | def children($pid): [ $all[] | select(.parentId == $pid) ];
      def render($pid; $depth):
        children($pid)[] as $n
        | ( "  " * $depth )
          + "[" + $n.type[0:1] + "/" + $n.status[0:1] + "] "
          + $n.id + " " + $n.content
          + ( if $n.dependsOn? and ($n.dependsOn|length>0) then "  (⤷ " + ($n.dependsOn|join(",")) + ")" else "" end ),
          render($n.id; $depth+1);
      render(null; 0)
  ' "$f"
}

cmd_open() {
  local f="${1:?open: missing <graph.json>}"
  # Discussion points are Question/Idea/Counter. Actions are work, not points to
  # discuss, so they live in action-items, not the open-questions queue.
  jq -r '
    def discussable: (.type=="Question" or .type=="Idea" or .type=="Counter");
    [ "decide","investigate","validate","deepen", null ][] as $m
    | ( [ .nodes[] | select(.status=="open" and discussable and (.nextMove == $m)) ] ) as $g
    | if ($g|length) > 0 then
        "## nextMove: " + ($m // "(unset)"),
        ( $g[] | "- " + .id + " [" + .type + "] " + .content
                 + ( if (.dependsOn? // []) | length > 0 then "  (blocked by " + (.dependsOn|join(",")) + ")" else "" end ) ),
        ""
      else empty end
  ' "$f"
}

cmd_next() {
  local f="${1:?next: missing <graph.json>}"
  # Foundational = open, all dependencies resolved/absent, ranked by how many
  # other open nodes (transitively) depend on it.
  jq -r '
    def discussable: (.type=="Question" or .type=="Idea" or .type=="Counter");
    .nodes as $all
    | ( [ $all[] | select(.status=="open" and discussable) ] ) as $open
    | def resolved($id): ( [ $all[] | select(.id==$id) ][0] // null ) as $n
        | ($n != null) and ($n.status=="resolved" or $n.status=="dropped" or $n.status=="deferred");
      def unblocked($n): [ ($n.dependsOn // [])[] | select( resolved(.) | not ) ] | length == 0;
      def dependents($id): [ $open[] | select( (.dependsOn // []) | index($id) ) ] | length;
      [ $open[] | select( unblocked(.) )
        | { id, type, content, score: dependents(.id), nextMove } ]
      | sort_by(-.score)
      | if length==0 then "No unblocked open nodes. Resolve a dependency or add nodes."
        else "Most foundational open nodes (unblocked, by #dependents):",
             ( .[] | "- " + .id + " [" + .type + "] (" + (.score|tostring) + " dependents"
                     + (if .nextMove then ", move=" + .nextMove else "" end) + ") " + .content )
        end
  ' "$f"
}

cmd_check() {
  local f="${1:?check: missing <graph.json>}"
  jq -r '
    .nodes as $all
    | ( [ $all[].id ] ) as $ids
    | [
        ( $ids | group_by(.) | map(select(length>1)[0]) | map("duplicate id: " + .) ),
        ( [ $all[] | select(.parentId != null and (.parentId as $p | $ids | index($p) | not))
            | "dangling parentId: " + .id + " -> " + .parentId ] ),
        ( [ $all[] | . as $n | (.dependsOn // [])[] | select(. as $d | $ids | index($d) | not)
            | "dangling dependsOn: " + $n.id + " -> " + . ] ),
        ( [ $all[] | select(.type=="Decision" and (.decision|not)) | "Decision node without decision field: " + .id ] ),
        ( [ $all[] | select(.status=="open" and (.type=="Question" or .type=="Idea" or .type=="Counter") and (.nextMove|not)) | "open discussion node without nextMove: " + .id ] ),
        ( [ $all[] | select(.status=="deferred" and ((.deferReason // "")=="")) | "deferred node without deferReason: " + .id ] )
      ] | add
    | if length==0 then "ok: no structural issues" else .[] end
  ' "$f"
}

cmd_render() {
  local f="${1:?render: missing <graph.json>}"; local dir="${2:?render: missing <dir>}"
  mkdir -p "$dir"

  # PRD — a foundational document. Every section renders; unfilled ones show
  # "_not yet defined_" so a thin PRD is visibly incomplete rather than "done".
  jq -r '
    .session as $s | .nodes as $all
    | def ph($v): ($v // "" | if .=="" then "_not yet defined_" else . end);
      "# " + ( ($s.topic // "") | if .=="" then "(untitled)" else . end ) + " — PRD",
      "",
      "## Summary", "", ph($s.summary), "",
      "## Background", "", ph($s.background), "",
      "## Problem", "", ph($s.problem), "",
      "## Purpose / Vision", "", ph($s.purpose), "",
      "## Central question", "", ph($s.centralQuestion), "",
      "## Target users", "", ph($s.targetUsers), "",
      "## Value proposition", "", ph($s.valueProposition), "",
      "## Goals", "", ph($s.goal), "",
      "## Non-goals", "", ph($s.nonGoals), "",
      "## Direction (decided)", "",
      ( [ $all[] | select(.type=="Decision") ] as $d
        | if ($d|length)==0 then "_no decisions recorded yet_"
          else ( $d[] | "- **" + (.decision.chosen) + "**"
                        + (if (.decision.rationale // "")!="" then " — " + .decision.rationale else "" end) )
          end ),
      "",
      "## Risks", "",
      ( [ $all[] | select(.type=="Counter") ] as $r
        | if ($r|length)==0 then "_none captured yet_"
          else ( $r[] | "- " + .content )
          end ),
      "",
      "## Open by design", "",
      ( [ $all[] | select(.status=="deferred") ] as $d
        | if ($d|length)==0 then "_none_"
          else ( $d[] | "- " + .content + " — " + (.deferReason // "no reason given") )
          end )
  ' "$f" > "$dir/prd.md"

  jq -r '
    "# Decisions", "",
    ( [ .nodes[] | select(.type=="Decision") ] as $d
      | if ($d|length)==0 then "_no decisions recorded yet_"
        else ( $d[]
               | "## " + .decision.chosen, "",
                 (if (.decision.rationale // "")!="" then "Rationale: " + .decision.rationale + "\n" else empty end),
                 (if (.decision.rejected // []) | length > 0 then
                    "Rejected alternatives:", ( .decision.rejected[] | "- " + .option + " — " + .reason ), ""
                  else empty end) )
        end )
  ' "$f" > "$dir/decisions.md"

  jq -r '
    "# Action items", "",
    ( [ .nodes[] | select(.type=="Action") ] as $a
      | if ($a|length)==0 then "_none yet_"
        else ( $a[]
               | (if .status=="resolved" then "- [x] " else "- [ ] " end)
                 + .content
                 + (if (.status=="deferred" or .status=="dropped") then " (" + .status + ")" else "" end) )
        end )
  ' "$f" > "$dir/action-items.md"

  jq -r '
    def heading($m): if $m=="decide" then "Needs a decision"
                     elif $m=="investigate" then "Needs investigation"
                     elif $m=="validate" then "Needs validation"
                     elif $m=="deepen" then "Needs more thought"
                     else "Open" end;
    "# Open questions", "",
    ( [ "decide","investigate","validate","deepen", null ][] as $m
      | ( [ .nodes[] | select(.status=="open" and (.type=="Question" or .type=="Idea" or .type=="Counter") and (.nextMove==$m)) ] ) as $g
      | if ($g|length)>0 then
          "## " + heading($m),
          ( $g[] | "- " + .content ),
          ""
        else empty end ),
    ( [ .nodes[] | select(.status=="deferred") ] as $d
      | if ($d|length)>0 then
          "## Deferred (intentionally left open)",
          ( $d[] | "- " + .content + " — " + (.deferReason // "no reason given") ), ""
        else empty end )
  ' "$f" > "$dir/open-questions.md"

  printf 'rendered prd.md, decisions.md, action-items.md, open-questions.md into %s\n' "$dir"
}

need_jq
sub="${1:-}"; shift || true
case "$sub" in
  init)   cmd_init   "$@" ;;
  tree)   cmd_tree   "$@" ;;
  open)   cmd_open   "$@" ;;
  next)   cmd_next   "$@" ;;
  check)  cmd_check  "$@" ;;
  render) cmd_render "$@" ;;
  ""|-h|--help|help)
    grep -E '^#( |$)' "$0" | sed -E 's/^# ?//' ;;
  *) die "unknown command: $sub (try --help)" ;;
esac
