---
name: jira-cli
description: >
  jira-cli command reference for managing Jira issues, epics, sprints, and boards from the terminal.
  Use when the user explicitly mentions "Jira" by name (e.g., "Jira issue", "Jira sprint") or
  references "jira-cli" / "jira" CLI tool. Do NOT trigger on generic issue/sprint/epic mentions
  without "Jira" — those may refer to GitHub issues or other systems.
  Triggers on: "Jira", "jira-cli", "Jira issue", "Jira sprint", "Jira epic", "Jira board", "JQL".
  Should NOT trigger on: "create issue", "list issues", "sprint", "epic" without explicit Jira context.
---

# jira-cli Command Reference

## Critical Rules for AI Usage

- **Always use `--no-input`** when creating or modifying data to skip interactive prompts
- **Always use `--plain`** for list commands when output needs to be parsed
- **Use `--raw`** when JSON output is needed
- **Never run interactive TUI mode** — always add `--plain` or `--no-input` as appropriate
- Use `$(jira me)` to reference the current user

## Configuration

```bash
# Set API token (required before jira init)
export JIRA_API_TOKEN="your-token"

# Initialize (interactive — user must run this themselves)
jira init

# Use custom config file
jira --config /path/to/config.yml issue list
```

- Cloud: Get API token from https://id.atlassian.com/manage-profile/security/api-tokens
- On-premise: Use login password (basic auth) or set `JIRA_AUTH_TYPE=bearer` for PAT
- Config location: `~/.config/.jira/.config.yml`

## Issue Operations

### List Issues

```bash
jira issue list --plain
jira issue list -s "To Do" --plain
jira issue list -yHigh -s"To Do" --created month -lbackend --plain
jira issue list -a $(jira me) --plain
jira issue list -q "summary ~ cli" --plain
```

| Flag | Description |
|------|-------------|
| `-s/--status` | Filter by status (e.g., `"To Do"`, `"In Progress"`, `Done`) |
| `-y/--priority` | Filter by priority (`High`, `Medium`, `Low`) |
| `-a/--assignee` | Filter by assignee (`x` = unassigned, `$(jira me)` = self) |
| `-r/--reporter` | Filter by reporter |
| `-l/--label` | Filter by label (repeatable) |
| `-C/--component` | Filter by component |
| `-t/--type` | Filter by issue type (`Bug`, `Task`, `Story`) |
| `-p/--project` | Specify project |
| `-q/--jql` | Raw JQL query |
| `-w/--watching` | Show only watched issues |
| `--created` | Filter by creation date (`-7d`, `week`, `month`) |
| `--created-before` | Filter created before date |
| `--updated` | Filter by update date |
| `-R/--resolution` | Filter by resolution |
| `--history` | Show recently viewed issues |
| `--order-by` | Sort field (`created`, `rank`, `priority`) |
| `--reverse` | Reverse sort order |
| `~` prefix | Negation operator (e.g., `-s~Done` = not Done) |

### Create Issue

```bash
jira issue create -tTask -s"Summary" -yMedium -b"Description" --no-input
jira issue create -tBug -s"Bug title" -yHigh -lbug -lurgent -b"Details" --no-input
jira issue create -tStory -s"Story title" -PEPIC-42 --no-input
jira issue create -tTask -s"From template" --template /path/to/template.tmpl --no-input
```

| Flag | Description |
|------|-------------|
| `-t/--type` | Issue type (`Bug`, `Task`, `Story`) |
| `-s/--summary` | Summary/title |
| `-y/--priority` | Priority level |
| `-b/--body` | Description body |
| `-l/--label` | Add label (repeatable) |
| `-C/--component` | Add component (repeatable) |
| `-P/--parent` | Attach to epic (epic key) |
| `--fix-version` | Add fix version |
| `--template` | Load description from file or stdin (`-`) |
| `--custom` | Set custom fields |
| `--no-input` | Skip interactive prompts |

### View Issue

```bash
jira issue view ISSUE-1 --plain
jira issue view ISSUE-1 --comments 5 --plain
```

### Edit Issue

```bash
jira issue edit ISSUE-1 -s"Updated summary" --no-input
jira issue edit ISSUE-1 -yHigh -lnew-label -b"Updated description" --no-input
jira issue edit ISSUE-1 --label -old-label --label new-label --no-input
jira issue edit ISSUE-1 --component -FE --component BE --no-input
```

- Prefix with `-` to remove labels/components/fix-versions (e.g., `--label -p2`)

### Move Issue (State Transition)

```bash
jira issue move ISSUE-1 "In Progress"
jira issue move ISSUE-1 Done -RFixed -a$(jira me)
jira issue move ISSUE-1 "In Progress" --comment "Started working on it"
```

| Flag | Description |
|------|-------------|
| `--comment` | Add comment during transition |
| `-R/--resolution` | Set resolution |
| `-a/--assignee` | Assign during transition |

### Assign Issue

```bash
jira issue assign ISSUE-1 "Jon Doe"
jira issue assign ISSUE-1 $(jira me)
jira issue assign ISSUE-1 x          # unassign
jira issue assign ISSUE-1 default    # default assignee
```

