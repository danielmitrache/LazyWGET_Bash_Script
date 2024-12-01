#!/bin/bash

absolute_only=false

if [[ ( "$#" -lt 1 || "$#" -gt 2) ]]; then
  echo "Utilizare: lwget (<flag>) <URL>"
  exit 1
fi

input_site=$1
if [ "$#" -eq 2 ]; then
  if [[ "$1" == "--absolute" ]]; then
    absolute_only=true
    input_site=$2
  fi
fi

mkdir LWGET_CONTENTS
cd LWGET_CONTENTS

base_dir="downloads"

if [[ !("$input_site" =~ ^https?://\.*) ]]; then
  protocol=$(wget -nv "$input_site" 2>&1 | grep -oP "(?<=URL:)https?")
  input_site="${protocol}://${input_site}"
fi

touch new_links
touch processed_links

mkdir -p "$base_dir"

wget -nv "$input_site" -P "$base_dir"

file_name=$(ls -t "$base_dir" | head -n 1)

if [ ! -f "$base_dir/$file_name" ]; then
  echo "Eroare: Nu s-a descărcat fișierul HTML de la $input_site."
  rm -r ../LWGET_CONTENTS
  exit 2
fi

echo "Fișierul HTML descărcat este: LWGET_CONTENTS/$base_dir/$file_name"

current_dir=$(dirname "$input_site")

while read -r extracted_link; do
  if [[ "$extracted_link" == http* ]]; then
    # echo "Link absolut: $extracted_link"
    echo "$extracted_link" >> new_links
  elif [[ "$extracted_link" == /* && "$absolute_only" == false ]]; then
    # echo "Link relativ absolut completat: ${base_url}${extracted_link}"
    echo "${input_site}${extracted_link}" >> new_links
  elif [[ "$absolute_only" == false ]]; then
    # echo "Link relativ la director completat: ${base_url}/${current_dir}/${extracted_link}"
    echo "${input_site}/${current_dir}/${extracted_link}" >> new_links
  fi
done < <(grep -oP '(?<=href=")[^"]*' "$base_dir/$file_name")

echo "Link-urile au fost salvate în fișierul LWGET_CONTENTS/new_links."

exit 0
