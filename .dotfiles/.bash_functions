#!/bin/bash


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