### Link / Unlink Issues

```bash
jira issue link ISSUE-1 ISSUE-2 Blocks
jira issue link remote ISSUE-1 https://example.com "Link text"
jira issue unlink ISSUE-1 ISSUE-2
```

### Clone Issue

```bash
jira issue clone ISSUE-1
jira issue clone ISSUE-1 -s"Modified summary" -yHigh -a$(jira me)
jira issue clone ISSUE-1 -H"find me:replace with me"
```

| Flag | Description |
|------|-------------|
| `-s/--summary` | Modify summary |
| `-y/--priority` | Modify priority |
| `-a/--assignee` | Modify assignee |
| `-l/--label` | Add labels |
| `-C/--component` | Add components |
| `-H/--replace` | Replace text in summary/description (`"find:replace"`) |

### Comment

```bash
jira issue comment add ISSUE-1 "Comment body"
jira issue comment add ISSUE-1 "Internal note" --internal
jira issue comment add ISSUE-1 --template /path/to/template.tmpl
echo "Comment from stdin" | jira issue comment add ISSUE-1
```

### Delete Issue

```bash
jira issue delete ISSUE-1
jira issue delete ISSUE-1 --cascade   # delete with subtasks
```

### Worklog (Time Tracking)

```bash
jira issue worklog add ISSUE-1 "2d 3h 30m" --no-input
jira issue worklog add ISSUE-1 "10m" --comment "Work done" --no-input
```

## Epic Management

```bash
# List epics
jira epic list --plain
jira epic list --table
jira epic list -sOpen -r$(jira me) --plain

# List issues in an epic
jira epic list EPIC-1 --plain
jira epic list EPIC-1 -ax -yHigh --plain

# Create epic
jira epic create -n"Epic name" -s"Summary" -yHigh -b"Description" --no-input

# Add/remove issues (up to 50 at once)
jira epic add EPIC-1 ISSUE-1 ISSUE-2
jira epic remove ISSUE-1 ISSUE-2
```

## Sprint Management

```bash
# List sprints
jira sprint list --plain
jira sprint list --table
jira sprint list --current --plain
jira sprint list --prev --plain
jira sprint list --next --plain
jira sprint list --state future,active --plain

# List issues in a sprint
jira sprint list SPRINT_ID --plain
jira sprint list SPRINT_ID -yHigh -a$(jira me) --plain
jira sprint list SPRINT_ID --order-by rank --reverse --plain

# Add issues to sprint (up to 50 at once)
jira sprint add SPRINT_ID ISSUE-1 ISSUE-2
```

## Board & Project

```bash
jira board list --plain
jira project list --plain
jira open              # open project in browser
jira open ISSUE-1      # open issue in browser
```

## Release

```bash
jira release list --plain
jira release list --project KEY --plain
```

## Output Modes

| Flag | Output |
|------|--------|
| (default) | Interactive TUI — do not use in AI context |
| `--plain` | Plain text table (tab-separated) |
| `--raw` | Raw JSON from API |
| `--csv` | CSV format |
| `--no-headers` | Omit column headers |
| `--columns` | Specify columns to display |

## JQL Patterns

For full JQL syntax (fields, operators, functions), see @references/jql.md

```bash
# Raw JQL query via -q/--jql flag
jira issue list -q "project = PROJ AND status = 'In Progress'" --plain

# Common JQL patterns
jira issue list -q "assignee = currentUser() AND status != Done" --plain
jira issue list -q "sprint in openSprints()" --plain
jira issue list -q "created >= -7d AND priority = High" --plain
jira issue list -q "labels in (backend, api) AND status = 'To Do'" --plain
jira issue list -q "parent = EPIC-1 AND status != Done" --plain
jira issue list -q "duedate < now() AND resolution IS EMPTY" --plain
jira issue list -q "status CHANGED DURING (startOfMonth(), now())" --plain
```

## Common Workflows

### Triage: Find and assign unassigned issues

```bash
jira issue list -ax -yHigh --plain              # list unassigned high-priority
jira issue assign ISSUE-1 $(jira me)            # assign to self
jira issue move ISSUE-1 "In Progress"           # start working
```

### Sprint planning: Review backlog and add to sprint

```bash
jira issue list -s"To Do" --order-by priority --plain   # review backlog
jira sprint list --current --plain                       # find current sprint
jira sprint add SPRINT_ID ISSUE-1 ISSUE-2               # add to sprint
```

### Daily standup: Check my in-progress work

```bash
jira issue list -a$(jira me) -s"In Progress" --plain    # my active issues
jira issue comment add ISSUE-1 "Progress update"        # add update
```

### Create issue from description

```bash
echo "Detailed description here" | jira issue create -tTask -s"Summary" --template - --no-input
```

## Environment Variables

| Variable | Description |
|----------|-------------|
| `JIRA_API_TOKEN` | Authentication token |
| `JIRA_AUTH_TYPE` | Auth method (`basic`, `bearer`, `mtls`) |
| `JIRA_CONFIG_FILE` | Config file location |
