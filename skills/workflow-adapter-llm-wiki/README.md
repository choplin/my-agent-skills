# llm-wiki workflow adapter

Provider integration for using the externally installed llm-wiki skill family
through generic workflows in this repository.

| Skill | Description |
|---|---|
| `workflow-adapter-llm-wiki` | Apply provider-neutral durable Markdown operations through llm-wiki |

Install `llm-wiki-base`, `llm-wiki-capture`, and `llm-wiki-retrieve` from the
llm-wiki distribution separately. This group owns the integration boundary;
the llm-wiki distribution owns the knowledge-base model and operation skills.
