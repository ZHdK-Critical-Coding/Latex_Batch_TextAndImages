# LaTeX: Text and Images

[Deutsch](README_DE.md)

Turns all folders in `source/` into one PDF: every folder starts on a new
page with the text from its `.txt` file (optional, any name), followed by every image in the folder
on a page of its own. One template, any amount of material – add a folder and run the script
again. A shell script collects the
folders into a LaTeX file, XeLaTeX turns it into the PDF.

## Installation

Requirements: a TeX distribution with XeLaTeX, a terminal. The template
uses only standard packages (`geometry`, `fontspec`, `babel`, `graphicx`, `adjustbox`, `eso-pic`).

Install a TeX distribution:

- **macOS**: [MacTeX](https://tug.org/mactex/) (about 6 GB, contains
  everything). Download the installer, or with
  [Homebrew](https://brew.sh):
  ```sh
  brew install --cask mactex-no-gui
  ```
  Open a new terminal window afterwards, so the programs are found.
- **Windows**: [MiKTeX](https://miktex.org/download). During the
  installation, allow missing packages to be installed on the fly; the
  first run then downloads what it needs.
- **Linux**: [TeX Live](https://tug.org/texlive/), e.g.
  `sudo apt install texlive-xetex texlive-latex-extra`.

The font TeX Gyre Heros (a free Helvetica clone) is included in `fonts/`,
nothing to install.

Check the installation with `xelatex --version`. An editor with LaTeX
support helps, e.g. Visual Studio Code with the extension **LaTeX
Workshop**.

License: MIT. Font: TeX Gyre Heros, [GUST Font License](fonts/GUST-FONT-LICENSE.txt).

## How to Run

The source material lies in `source/`, one folder per section:

```
source/
  glacier/
    text.txt     optional, any name ending in .txt (the first one is used);
                 an empty line starts a new paragraph
    01.jpg       images (jpg, png), placed in alphabetical order
    02.jpg
  harbour/
    ...
```

Open a terminal in the repository folder and run

- **macOS / Linux**: `./build.sh`
- **Windows**: `powershell -ExecutionPolicy Bypass -File build.ps1`

The script creates `output/document.pdf` (A5, 12 mm margins, full-bleed images) with the
folders in alphabetical order. Replace the folders in `source/` with your own material and run
it again. An existing PDF is overwritten. If it fails, the error is in `output/document.log`.

The same by hand:

```sh
xelatex -jobname=document -output-directory=output template.tex
```

## On GitHub

Every push to `main` builds the PDF on GitHub
(`.github/workflows/build.yml`, with
[GitHub Action for LaTeX](https://github.com/marketplace/actions/github-action-for-latex)).
Download it in the **Actions** tab: open the run, then click
**Download document_….pdf** at the top of the page (or **Artifacts →
document_….pdf** at the bottom). The file name contains the creation
date (Zurich time), e.g. `document_2026-11-02_1804.pdf`. You have to be signed in to GitHub; the
PDF is kept for 90 days. **Run workflow** starts a build by hand.

The latest PDF, with build date and page count, is always on the
GitHub Page: <https://zhdk-critical-coding.github.io/Latex_Batch_TextAndImages/>. `site/index.html` is the page; the workflow
fills in `{{FILE}}` (the dated file name), `{{DATE}}` and `{{PAGES}}` (from `output/document.log`) and
publishes it together with the PDF. For your own repository, first set
**Settings → Pages → Source** to **GitHub Actions**.

A tag starting with `v` also creates a release with the PDF attached:

```sh
git tag v1.0
git push origin v1.0
```

The workflow uses TeX Live 2026 (`texlive_version`) and installs the
fonts in `fonts/` (`extra_fonts`). `pre_compile` runs
`./build.sh --content-only`, which writes only `output/content.tex`;
the action then compiles `template.tex` with XeLaTeX.

## Coding Help

LaTeX cannot list the files of a folder by itself. The build script does
that and writes the content of all folders into `output/content.tex`;
`template.tex` defines what it looks like and includes that file.

- **`build.sh` / `build.ps1`**: go through the folders in `source/`
  (alphabetically) and write, for each one:
  - `\clearpage`, so every folder starts on a new page,
  - the first `.txt` file as plain text (if there is none, the folder gets
    no text) – an empty line starts a new paragraph, as always in LaTeX,
  - one `\itemimage{...}` per file ending in `jpg`, `jpeg` or `png`.

  The function `escape` puts a backslash in front of `& % $ # _ { }` (and
  replaces `\ ~ ^`), so these characters are printed instead of being
  read as LaTeX commands. Remove it to allow LaTeX commands in the text.
  Then `xelatex -jobname=document -output-directory=output template.tex`
  runs once; the jobname names the PDF. `-interaction=nonstopmode
  -halt-on-error` stops at the first error instead of waiting for input.
  Auxiliary `.aux` files are deleted at the end. `./build.sh
  --content-only` stops after writing `output/content.tex` (used on
  GitHub).
- **`template.tex`**: the layout. `geometry` sets A5 with a 12 mm
  border (try `a4paper`), `fontspec` allows Unicode text and loads the font
  from `fonts/` (`\setmainfont{texgyreheros-regular.otf}[Path=fonts/]`;
  for a system font write e.g. `\setmainfont{Helvetica}`), `babel` selects German hyphenation. The
  text is set in 14/16 pt, justified, with one empty line (16 pt) between
  paragraphs and the first baseline 16 pt below the border, as in the
  Typst and CSS versions. `\itemimage{...}` puts one image on its own
  page, full bleed: `eso-pic` places it in the page background, ignoring
  the margins, and `adjustbox` scales it to cover the whole page, cutting
  off what sticks out. `\input{output/content.tex}` inserts the generated
  content.
