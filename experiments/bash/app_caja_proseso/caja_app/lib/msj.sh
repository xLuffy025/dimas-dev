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

