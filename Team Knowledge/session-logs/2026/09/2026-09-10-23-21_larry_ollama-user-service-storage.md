---
agent_id: larry
session_id: ollama-user-service-storage
timestamp: 2026-09-10T23:21:48Z
type: close-session
linked_sops: []
linked_workstreams: []
linked_guidelines: []
---

# Ollama moved to user systemd unit on /Storage, pacman vs curl clarified

## Context

David came back after the 09-08 cloud-only decision to do local-AI experimenting outside myPKA. He had reinstalled ollama-cuda and wanted systemd pointed at his owned path `/Storage/dabrown/ollama`, then clarified: make it a user unit, not a system unit. He also asked how the curl install differs from pacman on CachyOS.

## What we did

- Rex assessed stock state: `ollama-cuda 0.33.3-1.1`, system unit stock (`User=ollama`, `OLLAMA_MODELS=/var/lib/ollama`), `enabled` but `inactive`, no override, no user unit, `/Storage/dabrown/ollama` empty and owned `dabrown:dabrown`.
- Rex created `~/.config/systemd/user/ollama.service` (WorkingDirectory + `OLLAMA_MODELS=/Storage/dabrown/ollama`, `OLLAMA_HOST=127.0.0.1:11434`), then `daemon-reload + enable --now`.
- Rex verified: `active (running)`, server config log confirms `OLLAMA_MODELS:/Storage/dabrown/ollama`, API `{"models":[]}`, `ollama list` works.
- Rex answered pacman vs curl: same upstream version today, different packaging (split `ollama`+`ollama-cuda` v3-optimized + system cuda vs static upstream bundle in `/usr/local`, pacman-managed vs re-run-script, Arch lags upstream by hours/days). Recommendation: stay on pacman, don't mix.
- Larry flagged the one remaining sudo step (disable system unit to avoid :11434 clash) and the optional linger note.

## Decisions made

- **Question:** System override or user unit for local experimenting?
  **Decision:** User unit (`~/.config/systemd/user/ollama.service`) as `dabrown`, models on `/Storage/dabrown/ollama`. Matches ownership, avoids permission fights, keeps myPKA cloud-only stance intact.
- **Question:** Pacman or curl install on CachyOS?
  **Decision:** Stay on pacman (`ollama-cuda`); don't layer curl bundle over it.
- **Question:** Keep 7b reasoning models local?
  **Decision:** No change to 09-08 stance — small chat/code models only locally; full Larry stays cloud until 24GB+ VRAM.

## Insights

- User-unit approach sidesteps the `ollama` vs `dabrown` ownership fight entirely and needs no sudo except to silence the stock system unit.
- `Linger=no` means the user ollama stops on logout — fine for experimenting, needs `enable-linger` only if David wants boot-persistent local models.
- Empty `{"models":[]}` on first start is the expected clean-store signal, not an error.

## Realignments

- "oh yes I remember we made it a user config instead of a system one can you move it to user" — corrected the in-flight system-override plan to a user unit; system override was never applied (reinstall had wiped it).

## Open threads

- [ ] David to run `sudo systemctl disable --now ollama` to prevent boot-time port clash, then `systemctl --user restart ollama`.
- [ ] Optional: `sudo loginctl enable-linger dabrown` if local ollama should survive logout.
- [ ] Test pull (e.g. `ollama pull qwen2.5:3b`) and confirm blobs land in `/Storage/dabrown/ollama`.

## Next steps

- David runs the disable-now command and reports back if `systemctl --user is-active ollama` ever shows anything but `active`.
- Next local-AI session starts from a working user unit with empty store — pull small models first.

## Cross-links

- `[[2026-09-08-13-20_larry_ollama-purge-voice-programming-doctrine]]` — prior purge + cloud-only decision this session builds on.
