# app-reference

Conventions for the shape of an application, one skill per tier. They settle what
to build with and where the boundaries sit; how the code inside a module is
written belongs to `lang-reference`, and how modules are carved up belongs to
`codebase-structure`.

## Skills

| Skill | Description |
|-------|-------------|
| `app-reference-backend` | Implementation language and runtime choice, whether to split services, and database integration tests |
| `app-reference-frontend` | Server-driven HTML versus a client-side application, htmx, CSS frameworks and UI libraries, and the state, rendering, and test boundaries |
| `app-reference-cli` | The product channel versus the run-report channel, the operation surface versus the navigation surface, where each input belongs, and the ergonomics of run reports, prompts, and TUI components |

None of these skills appear in the `/` menu. They apply from context while
backend, frontend, or terminal tool work is underway.

## Installation

Install these skills through the repository's `skills add` workflow documented
in the root README.

