#!/usr/bin/env bash

set -eou pipefail
IFS=$'\n\t'  

registrar_socio() {
  clear
  printf "%b=========================%b\n" "$CYAN" "$RESET"
  printf "%b  Registro de socio nuevo %b\n" "$MAGENTA" "$RESET"
  printf "%b=========================%b\n" "$CYAN" "$RESET"

  # ------ Pedir nombre corto ------
  
  while true; do 
    read -r -p "Nombre corto (0 pata cancelar): " nombre
    cancelar_si_solicita "$nombre" || return 0

    # ------ Validacion
    
               
}
