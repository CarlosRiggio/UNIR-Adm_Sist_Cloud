#!/bin/bash

# Verificar que el número de parámetros sea exactamente 2
if [ "$#" -ne 2 ]; then
  echo "Uso: $0 archivo_origen archivo_destino"
  exit 1
fi

# Copiar el archivo origen al archivo destino
cp "$1" "$2"

# Verificar si la copia fue exitosa
if [ $? -eq 0 ]; then
  echo "Archivo copiado exitosamente."
else
  echo "Error al copiar el archivo."
  exit 1
fi