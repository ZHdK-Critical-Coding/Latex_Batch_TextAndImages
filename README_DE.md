# LaTeX: Text and Images

[English](README.md)

Macht aus allen Ordnern in `source/` ein PDF: jeder Ordner beginnt auf
einer neuen Seite mit dem Text aus seiner `.txt`-Datei (optional, beliebiger Name), danach folgt jedes Bild aus
dem Ordner auf einer eigenen Seite. Eine Vorlage, beliebig viel Material – einen Ordner hinzufügen und das
Script nochmals ausführen. Ein Shell-Script sammelt die
Ordner in einer LaTeX-Datei, XeLaTeX macht daraus das PDF.

## Installation

Voraussetzungen: eine TeX-Distribution mit XeLaTeX, ein Terminal. Die
Vorlage verwendet nur Standardpakete (`geometry`, `fontspec`, `babel`, `graphicx`, `adjustbox`, `eso-pic`).

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

Die Schrift TeX Gyre Heros (ein freier Helvetica-Klon) liegt in `fonts/`,
es muss nichts installiert werden.

Die Installation mit `xelatex --version` prüfen. Ein Editor mit
LaTeX-Unterstützung hilft, z. B. Visual Studio Code mit der Erweiterung
**LaTeX Workshop**.

Lizenz: MIT. Schrift: TeX Gyre Heros, [GUST Font License](fonts/GUST-FONT-LICENSE.txt).

## Ausführen

Das Ausgangsmaterial liegt in `source/`, ein Ordner pro Abschnitt:

```
source/
  glacier/
    text.txt     optional, beliebiger Name mit Endung .txt (die erste wird verwendet);
                 eine Leerzeile beginnt einen neuen Absatz
    01.jpg       Bilder (jpg, png), in alphabetischer Reihenfolge gesetzt
    02.jpg
  harbour/
    ...
```

Ein Terminal im Ordner des Repositorys öffnen und ausführen:

- **macOS / Linux**: `./build.sh`
- **Windows**: `powershell -ExecutionPolicy Bypass -File build.ps1`

Das Script erzeugt `output/document.pdf` (A5, 12 mm Rand, randabfallende Bilder) mit den Ordnern
in alphabetischer Reihenfolge. Die Ordner in `source/` durch eigenes Material ersetzen und das
Script nochmals ausführen. Ein bestehendes PDF wird überschrieben. Schlägt es fehl, steht der Fehler in `output/document.log`.

Dasselbe von Hand:

```sh
xelatex -jobname=document -output-directory=output template.tex
```

## Auf GitHub

Jeder Push auf `main` erzeugt das PDF auf GitHub
(`.github/workflows/build.yml`, mit
[GitHub Action for LaTeX](https://github.com/marketplace/actions/github-action-for-latex)).
Herunterladen im Tab **Actions**: den Durchlauf öffnen, dann **Artifacts →
document**. **Run workflow** startet einen Build von Hand.

Ein Tag, der mit `v` beginnt, erstellt zusätzlich ein Release mit dem PDF:

```sh
git tag v1.0
git push origin v1.0
```

Der Workflow verwendet TeX Live 2026 (`texlive_version`) und installiert
die Schriften aus `fonts/` (`extra_fonts`). `pre_compile` führt
`./build.sh --content-only` aus, das nur `output/content.tex` schreibt;
danach kompiliert die Action `template.tex` mit XeLaTeX.

## Coding-Hilfe

LaTeX kann die Dateien eines Ordners nicht selbst auflisten. Das übernimmt
das Build-Script und schreibt den Inhalt aller Ordner in
`output/content.tex`; wie er aussieht, legt `template.tex` fest, das diese
Datei einbindet.

- **`build.sh` / `build.ps1`**: gehen die Ordner in `source/` durch
  (alphabetisch) und schreiben für jeden:
  - `\clearpage`, damit jeder Ordner auf einer neuen Seite beginnt,
  - die erste `.txt`-Datei als normalen Text (gibt es keine, erhält der
    Ordner keinen Text) – eine Leerzeile beginnt einen neuen Absatz, wie
    immer in LaTeX,
  - ein `\itemimage{...}` pro Datei mit der Endung `jpg`, `jpeg` oder
    `png`.

  Die Funktion `escape` setzt einen Backslash vor `& % $ # _ { }` (und
  ersetzt `\ ~ ^`), damit diese Zeichen gedruckt und nicht als
  LaTeX-Befehle gelesen werden. Ohne sie sind LaTeX-Befehle im Text
  möglich. Danach läuft einmal
  `xelatex -jobname=document -output-directory=output template.tex`; der
  Jobname benennt das PDF. `-interaction=nonstopmode -halt-on-error` bricht
  beim ersten Fehler ab, statt auf eine Eingabe zu warten. Die
  Hilfsdateien `.aux` werden am Schluss gelöscht. `./build.sh
  --content-only` hört nach dem Schreiben von `output/content.tex` auf
  (für GitHub).
- **`template.tex`**: das Layout. `geometry` setzt A5 mit 12 mm Rand
  (z. B. `a4paper` ausprobieren), `fontspec` erlaubt Unicode-Text und lädt die
  Schrift aus `fonts/` (`\setmainfont{texgyreheros-regular.otf}[Path=fonts/]`;
  für eine Systemschrift z. B. `\setmainfont{Helvetica}`), `babel` wählt die deutsche
  Silbentrennung. Der Text steht in 14/16 pt im Blocksatz, mit einer
  Leerzeile (16 pt) zwischen den Absätzen und der ersten Grundlinie 16 pt
  unter dem Rand, wie in der Typst- und der CSS-Version.
  `\itemimage{...}` stellt ein Bild randabfallend auf eine eigene Seite:
  `eso-pic` setzt es in den Seitenhintergrund, unabhängig von den Rändern,
  und `adjustbox` skaliert es so, dass es die ganze Seite bedeckt; was
  übersteht, wird abgeschnitten. `\input{output/content.tex}` fügt den
  erzeugten Inhalt ein.
