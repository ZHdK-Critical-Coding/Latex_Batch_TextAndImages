# LaTeX: Text and Images

[Deutsch](README_DE.md)

Turns all folders in `source/` into one PDF: every folder starts on a new
page with the text from `text.txt`, followed by every image in the folder
on a page of its own. One template, any amount of material – add a folder and run the script
again. Written in LaTeX and compiled with LuaLaTeX, whose built-in
Lua scripting reads the folder and the text file.

## Installation

Requirements: a TeX distribution with LuaLaTeX, a terminal. The template
uses only standard packages (`geometry`, `fontspec`, `graphicx`).

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
  `sudo apt install texlive-luatex texlive-latex-extra`.

Check the installation with `lualatex --version`. An editor with LaTeX
support helps, e.g. Visual Studio Code with the extension **LaTeX
Workshop**.

License: MIT

## How to Run

The source material lies in `source/`, one folder per section:

```
source/
  glacier/
    text.txt     first line: title; an empty line starts a new paragraph
    01.jpg       images (jpg, png), placed in alphabetical order
    02.jpg
  harbour/
    ...
```

Open a terminal in the repository folder and run

- **macOS / Linux**: `./build.sh`
- **Windows**: `powershell -ExecutionPolicy Bypass -File build.ps1`

The script creates `output/document.pdf` (A4, 20 mm margins) with the
folders in alphabetical order. Replace the folders in `source/` with your own material and run
it again. An existing PDF is overwritten. If it fails, the error is in `output/document.log`.

The same by hand:

```sh
lualatex -jobname=document -output-directory=output template.tex
```

## Coding Help

LaTeX cannot list the files of a folder by itself. Lua code in
`batch.lua` does that and writes the content for all folders into the
document; `template.tex` defines what it looks like.

- **`build.sh` / `build.ps1`**: call
  `lualatex -jobname=document -output-directory=output template.tex` once;
  the jobname names the PDF. `-interaction=nonstopmode -halt-on-error` stops at the first
  error instead of waiting for input. Auxiliary `.aux` files are deleted
  at the end.
- **`template.tex`**: the layout. `geometry` sets the margins, `fontspec`
  allows Unicode text and other fonts (e.g. `\setmainfont{Helvetica}`),
  `graphicx` places the images. `\itemtitle{...}` sets the title of a
  folder, `\itemimage{...}` puts one image on its own page, fitted into
  the margins (`width=\textwidth, height=\textheight, keepaspectratio`)
  and centred vertically with `\vfill`. `\directlua{batch.items()}` runs
  the Lua code in the middle of the document and writes its content
  exactly there.
- **`batch.lua` → `items()`**: `lfs.dir()` lists `source/`; the folders
  are sorted with `table.sort()` and passed to `item()` one by one.
- **`batch.lua` → `item()` → text**: `\clearpage` starts the folder on a
  new page. `text.txt` is read line by line; the first line goes into
  `\itemtitle`.
  `tex.sprint(-2, s)` prints a string with every character taken
  literally, so `& % # $ _ { }` don't have to be escaped. To allow LaTeX
  commands in the text, use `tex.sprint(s)` instead. An empty line becomes
  `\par`.
- **`batch.lua` → `item()` → images**: files ending in `jpg`, `jpeg` or
  `png` are sorted by name, each one becomes an `\itemimage{...}`.
