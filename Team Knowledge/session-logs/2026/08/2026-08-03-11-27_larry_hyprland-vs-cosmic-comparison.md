---
agent_id: larry
session_id: hyprland-vs-cosmic-comparison
timestamp: 2026-08-03T11:27:00Z
type: close-session
linked_sops: []
linked_workstreams: []
linked_guidelines: []
---

# Hyprland vs COSMIC Keybinding Comparison & Migration Considerations

## Context

The user asked for a comparison of their Hyprland/Noctalia keybindings versus COSMIC defaults to understand where they align and differ. This evolved into a broader discussion about the reliability of Hyprland versus COSMIC as a daily driver, with the user revealing significant pain points with Hyprland stability.

## What we did

- Larry analyzed the user's Hyprland config at `~/.config/hypr/config/binds.lua` and COSMIC defaults from official documentation
- Larry produced a detailed comparison table of matching and differing keybindings
- Larry explained the difference between "Close window" (graceful) and "Kill active window" (force kill)
- Larry provided a revised recommendation based on user feedback about Hyprland stability issues
- Larry created a concise COSMIC keybinding cheatsheet saved as `COSMIC-Keybindings.md` in the project root

## Decisions made

- **Question:** Should the user switch from Hyprland/Noctalia to COSMIC?
  **Decision:** leaning toward COSMIC due to Hyprland stability issues (broken zoom since .53, config breakage across versions, unreliable window rules, Noctalia v4→v5 breaking changes). Final decision pending user confirmation.

## Insights

- Hyprland window rules are unreliable — user reports that monitor assignment is ignored despite configuration
- Hyprland has had broken zoom functionality since version .53
- Both Hyprland and COSMIC are approximately the same age (Hyprland 2021, COSMIC 2022)
- COSMIC's stability advantage is significant for users who cannot afford workflow breakage
- The missing COSMIC features (scratchpads, clipboard manager, emoji picker) can be addressed with standalone tools

## Realignments

- Larry initially recommended staying with Hyprland based on feature completeness, but revised to recommending COSMIC after user pointed out that Hyprland's features (like window rules) don't actually work reliably. Feature count means nothing if the features are broken.

## Open threads

- [ ] User to confirm whether they want to proceed with COSMIC migration
- [ ] If migrating, need to identify standalone tools for: clipboard manager, emoji picker, scratchpad functionality
- [ ] User may return to continue the migration planning

## Next steps

- Await user confirmation on COSMIC migration decision
- If proceeding, plan the migration steps including app replacements and keybinding muscle memory retraining

## Cross-links

- `COSMIC-Keybindings.md` — the cheatsheet created this session
