---
agent_id: larry
session_id: 2026-09-12-20-35-larry-tpm-signing-break-and-reenroll-check
timestamp: 2026-09-13T03:35:10Z
type: close-session
linked_sops: []
linked_workstreams: []
linked_guidelines: []
---

# TPM PCR7 break on 7.2.4-3 chain rebuild fixed by re-enroll, guard script added

## Context

David came in reporting the 7.2.4-3 update succeeded with no password prompts via TPM, then clarified the two threads I listed, asked for future-handling options, and challenged whether the CDN77 and TPM breaks were real. Session became a TPM forensics + prevention build.

## What we did

- Larry routed CachyOS/TPM work to Rex per [[agent-index]].
- Rex verified `uname -r 7.2.4-3-cachyos`, `linux-cachyos 7.2.4-3` + headers + lts in place.
- Rex confirmed `ParallelDownloads = 10` with cdn77 first; David set `= 5`, Rex verified live.
- Rex pulled `journalctl -b 0` + `-b -1`: both show `TPM policy does not match current system state` on `luks-e6514b65` (root) and `luks-0feb9776` (storage). 19:26 boot took 27s + 12s password waits (broken), 19:42 boot took 1s each with no prompt (post-reenroll fixed, one stale-token line remains).
- Rex pulled `/var/log/pacman.log 10:39:31-10:40:07`: not kernel-only — `systemd 261.2-1 -> 261.3-1` + `mkinitcpio 41.1-2 -> 42-1` + limine re-sign + sbctl bundle regen + snapshot 124.
- Rex compared August signs (08-17, 08-21, 08-25 limine 12.6.0->12.6.1, 08-28 kernel 7.2.0->7.2.2) — all signing-only, none broke TPM, none had systemd/mkinitcpio upgrades.
- Rex wrote `Team/Rex - Senior Administrator/scripts/check-tpm-reenroll.sh` (UUID-based, handled-state, prompts only on core crypto upgrades), syntax-checked and live-tested against Sep 12 log.

## Decisions made

- **Question:** Default handling for future system-update breaks?
  **Decision:** Option 2 — Rex triages read-only, hands David sudo commands, David pastes back output. Recorded as default.
- **Question:** Which grep signals a TPM-risky update?
  **Decision:** Only `upgraded (systemd |systemd-libs|mkinitcpio )` with trailing spaces. `Signed`, `Generating EFI bundles`, `limine`, `sbctl`, `systemd-resolvconf/sysvcompat/lib32-systemd` alone are safe (proven Aug 17-28).
- **Question:** Hire a developer for the post-update check?
  **Decision:** No — Rex-scope bash script, delivered and tested. No Nolan hire.
- **Question:** Auto re-enroll hook?
  **Decision:** Rejected — high blast radius on LUKS seals. Manual 2-command re-enroll via script prompt instead. Stay on PCR 7 only.

## Insights

- PCR 7 seals Secure Boot chain state, not kernel version — re-signing vmlinuz/limine with same key preserves it (4x August proof). systemd + mkinitcpio major in same run is what invalidated it.
- `19:42` 1x-fail + 1s unlock vs `19:26` 2x-fail + 27s wait is the fingerprint of stale-token noise + new seal working vs fully broken.
- NVMe order swapped (`nvme0n1p2/p5` in 09-04 notes vs `nvme1n1p2/p5` now, UUIDs `e6514b65` / `0feb9776`) — UUID paths required in all future commands.
- `ParallelDownloads = 10` + cdn77 first trips `Maximum file size exceeded` on large v3 kernels; `= 5` avoids it, fallback to krfoss masks it.
- `mkinitcpio` warns `/etc/crypttab.initramfs is deprecated` — merge into `/etc/crypttab` with `x-initrd.attach` before a future initrd build complains louder.

## Realignments

- "nothing to do with sudoers. reboot used tpm to provide passwords to decrypt partitions" — corrected my sudoers detour back to TPM auto-unlock.
- "I don't think I have these 2 open issues. What are my options for dealing with a change like this in the future" — forced latent-vs-active split (CDN77 latent, LUKS recovery truly open).
- "Something broke TPM after kernel update to 7.2.4-3 (that is what we just fixed)" — corrected my no-prompt = healthy read; logs showed policy mismatch, user pointed to real break.
- "I thought I have had kernel updates before that didn't get broken was this a fluke or a real issue" — drove August log comparison that isolated systemd/mkinitcpio as the breaker.
- "so the grep you provided wasn't specific enough to flag only things that would cause problem" — correct, tightened to core-only grep.
- "is it an upgrade to anything with systemd in name (i.e systemd-resolv.conf) our just systemd" — narrowed to systemd/systemd-libs/mkinitcpio, excluded resolvconf/sysvcompat riders.
- "I don't know what you are talking about, I have rebooted and did not get prompted for passwords after re-enrolling" — correct; 19:42 is the fixed boot, my `grep -c 2` counted stale-token noise.

## Open threads

- [ ] David to run USB header + slot-2 recovery from `[[luks-recovery-keys-and-header-backup]]` when home (spare key, does not fix TPM)
- [ ] David to answer N on first `check-tpm-reenroll.sh` run for already-handled 09-12, or Larry to mark handled on request
- [ ] Optional: merge `/etc/crypttab.initramfs` deprecation warning before next mkinitcpio 42+ build
- [ ] Optional: write 1-page `tpm-break-recover.md` in `User Knowledge/Procedures/` (offered, not yet accepted)

## Next steps

- David runs check script after next `cachy-update`, before reboot; re-enrolls only on core hits
- Home session combines TPM stale-token cleanup (`luksDump` token check) + LUKS slot-2 + header backup under Option 2
- Next boot verify: `journalctl -b 0 --no-pager | grep -c 'TPM policy does not match'` expect 0

## Cross-links

- `[[2026-09-12-17-43_larry_cachyos-v3-corrupt-packages-fix]]` — Sep 12 mirror-rotate fix this builds on
- `[[2026-09-04-15-00_larry_luks-recovery-codes-and-procedure-fix]]` — slot 0/1/PCR7 layout + open recovery procedure
- `[[2026-09-03-20-30_larry_pacman-chaotic-aur-fix-rex-integration]]` — prior chaotic-aur contrast
