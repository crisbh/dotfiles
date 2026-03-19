#!/bin/bash

# Visualises PDF files in the terminal.
# Uses timg if inside a TMUX sesion, otherwise uses pdftoppm and wezterm's imgcat.

pdfview() {
  if [ -n "$TMUX" ]; then
    timg --title "$@"
  else
    pdftoppm -r 150 "$1" /tmp/pdfpreview
    for img in /tmp/pdfpreview-*.ppm; do
      wezterm imgcat "$img"
    done
    command rm -f /tmp/pdfpreview-*.ppm
  fi
}

# Removes (temp) files with specific extensions in target directory

cleanuptmp() {
  local extensions=("aux" "bbl" "out" "log" "blg" "synctex.gz" "fls" "fdb_latexmk" \
      "bak" ".o")

  if (( $# == 0 )); then
    local directory=./
  else
    local directory=$1"/"
  fi

  local files_found=false

  for ext in "${extensions[@]}"; do
    local matching_files=($directory*.$ext(N))
    if (( ${#matching_files} > 0 )); then
      files_found=true
      rm -f $matching_files
    fi
  done

  if $files_found; then
    echo "Done removing temp files."
  else
    echo "No temp files found."
  fi
}

