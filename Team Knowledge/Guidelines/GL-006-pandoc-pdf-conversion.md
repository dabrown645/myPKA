# GL-006: Pandoc PDF Conversion with Color Emojis

**Purpose:** Standard setup for converting markdown files to PDF with color emoji support using pandoc and LuaLaTeX.

**When to use:** Any time a markdown file with emojis (✅, ❌, 🚗, etc.) needs to be converted to PDF.

---

## Prerequisites (CachyOS/Arch Linux)

Install these packages via pacman:

```bash
sudo pacman -S pandoc-cli texlive-bin texlive-basic texlive-fontsrecommended texlive-luatex texlive-latexextra
```

**Required packages:**
- `pandoc-cli` — The pandoc command
- `texlive-bin` — LuaLaTeX and other TeX binaries
- `texlive-basic` — Essential TeX files
- `texlive-fontsrecommended` — Font packages
- `texlive-luatex` — fontspec, luacode, and LuaTeX packages
- `texlive-latexextra` — lualatex-math and other LaTeX extras

**Already installed on CachyOS:**
- `noto-fonts-emoji` — Color emoji font
- `ttf-dejavu` — DejaVu fonts

---

## header.tex File

Create `header.tex` in your project directory (or use a shared location):

```tex
\usepackage{fontspec}
\usepackage{luacode}

% Configure emoji fallback
\directlua{
    luaotfload.add_fallback("emojifallback", {
        "Noto Color Emoji:mode=harf;script=DFLT;"
    })
}

% Set main font with emoji fallback
\setmainfont{DejaVu Sans}[RawFeature={fallback=emojifallback}]
```

**What it does:**
1. Loads `fontspec` — Allows LuaLaTeX to use system fonts
2. Configures emoji fallback — When DejaVu Sans doesn't have a character (like ✅), look in Noto Color Emoji
3. Sets DejaVu Sans as main font — With fallback attached

---

## Conversion Commands

### PDF with Color Emojis

```bash
pandoc input.md -o output.pdf --pdf-engine=lualatex -H header.tex
```

### DOCX (No header.tex needed)

```bash
pandoc input.md -o output.docx
```

Word/LibreOffice handles fonts and emojis natively.

### HTML (No header.tex needed)

```bash
pandoc input.md -o output.html
```

---

## Troubleshooting

### Missing `lualatex-math.sty`

**Error:** `! LaTeX Error: File 'lualatex-math.sty' not found.`

**Fix:** Ensure `texlive-latexextra` is installed:
```bash
sudo pacman -S texlive-latexextra
```

### Missing font cache writability

**Error:** `luaotfload | load : FATAL ERROR ... no writeable cache path`

**Fix:** Set HOME to a writable directory:
```bash
export HOME=$(mktemp -d)
```

Or add to your shell.nix (if using nix):
```nix
shellHook = ''
  export HOME=$(mktemp -d)
'';
```

### Emojis not rendering in color

**Check:**
1. Noto Color Emoji is installed: `fc-list | grep -i "noto.*emoji"`
2. Using `--pdf-engine=lualatex` (not xelatex or pdflatex)
3. `-H header.tex` is included in command

---

## Nix Shell Alternative

If you prefer nix-shell over local install, use this `shell.nix`:

```nix
{ pkgs ? import <nixpkgs> {} }:
  pkgs.mkShell {
    nativeBuildInputs = with pkgs.buildPackages;
    [
      pandoc
      (pkgs.texliveSmall.withPackages (ps: with ps; [
        newunicodechar
        collection-fontsrecommended
        luacode
        fontspec
        lualatex-math
      ]))
      pkgs.dejavu_fonts
      pkgs.noto-fonts-color-emoji
    ];
    shellHook = ''
      export HOME=$(mktemp -d)
    '';
}
```

**Note:** Local install is recommended for faster startup and simpler workflow.

---

## References

- pandoc-latex-template (Eisvogel) — Color emoji examples: `examples/font-emoji-noto-color-emoji/`
- Noto Color Emoji: https://github.com/googlefonts/noto-emoji
- Known nixpkgs issue with noto-fonts-color-emoji TTF: https://github.com/NixOS/nixpkgs/issues/396793

---

**Last updated:** 2026-08-25
**Tested on:** CachyOS (Arch-based), pandoc 3.10.2, texlive 2026
