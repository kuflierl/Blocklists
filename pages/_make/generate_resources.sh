#!/usr/bin/env sh
find resources -mindepth 1 -type d | while read folder; do
  echo "$folder" | awk -F "/" '{while (i++ < NF-1) printf "#"; printf " "; print $NF}'
  for file in `find "$folder" -maxdepth 1 -type f -printf "%f\n"`; do
    echo "[$file]({{ \"/$folder/$file\" | relative_url }})  "
  done
done
