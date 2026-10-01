---
agent_id: larry
session_id: 2026-10-01-rog1-hdmi-battery-power-automation
timestamp: 2026-10-01T17:14:00Z
type: close-session  # close-session | mid-session-insight | realignment | proactive
linked_sops: []
linked_workstreams: []
linked_guidelines: ["GL-001-file-naming-conventions"]
---

# HDMI recurrence fixed + battery automation shipped (rog1)

## Context

David reported HDMI no-signal again on his ASUS ROG (`rog1`, CachyOS, COSMIC) — recurrence of the Sept 15 Hybrid HDMI issue, now on cosmic-comp 1.9.0. Session grew into battery-life analysis for MUX vs Hybrid and a fully installed unplug automation.

## What we did

- Rex re-triaged live: Hybrid, kernel 7.2.8, cosmic-comp/randr 1.9.0, HDMI now on `card2-HDMI-A-3` (NVIDIA) vs `card1` (Intel) on Sept 15; same `Unable to become drm master` lines plus new `Failed to create drm surface: Output has no active mode`.
- Rex identified the 1.9.0 behavior change: `cosmic-randr enable` alone fails with `configuration failed`; direct 4K mode-set silently does nothing.
- David found the working bootstrap (1080p first, then 4K); Rex verified `HDMI-A-3 (enabled)` at `3840x2160@60` and documented it.
- Rex updated `Deliverables/2026-09-15-cosmic-hybrid-hdmi-evidence.md` with the 2026-10-01 delta (routing change, new log signature, workaround v2, verified final state).
- Rex + Pax estimated MUX battery cost from David's real battery (66 Wh / 90 Wh design, 73%): MUX ~2.2h vs Hybrid ~5.5h light use; recommended staying Hybrid given the weekly 2hr meeting with zero margin.
- Rex wrote `Deliverables/2026-10-01-rog1-dock-meeting-checklists.md` (docked HDMI on/off, meeting battery on/off, brightness pairs, do-not-do list).
- Rex verified brightness split: `brightnessctl` = laptop panel only (`nvidia_wmi_ec_backlight`), `ddcutil setvcp 10` = ASUS MS27UC over HDMI only; eDP reports no DDC/CI.
- Mack drafted, David reviewed, Mack finalized and installed `rog1-power` (extensionless): `~/.local/bin/rog1-power` + user systemd `rog1-power.path/.service`, active and test-fired.
- Mack fixed a real ordering bug found in testing (`powerprofilesctl` after `asusctl` dragged platform back to Balanced; reordered asusctl-last, verified Performance sticks).
- Mack renamed `rog1-power.sh` to `rog1-power` across source, live copy, service file, and install doc on David's request.

## Decisions made

- **Question:** MUX or Hybrid daily?
  **Decision:** Stay Hybrid; MUX turns the 2hr meeting into ~1.4hrs. MUX only ever docked-and-plugged, with reboot back before meeting day.
- **Question:** Where does the automation live?
  **Decision:** Script source of truth in `Deliverables/2026-10-01-rog1-power-automation/`, live in `~/.local/bin/rog1-power`, user-systemd path trigger (no udev, no root). Timer dropped to back pocket.
- **Question:** Does unplugged/no-HDMI scripting need ddcutil?
  **Decision:** No — script skips ddcutil when no HDMI `status == connected`, since it would just error.

## Insights

- COSMIC 1.9.0 requires an active mode to enable an output: cold 4K allocation on the NVIDIA-driven HDMI fails, 1080p bootstrap then step-up works. 1.8.0 two-step (`enable` then `mode`) is dead.
- ASUS MUX laptops move the HDMI port between GPUs per mode (Intel `HDMI-A-3` → NVIDIA `HDMI-A-3` across updates); always glob `card*-HDMI-*/status`, never hardcode `card1`/`card2`.
- `powerprofilesctl` (power-profiles-daemon) and `asusctl profile` (platform_profile) fight: last writer wins on platform profile. Set powerprofilesctl first, asusctl last.
- `(return 0 2>/dev/null) || main "$@"` makes bash scripts source-safe with zero cost to systemd ExecStart; pair with an explicit comment or future-David will be confused.
- ddcutil first-touch on this monitor throws `DDCRC_RETRIES` probe noise but still applies the set — harmless, not a failure.

## Realignments

- _(none this session — David steered: requested checklist for both on/off sides, script preview before install, timer dropped, extensionless rename; all applied as asked)_

## Open threads

- [ ] Next unplug is the first real-world firing of `rog1-power.path` — confirm Quiet + power-saver + 40% engages (David to report).
- [ ] If `.path` ever misses an unplug on kernel 7.2.8, install the back-pocket 30s timer in `INSTALL-REVIEW-ONLY.md`.
- [ ] Upstream: paste 2026-10-01 evidence to https://github.com/pop-os/cosmic-comp/issues/2627 (draft + pack ready since Sept 15).
- [ ] Battery at 73% (66/90 Wh) is why the 2hr meeting has no margin; replacement restores ~2.7hrs Hybrid.
- [ ] Uncommitted work in git: `M Deliverables/2026-09-15-cosmic-hybrid-hdmi-evidence.md`, `?? Deliverables/2026-10-01-rog1-dock-meeting-checklists.md`, `?? Deliverables/2026-10-01-rog1-power-automation/` — commit not requested, left in working tree.

## Next steps

- Watch next unplug event; check `journalctl --user -u rog1-power.service` + `rog1-power --status`.
- Re-test HDMI bootstrap after next cosmic-comp / kernel / supergfxd update; recurrence pattern is update-driven.

## Cross-links

- [[2026-09-15-cosmic-hybrid-hdmi]] — prior session: original diagnosis, workaround v1, evidence pack v1.
