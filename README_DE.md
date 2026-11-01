# LaTeX: Text and Images

[English](README.md)

Macht aus allen Ordnern in `source/` ein PDF: jeder Ordner beginnt auf
einer neuen Seite mit dem Text aus seiner `.txt`-Datei, danach folgt jedes Bild aus
dem Ordner auf einer eigenen Seite. Eine Vorlage, beliebig viel Material – einen Ordner hinzufügen und das
Script nochmals ausführen. Ein Shell-Script sammelt die
Ordner in einer LaTeX-Datei, XeLaTeX macht daraus das PDF.

## Installation

Voraussetzungen: eine TeX-Distribution mit XeLaTeX, ein Terminal. Die
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
  `sudo apt install texlive-xetex texlive-latex-extra`.

Die Installation mit `xelatex --version` prüfen. Ein Editor mit
LaTeX-Unterstützung hilft, z. B. Visual Studio Code mit der Erweiterung
**LaTeX Workshop**.

Lizenz: MIT

## Ausführen

Das Ausgangsmaterial liegt in `source/`, ein Ordner pro Abschnitt:

```
source/
  glacier/
    text.txt     beliebige .txt-Datei; erste Zeile: Titel; eine Leerzeile beginnt einen neuen Absatz
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
xelatex -jobname=document -output-directory=output template.tex
```

## Coding-Hilfe

LaTeX kann die Dateien eines Ordners nicht selbst auflisten. Das übernimmt
das Build-Script und schreibt den Inhalt aller Ordner in
`output/content.tex`; wie er aussieht, legt `template.tex` fest, das diese
Datei einbindet.

- **`build.sh` / `build.ps1`**: gehen die Ordner in `source/` durch
  (alphabetisch) und schreiben für jeden:
  - `\itemtitle{...}` mit der ersten Zeile der ersten `.txt`-Datei (oder
    dem Ordnernamen, wenn es keine gibt),
  - die übrigen Zeilen als normalen Text – eine Leerzeile beginnt einen
    neuen Absatz, wie immer in LaTeX,
  - ein `\itemimage{...}` pro Datei mit der Endung `jpg`, `jpeg` oder
    `png`.

  Die Funktion `escape` setzt einen Backslash vor `& % $ # _ { }` (und
  ersetzt `\ ~ ^`), damit diese Zeichen gedruckt und nicht als
  LaTeX-Befehle gelesen werden. Ohne sie sind LaTeX-Befehle im Text
  möglich. Danach läuft einmal
  `xelatex -jobname=document -output-directory=output template.tex`; der
  Jobname benennt das PDF. `-interaction=nonstopmode -halt-on-error` bricht
  beim ersten Fehler ab, statt auf eine Eingabe zu warten. Die
  Hilfsdateien `.aux` werden am Schluss gelöscht.
- **`template.tex`**: das Layout. `geometry` setzt die Ränder, `fontspec`
  erlaubt Unicode-Text und andere Schriften (z. B.
  `\setmainfont{Helvetica}`), `graphicx` setzt die Bilder.
  `\itemtitle{...}` beginnt eine neue Seite mit dem Titel eines Ordners,
  `\itemimage{...}` stellt ein Bild auf eine eigene Seite, eingepasst in
  die Ränder (`width=\textwidth, height=\textheight, keepaspectratio`)
  und mit `\vfill` vertikal zentriert. `\input{output/content.tex}` fügt
  den erzeugten Inhalt ein.
