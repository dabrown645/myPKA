#!/usr/bin/env python3
"""validate-links-indexes.py: opt-in check groups for validation-script.sh.

Called by validation-script.sh when it is invoked with --links / --indexes /
--all. Not usually run by hand, but it works standalone:

    python3 scripts/validate-links-indexes.py --root <scaffold-root> --links --indexes

Check groups
------------
--links    Wikilink resolution over every .md file in the scaffold, with
           Obsidian semantics: bare stem (unique match, then frontmatter
           aliases), path-suffix targets ([[Templates/person]]), |alias
           labels, ![[embeds]], explicit-extension targets ([[x.py]]).
           Code FENCES are excluded; inline backtick spans are kept (a
           backticked live wikilink is still a live wikilink; this is how
           the 2026-08-26 audit caught two of its ten defects).
           Intentional classes are suppressed (see SUPPRESSION below).
           Everything else unresolved is a FAIL. A bare stem that matches
           more than one file is a WARN (Obsidian resolves it arbitrarily).

--indexes  (a) Coverage in both directions for the four Team Knowledge
               indexes (SOPs, Workstreams, Guidelines, Templates): every
               wikilink in the INDEX resolves, and every on-disk file in
               the folder is reachable from a wikilink in its INDEX.
           (b) Expansions/INDEX.md: the Version cell of each expansion's
               row must equal the `version:` in that expansion's
               expansion.yaml (matched by the yaml `name:`); an expansion
               folder with no row is a FAIL.
           (c) PKM/INDEX.md: every wikilink in the "## Sections" block
               resolves.

SUPPRESSION (--links): the intentional-unresolved classes from the
2026-08-26 orphan audit (Deliverables/2026-08-26-scaffold-latest-audit/
silas-orphan-audit.md §1) are skipped, never failed:

  Class A (convention prose): targets that are documentation about the
      wikilink syntax itself. Exact-match list (case-insensitive):
      wikilink, wikilinks, filename, path/filename, embed, target, link,
      basename, path, old-name, orphan-link. Additionally any target
      containing a comma (a prose enumeration is never a note name).
  Class B (template placeholders): targets containing < or >, {{, an
      ellipsis (... or the Unicode character), YYYY, NNN, or ending in
      -slug / equal to slug.
  Class C (worked examples): stems that intentionally do not ship: the
      inline ignore list defined in the validation-script.sh header and
      passed in via --ignore-stems (exact target match, case-insensitive).
  Class D (expansion demo content): every file under an
      Expansions/*/examples/ directory is skipped wholesale.

Output protocol (stdout, one record per line, tab-separated):
    OK<TAB>message  |  WARN<TAB>message  |  FAIL<TAB>message
validation-script.sh routes these through its pass/warn/fail counters.

Exit codes: 0 = no FAIL records, 1 = at least one FAIL, 2 = bad invocation.

Stdlib only. No third-party dependencies.
"""

import argparse
import os
import re
import sys

WIKILINK_RE = re.compile(r"(!?)\[\[([^\[\]\n]+?)\]\]")
FENCE_RE = re.compile(r"^\s*(```|~~~)")

CONVENTION_TARGETS = {
    "wikilink", "wikilinks", "filename", "path/filename", "embed",
    "target", "link", "basename", "path", "old-name", "orphan-link",
}

records = []  # (kind, message)


def emit(kind, message):
    records.append((kind, message))


# ---------------------------------------------------------------------------
# Inventory
# ---------------------------------------------------------------------------

