#!/usr/bin/env bash

# -------------------------------------------------
#  Calculadora de Edad
#  - Pregunta el año de nacimiento al usuario
#  - Calcula la edad basada en el año actual
#  - Informa si es mayor o menor de edad
# -------------------------------------------------

# Pedir el año de nacimiento
read -p "Introduce tu año de nacimiento (ejemplo: 1995): " nacimiento

# Validar que se haya introducido un número
if ! [[ "$nacimiento" =~ ^[0-9]{4}$ ]]; then
    echo "❌ Entrada no válida. Por favor, escribe un año de 4 dígitos."
    exit 1
fi

# Obtener el año actual
anio_actual=$(date +"%Y")

# Calcular la edad
edad=$((anio_actual - nacimiento))

# Verificar que la edad sea razonable (por ejemplo, entre 0 y 130 años)
if (( edad < 0 || edad > 130 )); then
    echo "❌ La edad calculada ($edad) no parece correcta. Revisa el año ingresado."
    exit 1
fi

# Determinar mayoría de edad (en la mayoría de países: 18 años)
if (( edad >= 18 )); then
    echo "🎉 Tienes $edad años. Eres mayor de edad."
else
    echo "🧒 Tienes $edad años. Eres menor de edad."
fi 


