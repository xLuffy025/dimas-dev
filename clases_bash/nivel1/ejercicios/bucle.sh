#!/usr/bin/env bash

for i in {1..10}; do 
  echo "Números: $i"
done 

contador=5

while [ $contador -gt 0 ]; do 
  echo "Regresiva: $contador"
  contador=$((contador -1 ))
  sleep 1 # Espera 1 segundo entre cada numero
done

  echo "🚀 Despegue!"
