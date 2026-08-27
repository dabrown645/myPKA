# Plan: Reset Repo History + Re-hire Rex

## Problem

The upstream repo (`myICOR/myPKA`) was re-initialized at v5.5.1, creating a completely new history with no common ancestor to our fork. This means:

- `git rebase upstream/main` fails every time (no shared history)
- The `myPKA` script's `sync_with_upstream()` function errors on every startup
- We can't pull framework updates

Additionally, the hiring process (SOP-001) has gaps:
- Missing step to create `journal/_template.md` for new specialists
- Missing step to update Larry's routing cheatsheet when hiring

Rex's setup is incomplete as a result — no journal template, routing not properly registered.

## Goal

1. Align our fork's history with upstream so the `myPKA` script works again
2. Preserve all personal content (PKM, Deliverables, session-logs, etc.)
3. Fix SOP-001 so future hires are set up correctly
4. Re-hire Rex properly through the fixed process

## Safety Net

**Before any changes**, create a complete backup. If anything goes wrong, restore this backup and `git push --force origin main` to get back to the current state.

---

## Step 1: Create Safety Net Backup

```bash
# From the repo root
cd ~/Projects/myPKA/main

# Create a complete backup directory
mkdir -p ~/Projects/myPKA-backup-2026-08-26

# Copy everything including .git
rsync -a --progress ./ ~/Projects/myPKA-backup-2026-08-26/
```

**Verify backup:**
```bash
ls -la ~/Projects/myPKA-backup-2026-08-26/
git -C ~/Projects/myPKA-backup-2026-08-26 log --oneline -3
```

Also back up the global opencode config:
```bash
cp -r ~/.config/opencode/ ~/Projects/myPKA-backup-2026-08-26/opencode-config/
```

---

## Step 2: Save Personal Content

Before resetting, identify and save all personal content. The key directories:

```bash
# Create staging area for personal content
mkdir -p ~/Projects/myPKA-personal-2026-08-26

# Copy personal content directories
cd ~/Projects/myPKA/main
cp -r PKM/ ~/Projects/myPKA-personal-2026-08-26/
cp -r Deliverables/ ~/Projects/myPKA-personal-2026-08-26/
cp -r "Team Knowledge/session-logs/" ~/Projects/myPKA-personal-2026-08-26/
cp -r "Team/Rex - Senior Administrator/" ~/Projects/myPKA-personal-2026-08-26/
cp -r "User Knowledge/" ~/Projects/myPKA-personal-2026-08-26/
cp -r "Expansions/" ~/Projects/myPKA-personal-2026-08-26/
cp -r "Team Inbox/" ~/Projects/myPKA-personal-2026-08-26/
cp -r ".mypka/" ~/Projects/myPKA-personal-2026-08-26/
```

**Verify the backup has everything:**
```bash
du -sh ~/Projects/myPKA-personal-2026-08-26/
ls ~/Projects/myPKA-personal-2026-08-26/
```

---

## Step 3: Reset Repo to Align with Upstream

This is the critical step. We reset `main` to point at upstream's history, then re-add personal content on top.

```bash
cd ~/Projects/myPKA/main

# Verify upstream is fetched
git fetch upstream

# Confirm upstream/main is at v5.5.2
git log --oneline upstream/main -3

# Create a backup branch (safety net within git)
git branch backup-main

# Reset main to upstream's history
git reset --hard upstream/main

# Verify we're now on upstream's commits
git log --oneline -3
# Should show: 7b77800, 1f59212
```

**At this point, the working tree matches upstream. All personal files are gone from the working tree (but preserved in `backup-main` branch and in `~/Projects/myPKA-personal-2026-08-26/`).**

---

## Step 4: Restore Personal Content

Copy all personal content back into the working tree:

```bash
cd ~/Projects/myPKA/main

# Restore personal content from staging area
cp -r ~/Projects/myPKA-personal-2026-08-26/PKM/ ./PKM/
cp -r ~/Projects/myPKA-personal-2026-08-26/Deliverables/ ./Deliverables/
cp -r ~/Projects/myPKA-personal-2026-08-26/session-logs/ "./Team Knowledge/session-logs/"
cp -r ~/Projects/myPKA-personal-2026-08-26/User\ Knowledge/ ./User\ Knowledge/
cp -r ~/Projects/myPKA-personal-2026-08-26/Expansions/ ./Expansions/
cp -r ~/Projects/myPKA-personal-2026-08-26/Team\ Inbox/ ./Team\ Inbox/
cp -r ~/Projects/myPKA-personal-2026-08-26/.mypka/ ./.mypka/

# Restore Rex's files
cp -r ~/Projects/myPKA-personal-2026-08-26/Rex\ -\ Senior\ Administrator/ "./Team/Rex - Senior Administrator/"
```

