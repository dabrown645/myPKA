# COSMIC Keyboard Shortcuts

## Launcher & Apps

| Shortcut | Action |
|----------|--------|
| `Super` | Open Launcher |
| `Super + /` | Launcher (alt) |
| `Super + T` | Terminal |
| `Super + F` | Files |
| `Super + B` | Web Browser |
| `Super + A` | App Library |
| `Super + W` | Workspace Overview |

## Navigation

| Shortcut | Action |
|----------|--------|
| `Super + Arrow/hjkl` | Focus next window |
| `Super + Tab` | Switch windows |
| `Super + Shift + Tab` | Switch windows (reverse) |
| `Super + Alt + Arrow/hjkl` | Focus next display |
| `Super + Ctrl + Arrow/hjkl` | Focus next workspace |
| `Super + 1-9` | Go to workspace 1-9 |
| `Super + 0` | Last workspace |

## Window Management

| Shortcut | Action |
|----------|--------|
| `Super + Q` | Close window |
| `Super + M` | Maximize |
| `Super + F11` | Fullscreen |
| `Super + G` | Toggle floating |
| `Super + Y` | Toggle tiling |
| `Super + S` | Toggle stacking |
| `Super + O` | Toggle orientation |
| `Super + X` | Swap windows |
| `Super + R` / `Super + Shift + R` | Resize |
| `Super + U` | Select more windows in tiling tree |
| `Super + I` | Select fewer windows in tiling tree |

## Move Windows

| Shortcut | Action |
|----------|--------|
| `Super + Shift + Arrow/hjkl` | Move window (follows workspaces, then displays) |
| `Super + Alt + Shift + Arrow/hjkl` | **Move window to next display** |
| `Super + Ctrl + Shift + Arrow/hjkl` | Move window to next workspace |
| `Super + Shift + 1-9` | Move window to workspace 1-9 |
| `Super + Shift + 0` | Move window to last workspace |

## Multi-Monitor

| Shortcut | Action |
|----------|--------|
| `Super + Alt + Arrow/hjkl` | Focus next display |
| `Super + Alt + Shift + Arrow/hjkl` | Move window to next display |

> **Tip:** Use `Super + Alt + Shift + Left/Right` to send the active window to the adjacent monitor. Works in both tiling and floating mode.

## System

| Shortcut | Action |
|----------|--------|
| `Super + Escape` | Lock screen |
| `Super + Shift + Escape` | Log out |
| `Super + Alt + Escape` | Terminate |
| `Print` | Screenshot |
| `Super + Space` | Switch input source |
| `Super + =/-` or `Super + ./,` | Zoom in/out |

## Hardware

| Shortcut | Action |
|----------|--------|
| `XF86AudioRaise/LowerVolume` | Volume |
| `XF86AudioMute` | Mute |
| `XF86AudioMicMute` | Mic mute |
| `XF86MonBrightnessUp/Down` | Brightness |
| `XF86AudioPlay/Prev/Next` | Media |

## Vim Navigation

Arrow keys can be replaced with:

| Key | Direction |
|-----|-----------|
| `h` | Left |
| `j` | Down |
| `k` | Up |
| `l` | Right |

## Custom Shortcuts

Custom shortcuts are stored at:
`$HOME/.config/cosmic/com.system76.CosmicSettings.Shortcuts/v1/custom`

Defaults are at:
`/usr/share/cosmic/com.system76.CosmicSettings.Shortcuts/v1/defaults`

### Notes

- Config files are in RON (Rust Object Notation) format
- Disable shortcuts by mapping to `Disabled`
- Some keys may be captured wrong in the UI (e.g., Pause Break shows as `Break`)
- All bindings can be modified in COSMIC Settings > Input Devices > Keyboard > Keyboard Shortcuts

---

*Source: System76 Support & COSMIC Documentation*