class Vault:
    def __init__(self, root):
        self.root = root
        self.all_files = []          # relative posix paths, every file
        self.md_files = []           # relative posix paths, *.md only
        self.stem_map = {}           # lowercased stem -> [md paths]
        self.alias_map = {}          # lowercased alias -> [md paths]
        self._walk()
        self._collect_aliases()

    def _walk(self):
        for dirpath, dirnames, filenames in os.walk(self.root):
            dirnames[:] = [d for d in dirnames
                           if d not in (".git", "node_modules")]
            for fn in filenames:
                rel = os.path.relpath(os.path.join(dirpath, fn), self.root)
                rel = rel.replace(os.sep, "/")
                self.all_files.append(rel)
                if fn.lower().endswith(".md"):
                    self.md_files.append(rel)
                    stem = fn[:-3].lower()
                    self.stem_map.setdefault(stem, []).append(rel)
        self.all_files.sort()
        self.md_files.sort()

    def _collect_aliases(self):
        for rel in self.md_files:
            try:
                with open(os.path.join(self.root, rel), encoding="utf-8",
                          errors="replace") as fh:
                    lines = fh.read().splitlines()
            except OSError:
                continue
            if not lines or lines[0].strip() != "---":
                continue
            in_alias_block = False
            for line in lines[1:200]:
                if line.strip() == "---":
                    break
                m = re.match(r"^aliases:\s*(.*)$", line)
                if m:
                    rest = m.group(1).strip()
                    in_alias_block = False
                    if rest.startswith("["):
                        for a in rest.strip("[]").split(","):
                            a = a.strip().strip("\"'")
                            if a:
                                self.alias_map.setdefault(
                                    a.lower(), []).append(rel)
                    elif rest:
                        self.alias_map.setdefault(
                            rest.strip("\"'").lower(), []).append(rel)
                    else:
                        in_alias_block = True
                    continue
                if in_alias_block:
                    m2 = re.match(r"^\s*-\s*(.+)$", line)
                    if m2:
                        a = m2.group(1).strip().strip("\"'")
                        if a:
                            self.alias_map.setdefault(
                                a.lower(), []).append(rel)
                    else:
                        in_alias_block = False

    def resolve(self, target):
        """Resolve a wikilink target (anchor/alias already stripped).

        Returns ("ok", path) | ("ambiguous", n_candidates) | ("miss", None).
        Matching is case-insensitive (macOS/Windows filesystems are)."""
        t = target.strip().strip("/")
        if not t:
            return ("ok", None)  # pure-anchor link, resolves to self
        tl = t.lower()
        last = t.rsplit("/", 1)[-1]
        if "/" in t:
            # Path-suffix semantics: [[a/b]] matches any path ending a/b.md;
            # an explicit extension matches the literal file of any type.
            if "." in last:
                for p in self.all_files:
                    pl = p.lower()
                    if pl == tl or pl.endswith("/" + tl):
                        return ("ok", p)
            suffix = tl + ".md"
            for p in self.md_files:
                pl = p.lower()
                if pl == suffix or pl.endswith("/" + suffix):
                    return ("ok", p)
            return ("miss", None)
        # Bare target.
        if "." in last:
            hits = [p for p in self.all_files
                    if p.rsplit("/", 1)[-1].lower() == tl]
            if len(hits) == 1:
                return ("ok", hits[0])
            if len(hits) > 1:
                return ("ambiguous", len(hits))
        hits = self.stem_map.get(tl, [])
        if len(hits) == 1:
            return ("ok", hits[0])
        if len(hits) > 1:
            return ("ambiguous", len(hits))
        alias_hits = self.alias_map.get(tl, [])
        if alias_hits:
            return ("ok", alias_hits[0])
        return ("miss", None)


# ---------------------------------------------------------------------------
# Link extraction
# ---------------------------------------------------------------------------

def extract_links(root, rel):
    """Yield (lineno, raw_target) for every wikilink outside code fences."""
    try:
        with open(os.path.join(root, rel), encoding="utf-8",
                  errors="replace") as fh:
            text = fh.read()
    except OSError as exc:
        emit("WARN", "could not read %s: %s" % (rel, exc))
        return
    in_fence = False
    for lineno, line in enumerate(text.splitlines(), 1):
        if FENCE_RE.match(line):
            in_fence = not in_fence
            continue
        if in_fence:
            continue
        for m in WIKILINK_RE.finditer(line):
            yield lineno, m.group(2)


def clean_target(raw):
    """Strip |alias label and #anchor from a raw wikilink body."""
    target = raw.split("|", 1)[0]
    target = target.split("#", 1)[0]
    return target.strip()


def is_suppressed(target, ignore_set):
    """True when the target belongs to an intentional-unresolved class."""
    # Class B: placeholder syntax.
    if any(ch in target for ch in ("<", ">")):
        return True
    if "{{" in target:
        return True
    if "..." in target or "…" in target:
        return True
    if "YYYY" in target or "NNN" in target:
        return True
    if target.lower() == "slug" or target.lower().endswith("-slug"):
        return True
    # Class A: convention prose.
    if "," in target:
        return True
    if target.lower() in CONVENTION_TARGETS:
        return True
    # Class C: inline ignore list from the validation-script.sh header.
    if target.lower() in ignore_set:
        return True
    return False


def in_examples_dir(rel):
    """Class D: expansion demo content is skipped wholesale."""
    parts = rel.split("/")
    return len(parts) >= 3 and parts[0] == "Expansions" and "examples" in parts[1:-1]


# ---------------------------------------------------------------------------
# --links
# ---------------------------------------------------------------------------

