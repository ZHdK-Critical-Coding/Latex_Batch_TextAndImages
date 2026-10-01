# LaTeX: Text and Images

[Deutsch](README_DE.md)

Turns every folder in `source/` into its own PDF: the text from `text.txt`
on the first page, followed by every image in the folder on a page of its
own. One template, any number of documents – add a folder and run the
script again. Written in LaTeX and compiled with LuaLaTeX, whose built-in
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

The source material lies in `source/`, one folder per document:

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

The script creates `output/glacier.pdf`, `output/harbour.pdf` … (A4, 20 mm
margins). Replace the folders in `source/` with your own material and run
it again. Existing PDFs are overwritten. If a document fails, the error is
in `output/<folder>.log`.

A single folder can be compiled by hand:

```sh
lualatex -jobname=glacier -output-directory=output template.tex
```

## Coding Help

The folder name is passed to LaTeX as the *jobname*, which also names the
PDF. Lua code in `batch.lua` reads `tex.jobname` and with it the matching
folder in `source/`.

- **`build.sh` / `build.ps1`**: loop over the folders in `source/` and
  call `lualatex -jobname=<folder> -output-directory=output template.tex`
  for each. `-interaction=nonstopmode -halt-on-error` stops at the first
  error instead of waiting for input. Auxiliary `.aux` files are deleted
  at the end.
- **`template.tex`**: the layout. `geometry` sets the margins, `fontspec`
  allows Unicode text and other fonts (e.g. `\setmainfont{Helvetica}`),
  `graphicx` places the images. `\directlua{...}` runs Lua code in the
  middle of the document: `batch.title()`, `batch.body()` and
  `batch.images()` write their content exactly where they are called.
- **`batch.lua` → `title()` / `body()`**: read `text.txt` line by line.
  `tex.sprint(-2, s)` prints a string with every character taken
  literally, so `& % # $ _ { }` don't have to be escaped. To allow LaTeX
  commands in the text, use `tex.sprint(s)` instead. An empty line becomes
  `\par`.
- **`batch.lua` → `images()`**: `lfs.dir()` lists the folder; files ending
  in `jpg`, `jpeg` or `png` are sorted with `table.sort()`. For each image
  it writes `\clearpage` and an `\includegraphics` with
  `width=\textwidth, height=\textheight, keepaspectratio`, which fits the
  image into the area inside the margins. `\vfill` above and below
  centres it vertically.
