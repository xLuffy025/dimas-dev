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
CYAN="\e[36m"
BLANCO="\e[97m"
# ---------------------------------------------------
# Funciones de mensajes 
# ---------------------------------------------------
msg() { printf "%b===>%b %s\n" "$CYAN" "$RESET" "$1"; }
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
  local valor="$1"
  if [[ "$valor" == "0" ]]; then 
    return 1 
  fi
  return 0
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