def check_links(vault, ignore_set):
    n_files = 0
    n_links = 0
    n_broken = 0
    n_ambiguous = 0
    n_suppressed = 0
    for rel in vault.md_files:
        if in_examples_dir(rel):
            continue
        n_files += 1
        for lineno, raw in extract_links(vault.root, rel):
            n_links += 1
            target = clean_target(raw)
            if not target:
                continue
            if is_suppressed(target, ignore_set):
                n_suppressed += 1
                continue
            status, detail = vault.resolve(target)
            if status == "miss":
                n_broken += 1
                emit("FAIL", "broken wikilink: %s:%d -> [[%s]]"
                     % (rel, lineno, target))
            elif status == "ambiguous":
                n_ambiguous += 1
                emit("WARN",
                     "ambiguous wikilink: %s:%d -> [[%s]] (%d files share "
                     "this stem; Obsidian resolves it arbitrarily, use a "
                     "path-suffix link)" % (rel, lineno, target, detail))
    # An OK summary only when genuinely clean: an "ok" glyph must never
    # wrap a failure count (the per-link FAIL lines carry the red state).
    if n_broken == 0:
        emit("OK", "links: scanned %d md files, %d wikilinks "
             "(%d intentional-class suppressed): 0 broken, %d ambiguous"
             % (n_files, n_links, n_suppressed, n_ambiguous))


# ---------------------------------------------------------------------------
# --indexes
# ---------------------------------------------------------------------------

INDEXED_DIRS = [
    ("Team Knowledge/SOPs", "SOPs"),
    ("Team Knowledge/Workstreams", "Workstreams"),
    ("Team Knowledge/Guidelines", "Guidelines"),
    ("Team Knowledge/Templates", "Templates"),
]


def index_links_resolved(vault, index_rel, ignore_set, label):
    """Direction 1: every non-suppressed wikilink in the INDEX resolves.
    Returns the set of resolved paths (for direction 2)."""
    resolved = set()
    for lineno, raw in extract_links(vault.root, index_rel):
        target = clean_target(raw)
        if not target or is_suppressed(target, ignore_set):
            continue
        status, detail = vault.resolve(target)
        if status == "ok" and detail:
            resolved.add(detail)
        elif status == "miss":
            emit("FAIL", "%s row does not resolve: %s:%d -> [[%s]]"
                 % (label, index_rel, lineno, target))
        elif status == "ambiguous":
            emit("WARN", "%s link is ambiguous: %s:%d -> [[%s]] (%d files)"
                 % (label, index_rel, lineno, target, detail))
    return resolved


def check_indexed_dirs(vault, ignore_set):
    for dir_rel, label in INDEXED_DIRS:
        index_rel = dir_rel + "/INDEX.md"
        if not os.path.isfile(os.path.join(vault.root, index_rel)):
            emit("FAIL", "%s INDEX missing at %s" % (label, index_rel))
            continue
        resolved = index_links_resolved(vault, index_rel, ignore_set, label)
        on_disk = [p for p in vault.md_files
                   if p.startswith(dir_rel + "/")
                   and "/" not in p[len(dir_rel) + 1:]
                   and p != index_rel]
        missing = [p for p in on_disk if p not in resolved]
        for p in missing:
            emit("FAIL", "%s INDEX has no row for on-disk file: %s "
                 "(add a wikilinked row to %s)"
                 % (label, p.rsplit("/", 1)[-1], index_rel))
        if not missing:
            emit("OK", "%s INDEX coverage: %d/%d on-disk files indexed"
                 % (label, len(on_disk), len(on_disk)))


def parse_expansion_yaml(path):
    """Minimal top-level scalar reader, enough for name:/version:."""
    name = version = None
    try:
        with open(path, encoding="utf-8", errors="replace") as fh:
            for line in fh:
                m = re.match(r"^(name|version):\s*(.+?)\s*$", line)
                if m:
                    value = m.group(2).strip().strip("\"'")
                    if m.group(1) == "name":
                        name = value
                    else:
                        version = value
                if name and version:
                    break
    except OSError:
        pass
    return name, version


