# COSMIC Hybrid HDMI No-Signal — Upstream Evidence Pack (2026-09-15)

Saved by Rex via Larry for David. Paste-ready excerpts for
https://github.com/pop-os/cosmic-comp/issues/2627
(related: cosmic-comp #1644, cosmic-epoch #3012 / #3487).

## System

- Laptop: ASUS ROG (`rog1`), ASUS MUX design, `supergfxd` Hybrid mode
- OS: CachyOS rolling, kernel `7.2.5-1-cachyos`
- GPUs: Intel Raptor Lake-S UHD (`i915`, `card1`) + RTX 4060 Laptop GPU (`nvidia` 615.71.09, `card2`)
- Kernel cmdline already contains `nvidia-drm.modeset=1 nvidia-drm.fbdev=1` (present on failing boot — did NOT fix)
- COSMIC: `cosmic-comp 1:1.8.0-1.1`, `cosmic-randr 1:1.8.0-1.1`, Wayland
- External: ASUS MS27UC 4K over HDMI. Internal: BOE NE160WUM-NX2 1920x1200 165Hz

## Symptom

Hybrid boot: HDMI port routes to Intel iGPU (`card1-HDMI-A-3` = connected in
`/sys/class/drm`, EDID reads fine) but `cosmic-randr list` shows it `disabled`.
Monitor reports no-signal. Same port works in `AsusMuxDgpu` mode (routes to
NVIDIA as `HDMI-A-1`) and in Hyprland Hybrid — hardware/cable/EDID ruled out.

## Failing-boot evidence (boot `-3`, 2026-09-15 11:35 PDT, boot ID `55a6a07b…`)

Regen while retained (~6 boots in journal):
`journalctl --user -b -3 _COMM=cosmic-comp --no-pager | grep -Ei 'drm master|failed|error|hdmi|output|prime|restore|master'`

```
Sep 15 11:35:36 rog1 cosmic-comp[1585]: Unable to become drm master, assuming unprivileged mode
Sep 15 11:35:36 rog1 cosmic-comp[1585]: Unable to become drm master, assuming unprivileged mode
Sep 15 11:35:36 rog1 cosmic-comp[1585]: Failed to create sockets: Address already in use (os error 98)
Sep 15 11:35:36 rog1 cosmic-comp[1585]: Failed to remove X11 socket
Sep 15 11:35:36 rog1 cosmic-comp[1585]: Error reading from session socket
```

(Note: `dark theme GetKey` lines trimmed as unrelated packaging noise.
Socket lines are stale-socket noise from the prior crashed session.)

Kernel (`journalctl -b -3 -k | grep -Ei 'drm|i915|nvidia|hdmi'`): i915 loads
clean (GuC/HuC auth OK), nvidia-drm 615.71.09 loads, only EDID warnings are
for unconnected `DP-2`. No kernel-side HDMI failure — compositor-side.

## Workaround (stable, persists across reboots)

```bash
cosmic-randr enable HDMI-A-3
cosmic-randr mode HDMI-A-3 3840 2160 --refresh 60 --scale 2 --pos-x 0 --pos-y 0
```

After one forced enable + reboot: HDMI auto-enables on login at
3840x2160@60, hot-unplug/re-plug works. Adding user to `render` group alone
did not fix it. (Correct `cosmic-randr` syntax: `enable <OUTPUT>` takes no
flags; mode/pos/scale go on the `mode` subcommand.)

## Behavioral notes

- Hybrid: HDMI activates only AFTER login (greeter is eDP-only). MUX: SDDM on both displays pre-login. Consistent with greeter→session DRM-master handoff race (#1644).
- Hot mode-set once hung systemd input (keyboard dead, mouse alive); config survived the forced reboot.
- cosmic-comp display config is NOT in `~/.config/cosmic/comp*.toml` (does not exist) — persistence is via compositor state, not a user-editable TOML.

## 2026-10-01 Update — recurrence on cosmic-comp 1.9.0 (Hybrid, kernel 7.2.8)

System delta vs Sept 15:

- OS: CachyOS rolling, kernel `7.2.8-1-cachyos` (was 7.2.5)
- COSMIC: `cosmic-comp 1:1.9.0-1.1`, `cosmic-randr 1:1.9.0-1.1` (was 1.8.0), Wayland `cosmic` session
- `supergfxctl 5.2.7-2`, mode `Hybrid`, `supergfxd` healthy, NVIDIA 615.71.09 loaded (`nvidia-smi` shows `cosmic-comp` + `Xorg` clients)
- GPUs same: Intel Raptor Lake-S UHD (`i915`, `card1`) + RTX 4060 (`nvidia`, `card2`)
- Routing change: HDMI now `card2-HDMI-A-3` = connected in `/sys/class/drm` (NVIDIA). Sept 15 it was `card1-HDMI-A-3` (Intel). EDID still reads fine (ASUS MS27UC).
- Kernel cmdline still has `nvidia-drm.modeset=1 nvidia-drm.fbdev=1` — still NOT the fix.
- User already in `render` + `video` groups.
- `cosmic-randr list` again shows `HDMI-A-3 (disabled)` with full 4K60 mode list present (`3840x2160 @ 60Hz preferred`).

New failure mode on 1.9.0:

```bash
cosmic-randr enable HDMI-A-3
# Error: "configuration failed"
```

Log (`journalctl --user -b 0 _COMM=cosmic-comp`):

```
Oct 01 09:04:51 rog1 cosmic-comp[1874]: Failed to apply config. Resetting: Failed to create drm surface
  Caused by: Output has no active mode
```

Plus the same recurring lines as Sept 15:

```
Unable to become drm master, assuming unprivileged mode (x2)
Failed to create sockets: Address already in use (os error 98)
```

Workaround v2 (1.9.0 — skip `enable`, low-res bootstrap):

```bash
# 1. Do NOT use `enable` on 1.9.0 — rejected with "Output has no active mode"
# 2. Direct 4K mode-set silently does nothing:
cosmic-randr mode HDMI-A-3 3840 2160 --refresh 60
# 3. Working path found by David 2026-10-01 — set 1080p first to create DRM surface, then step up:
cosmic-randr mode HDMI-A-3 1920 1080 --refresh 60
cosmic-randr mode HDMI-A-3 3840 2160 --refresh 60
```

Verified final state 2026-10-01 09:08 PDT (`cosmic-randr list`):

- `HDMI-A-3 (enabled)` at `3840x2160 @ 60Hz (current) (preferred)`, Scale 175%, Pos 1536,0
- `eDP-1 (enabled)` at `1920x1200 @ 165Hz`, Scale 125%, Pos 0,274
- No more `Failed to create drm surface` after bootstrap — only `xrdb not found` noise (harmless, xrdb not installed).
