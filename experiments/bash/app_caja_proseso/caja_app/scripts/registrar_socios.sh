#!/usr/bin/env bash

# ================================================================ 
# Nombre: registrar_socio.sh
# Discripción: registrar socio en caja de ahorro por (Nombre, 
# Fecha de entrega, Contreseña, Numero de Telefono).
# Autor: xLuffy025
# ================================================================ 

# ---------------------------------------------------------------- 
# MODO ESTRICTO (red de seguridaf)
# ---------------------------------------------------------------- 
set -eou pipefail
IFS=$'\n\t'  

# ---------------------------------------------------------------- 
# VARIABLED GLOBALES Y CONFIGURACION
# ---------------------------------------------------------------- 
PROJET-ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "PROJET-ROOT"

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)../config/config.sh"

# ----------------------------------------------------------------
# FUNCIONES DE UTILIDAD
# ---------------------------------------------------------------- 

