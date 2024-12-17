#!/bin/bash
fecha=$(date +%Y%m%d)
for archivo in *.jpg *.JPG; do
  if [ -e "$archivo" ]; then
    mv "$archivo" "${fecha}-${archivo}"
  fi
done


# for archivo in *.jpg *.JPG; do
#     if [ -f "$archivo" ]; then
#         nombre_fecha="${fecha}-$archivo"
#         mv "$archivo" "$nombre_fecha"
#         echo "Archivo renombrado: $archivo -> $nombre_fecha"
#     fi
# done