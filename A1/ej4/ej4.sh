#!/bin/bash
if [ "$#" -ne 2 ]; then
  echo "Se necesitan 2 argumentos. Uso: $0 archivo_origen archivo_destino"
  exit 1
fi
cp "$1" "$2"
