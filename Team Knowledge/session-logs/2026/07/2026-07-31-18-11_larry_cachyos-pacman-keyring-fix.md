---
agent_id: larry
session_id: cachyos-pacman-keyring-fix
timestamp: 2026-07-31T18:45:00Z
type: close-session
linked_sops: []
linked_workstreams: []
linked_guidelines: []
---

# CachyOS fresh install - pacman "unknown trust" signature errors

## Context

User is building a new CachyOS system and getting "signature from <X> is unknown trust" errors when trying to install packages from Chaotic-AUR and other repos. The same packages work fine on their existing CachyOS system. This is a fresh install from the `cachyos-desktop-linux-2060628.iso`.

## What we did

- Larry diagnosed the issue as a stale keyring on the fresh CachyOS install.
- Larry initially provided incorrect Chaotic-AUR key IDs (`FBA220DFC880C036`, `CFB8409CA9E10A94`) — these were outdated.
- User followed official Chaotic-AUR docs (`aur.chaotic.cx/docs`) which have the correct primary key: `3056513887B78AEB`.
- Larry confirmed the official docs are correct and acknowledged the bad key IDs.
- User clarified the system is CachyOS (not Garuda), which reframed the problem.
- Larry researched CachyOS-specific keyring issues and found it's a known recurring problem across multiple ISO releases.
- Larry provided the correct fix order: update keyrings first, then add Chaotic-AUR.
- Minimal keyring update (`pacman -Sy archlinux-keyring cachyos-keyring`) did not fix the issue.
- Full keyring reset (`rm -rf /etc/pacman.d/gnupg/ && pacman-key --init && --populate`) also did not fix it.
- Root cause identified: `chaotic-keyring` package itself is stale — doesn't include TNE's extended key (`D6C9442437365605`). TNE's key expired and was re-extended, but the upstream `chaotic-keyring` package hasn't been rebuilt.
- Larry helped user debug and correct their pyinfra provisioning script for setting up Chaotic-AUR on CachyOS.

## Decisions made

- **Question:** Should the user reset the entire keyring or just update the keyring packages?
  **Decision:** Minimal fix didn't work. Full reset didn't work. The issue is upstream — the `chaotic-keyring` package is stale and needs to be rebuilt by the maintainers.

- **Question:** What order should keyring update vs Chaotic-AUR setup be done in?
  **Decision:** Update keyrings first (while only official repos are active), then add Chaotic-AUR. Adding Chaotic-AUR before fixing the keyring causes pacman to fail on sync before it can even use the new repo.

- **Question:** Does the pyinfra script need to handle `y` prompts?
  **Decision:** Yes. `pacman-key --lsign-key` requires `printf 'y\n' |` (not `yes |` — it didn't work). `pacman -U` requires `--noconfirm`. The `script -q -c` approach from the original script was unnecessarily complex.

- **Question:** Should `files.block` (adding `[chaotic-aur]` to pacman.conf) come before or after `pacman.update()`?
  **Decision:** Before. If the repo isn't in pacman.conf when sync runs, chaotic-aur packages won't be found.

## Insights

- CachyOS ISOs have a recurring issue where the baked-in keyring goes stale before the ISO is re-released. This affects multiple ISO versions going back years (forum posts from 2024, 2025, 2026 all show the same problem).
- Always trust the project's own docs for signing keys over LLM-provided keys — key IDs change over time and LLMs may have stale training data.
- The "unknown trust" errors with different packager names (not just the repo key) indicates the local keyring is missing individual packager keys, not just the repo signing key.
- `pacman-key --lsign-key` needs `printf 'y\n' |` for non-interactive use — `yes |` doesn't work.
- The `chaotic-keyring` package from `cdn-mirror.chaotic.cx` may be stale upstream. TNE's key (`D6C9442437365605`) expired and was re-extended, but the keyring package hasn't been rebuilt to include it.
- The `cachyos-keyring` on the mirror was also stale (March 2024 on a July 2026 ISO).

## Realignments

- User corrected Larry's assumption that they were on Garuda Linux — the system is CachyOS.
- User corrected Larry's key IDs by pointing to the official Chaotic-AUR docs.

## Open threads

- [ ] Upstream `chaotic-keyring` package needs rebuild to include TNE's extended key — worth reporting to Chaotic-AUR maintainers.
- [ ] User's pyinfra script needs testing after the fixes are applied.

## Next steps

- User to apply the corrected pyinfra script to their CachyOS provisioning.
- Test that `paru` installs without "unknown trust" errors.
- Report the stale `chaotic-keyring` to Chaotic-AUR maintainers if TNE's key still isn't included after a fresh pull.

## Cross-links

- `[[2026-07-23-gpg-environment-fix-and-sop-planning]]` — prior session on GPG key management
- `[[2026-07-25-gpg-restore-and-user-knowledge-restructure]]` — prior session on GPG procedures
