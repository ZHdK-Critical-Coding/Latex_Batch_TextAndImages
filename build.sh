#!/bin/sh
# Creates output/document.pdf with all folders in source/.
# Usage: ./build.sh
cd "$(dirname "$0")"
mkdir -p output

# make text safe for LaTeX: & % $ # _ { } \ ~ ^ are printed as characters
escape() {
  tr -d '\r' | sed -e 's/\\/\\textbackslash /g' \
                   -e 's/[&%$#_{}]/\\&/g' \
                   -e 's/~/\\textasciitilde /g' \
                   -e 's/\^/\\textasciicircum /g'
}

# write the content of every folder into output/content.tex
for folder in source/*/; do
  text=$(ls "$folder"*.txt 2>/dev/null | head -n 1)   # first .txt file

  # every folder starts on a new page
  echo "\\clearpage"

  # text (optional): the whole file, an empty line starts a new paragraph
  [ -n "$text" ] && escape < "$text"
  echo

  # images: jpg, jpeg, png, sorted by name
  ls "$folder" | grep -i -E '\.(jpe?g|png)$' | while read -r image; do
    echo "\\itemimage{$folder$image}"
  done
done > output/content.tex

echo "source/ -> output/document.pdf"
xelatex -interaction=nonstopmode -halt-on-error \
  -jobname=document -output-directory=output template.tex > /dev/null \
  || echo "  failed, see output/document.log"

# remove the auxiliary files, keep the PDF and the log
rm -f output/*.aux
