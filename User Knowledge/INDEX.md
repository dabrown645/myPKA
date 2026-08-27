# User Knowledge - Master Hub

This is your personal knowledge base for procedures, references, and checklists. It's parallel to [[Team Knowledge/INDEX]], but for **your** workflows — not agent operations.

## Sections

- **[[User Knowledge/Procedures/INDEX|Procedures]]** — step-by-step instructions you follow. Each procedure has an agent that can guide you through it, but you run the commands. Think of these as your personal runbooks. Filenames: `<topic>.md`.
- **[[User Knowledge/Cheatsheets/INDEX|Cheatsheets]]** — quick-reference cards for tools, DEs, and workflows. Scannable tables, no prose.
- **[[User Knowledge/References/INDEX|References]]** — lookup tables and reference material. Things you want to glance at, not follow step-by-step.
- **[[User Knowledge/Checklists/INDEX|Checklists]]** — pre-flight checks, maintenance routines, go/no-go decision points. Short, scannable, actionable.

## Distinction from Team Knowledge

| Team Knowledge | User Knowledge |
|----------------|----------------|
| Agent-executed procedures (SOPs) | User-executed procedures |
| Agents run commands, user observes | User runs commands, agent guides |
| Example: SOP-001 (hire a specialist) | Example: GPG backup and lockdown |
| Filenames: `SOP-NNN-<title>.md` | Filenames: `<topic>.md` |

## SSOT applies here too

If a fact about a procedure appears in both a Procedure and a Session Log, the Procedure file is the source of truth. The session log captures what happened during a specific run; the Procedure captures the canonical steps.

See root [[AGENTS]] for the full SSOT Golden Rule. See [[GL-001-file-naming-conventions]] for naming.

## How agents help

- **Larry** (or any agent) can guide you through a Procedure by reading the steps and prompting you.
- The agent does not execute the commands — you do.
- The agent's role is to keep you on track, handle clarifying questions, and log results.
