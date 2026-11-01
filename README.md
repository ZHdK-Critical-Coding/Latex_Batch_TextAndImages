# LaTeX: Text and Images

[Deutsch](README_DE.md)

Turns all folders in `source/` into one PDF: every folder starts on a new
page with the text from its `.txt` file, followed by every image in the folder
on a page of its own. One template, any amount of material – add a folder and run the script
again. A shell script collects the
folders into a LaTeX file, XeLaTeX turns it into the PDF.

## Installation

Requirements: a TeX distribution with XeLaTeX, a terminal. The template
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
  `sudo apt install texlive-xetex texlive-latex-extra`.

Check the installation with `xelatex --version`. An editor with LaTeX
support helps, e.g. Visual Studio Code with the extension **LaTeX
Workshop**.

License: MIT

## How to Run

The source material lies in `source/`, one folder per section:

```
source/
  glacier/
    text.txt     any .txt file; first line: title; an empty line starts a new paragraph
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
xelatex -jobname=document -output-directory=output template.tex
```

## Coding Help

LaTeX cannot list the files of a folder by itself. The build script does
that and writes the content of all folders into `output/content.tex`;
`template.tex` defines what it looks like and includes that file.

- **`build.sh` / `build.ps1`**: go through the folders in `source/`
  (alphabetically) and write, for each one:
  - `\itemtitle{...}` with the first line of the first `.txt` file (or the
    folder name, if there is none),
  - the remaining lines as plain text – an empty line starts a new
    paragraph, as always in LaTeX,
  - one `\itemimage{...}` per file ending in `jpg`, `jpeg` or `png`.

  The function `escape` puts a backslash in front of `& % $ # _ { }` (and
  replaces `\ ~ ^`), so these characters are printed instead of being
  read as LaTeX commands. Remove it to allow LaTeX commands in the text.
  Then `xelatex -jobname=document -output-directory=output template.tex`
  runs once; the jobname names the PDF. `-interaction=nonstopmode
  -halt-on-error` stops at the first error instead of waiting for input.
  Auxiliary `.aux` files are deleted at the end.
- **`template.tex`**: the layout. `geometry` sets the margins, `fontspec`
  allows Unicode text and other fonts (e.g. `\setmainfont{Helvetica}`),
  `graphicx` places the images. `\itemtitle{...}` starts a new page with
  the title of a folder, `\itemimage{...}` puts one image on its own page,
  fitted into the margins (`width=\textwidth, height=\textheight,
  keepaspectratio`) and centred vertically with `\vfill`.
  `\input{output/content.tex}` inserts the generated content.
