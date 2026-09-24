---
agent_id: larry
session_id: cosmic-hotkeys-mypka-wrapper
timestamp: 2026-09-24T13:32:00Z
type: close-session  # close-session | mid-session-insight | realignment | proactive
linked_sops: []
linked_workstreams: []
linked_guidelines: []
---

# COSMIC hotkeys: LibreOffice, myPKA wrapper, ghostty cleanup

## Context

User reported LibreOffice GLib warnings on CachyOS/COSMIC, then asked for COSMIC hotkeys for LibreOffice and for the interactive `myPKA` opencode starter script, ending with a ghostty config question.

## What we did

- Rex diagnosed the LibreOffice `GLib-GObject-CRITICAL ... has no handler with id` spam as harmless GTK teardown noise: `libreoffice-fresh 26.8.0` stayed RUNNING on Wayland/COSMIC in both StartCenter and `--writer` tests.
- Rex confirmed `libreoffice` (no args) = StartCenter via `libreoffice-startcenter.desktop`.
- Rex mapped COSMIC shortcuts: `~/.config/cosmic/com.system76.CosmicSettings.Shortcuts/v1/custom` uses `Spawn("...")`; `%U` is `.desktop`-only.
- Rex found default terminal in `.../Shortcuts/v1/system_actions` (`Terminal: "/usr/bin/ghostty --gtk-single-instance=true"`); `cosmic-term 1.8.0` has no `-e` flag, `ghostty -e` works.
- Rex wrote `~/.local/bin/myPKA-hotkey` wrapper that parses `system_actions` Terminal entry and execs `ghostty -e /home/dabrown/.local/bin/myPKA`.
- Larry fixed hotkey path typo in `custom:25` (`~/.local/myPKA-hotkey` → `~/.local/bin/myPKA-hotkey`).
- Rex removed deprecated `background-blur-radius` and `bold-is-bright` from `~/.config/ghostty/config` (replaced by `background-blur` / `bold-color` since 1.2.0); classified remaining ghostty/Adwaita log lines as upstream noise.

## Decisions made

- **Question:** Bare `myPKA` as hotkey command or terminal-wrapped?
  **Decision:** Terminal-wrapped, since `myPKA` runs interactive `opencode` TUI plus `read -p` prompts.
- **Question:** Hardcode ghostty or follow COSMIC default?
  **Decision:** Wrapper reads `system_actions` so the hotkey follows whatever `System(Terminal)` / Super+Return uses.

## Insights

- COSMIC `System(Terminal)` takes no args; custom command-in-terminal must go through `Spawn("<term> -e <cmd>")` or a wrapper.
- `Spawn` does no `~` expansion; use absolute paths.
- Ghostty `-e` launch from an existing terminal dumps verbose `info:`/`warning:` startup log to the parent; via hotkey it is invisible and harmless.

## Realignments

- _(none this session)_

## Open threads

- [ ] User to test Super+Shift+P after path fix; confirm new ghostty window runs `myPKA` end-to-end.

## Next steps

- If hotkey still silent, check for keybinding conflict and restart `cosmic-settings-daemon` to reload `custom`.
- Consider graduating COSMIC `Spawn` + default-terminal wrapper pattern to a Guideline if reused.

## Cross-links

- `[[2026-09-15-cosmic-hybrid-hdmi]]` — closest prior COSMIC session log.
