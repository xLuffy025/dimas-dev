#!/usr/bin/env bash

# Preguntar el nombre
read -p "¿Cual es tu nombre?: " nombre

# Preguntar tu edad 
read -p "¿Cual es tu edad?: " edad

if [ $edad -ge 60 ]; then 
  echo "Hola $nombre, eres adulto mayor."
elif [ $edad -ge 18 ]; then 
  echo "Hola $nombre, eres un adulto."
else 
  echo "Hola, eres un menor de edad."
fi
