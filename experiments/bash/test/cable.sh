#!/bin/bash

clear
echo "=== Validación de medida de cable ==="

# Ingreso de medidas
read -p "Ingresa M1 (metros): " m1
read -p "Ingresa M2 (metros): " m2
read -p "Ingresa P1 (pulgadas): " p1
read -p "Ingresa P2 (pulgadas): " p2
read -p "Ingresa medida solicitada (en pies, ej. 40F): " cable_ft

# Convertir cable_total a metros
cable_total=$(echo "$cable_ft * 0.3048" | bc -l)

# Calcular res(M) y res(P)
resM=$(echo "$m1 - $m2" | bc -l)
resP=$(echo "$p1 + $p2" | bc -l)
pulgadas_m=$(echo "$resP * 0.0254" | bc -l)

# Sumar todo
resultado=$(echo "$pulgadas_m + $resM" | bc -l)

# Calcular diferencia y valor absoluto
diferencia=$(echo "$resultado - $cable_total" | bc -l)
abs_dif=$(echo "if ($diferencia < 0) -$diferencia else $diferencia" | bc -l)

# Determinar si falta o sobra
if echo "$diferencia < 0" | bc -l | grep -q 1; then
    mensaje="Faltan"
else
    mensaje="Sobran"
fi

# Mostrar resultados
echo ""
echo "resM = $resM m"
echo "resP = $resP in → $pulgadas_m m"
echo "Resultado final = $resultado m"
echo "Medida solicitada = $cable_total m"
echo "$mensaje $abs_dif m"
