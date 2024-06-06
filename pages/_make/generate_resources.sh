#!/usr/bin/env sh
set -e
[ -d "resources" ] || (echo "find: ‘resources’: No such file or directory" >&2; exit 1)
find resources -mindepth 1 -type d | while read folder; do
  echo "$folder" | awk -F "/" '{while (i++ < NF-1) printf "#"; printf " "; print $NF}'
  for file in `find "$folder" -maxdepth 1 -type f -printf "%f\n"`; do
    echo "[$file]({{ \"/$folder/$file\" | relative_url }})  "
  done
done
