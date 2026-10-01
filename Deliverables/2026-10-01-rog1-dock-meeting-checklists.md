# ROG1 Docked + Meeting Checklists (2026-10-01)

Saved by Rex via Larry for David. Companion to `2026-09-15-cosmic-hybrid-hdmi-evidence.md`.
Machine: ASUS ROG (`rog1`), CachyOS, COSMIC 1.9.0, Hybrid default. Battery 66 Wh full / 90 Wh design (73%).

## Side A — Docked HDMI (turn on when you dock)

Use every time monitor says `HDMI1 - No signal` in Hybrid.

```bash
# 1. Confirm port seen (should say disabled + ASUSTek MS27UC)
cosmic-randr list | grep -A2 HDMI-A-3

# 2. Bootstrap — 1080p first creates the DRM surface, then step up
# Do NOT use `cosmic-randr enable` on 1.9.0 — fails with "configuration failed"
cosmic-randr mode HDMI-A-3 1920 1080 --refresh 60
cosmic-randr mode HDMI-A-3 3840 2160 --refresh 60

# 3. Verify
cosmic-randr list | grep -E 'HDMI-A-3|eDP-1|current'
# want: HDMI-A-3 (enabled) 3840x2160 @ 60Hz (current) (preferred)
```

Then set scale/position in Settings > Displays (known-good: HDMI 175% at 1536,0 + eDP 125%).
If direct 4K does nothing, you skipped step 2 — redo 1080p first.

Docked power (plugged in):

```bash
asusctl profile set Performance
asusctl battery info  # want 100% for docked
supergfxctl -g  # want Hybrid
```

## Side A OFF — Undock (before you walk to meeting)

```bash
# Disconnect external cleanly so compositor drops the output
cosmic-randr disable HDMI-A-3
# Unplug HDMI cable
```

## Side B — Meeting battery stretch (turn on before 2hr meeting)

Do night-before or 1hr before, plugged in:

```bash
asusctl battery oneshot 100  # one full charge even if limiter set
# charge to 100%, then unplug
```

On battery, right before meeting:

```bash
asusctl profile set Quiet
powerprofilesctl set power-saver
brightnessctl set 40%                  # laptop panel (was 35% on 2026-10-01)
ddcutil --display 1 setvcp 10 40       # external ASUS MS27UC brightness to 40 (was 50)
# close Steam/Discord, 1 browser window, mute animations if needed
supergfxctl -g  # confirm Hybrid (not AsusMuxDgpu) — MUX will kill the meeting
```

Expected: ~26-33W drain = 2.0 hrs on 66 Wh with zero margin. If `energy-rate` >33W you won't make it — lower brightness, kill background apps:

```bash
upower -d | grep energy-rate  # check live drain while on battery
```

## Side B OFF — Restore after meeting (back to docked)

```bash
asusctl profile set Performance
powerprofilesctl set balanced
brightnessctl set 70%                  # or your normal indoor level
ddcutil --display 1 setvcp 10 70       # restore external
# plug in, redock, run Side A turn-on again if HDMI shows No signal
asusctl battery info
```

## Do NOT do

- `supergfxctl -m AsusMuxDgpu` before the meeting — needs reboot, keeps 4060 awake (~+18W), turns 2.0 hrs into ~1.4 hrs.
- `supergfxctl --mode Integrated` while docked if you need HDMI — HDMI currently lives on NVIDIA `card2-HDMI-A-3`, may not light in Integrated. Test once, don't discover mid-meeting.
- Mix `supergfxctl` with other Optimus/MUX scripts — black-screen risk per asus-linux docs.
