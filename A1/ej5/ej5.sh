#!/bin/bash

# Obtener la fecha actual en formato año, mes, día
fecha=$(date +%Y%m%d)

# Recorrer todos los archivos con extensión JPG en el directorio actual
for archivo in *.jpg; do
  # Verificar si existen archivos con extensión JPG
  if [ -e "$archivo" ]; then
    # Renombrar el archivo añadiendo el prefijo de la fecha
    mv "$archivo" "${fecha}-${archivo}"
  fi
done