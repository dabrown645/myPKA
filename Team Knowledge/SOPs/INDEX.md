# SOPs - Index

**SOPs are agent skills.** Each SOP is a canonical procedure — a step-by-step recipe for one job. They are LLM-agnostic and reusable across agents: an SOP has a **default owner** (the specialist who runs it most often), but any agent can invoke an SOP when they need its procedure. Think of SOPs the way Claude skills work — discrete, named, callable.

Filename pattern: `SOP-NNN-<title>.md` for domain SOPs. Framework-lifecycle SOPs (the task and journal plumbing) are un-numbered by design (`SOP-<verb>-<noun>.md`) - see the sub-table below. See [[GL-001-file-naming-conventions]] for slug rules. Numbering follows authorship order, not topic — gaps are intentional and reserve slots for future agents.

## Active SOPs

| SOP | Title | Default owner | Description |
|---|---|---|---|
| SOP-001 | [[SOP-001-how-to-add-a-new-specialist]] | Nolan | Step-by-step procedure to draft and onboard a new team specialist. References [[GL-001-file-naming-conventions]]. |
| SOP-002 | [[SOP-002-convert-mypka-to-sqlite]] | Silas (run by the user via paste-into-LLM prompt) | Generate a SQLite mirror of your myPKA on demand. Markdown stays canonical; SQLite is a derived performance layer. Body is a paste-into-LLM prompt. |

*Reserved (genuinely open for future agents):* SOP-003 onward. Agent packs installed from the myICOR Expansion Packs page claim the lowest free slots at install time (per [[WS-003-install-an-expansion]] §3.2); for example, the App Developer Pack claims 003 to 005 and the Designer Pack 006 to 009 when installed. Do not back-fill these slots without coordinating across the team.

## Framework-lifecycle SOPs (un-numbered by design)

The task and journal plumbing that keeps work continuous across sessions. These SOPs are **un-numbered by design** (`SOP-<verb>-<noun>.md`): they are framework internals that ship and version with the scaffold itself, while numbered slots stay reserved for domain SOPs (see [[GL-001-file-naming-conventions]] rule 6). `validation-script.sh` checks for these exact filenames. Cross-linking rules for the task files themselves live in [[GL-004-task-resource-linking]].

| SOP | Default owner | Description |
|---|---|---|
| [[SOP-create-task]] | any agent | Create a resumption-point task file in `tasks/open/`, with all cross-reference arrays populated. |
| [[SOP-claim-task]] | the agent picking up the task | Claim a task (`open/` → `in-progress/`), plus the block / unblock sub-procedures. |
| [[SOP-close-task]] | the agent finishing the task | Close a task as done or cancelled; archive its linked deliverables. |
| [[SOP-list-open-tasks]] | any agent (Larry at session boot) | Summarize open and in-progress tasks, with blocked tasks called out. |
| [[SOP-rebuild-task-index]] | any agent (called by every task-touching SOP) | Regenerate `tasks/INDEX.md`, the resumption-summary view of the task folder. |
| [[SOP-read-own-journal]] | any specialist at session start or task pickup | Load your own journal priors before starting referenced work. |
| [[SOP-write-journal-entry]] | any specialist (own `journal/`) | Capture a durable cross-session insight in your own journal. |
| [[SOP-write-session-log]] | Larry (default), any specialist running independently | Write the chronological session record under `session-logs/YYYY/MM/`. |

## How to add a new SOP

1. Pick the next unused number (`SOP-NNN`) — by authorship order, not topic. Don't reuse reserved numbers.
2. Filename: `SOP-NNN-<kebab-case-title>.md`.
3. Header includes the default owner, status, triggers, references, and an explicit "Reusable by any agent" note — the SOP is a skill, not 1:1 ownership.
4. Reference [[GL-001-file-naming-conventions]] and any other Guideline instead of duplicating its content.
5. Add a row to this index.
