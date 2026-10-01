#!/bin/sh
# Creates output/<folder>.pdf for every folder in source/.
# Usage: ./build.sh
cd "$(dirname "$0")"
mkdir -p output

for dir in source/*/; do
  item=$(basename "$dir")
  echo "source/$item -> output/$item.pdf"
  lualatex -interaction=nonstopmode -halt-on-error \
    -jobname="$item" -output-directory=output template.tex > /dev/null \
    || echo "  failed, see output/$item.log"
done

# remove the auxiliary files, keep the PDFs and logs
rm -f output/*.aux
