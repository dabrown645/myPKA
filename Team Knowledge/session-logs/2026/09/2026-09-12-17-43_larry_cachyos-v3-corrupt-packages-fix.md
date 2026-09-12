---
agent_id: larry
session_id: 2026-09-12-17-43-larry-cachyos-v3-corrupt-packages-fix
timestamp: 2026-09-12T17:43:31Z
type: close-session
linked_sops: []
linked_workstreams: []
linked_guidelines: []
---

# CachyOS cachyos-v3 corrupt packages fixed via mirror rotate

## Context

David came in with corrupt packages during update, asking how we fixed it last time. Last time (Sept 3) was chaotic-aur unknown trust; this time was cachyos/cachyos-v3 kernel packages with invalid PGP signatures. Session started in plan mode, moved to build mode for execution.

## What we did

- Larry routed corrupt-packages update failure to Rex per [[agent-index]].
- Rex distinguished this from Sept 3 chaotic-aur case via prior logs — this was `signature from "CachyOS <admin@cachyos.org>" is invalid` on `linux-cachyos-7.2.4-3`, `headers`, `nvidia-open`, transaction aborted.
- Rex ran read-only diagnostics: clock synced, sync DB `0644` + `.sig` intact (ruled out Shelly 0640 bug), `SigLevel Required DatabaseOptional` correct, `cachyos-keyring 20240331-1` stale both installed and repo, `archlinux-keyring 1:20260909-1` current.
- Rex hit sudo privilege wall in tool (no terminal for password) and handed sudo steps to David: delete 3 cached files, `Syyu`, `cachyos-rate-mirrors`, repopulate if needed.
- David ran `cachyos-rate-mirrors` + upgrade — got CDN77 `Maximum file size exceeded` x3 with fallback to next mirror, transaction ran to completion.
- Rex verified: `pacman -Q` shows `7.2.4-3` + `lts 6.18.50-3`, log `10:39:31-10:40:07` shows upgrade + initramfs + limine enroll + sbctl signing + snapshot 124. Disk 48% free. `net.core.netdev_max_backlog = 4096` currently healthy.

## Decisions made

- **Question:** Full keyring reset first or minimal + mirror rotate?
  **Decision:** Minimal first — master CachyOS key already `[ full ]`, no reason to wipe healthy trust. Full `rm -rf /etc/pacman.d/gnupg` stays last-resort.
- **Question:** CDN77 max-filesize failure = fatal?
  **Decision:** No — download-layer fallback. With `ParallelDownloads = 10`, cdn77 bailed on large kernel files, pacman skipped it and completed via krfoss. Demote cdn77 or drop to `ParallelDownloads = 5` only if it recurs.

## Insights

- `cachyos-keyring 20240331-1` is still the repo version 2.5 years later — same staleness pattern as July ISO issue. Reinstall alone does not fix when the package itself is stale; mirror rotate + repopulate matters more.
- Cache `.sig` timestamps 18h newer than `.pkg` + all 3 same-version kernel pkgs failing together points to mirror desync, not local trust loss.
- CDN77 + `ParallelDownloads = 10` fails large `x86_64_v3` kernel packages with `Maximum file size exceeded` — fallback works, but cdn77 first in rate-mirrors order will repeat this.
- `70-cachyos-settings.conf` `netdev_max_backlog` write failure during update is transient — `/proc` value is `4096` post-update, safe to ignore.

## Realignments

- User corrected scope: "bad files were from cachyos/cachyos-v3 this time" — shifted diagnosis from chaotic-aur lsign path to CachyOS keyring/mirror path.
- Plan-mode constraint blocked execution on "Go ahead" / "yes" until mode flipped to build — Larry stayed read-only and finalized plan instead of executing.

## Open threads

- [ ] David to reboot — still booted on `7.2.3-1-cachyos`, new `7.2.4-3-cachyos` loads after reboot
- [ ] Confirm `uname -r` shows `7.2.4-3-cachyos` post-reboot
- [ ] If CDN77 max-filesize recurs, demote cdn77 or set `ParallelDownloads = 5`

## Next steps

- David reboots, verifies `uname -r` and snapshot 124 as rollback if needed
- Return to team for any post-reboot issues

## Cross-links

- `[[2026-09-03-20-30_larry_pacman-chaotic-aur-fix-rex-integration]]` — last time's chaotic-aur lsign fix, contrasted this session
- `[[2026-08-21-16-00_larry_shelly-cli-breaks-pacman-signatures]]` — Shelly 0640 + missing .sig pattern ruled out here
- `[[2026-08-20-15-55_larry_cachyos-nvidia-suspend-and-shelly-fix]]` — prior full keyring reset reference
- `[[2026-07-31-18-11_larry_cachyos-pacman-keyring-fix]]` — stale cachyos-keyring / TNE key root history
