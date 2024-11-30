#!/bin/bash

if [ "$#" -ne 1 ]; then
  echo "Utilizare: lwget <URL>"
  exit 1
fi

mkdir LWGET_CONTENTS
cd LWGET_CONTENTS

input_site=$1
base_dir="downloads"

touch new_links
touch processed_links

mkdir -p "$base_dir"

wget -nv "$input_site" -P "$base_dir"

file_name=$(ls -t "$base_dir" | head -n 1)

if [ ! -f "$base_dir/$file_name" ]; then
  echo "Eroare: Nu s-a descărcat fișierul HTML de la $input_site."
  exit 2
fi

echo "Fișierul HTML descărcat este: $base_dir/$file_name"

grep -oP '(?<=href=")[^"]*' "$base_dir/$file_name" > new_links
echo "Link-urile au fost salvate în fișierul new_links."

exit 0
