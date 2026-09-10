#!/bin/sh
# Compile the LaTeX CV and install it as the site's downloadable PDF.
#
# Source of truth:  cv/Tanvir-Ahmed-CV.tex
# Published copy:   assets/cv/Tanvir-Ahmed-CV.pdf
#
# Layout follows the "Jake's Resume" template (MIT). Two pdflatex passes are
# required because the entry headers use tabularx and need their widths settled.
#
# Usage:  ./build-cv.sh
set -e

[ -f cv/Tanvir-Ahmed-CV.tex ] || { echo "run this from the repository root"; exit 1; }
command -v pdflatex >/dev/null 2>&1 || { echo "pdflatex not found (brew install --cask mactex-no-gui)"; exit 1; }

cd cv
pdflatex -interaction=nonstopmode -halt-on-error Tanvir-Ahmed-CV.tex >/dev/null
pdflatex -interaction=nonstopmode -halt-on-error Tanvir-Ahmed-CV.tex >/dev/null
# keep the working tree clean; the .tex and .pdf are the only things worth keeping
rm -f Tanvir-Ahmed-CV.aux Tanvir-Ahmed-CV.log Tanvir-Ahmed-CV.out
cd ..

cp cv/Tanvir-Ahmed-CV.pdf assets/cv/Tanvir-Ahmed-CV.pdf
echo "built cv/Tanvir-Ahmed-CV.pdf and installed to assets/cv/"
if command -v pdfinfo >/dev/null 2>&1; then
  PAGES=$(pdfinfo assets/cv/Tanvir-Ahmed-CV.pdf | awk '/^Pages:/{print $2}')
else
  PAGES="?"
fi
# pdflatex stores objects in compressed streams, so count the links at the source
LINKS=$(grep -o '\\href{' cv/Tanvir-Ahmed-CV.tex | wc -l | tr -d ' ')
SIZE=$(( $(wc -c < assets/cv/Tanvir-Ahmed-CV.pdf) / 1024 ))
echo "  pages: $PAGES   size: ${SIZE} KB   hyperlinks: $LINKS"
