#!/bin/bash

echo "Nombre del script: $0"
args_num=$#
echo "Número de argumentos: $args_num"

if [ $args_num -eq 1 ]; then
    echo "Primer argumento: $1"
elif [ $args_num -ge 2 ]; then
    echo "Primer y segundo argumentos: $1 $2"
    if [ $args_num -gt 2 ]; then
        echo "Argumentos a partir del tercero:"
        for arg in "${@:3}"; do
            echo "$arg"
        done
    fi
fi