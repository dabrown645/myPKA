# Team Knowledge / scripts

Utility scripts that ship with the myPKA scaffold. Two families live here:

- **One-shot migration and repair tools** you run once (or a handful of times),
  then forget about: `migrate-inline-fields-to-frontmatter.py`.
- **The Weekly Reports pipeline** you run recurring to produce The Week in Ink:
  `weekly-report-gather.py`, `weekly-report-render.py`, `weekly-reports-nav.py`,
  plus their shared rendering assets in `weekly-report-assets/`. See
  [[PKM/Weekly Reports/INDEX]] for the full production procedure.

---

## `migrate-inline-fields-to-frontmatter.py`

**Status:** ships in v1.3.0. Optional. Safe to delete after you've migrated.

### What it does

Pre-v1.3.0, you may have written entity notes with metadata as inline body
text:

```markdown
# Dr. Schmidt

**Full name:** Dr. Andrea Schmidt
**Role:** practicing physician
**Organization:** [[dr-schmidt-clinic]]
```

v1.3.0 makes **YAML frontmatter** the canonical source of truth (per
`Guidelines/GL-002-frontmatter-conventions.md` and the entity templates in
`Templates/`). The Properties tab in the myPKA Cockpit parses
frontmatter; the SQLite converter (SOP-002) extracts structured columns
from frontmatter. Inline body fields parse to **nothing** — silent data
loss.

This script scans your myPKA, detects the old `**Field:** value` pattern,
and rewrites your notes with a YAML frontmatter block on top.

### What it touches

It only looks inside the eight canonical entity folders:

```
PKM/CRM/People/
PKM/CRM/Organizations/
PKM/My Life/Projects/
PKM/My Life/Goals/
PKM/My Life/Habits/
PKM/My Life/Topics/
PKM/My Life/Key Elements/
PKM/Documents/
```

It **skips**:

- files that already have YAML frontmatter (no double-write)
- `INDEX.md`, `README.md`, `_template.md` files
- folders outside the eight entity folders above (e.g. `PKM/Journal/`,
  `PKM/Images/`, anything under `Team Knowledge/`)

### How to run it

The script is **dry-run by default** — it prints unified diffs and does not
touch your files until you pass `--apply`.

```bash
# 1. Preview what would change (safe; reads only)
python3 "Team Knowledge/scripts/migrate-inline-fields-to-frontmatter.py" .

# 2. Apply the rewrites (originals are saved as `<file>.bak`)
python3 "Team Knowledge/scripts/migrate-inline-fields-to-frontmatter.py" . --apply

# 3. (optional) Limit to one entity folder
python3 "Team Knowledge/scripts/migrate-inline-fields-to-frontmatter.py" . \
    --only "PKM/CRM/People"

# 4. (optional) Quieter preview (summary only, no diffs)
python3 "Team Knowledge/scripts/migrate-inline-fields-to-frontmatter.py" . --quiet
```

The first positional argument is your **myPKA root** — the folder that
contains `PKM/`, `Team Knowledge/`, etc. Run from your myPKA and pass `.`,
or pass an absolute path from anywhere.

### Requirements

- Python 3.9 or newer (preinstalled on macOS, most Linux distros, and
  Windows via the Microsoft Store)
- **No third-party packages.** Stdlib only.

### Safety

- Default mode is `--dry-run`. You will not accidentally overwrite anything.
- `--apply` writes a `.bak` sibling next to every modified file before
  rewriting it. To roll back a single file: `mv note.md.bak note.md`.
- Files with existing YAML frontmatter are skipped entirely. The script is
  idempotent — running it twice is a no-op the second time.
- Unknown inline labels (labels not in the field map for the entity type)
  are **left in the body untouched** and reported in the per-file summary
  so you can decide what to do with them.

### When to delete this script

Once you've run it on your myPKA and you're satisfied with the result, you
can safely delete `Team Knowledge/scripts/migrate-inline-fields-to-frontmatter.py`
and its section of this README. They serve no day-to-day purpose; the canonical authority
for frontmatter shape going forward is `Guidelines/GL-002-frontmatter-conventions.md`
and `Templates/`.

If you'd rather keep them around in case you ingest legacy notes later,
that's also fine. The script will only ever rewrite files that match its
strict pattern (bold-label inline fields in entity folders without
existing frontmatter), so it is safe to leave installed.

### Reporting issues

If the script mis-extracts a field or mangles a note, please open an issue
with:

1. The dry-run diff for the affected file
2. The inline pattern it failed on
3. The entity folder

The script's regex is conservative by design (it requires `**Label:** value`
on its own line). False negatives (skipped fields) are preferred to false
positives (corrupted prose).

---

## The Weekly Reports pipeline

Three scripts produce **The Week in Ink**, the Friday weekly recap filed under
`PKM/Weekly Reports/YYYY/MM/<slug>/`. Run them in order; the full production
procedure and reading guide live in [[PKM/Weekly Reports/INDEX]]. Frontmatter
schema: [[GL-002-frontmatter-conventions]] section "Weekly reports".

### `weekly-report-gather.py`

Assembles the deterministic source bundle for one edition. Given a Friday
anchor date, it collects everything captured in the covered week (the
preceding Saturday through that Friday, inclusive): Journal entries, Images
captures, Deliverables folders, session logs, and the week's aggregate
signals. Emits one JSON bundle plus a density verdict, so a thin week is
filed honestly as `sparse` instead of being padded.

```bash
# one anchor, bundle into a working dir
python3 "Team Knowledge/scripts/weekly-report-gather.py" 2026-07-10 --outdir /tmp/wk

# every Friday in a span (backfill)
python3 "Team Knowledge/scripts/weekly-report-gather.py" --range 2026-05-01 2026-07-24 --outdir /tmp/wk
```

### `weekly-report-render.py`

Turns a gathered bundle into a filed edition inside
`PKM/Weekly Reports/YYYY/MM/<slug>/`: `metadata.md` (frontmatter plus a real
prose mirror of the week) and the rendered deck HTML. Assembles from captured
facts only, never invents. A `.hand-built` marker file inside an edition
folder protects that edition's HTML from being overwritten, even with
`--force`.

```bash
python3 "Team Knowledge/scripts/weekly-report-render.py" /tmp/wk/2026-07-10.json
python3 "Team Knowledge/scripts/weekly-report-render.py" --all /tmp/wk
```

### `weekly-reports-nav.py`

Injects the self-contained, foldable archive drawer into every rendered
edition, so any edition is a complete entry point to the whole archive.
Idempotent; re-run it after filing a new edition. `--check` reports staleness
without writing anything, which suits a pre-publish gate.

```bash
python3 "Team Knowledge/scripts/weekly-reports-nav.py"
python3 "Team Knowledge/scripts/weekly-reports-nav.py" --check
```

### `weekly-report-assets/`

Shared rendering assets for the deck: `deck.css`, `deck.js`,
`inkline-fonts.css`, and `FONT-LICENSES.md`. This is a framework path, so the
assets receive scaffold updates; editions reference them rather than carrying
copies.
