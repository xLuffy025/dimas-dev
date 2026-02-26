#!/usr/bin/env bash
set -eou pipefail
IFS=$'\n\t'

titulo "Consultar historial de un socio"

# -------------------------------------------------------
# 1. verificar si hay socios registrados 
# -------------------------------------------------------
confirmar_socios || return 0

# -------------------------------------------------------
# 2. Seleccionar socio
# -------------------------------------------------------
echo ""
read -r -p "Ingresa el número del socio: " socio

if ! grep -E "^$socio," "$USUARIO_DIR/lista_usuarios.csv" >/dev/null 2>&1; then 
  err "Error el socio no existe."
  return
fi 

archivo="$USUARIO/$socio/registros.csv"

# -------------------------------------------------------
# 3. Validar si tiene registros 
# -------------------------------------------------------
if [[ ! -s "$archivo" ]]; then
  warn "el socio '$socio' no tiene aportaciones registradas."
  sleep 3
  return
fi 

# -------------------------------------------------------
# 4. Mostrar historial 
# -------------------------------------------------------
echo ""
titulo "historial de aportaciones de: $socio"

toral=0
contador=0
ultima_fecha"N/A"

while IFS=',' read -r fecha monto evidencia; do 
  
