# LaTeX: Text and Images

[English](README.md)

Macht aus allen Ordnern in `source/` ein PDF: jeder Ordner beginnt auf
einer neuen Seite mit dem Text aus `text.txt`, danach folgt jedes Bild aus
dem Ordner auf einer eigenen Seite. Eine Vorlage, beliebig viel Material – einen Ordner hinzufügen und das
Script nochmals ausführen. Geschrieben in LaTeX und
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

Das Ausgangsmaterial liegt in `source/`, ein Ordner pro Abschnitt:

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

Das Script erzeugt `output/document.pdf` (A4, 20 mm Rand) mit den Ordnern
in alphabetischer Reihenfolge. Die Ordner in `source/` durch eigenes Material ersetzen und das
Script nochmals ausführen. Ein bestehendes PDF wird überschrieben. Schlägt es fehl, steht der Fehler in `output/document.log`.

Dasselbe von Hand:

```sh
lualatex -jobname=document -output-directory=output template.tex
```

## Coding-Hilfe

LaTeX kann die Dateien eines Ordners nicht selbst auflisten. Das übernimmt
der Lua-Code in `batch.lua`, der den Inhalt aller Ordner ins Dokument
schreibt; wie er aussieht, legt `template.tex` fest.

- **`build.sh` / `build.ps1`**: rufen einmal
  `lualatex -jobname=document -output-directory=output template.tex` auf;
  der Jobname benennt das PDF. `-interaction=nonstopmode -halt-on-error` bricht beim ersten Fehler
  ab, statt auf eine Eingabe zu warten. Die Hilfsdateien `.aux` werden am
  Schluss gelöscht.
- **`template.tex`**: das Layout. `geometry` setzt die Ränder, `fontspec`
  erlaubt Unicode-Text und andere Schriften (z. B.
  `\setmainfont{Helvetica}`), `graphicx` setzt die Bilder. `\itemtitle{...}` setzt den Titel eines
  Ordners, `\itemimage{...}` stellt ein Bild auf eine eigene Seite,
  eingepasst in die Ränder (`width=\textwidth, height=\textheight,
  keepaspectratio`) und mit `\vfill` vertikal zentriert.
  `\directlua{batch.items()}` führt mitten im Dokument den Lua-Code aus
  und schreibt seinen Inhalt genau dort hin.
- **`batch.lua` → `items()`**: `lfs.dir()` listet `source/` auf; die
  Ordner werden mit `table.sort()` sortiert und einzeln an `item()`
  übergeben.
- **`batch.lua` → `item()` → Text**: `\clearpage` beginnt den Ordner auf
  einer neuen Seite. `text.txt` wird Zeile für Zeile gelesen; die erste
  Zeile kommt in `\itemtitle`. `tex.sprint(-2, s)` gibt einen String aus, bei dem jedes Zeichen
  wörtlich genommen wird; `& % # $ _ { }` müssen also nicht maskiert
  werden. Um LaTeX-Befehle im Text zu erlauben, stattdessen
  `tex.sprint(s)` verwenden. Eine Leerzeile wird zu `\par`.
- **`batch.lua` → `item()` → Bilder**: Dateien mit der Endung `jpg`,
  `jpeg` oder `png` werden nach Namen sortiert, jede wird zu einem
  `\itemimage{...}`.