def check_expansions_index(vault):
    index_rel = "Expansions/INDEX.md"
    index_abs = os.path.join(vault.root, index_rel)
    expansions = []  # (folder, name, version)
    exp_root = os.path.join(vault.root, "Expansions")
    if os.path.isdir(exp_root):
        for entry in sorted(os.listdir(exp_root)):
            yaml_path = os.path.join(exp_root, entry, "expansion.yaml")
            if os.path.isfile(yaml_path):
                name, version = parse_expansion_yaml(yaml_path)
                expansions.append((entry, name, version))
    if not expansions:
        emit("OK", "Expansions: no expansion.yaml found; version check "
             "not applicable")
        return
    if not os.path.isfile(index_abs):
        emit("FAIL", "Expansions/INDEX.md missing while %d expansion(s) "
             "are on disk" % len(expansions))
        return
    with open(index_abs, encoding="utf-8", errors="replace") as fh:
        lines = fh.read().splitlines()
    header_cols = []
    rows = []  # list of cell-lists
    for line in lines:
        stripped = line.strip()
        if not stripped.startswith("|"):
            continue
        cells = [c.strip() for c in stripped.strip("|").split("|")]
        if not header_cols:
            header_cols = [c.lower() for c in cells]
            continue
        if all(re.fullmatch(r":?-{3,}:?", c) for c in cells if c):
            continue
        rows.append(cells)
    try:
        ver_idx = header_cols.index("version")
        name_idx = header_cols.index("name")
    except ValueError:
        emit("FAIL", "Expansions/INDEX.md table has no Name/Version "
             "columns; cannot verify expansion versions")
        return
    checked = 0
    for folder, name, version in expansions:
        if not name or not version:
            emit("FAIL", "Expansions/%s/expansion.yaml has no parseable "
                 "name:/version:" % folder)
            continue
        row = None
        for cells in rows:
            if len(cells) > max(ver_idx, name_idx) and (
                    cells[name_idx].lower() == name.lower()
                    or folder.lower() in cells[name_idx].lower()):
                row = cells
                break
        if row is None:
            emit("FAIL", "Expansions/INDEX.md has no row for expansion "
                 "'%s' (folder Expansions/%s)" % (name, folder))
            continue
        cell = row[ver_idx]
        if cell != version:
            emit("FAIL", "Expansions/INDEX.md version cell for '%s' is %s "
                 "but Expansions/%s/expansion.yaml says %s: stale row"
                 % (name, cell, folder, version))
        else:
            checked += 1
    if checked == len(expansions):
        emit("OK", "Expansions INDEX versions: %d/%d row(s) match "
             "expansion.yaml" % (checked, len(expansions)))


def check_pkm_sections(vault, ignore_set):
    index_rel = "PKM/INDEX.md"
    index_abs = os.path.join(vault.root, index_rel)
    if not os.path.isfile(index_abs):
        emit("FAIL", "PKM/INDEX.md missing")
        return
    with open(index_abs, encoding="utf-8", errors="replace") as fh:
        lines = fh.read().splitlines()
    in_sections = False
    in_fence = False
    n_ok = 0
    n_bad = 0
    for lineno, line in enumerate(lines, 1):
        if FENCE_RE.match(line):
            in_fence = not in_fence
            continue
        if in_fence:
            continue
        if re.match(r"^##\s", line):
            in_sections = line.strip().lower() == "## sections"
            continue
        if not in_sections:
            continue
        for m in WIKILINK_RE.finditer(line):
            target = clean_target(m.group(2))
            if not target or is_suppressed(target, ignore_set):
                continue
            status, _ = vault.resolve(target)
            if status == "miss":
                n_bad += 1
                emit("FAIL", "PKM/INDEX.md section link does not resolve: "
                     "line %d -> [[%s]]" % (lineno, target))
            else:
                n_ok += 1
    if n_bad == 0:
        emit("OK", "PKM/INDEX.md sections: all %d link(s) resolve" % n_ok)


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main(argv):
    parser = argparse.ArgumentParser(add_help=True)
    parser.add_argument("--root", required=True)
    parser.add_argument("--links", action="store_true")
    parser.add_argument("--indexes", action="store_true")
    parser.add_argument("--ignore-stems", default="",
                        help="comma-separated worked-example targets "
                             "(class C) to skip in --links")
    args = parser.parse_args(argv)

    if not os.path.isdir(args.root):
        print("FAIL\t--root '%s' is not a directory" % args.root)
        return 1
    if not (args.links or args.indexes):
        print("FAIL\tnothing to do: pass --links and/or --indexes")
        return 2

    ignore_set = {s.strip().lower()
                  for s in args.ignore_stems.split(",") if s.strip()}

    vault = Vault(args.root)

    if args.links:
        check_links(vault, ignore_set)
    if args.indexes:
        check_indexed_dirs(vault, ignore_set)
        check_expansions_index(vault)
        check_pkm_sections(vault, ignore_set)

    fails = 0
    for kind, message in records:
        print("%s\t%s" % (kind, message))
    fails = sum(1 for kind, _ in records if kind == "FAIL")
    return 1 if fails else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
