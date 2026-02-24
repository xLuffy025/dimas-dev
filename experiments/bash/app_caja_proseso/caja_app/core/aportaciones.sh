#!/usr/bin/env bash
set -eou pipelfail
IFS=$'\n\t'

clear
while true; do 
  printf "%b==============================%b\n" "$CYAN" "$RESET"
  printf "%b Registrar aportaciones  %b\n" "$MAGENTA" "$RESET"
  printf "%b==============================%b\n" "$CYAN" "$RESET"

  # -------------------------------------------------------
  # 1. Verificar si ahi socio registrados 
  # -------------------------------------------------------
  [[ ! -s "$USUARIO_DIR/lista_usuarios.csv" ]] &&
    warn "No hay socios registrados." &&
    pausa &&
    return 
  cut -d',' -f1 "$USUARIO_DIR/lista_usuarios.csv"
  msg "Socio disponibles: "

  # ------------------------------------------------------
  # 2. Seleccionar socio
  # ------------------------------------------------------
  while true; do 
    read -r -p "Selecciona socio (0 para cancelar): " socio
    cancelar_si_solicita "$socio" || return 0
    grep -q
