# Install (INSTALLED 2026-10-01 — kept for reinstall/rollback reference)

```bash
# 1. Eyeball the three files in this folder first
# 2. Install script (extensionless)
cp Deliverables/2026-10-01-rog1-power-automation/rog1-power ~/.local/bin/rog1-power
chmod +x ~/.local/bin/rog1-power
~/.local/bin/rog1-power --status   # read-only check

# 3. Install units (user manager, no sudo)
cp Deliverables/2026-10-01-rog1-power-automation/rog1-power.path ~/.config/systemd/user/
cp Deliverables/2026-10-01-rog1-power-automation/rog1-power.service ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable --now rog1-power.path
systemctl --user status rog1-power.path

# 4. Test: unplug AC, then
journalctl --user -u rog1-power.service --no-pager | tail -n 20
~/.local/bin/rog1-power --status
```

Rollback:

```bash
systemctl --user disable --now rog1-power.path
rm ~/.config/systemd/user/rog1-power.path ~/.config/systemd/user/rog1-power.service
systemctl --user daemon-reload
# script in ~/.local/bin is inert without the path unit — delete or keep for manual use
```

Back pocket (dropped 2026-10-01, keep if .path misses events on kernel 7.2.8):

```ini
# rog1-power.timer (NOT installed)
[Unit]
Description=Poll power state fallback
[Timer]
OnBootSec=1min
OnUnitActiveSec=30s
Unit=rog1-power.service
[Install]
WantedBy=timers.target
```

Notes:
- HDMI auto-enable is intentionally NOT in the script — COSMIC 1.9.0 needs the manual 1080p-then-4K bootstrap (see `2026-09-15-cosmic-hybrid-hdmi-evidence.md` 2026-10-01 update). Script only adjusts brightness/profiles.
- `ddcutil` is skipped when `/sys/class/drm/card*-HDMI-*/status` shows disconnected (your unplugged/no-HDMI meeting case).
