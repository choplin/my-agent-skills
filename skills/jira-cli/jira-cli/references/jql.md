# JQL (Jira Query Language) Reference

## Query Structure

```
field operator value [AND|OR field operator value ...] [ORDER BY field [ASC|DESC]]
```

- Use `AND` / `OR` to combine clauses
- Use `NOT` to negate a clause
- Use parentheses for precedence: `(status = Open OR status = Reopened) AND priority = High`
- `EMPTY` / `NULL` are interchangeable for checking empty fields
- Quote reserved words when used as values: `"and"`, `"or"`, `"not"`, `"in"`, `"is"`, `"empty"`, `"null"`

## Operators

### Comparison

| Operator | Description | Works with |
|----------|-------------|------------|
| `=` | Exact match | Non-text fields |
| `!=` | Not equal (does not match empty fields) | Non-text fields |
| `>` | Greater than | Dates, numbers, versions, priority |
| `>=` | Greater than or equal | Dates, numbers, versions, priority |
| `<` | Less than | Dates, numbers, versions, priority |
| `<=` | Less than or equal | Dates, numbers, versions, priority |

**Note:** `!=` does not match fields with no value. Use `field != value OR field IS EMPTY` for complete coverage.

### Text Search

| Operator | Description | Works with |
|----------|-------------|------------|
| `~` | Contains (fuzzy match) | summary, description, environment, comment |
| `!~` | Does not contain | summary, description, environment, comment |

### Set

| Operator | Description | Example |
|----------|-------------|---------|
| `IN` | Matches any value in list | `status IN ("Open", "Reopened")` |
| `NOT IN` | Excludes values in list | `priority NOT IN (High, Critical)` |

### Null Check

| Operator | Description | Example |
|----------|-------------|---------|
| `IS EMPTY` / `IS NULL` | Field has no value | `assignee IS EMPTY` |
| `IS NOT EMPTY` / `IS NOT NULL` | Field has a value | `fixVersion IS NOT EMPTY` |

### History (WAS / CHANGED)

| Operator | Description | Supported fields |
|----------|-------------|-----------------|
| `WAS` | Field previously had value | assignee, fixVersion, priority, reporter, resolution, status |
| `WAS IN` | Field previously had any of values | Same as WAS |
| `WAS NOT` | Field never had value | Same as WAS |
| `WAS NOT IN` | Field never had any of values | Same as WAS |
| `CHANGED` | Field value was modified | Same as WAS |

History predicates: `AFTER`, `BEFORE`, `BY`, `DURING`, `ON`, `FROM`, `TO`

```
status WAS "Resolved" BY jsmith BEFORE "2024/02/02"
status CHANGED FROM "In Progress" TO "Open"
assignee CHANGED AFTER startOfMonth()
```

## Common Fields

### Core Fields

| Field | Operators | Value format |
|-------|-----------|-------------|
| `project` | `=`, `!=`, `IN`, `NOT IN` | Key or name: `project = PROJ` |
| `type` / `issuetype` | `=`, `!=`, `IN`, `NOT IN` | `type = Bug`, `type IN (Bug, Task)` |
| `status` | `=`, `!=`, `IN`, `NOT IN`, `WAS`, `CHANGED` | `status = "In Progress"` |
| `priority` | `=`, `!=`, `>`, `<`, `>=`, `<=`, `IN`, `NOT IN`, `WAS`, `CHANGED` | `priority = High` |
| `resolution` | `=`, `!=`, `IS`, `IN`, `WAS`, `CHANGED` | `resolution = Fixed`, `resolution IS EMPTY` |

### People Fields

| Field | Operators | Value format |
|-------|-----------|-------------|
| `assignee` | `=`, `!=`, `IS`, `IN`, `WAS`, `CHANGED` | Username, email, or `currentUser()` |
| `reporter` | `=`, `!=`, `IS`, `IN`, `WAS` | Username or email |
| `creator` | `=`, `!=`, `IS`, `IN` | Username or email |
| `voter` | `=`, `!=`, `IS`, `IN` | Username or email |
| `watcher` | `=`, `!=`, `IS`, `IN` | Username or email |

