#!/usr/bin/env bash
set -eou pipefail
IFS=$'\n\t'


PROJET_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJET_ROOT"
# ==========================================
# Colores
# ==========================================
RESET="\e[0m"
ROJO="\e[31m"
VERDE="\e[32m"
AMARILLO="\e[33m"
AZUL="\e[34m"
MAGENTA="\e[35m"
CYAN="\e[36m"
BLANCO="\e[97m"
