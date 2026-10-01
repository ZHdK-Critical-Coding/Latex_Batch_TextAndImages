# LaTeX: Text and Images

[English](README.md)

Macht aus jedem Ordner in `source/` ein eigenes PDF: der Text aus
`text.txt` auf der ersten Seite, danach jedes Bild aus dem Ordner auf einer
eigenen Seite. Eine Vorlage, beliebig viele Dokumente – einen Ordner
hinzufügen und das Script nochmals ausführen. Geschrieben in LaTeX und
übersetzt mit LuaLaTeX, dessen eingebaute Lua-Programmierung den Ordner und
die Textdatei liest.

## Installation

Voraussetzungen: eine TeX-Distribution mit LuaLaTeX, ein Terminal. Die
Vorlage verwendet nur Standardpakete (`geometry`, `fontspec`, `graphicx`).

Eine TeX-Distribution installieren:

- **macOS**: [MacTeX](https://tug.org/mactex/) (etwa 6 GB, enthält
  alles). Den Installer herunterladen, oder mit
  [Homebrew](https://brew.sh):
  ```sh
  brew install --cask mactex-no-gui
  ```
  Danach ein neues Terminalfenster öffnen, damit die Programme gefunden
  werden.
- **Windows**: [MiKTeX](https://miktex.org/download). Bei der Installation
  erlauben, fehlende Pakete automatisch nachzuinstallieren; der erste
  Durchlauf lädt dann herunter, was er braucht.
- **Linux**: [TeX Live](https://tug.org/texlive/), z. B.
  `sudo apt install texlive-luatex texlive-latex-extra`.

Die Installation mit `lualatex --version` prüfen. Ein Editor mit
LaTeX-Unterstützung hilft, z. B. Visual Studio Code mit der Erweiterung
**LaTeX Workshop**.

Lizenz: MIT

## Ausführen

Das Ausgangsmaterial liegt in `source/`, ein Ordner pro Dokument:

```
source/
  glacier/
    text.txt     erste Zeile: Titel; eine Leerzeile beginnt einen neuen Absatz
    01.jpg       Bilder (jpg, png), in alphabetischer Reihenfolge gesetzt
    02.jpg
  harbour/
    ...
```

Ein Terminal im Ordner des Repositorys öffnen und ausführen:

- **macOS / Linux**: `./build.sh`
- **Windows**: `powershell -ExecutionPolicy Bypass -File build.ps1`

Das Script erzeugt `output/glacier.pdf`, `output/harbour.pdf` … (A4, 20 mm
Rand). Die Ordner in `source/` durch eigenes Material ersetzen und das
Script nochmals ausführen. Bestehende PDFs werden überschrieben. Schlägt
ein Dokument fehl, steht der Fehler in `output/<ordner>.log`.

Ein einzelner Ordner lässt sich auch von Hand übersetzen:

```sh
lualatex -jobname=glacier -output-directory=output template.tex
```

## Coding-Hilfe

Der Ordnername wird LaTeX als *Jobname* übergeben, der auch das PDF
benennt. Der Lua-Code in `batch.lua` liest `tex.jobname` und damit den
passenden Ordner in `source/`.

- **`build.sh` / `build.ps1`**: gehen die Ordner in `source/` durch und
  rufen für jeden `lualatex -jobname=<ordner> -output-directory=output template.tex`
  auf. `-interaction=nonstopmode -halt-on-error` bricht beim ersten Fehler
  ab, statt auf eine Eingabe zu warten. Die Hilfsdateien `.aux` werden am
  Schluss gelöscht.
- **`template.tex`**: das Layout. `geometry` setzt die Ränder, `fontspec`
  erlaubt Unicode-Text und andere Schriften (z. B.
  `\setmainfont{Helvetica}`), `graphicx` setzt die Bilder.
  `\directlua{...}` führt mitten im Dokument Lua-Code aus:
  `batch.title()`, `batch.body()` und `batch.images()` schreiben ihren
  Inhalt genau dort hin, wo sie aufgerufen werden.
- **`batch.lua` → `title()` / `body()`**: lesen `text.txt` Zeile für
  Zeile. `tex.sprint(-2, s)` gibt einen String aus, bei dem jedes Zeichen
  wörtlich genommen wird; `& % # $ _ { }` müssen also nicht maskiert
  werden. Um LaTeX-Befehle im Text zu erlauben, stattdessen
  `tex.sprint(s)` verwenden. Eine Leerzeile wird zu `\par`.
- **`batch.lua` → `images()`**: `lfs.dir()` listet den Ordner auf;
  Dateien mit der Endung `jpg`, `jpeg` oder `png` werden mit
  `table.sort()` sortiert. Für jedes Bild schreibt es `\clearpage` und ein
  `\includegraphics` mit `width=\textwidth, height=\textheight,
  keepaspectratio`, das das Bild in die Fläche innerhalb der Ränder
  einpasst. `\vfill` darüber und darunter zentriert es vertikal.