**Verify personal content is back:**
```bash
ls PKM/
ls Deliverables/
ls "Team/Rex - Senior Administrator/"
```

**Commit the personal content:**
```bash
git add --all
git commit -m "restore: personal content after upstream history alignment"
```

---

## Step 5: Fix SOP-001 (Two Gaps)

Now that the repo is aligned with upstream and personal content is restored, fix the hiring process so Rex (and future hires) get set up correctly.

### Gap 1: Add journal/_template.md step

Add a new step between current Step 5 (host shims) and Step 6 (agent-index). The template is identical across all specialists — copy from any existing one.

**New Step 6 — Create journal template (Nolan)**

Create `Team/<Name> - <Role>/journal/_template.md` by copying from any existing specialist:
```bash
cp "Team/Larry - Orchestrator/journal/_template.md" "Team/<Name> - <Role>/journal/_template.md"
```

The template is 29 lines, identical across all 6 core specialists (verified by md5sum).

### Gap 2: Update Larry's routing cheatsheet

Add a new step after the agent-index update. The routing cheatsheet at `Team/Larry - Orchestrator/AGENTS.md` lines 143-161 is where Larry dispatches user phrases to specialists.

**New Step 7 — Update Larry's routing cheatsheet (Nolan)**

Edit `Team/Larry - Orchestrator/AGENTS.md`. In the routing cheatsheet table, add a row with:
- User input patterns that should route to the new specialist
- The specialist's name

Pull trigger patterns from the new specialist's `AGENTS.md` "When Larry routes to them" section.

### Updated SOP-001 step sequence

Current steps 6-9 become steps 6-11:

| Step | Action |
|---|---|
| 6 | Create journal template |
| 7 | Add row to agent-index |
| 8 | Update Larry's routing cheatsheet |
| 9 | Update relevant Workstreams |
| 10 | Confirm with user |
| 11 | Log the hire |

---

## Step 6: Re-hire Rex Properly

Now that SOP-001 is fixed and the repo is aligned, re-hire Rex through the proper process.

### What gets recreated:
- `Team/Rex - Senior Administrator/AGENTS.md` — the contract (already exists from backup, but verify it's correct)
- `Team/Rex - Senior Administrator/journal/_template.md` — **was missing, now created**
- `.claude/agents/rex.md` — host shim
- `Team/agent-index.md` — Rex's row
- Larry's routing cheatsheet — Rex's triggers

### What doesn't need recreation:
- Rex's folder structure already exists
- Rex's AGENTS.md already exists and is comprehensive
- Just need to add the missing pieces

**Steps:**
1. Copy the journal template: `cp "Team/Larry - Orchestrator/journal/_template.md" "Team/Rex - Senior Administrator/journal/_template.md"`
2. Verify `.claude/agents/rex.md` exists (it does — created during original hire)
3. Verify `Team/agent-index.md` has Rex's row
4. Verify Larry's routing cheatsheet has Rex's triggers

**Commit:**
```bash
git add --all
git commit -m "fix(rex): complete setup — add journal template, verify routing"
```

---

## Step 7: Push to Origin

```bash
# Force-push since we rewrote history
git push --force-with-lease origin main
```

**Verify on GitHub:**
- Check `github.com/dabrown645/myPKA` shows the new history
- Confirm all personal content is present

---

## Step 8: Verify the myPKA Script Works

```bash
# Test the sync function
cd ~/Projects/myPKA/main
git fetch upstream
git rebase upstream/main
# Should succeed (common ancestor now exists)
git rebase --abort  # don't actually rebase yet, just verify it starts
```

---

## Tech Debt (for later)

| Item | Description |
|---|---|
| **myPKA script conflict resolution** | Add `myPKA --resolve` subcommand for interactive conflict resolution when rebase fails |
| **Scaffold extension point** | Request from myICOR: a `## User Customizations` section in AGENTS.md files that the updater preserves during overwrite |
| **SOP-001 gap tracking** | Monitor if myICOR fixes these gaps in a future release; if so, the local fix can be dropped during next scaffold update |

---

## Rollback (if something goes wrong)

```bash
cd ~/Projects/myPKA/main

# Option 1: Restore from backup branch
git reset --hard backup-main
git push --force-with-lease origin main

# Option 2: Restore from full backup
rsync -a --progress ~/Projects/myPKA-backup-2026-08-26/ ./
git push --force-with-lease origin main
```

Either option gets you back to the current state (old history chain, all content intact).
