#!/bin/bash

base_dir="downloads"
temp_links="temp_new_links"
processed_links="processed_links"
new_links="new_links"

absolute_only=false
if [[ $1 == "--absolute" ]]; then
  absolute_only=true
fi

if [ ! -d LWGET_CONTENTS ]; then
  echo "Eroare: Nu există directorul LWGET_CONTENTS. Rulați mai întâi lwget cu un URL."
  exit 1
fi

cd LWGET_CONTENTS

if [ ! -f "$processed_links" ]; then
  echo "Eroare: Nu mai exista fisierul $processed_links!"
  exit 1
fi

if [ ! -f "$new_links" ]; then
  echo "Eroare: Nu mai exista fisierul $new_links!"
  exit 1
fi

touch "$temp_links"

while read -r link; do
  
  if [[ "$link" == \#* ]]; then
    echo "Link ignorat (ancoră): $link"
    continue
  fi

  if [[ "$link" != http* ]]; then
    echo "Link relativ incomplet: $link"
    continue
  fi
    
  wget --content-disposition -q "$link" -P "$base_dir"
  if [ $? -eq 0 ]; then
    last_file=$(ls -t "$base_dir" | head -n 1)

    if [ -s "$base_dir/$last_file" ]; then

      echo "Descarcare reusita: $link"

      base_url=$(echo "$link" | grep -oP '^https?://[^/]+')
      current_dir=$(dirname "$link")

      while read -r extracted_link; do
        if [[ "$extracted_link" == http* ]]; then
          # echo "Link absolut: $extracted_link"
          echo "$extracted_link" >> "$temp_links"
        elif [[ "$extracted_link" == /* && "$absolute_only" == false ]]; then
          # echo "Link relativ absolut completat: ${base_url}${extracted_link}"
          echo "${base_url}${extracted_link}" >> "$temp_links"
        elif [[ "$absolute_only" == false ]]; then
          # echo "Link relativ la director completat: ${base_url}/${current_dir}/${extracted_link}"
          echo "${base_url}/${current_dir}/${extracted_link}" >> "$temp_links"
        fi
      done < <(grep -oP '(?<=href=")[^"]*' "$base_dir/$last_file")

    else
      echo "Descărcare eșuată (fișier gol): $link"
      rm "$base_dir/$last_file"
      continue
    fi
  else
    echo "Eroare la descărcarea link-ului: $link"
  fi

  echo "$link" >> "$processed_links"
done < "$new_links"

> "$new_links"

while read -r temp_link; do
  if ! grep -Fxq "$temp_link" "$processed_links"; then
    echo "$temp_link" >> "$new_links"
  fi
done < "$temp_links"

sort -u "$new_links" -o "$new_links"

rm "$temp_links"

echo "Nu mai sunt link-uri de procesat pe acest nivel."
exit 0
