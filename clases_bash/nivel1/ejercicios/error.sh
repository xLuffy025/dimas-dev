#!/usr/bin/env bash

# Intentamos listar una carpeta que no existe
ls ~/bootstrap/

# Capturamso el codigo de salida inmediatamente
estado=$?

if [ $estado -ne 0 ]; then 
  echo "¡Algo salió mal! El codigo de error fue:$estado"
else 
  echo "el comando se ejecutó correctamente."
fi 
