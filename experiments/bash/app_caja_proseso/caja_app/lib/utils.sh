#!/usr/bin/env bash
set -eou pipefail
IFS=$'\n\t'

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
  printf "%b============================================%b\n" "$CYAN" "$RESET"
}

titulo() {
  clear
  linea
  printf "%b$1%b\n" "$MAGENTA" "$RESET"
  linea
}
