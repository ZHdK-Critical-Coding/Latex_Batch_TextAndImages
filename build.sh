#!/bin/sh
# Creates output/document.pdf with all folders in source/.
# Usage: ./build.sh
cd "$(dirname "$0")"
mkdir -p output

echo "source/ -> output/document.pdf"
lualatex -interaction=nonstopmode -halt-on-error \
  -jobname=document -output-directory=output template.tex > /dev/null \
  || echo "  failed, see output/document.log"

# remove the auxiliary files, keep the PDF and the log
rm -f output/*.aux
