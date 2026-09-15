---
agent_id: larry
session_id: 2026-09-15-cosmic-hybrid-hdmi
timestamp: 2026-09-15T21:10:00Z
type: close-session  # close-session | mid-session-insight | realignment | proactive
linked_sops: []           # ["SOP-001-how-to-add-a-new-specialist"]
linked_workstreams: []    # ["WS-001-daily-journaling"]
linked_guidelines: []     # ["GL-001-file-naming-conventions"]
---

# COSMIC Hybrid HDMI no-signal — diagnosed, workaround stable, evidence saved

## Context

David reported COSMIC not driving his HDMI monitor in Hybrid mode on his ASUS
ROG laptop (CachyOS). Session ran plan-mode diagnosis → build-mode evidence
capture, routed through Rex.

## What we did

- Rex ran read-only DRM/GPU triage: Intel i915 + RTX 4060, `supergfxd` Hybrid, HDMI-A-3 on Intel iGPU connected-but-disabled, `Unable to become drm master` in logs.
- Rex ruled out hardware (Hyprland Hybrid works, MUX works) and isolated to cosmic-comp 1.8.0 reverse-PRIME / DRM-master failure.
- David added himself to `render` group (no fix alone), then forced enable via `cosmic-randr enable` + `mode` — HDMI came up and persisted across reboots; hot-plug verified.
- Corrected `cosmic-randr` syntax (`enable` takes no flags; mode/pos/scale belong on `mode` subcommand).
- Pax-side research (via Larry): confirmed open upstream issues cosmic-comp #2627 / #1644, cosmic-epoch #3012 / #3487; drafted a comment for #2627.
- Larry saved upstream evidence pack to `Deliverables/2026-09-15-cosmic-hybrid-hdmi-evidence.md` (failing boot `-3` excerpts, kernel DRM lines, workaround, regen commands).

## Decisions made

- **Question:** MUX or Hybrid for daily use?
  **Decision:** Stay on Hybrid with the forced-enable workaround; MUX remains the known-good fallback (`supergfxctl -m AsusMuxDgpu` + reboot).
- **Question:** File upstream bug now?
  **Decision:** Not yet filed — draft comment ready; David pastes to #2627 when ready. Evidence pack holds the excerpts (boot `-3` rotates out after ~6 boots).

## Insights

- ASUS MUX laptops re-route the physical HDMI port per graphics mode (Intel `HDMI-A-3` in Hybrid vs NVIDIA `HDMI-A-1` in MUX) — connector names change, which confuses `cosmic-randr` workflows.
- `nvidia-drm.modeset=1 fbdev=1` was already on the kernel cmdline on the failing boot — kernel params are NOT the fix here.
- cosmic-comp display state is not in a user-editable TOML; persistence lives in compositor state.
- Hybrid HDMI is post-login only by design (greeter is eDP-only); MUX shows SDDM on both.

## Realignments

- _(none this session)_

## Open threads

- [ ] David to paste draft comment to https://github.com/pop-os/cosmic-comp/issues/2627 (draft in chat + evidence pack).
- [ ] Optional: MUX↔Hybrid roundtrip stress test to confirm workaround persistence.
- [ ] Watch cosmic-comp 1.9+ / smithay updates for the upstream DRM-master fix; re-test auto-enable then.

## Next steps

- Next session: pick up any upstream replies or re-test after cosmic-comp update.

## Cross-links

- Evidence: `Deliverables/2026-09-15-cosmic-hybrid-hdmi-evidence.md`