### Date Fields

| Field | Operators | Value format |
|-------|-----------|-------------|
| `created` | `=`, `!=`, `>`, `>=`, `<`, `<=` | `"2024/01/15"`, `"-7d"`, `startOfWeek()` |
| `updated` | `=`, `!=`, `>`, `>=`, `<`, `<=` | Same as created |
| `resolved` | `=`, `!=`, `>`, `>=`, `<`, `<=`, `IS` | Same as created |
| `due` / `duedate` | `=`, `!=`, `>`, `>=`, `<`, `<=`, `IS` | Same as created |
| `lastViewed` | `=`, `!=`, `>`, `>=`, `<`, `<=` | Same as created |

Date formats: `"YYYY/MM/DD"`, `"YYYY-MM-DD"`, or relative: `"-1d"`, `"-2w"`, `"-3M"`

### Text Fields

| Field | Operators | Notes |
|-------|-----------|-------|
| `summary` | `~`, `!~`, `IS`, `IS NOT` | Fuzzy text search |
| `description` | `~`, `!~`, `IS`, `IS NOT` | Fuzzy text search |
| `comment` | `~`, `!~` | Search all comments |
| `environment` | `~`, `!~`, `IS`, `IS NOT` | Fuzzy text search |
| `text` | `~` | Searches summary + description + environment + comments |

### Categorization Fields

| Field | Operators | Value format |
|-------|-----------|-------------|
| `labels` | `=`, `!=`, `IS`, `IN`, `NOT IN` | `labels = backend` |
| `component` | `=`, `!=`, `IS`, `IN`, `NOT IN` | `component = "UI"` |
| `fixVersion` | `=`, `!=`, `>`, `<`, `IS`, `IN`, `WAS`, `CHANGED` | `fixVersion = "2.0"` |
| `affectedVersion` | `=`, `!=`, `>`, `<`, `IS`, `IN` | `affectedVersion = "1.0"` |

### Agile Fields

| Field | Operators | Value format |
|-------|-----------|-------------|
| `sprint` | `=`, `!=`, `IS`, `IN`, `NOT IN` | Name, ID, or function: `sprint IN openSprints()` |
| `parent` | `=`, `!=`, `IN`, `NOT IN` | Issue key: `parent = EPIC-123` |

### Time Tracking Fields

| Field | Operators | Value format |
|-------|-----------|-------------|
| `originalEstimate` | `=`, `!=`, `>`, `<`, `>=`, `<=`, `IS` | Duration: `1h`, `2d`, `30m` |
| `remainingEstimate` | `=`, `!=`, `>`, `<`, `>=`, `<=`, `IS` | Duration |
| `timeSpent` | `=`, `!=`, `>`, `<`, `>=`, `<=`, `IS` | Duration |
| `workRatio` | `=`, `!=`, `>`, `<`, `>=`, `<=` | Percentage: `workRatio > 75` |

### Other Fields

| Field | Operators | Notes |
|-------|-----------|-------|
| `key` / `issuekey` | `=`, `!=`, `>`, `<`, `>=`, `<=`, `IN`, `NOT IN` | `key = PROJ-123` |
| `attachments` | `IS`, `IS NOT` | `attachments IS NOT EMPTY` |
| `votes` | `=`, `!=`, `>`, `<`, `>=`, `<=` | Numeric: `votes >= 5` |
| `watchers` | `=`, `!=`, `>`, `<`, `>=`, `<=` | Numeric count |
| `filter` | `=`, `!=`, `IN`, `NOT IN` | Saved filter name or ID |
| `cf[ID]` | Varies by type | Custom field by ID |

## Functions

### User Functions

| Function | Description | Example |
|----------|-------------|---------|
| `currentUser()` | Logged-in user | `assignee = currentUser()` |
| `membersOf(group)` | Members of a group | `assignee IN membersOf("developers")` |

### Sprint Functions

| Function | Description | Example |
|----------|-------------|---------|
| `openSprints()` | Active sprints | `sprint IN openSprints()` |
| `closedSprints()` | Completed sprints | `sprint IN closedSprints()` |
| `futureSprints()` | Unstarted sprints | `sprint IN futureSprints()` |

