---
agent_id: larry
session_id: gpg-orphan-key-question
timestamp: 2026-07-26T22:21:29Z
type: close-session
linked_sops: []
linked_workstreams: []
linked_guidelines: []
---

# GPG Orphan Key Clarification

## Context

David asked whether orphaned GPG keys would continue to grow if not cleaned up before the initial backup.

## What we did

- Larry reviewed the GPG backup procedure's orphan handling (back up first, then remove after lockdown).

## Decisions made

- _(none)_

## Insights

- Orphaned `.key` files can accumulate over time from failed subkey operations, deleted keys with leftover files, etc.
- The current procedure backs them up defensively before removal — this is safe but can include cruft if accumulation is high.
- A pre-backup cleanup step could be added if accumulation becomes a nuisance (two-line change).

## Realignments

- _(none this session)_

## Open threads

- _(none)_

## Next steps

- Consider adding pre-backup cleanup if orphan accumulation becomes noticeable.

## Cross-links

- `[[2026-07-26-14-57_larry_gpg-procedures-review]]` — prior session on GPG procedures.
