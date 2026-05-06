#!/usr/bin/env bash
while true; do
  echo "Ingresa el primer numero:"
  read NUM1

  echo "Ingresa el Segundo numero:"
  read NUM2

  echo "Que operación desea reslizar? (+, - , *, /)"

  read OPERACION

  if [ "$OPERACION" = "+" ]; then 
    RESULTADO=$((NUM1 + NUM2))
  elif [ "$OPERACION" = "-" ]; then 
    RESULTADO=$((NUM1 - NUM2))
  elif [ "$OPERACION" = "*" ]; then
    RESULTADO=$((NUM1 * NUM2))
  elif [ "$OPERACION" = "/" ]; then
    RESULTADO=$((NUM1 / NUM2))
  else 
    echo "Operación no valida"
    return 
  fi 

echo "El resultado de $NUM1 $OPERACION $NUM2 es $RESULTADO"
do 
#  exit 1 