### Date Functions

All date functions accept an optional increment: `(+/-)nn(y|M|w|d|h|m)`

| Function | Description | Example |
|----------|-------------|---------|
| `now()` | Current timestamp | `duedate < now()` |
| `startOfDay(inc?)` | Start of current day | `created > startOfDay("-1d")` |
| `endOfDay(inc?)` | End of current day | `due < endOfDay()` |
| `startOfWeek(inc?)` | Start of week (Sunday) | `created > startOfWeek()` |
| `endOfWeek(inc?)` | End of week (Saturday) | `due < endOfWeek("+1")` |
| `startOfMonth(inc?)` | Start of month | `created > startOfMonth("-1")` |
| `endOfMonth(inc?)` | End of month | `due < endOfMonth()` |
| `startOfYear(inc?)` | Start of year | `created > startOfYear()` |
| `endOfYear(inc?)` | End of year | `due < endOfYear()` |
| `currentLogin()` | Current session start | `created > currentLogin()` |
| `lastLogin()` | Previous session start | `updated > lastLogin()` |

Increment examples: `"+1d"` (plus 1 day), `"-2w"` (minus 2 weeks), `"+3M"` (plus 3 months)

### Version Functions

| Function | Description | Example |
|----------|-------------|---------|
| `latestReleasedVersion(project)` | Latest released version | `fixVersion = latestReleasedVersion(PROJ)` |
| `earliestUnreleasedVersion(project)` | Earliest unreleased version | `fixVersion = earliestUnreleasedVersion(PROJ)` |
| `releasedVersions(project?)` | All released versions | `fixVersion IN releasedVersions()` |
| `unreleasedVersions(project?)` | All unreleased versions | `affectedVersion IN unreleasedVersions(PROJ)` |

### Issue Functions

| Function | Description | Example |
|----------|-------------|---------|
| `linkedWorkItems(key, type?)` | Issues linked to key | `issue IN linkedWorkItems(PROJ-123)` |
| `updatedBy(user, from?, to?)` | Issues updated by user | `issuekey IN updatedBy(jsmith, "-7d")` |
| `votedWorkItems()` | Issues you voted on | `issue IN votedWorkItems()` |
| `watchedWorkItems()` | Issues you watch | `issue IN watchedWorkItems()` |

### Component Functions

| Function | Description | Example |
|----------|-------------|---------|
| `componentsLeadByUser(user?)` | Components led by user | `component IN componentsLeadByUser()` |

## Practical Query Examples

```
# My open issues
assignee = currentUser() AND resolution IS EMPTY

# High-priority bugs in current sprint
type = Bug AND priority IN (High, Critical) AND sprint IN openSprints()

# Unassigned issues in project
project = PROJ AND assignee IS EMPTY AND status != Done

# Issues created this week
created >= startOfWeek()

# Overdue issues
duedate < now() AND resolution IS EMPTY

# Issues updated in the last 24 hours
updated >= "-1d"

# Issues containing keyword in summary or description
text ~ "search term"

# Issues moved to Done this month
status = Done AND status CHANGED DURING (startOfMonth(), now())

# Issues in backlog (not in any active sprint)
sprint NOT IN openSprints() AND sprint NOT IN futureSprints() AND resolution IS EMPTY

# Subtasks of a specific epic
parent = EPIC-123

# Issues with no fix version assigned
project = PROJ AND fixVersion IS EMPTY AND type != Epic

# Recently resolved issues
resolved >= "-7d" ORDER BY resolved DESC

# Issues blocking others
issueLinkType = "blocks"

# My watched issues that need attention
issue IN watchedWorkItems() AND status != Done AND updated <= "-7d"
```

## ORDER BY

```
ORDER BY field [ASC|DESC] [, field [ASC|DESC] ...]
```

Common sort fields: `created`, `updated`, `priority`, `status`, `assignee`, `key`, `rank`, `duedate`, `resolved`

```
ORDER BY priority DESC, created ASC
ORDER BY rank ASC
```
