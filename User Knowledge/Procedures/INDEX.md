# Procedures - Index

**Procedures are user runbooks.** Each Procedure is a step-by-step guide for a task **you** execute. An agent can walk you through it, but you type the commands. Think of these as your personal SOPs — the agent is the guide, you are the operator.

Filename pattern: `<kebab-case-title>.md`. See [[GL-001-file-naming-conventions]] for slug rules.

## Active Procedures

| Procedure | Title | Agent guide | Description |
|-----------|-------|-------------|-------------|
| [[GPG-restore-for-active-use]] | GPG Restore for Active Use | Larry | Restore GPG from encrypted USB backup. Gets you from "secret keys on USB" to "GPG fully functional." |
| [[GPG-backup-and-lockdown]] | GPG Backup and Lockdown | Larry | Backup GPG to encrypted USB and remove secret keys from local disk. |
| [[GPG-key-renewal]] | GPG Key Renewal | Larry | Renew expired or expiring GPG keys. Extends validity without changing key material. |

## How to add a new Procedure

1. Filename: `<kebab-case-title>.md` (no number prefix — procedures are organized by topic, not sequence).
2. Header includes: type (User procedure), agent guide, trigger, prerequisites, post-conditions, related procedures.
3. Reference [[GL-001-file-naming-conventions]] and any other Guideline instead of duplicating its content.
4. Add a row to this index.
5. Keep it scannable: numbered steps, code blocks, tables for reference data.
