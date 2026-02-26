#!/usr/bin/env bash
set -eou pipefail
IFS=$'\n\t'

SEPARADOR="===================================="

#----------------------------------------------------
# Colores 
#----------------------------------------------------
RESET="\e[0m"
ROJO="\e[31m"
VERDE="\e[32m"
AMARILLO="\e[33m"
AZUL="\e[34m"
MAGENTA="\e[35m"
CYAN="\e[36m":
BLANCO="\e[97m"
# ---------------------------------------------------
# Funciones de mensajes 
# ---------------------------------------------------
msg(){ printf "%b===>%b %s\n" "$CYAN" "$RESET" "$1"; }
ok(){ printf "%b [✅]%b %s\n" "$VERDE" "$RESET" "$1"; }
warn(){ printf "%b[!]>%b %s\n" "$AMARILLO" "$RESET" "$1"; } 
err(){ printf "%b[❌]%b %s\n" "$ROJO" "$RESET" "$1"; }

# ----------------------------------------------------
# Funcions Generales 
# ---------------------------------------------------
pausa() {
  read -p "Precione ENTER para continuar..."
}

cancelar_si_solicita() {
  read -r -p "¿Cancelar? (0 para concelar): " opcion
  
  if [[ "$opcion" == "0" ]]; then
    log_warn "Operación cancelada por el usuario"
    return 0 
  fi
  return 1
}

confirmar() {
  local mensaje="$1"
  read -r -p "¿${mensaje}? (s/n): " respuesta
  
  if [[ "$respuesta" == "s" || "$respuesta" == "S" ]]; then
    return 0  # Confirmado
  else
    return 1  # Cancelado
  fi
}
# ----------------------------------------------------
# Funciones de interfas 
# ----------------------------------------------------
linea() {
  # Imprime la liena usando la variable pura y le aplica el color 
  printf "%b%s%b\n" "$CYAN" "$SEPARADOR" "$RESET"
}

titulo() {
  clear 
  linea

  local ancho_menu=${#SEPARADOR}
  local texto="$1"
  local longitud=${#texto}

  # Cálculo para centrar
  local padding=$(( (ancho_menu + longitud)/2))

  # Imprime el texto centrado con color 
  printf "%b%*s%b\n" "$MAGENTA" $padding "$texto" "$RESET"

  linea
}
