---
agent_id: larry
session_id: mypka-hotkey-ssh-agent-fix
timestamp: 2026-09-24T13:38:00Z
type: close-session  # close-session | mid-session-insight | realignment | proactive
linked_sops: []
linked_workstreams: []
linked_guidelines: []
---

# myPKA hotkey SSH agent fix + pinentry check

## Context

Follow-up to the COSMIC hotkeys session: the new `Super+Shift+P` hotkey launched `myPKA` but `pre_syncing` failed with `git fetch upstream: Permission denied (publickey)`.

## What we did

- Rex confirmed remotes are SSH-only (`origin`/`upstream` = `git@github.com`) and the live terminal's agent is `gpg-agent` (`SSH_AUTH_SOCK=/run/user/1000/gnupg/S.gpg-agent.ssh`), while `systemctl --user show-environment` has no SSH vars — so COSMIC `Spawn` launches without an agent.
- Rex verified in a clean env that setting `SSH_AUTH_SOCK` to `gpgconf --list-dirs agent-ssh-socket` makes `ssh-add -l` and `git fetch upstream` succeed.
- Rex added an `SSH_AUTH_SOCK` fallback block to `~/.local/bin/myPKA-hotkey` (syntax-checked). User confirmed the hotkey syncs cleanly afterward.
- Rex checked pinentry path for the not-cached case: `gpg-agent.conf` has no `pinentry-program` override, GUI pinentries (`gnome3`/`qt`) installed, key currently cached with `default-cache-ttl 600`. Conclusion: GUI dialog will prompt when needed; no change made.

## Decisions made

- **Question:** Hardcode the agent socket path or resolve dynamically?
  **Decision:** Resolve via `gpgconf --list-dirs agent-ssh-socket` with `[ -S ]` guard, so UID/session changes don't break it.

## Insights

- COSMIC `Spawn`hotkey env lacks `SSH_AUTH_SOCK`; any SSH-remote git flow launched from a hotkey needs explicit agent injection.
- `gpg-agent` SSH socket path is deterministic per-user but best resolved via `gpgconf`, not hardcoded.

## Realignments

- _(none this session)_

## Open threads

- [ ] User will exercise the hotkey after key-cache expiry to confirm the GUI pinentry prompt appears; if `pinentry cancelled`/`no pinentry` occurs, add `GPG_TTY` handling inside the terminal-lived process.

## Next steps

- None pending unless the pinentry-after-expiry test fails.

## Cross-links

- `[[2026-09-24-13-32_larry_cosmic-hotkeys-mypka-wrapper]]` — parent session that created the wrapper.
