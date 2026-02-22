#!/usr/bin/env bash
set -eou pipefail
IFS=$'\n\t'

# ---------------------------------------------------
# Funciones Generalea
# ---------------------------------------------------
PROJET_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJET_ROOT"

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/colores.sh"

# ---------------------------------------------------
# Funciones de mensajes 
# ---------------------------------------------------
msg() { printf "%b===>%b %s\n" "$CYAN" "$RESET" "$1"; }
ok(){ printf "%b [✅]%b %s\n" "$VERDE" "$RESET" "$1"; }
warn(){ printf "%b[!]>%b %s\n" "$AMARILLO" "$RESET" "$1"; } 
err(){ printf "%b[❌]%b %s\n" "$ROJO" "$RESET" "$1"; }

msg "Error"
