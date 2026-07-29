# Label group setup

One-time setup of the issue and project label groups for a new workspace.

Create the issue label groups (`isGroup: true`, then members with `parent: <group>` — both supported by the label-create MCP tool):

1. Create the issue **Type** group and its 4 members (`impl` / `design` / `research` / `orchestration`).
2. Create the issue **Repo** group; add a member per active repository on demand.
3. Create the **Repo** project-label group in the project-label namespace (mirror the issue Repo group and its members). **This is a manual UI step — the MCP cannot create project labels.** Every Project must carry exactly one Repo label; when a repo's label is missing, ask the user to add it in the UI.
