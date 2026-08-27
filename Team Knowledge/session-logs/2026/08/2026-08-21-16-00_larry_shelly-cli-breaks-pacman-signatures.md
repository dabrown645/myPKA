---
agent_id: larry
session_id: shelly-cli-breaks-pacman-signatures
timestamp: 2026-08-21T16:00:00Z
type: close-session
linked_sops: []
linked_workstreams: []
linked_guidelines: []
---

# Shelly CLI Updates Break Pacman Signature Verification

## Context

David returned with a recurring issue: running `shelly` CLI to apply updates breaks `pacman -Ss` with signature errors. He fixed it yesterday, ran Shelly updates today, and it broke again. This is NOT a simultaneous-use issue — he only runs Shelly, never pacman alongside it. The Shelly GUI also hung on startup after the CLI update (had to reinstall `cosmic-osd` to fix, same polkit agent issue from previous session).

## What we did

- Larry researched the issue across CachyOS forums and GitHub — most reported issues involve running Shelly + pacman simultaneously, which doesn't apply here
- Larry checked `pacman.conf` — looks correct (`Required DatabaseOptional`, no `TrustAll` leak)
- Larry checked `/var/lib/pacman/sync/` — CachyOS repos have `.sig` files, but `core.db`, `extra.db`, `multilib.db` are missing their `.sig` files
- Larry checked Shelly config (`~/.config/shelly/config.json`) — clean, no weird sync settings
- Larry checked Shelly logs — successful update session, no errors
- Larry checked mirrorlist — `cachyos-rate-mirrors` output looks normal
- **REPRODUCED (Aug 22):** David ran `pacman -Ss git` (worked) → `shelly` (applied updates) → `pacman -Ss git` (all 8 databases failed)
- Rex captured diagnostics: ALL `.sig` files gone, ALL `.db` files written with `0640` instead of `0644`
- Shelly log showed exit code 0 — no errors reported despite corrupting the sync database
- Rex ran `sudo pacman -Syy` to restore correct permissions and sigs — confirmed working

## Decisions made

- **Question:** Should we investigate further now or wait for recurrence?
  **Decision:** Wait for recurrence. David will capture diagnostic output next time before fixing.

- **Question:** Is this bug already reported?
  **Decision:** No. Searched GitHub issues, discussions, and CachyOS forums — this specific bug (0640 permissions + missing .sig files) is unreported.

- **Question:** File a bug report?
  **Decision:** Yes. Drafted report at `Deliverables/shelly-bug-report-database-permissions.md`. Issue creation is restricted on the Shelly repo — report needs to be posted as a Q&A discussion.

## Insights

- **ROOT CAUSE CONFIRMED:** Shelly CLI (v3.0.6-1) writes `.db` files with `0640` (`-rw-r-----`) instead of `0644` (`-rw-r--r--`), and does not fetch `.db.sig` files at all. This breaks all subsequent pacman operations.
- **Shelly reports success despite corruption** — exit code 0, no errors in `/var/log/shelly.log`. The corruption is silent.
- **All 8 repos affected** — `cachyos-v3`, `cachyos-extra-v3`, `cachyos-core-v3`, `cachyos`, `core`, `extra`, `multilib`, `chaotic-aur`. Not just CachyOS repos — standard Arch repos too.
- **100% reproducible** — same steps, same result, across 3 attempts over 2 days.
- **Fix: `sudo pacman -Syy`** — restores correct permissions and sigs. But recurses on next Shelly run.
- **Shelly v3.0.6-1 on CachyOS** — known to have other issues: GUI hangs, AUR/repo discrepancies, `SigLevel` modifications reported by other users
- **cosmic-osd polkit issue recurs** — Shelly GUI hang fixed by reinstalling `cosmic-osd`, same as previous session. This seems to be a recurring problem after Shelly updates
- **Not a simultaneous-use issue** — David never runs pacman alongside Shelly. The corruption happens during Shelly's own sync/update operation.

## Realignments

- Larry initially routed this as a "both running at same time" issue based on forum results. David correctly clarified he only runs Shelly. This changes the diagnosis — the issue is Shelly's sync/update behavior itself, not lock contention.
- Larry initially assessed `.sig` files missing only on standard Arch repos. After reproduction, ALL repos (including CachyOS) lose their `.sig` files. The initial observation was from a partially-broken state.

## Open threads

- [x] Shelly CLI update breaks pacman signatures — **ROOT CAUSE FOUND** (0640 perms + missing .sig files). Fix: `sudo pacman -Syy`. recurses on next Shelly run.
- [ ] Shelly GUI hang after CLI updates — recurring, fixed by reinstalling `cosmic-osd` but root cause unknown
- [x] Bug report posted to Shelly GitHub Q&A discussions

## Next steps

- **Workaround:** Use `sudo pacman -Syu` for updates instead of Shelly CLI. Shelly is safe for browsing/searching only.
- If Shelly devs fix this, verify with: `shelly` → `ls -la /var/lib/pacman/sync/*.db` (should show `0644`) and `ls /var/lib/pacman/sync/*.sig` (should exist)
- Monitor Shelly releases for fix: https://github.com/Seafoam-Labs/Shelly-ALPM/releases

## Cross-links

- `[[2026-08-20-15-55_larry_cachyos-nvidia-suspend-and-shelly-fix]]` — Previous session: Shelly GUI hang fixed by reinstalling cosmic-osd (same polkit issue)
