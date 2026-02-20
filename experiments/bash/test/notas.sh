#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Directorios y archivos por defecto
DATA_DIR="${DATA_DIR:-$HOME/dimas-dev/nota}"
LOG_DIR="${LOG_DIR:-$DATA_DIR/logs}"
LOG_FILE="${LOG_FILE:-$LOG_DIR/notas.log}"
TRASH_DIR="$DATA_DIR/.trash"

mkdir -p "$DATA_DIR" "$LOG_DIR" "$TRASH_DIR"

trap 'err "Ocurrió un error inesperado."; exit 1' ERR

# -------------------------------------------------------
#       Colores
# -------------------------------------------------------
GREEN="\e[32m"
YELLOW="\e[33m"
CYAN="\e[36m"
RED="\e[31m"
BLUE="\e[34m"
MAGENTA="\e[35m"
WHITE="\e[97m"
RESET="\e[0m"

# -------------------------------------------------------
#       Funciones de Mensajes 
# -------------------------------------------------------
msg(){ echo -e "${CYAN}==>${RESET} $1"; }
ok(){ echo -e "${GREEN}[✔️]  ${RESET}  $1"; }
warn(){ echo -e "${YELLOW} [!]${RESET} $1"; }
err(){ echo -e "${RED} [✖️]  ${RESET} $1"; } 

# -------------------------------------------------------
#   DEPENDENCIAS
# -------------------------------------------------------
command -v nvim > /dev/null || { err "neovim no instalado"; exit 1; } 

command -v glow >/dev/null || { err  "glow no instalado"; exit 1; }

# --------------------------------------------------------
#   FUNCIONES GENERALES
# --------------------------------------------------------
obtener_notas() {
  shopt -s nullglob
  notas=("$DATA_DIR"/*.md)
  shopt -u nullglob
}

validar_notas() { 
  obtener_notas 
  [[ -e "${notas[0]}" ]] || return 1 
}

imprimir_notas() { 
  obtener_notas 
  for i in "${!notas[@]}"; do 
    nombre=$(basename "${notas[$i]%.md}") 
    echo "$((i+1))) $nombre" 
  done 
}
seleccionar_notas() {
  #obtener_notas
  validar_notas || { err "No hay notas disponibles."; return 1; }

  msg "Notas Disponibles:"
  imprimir_notas
  
  # Pedir sececcion
  while true; do
    if ! read -r -p "Seleccione una nota por numero: " opt; then
      return 1
    fi

    #cancelar_si_solicita "$opt" || return 0

    # Validación sea numero 
    [[ "$opt" =~ ^[0-9]+$ ]] || {
      err "Ingresa un numero valido."
      pausa
      continue
 

    }
  # Convertir a indice (0 based)
  idx=$((opt-1))
  
  # Validación: rango 
    if (( idx >= 0 && idx < ${#notas[@]} )); then
      seleccion="${notas[$idx]}"
      break 
    else
      err "Numero fuera de rango."
      pausa
    fi
  done
}

pausa(){
  read -r -p "Presione Enter para continuar... "
}

log_info() {
  local mensaje="$1"
  if ! echo "[INFO] $(date '+%F %T') - $mensaje" >> "$LOG_FILE"; then
    warn "No se pudo escribir en el log."
  fi
}

cancelar_si_solicita() {
  local valor="$1"
  if [[ "$valor" == "0" ]]; then
    return 1
  fi 
  return 0
}

# --------------------------------------------------------
#         Funciones Principales
# --------------------------------------------------------
crear_nota() {
  while true; do 
    if ! read -r -p "Nombre de Titulo (0) para cancelar: " texto; then
      return 1
    fi 
    cancelar_si_solicita "$texto" || return 0

    nota="${texto// /_}"

    # Validación: no vacio
    [[ -z "$nota"  ]] && {
      err "El Titulo no puede estar vacío." &&
      pausa &&
    continue
    }

  # Validación: caracteres permitidos
    [[ ! "$nota" =~ ^[A-Za-z0-9_]+$ ]] && {
    err "Solo permite letras, número y _ ... " &&
    pausa &&
    continue
    }
  
  # Validación: existencía previa
    if [[ -f "$DATA_DIR/$nota.md" ]]; then
      err "Aviso: la nota ya existe. No se puede sobrescribir."
      pausa && 
      continue

    fi 

    break 
  done

  
  local FILENAME="$DATA_DIR/$nota.md"
  local TITLE="$nota"
  log_info "Nota creada: $nota.md"

  echo "# $TITLE" > "$FILENAME"

  nvim "$FILENAME"
}

lista_notas() {
  clear

  validar_notas || { err "No hay notas disponibles."; return 1; }
  msg "Notas disponibles:"
  imprimir_notas

}

buscar_nota(){
  local notas
  local palabra
  local resultados
  local seleccion
  local idx
  local opt

  if ! read -r -p "Ingresa palabra a buscar (0) para cancelar: " palabra; then
    return 1
  fi

  cancelar_si_solicita "$palabra" || return 0

  [[ -z "$palabra" ]] && {
    err "Debes ingresar una palabra."
    return 1
  }
  
  obtener_notas
  validar_notas || { err "No hay notas disponibles. "; return 1; }

  resultados=()
  
  for archivo in "${notas[@]}"; do 
    if grep -Fqi  "$palabra" "$archivo"; then
      resultados+=("$archivo")
    fi 
  done

  if (( ${#resultados[@]} == 0 )); then
    warn "No se encontraron coincidencias."
    pausa 
    return 1 
  fi 

  echo
  msg "Coincidencias encontradas:"
  for i in "${!resultados[@]}"; do
    nombre=$(basename "${resultados[$i]%.md}")
    echo "$((i+1)) $nombre"
  done 

  while true; do
    if ! read -r -p "Seleccione una nota por numero (0) para cancelar: " opt; then
      return 1
    fi

    cancelar_si_solicita "$opt" || return 0

    [[ "$opt" =~ ^[0-9]+$ ]] || { err "Numero invalido."; continue; }

    idx=$((opt-1))

    if (( idx >= 0 && idx < ${#resultados[@]} )); then 
      seleccion="${resultados[$idx]}"
      break 
    else 
      err "Numero fuera de rango."
    fi 
  done 

  clear
  msg "Que desea hacer (0) para cancelar?"
  echo "1) Ver con glow"
  echo "2) Editar con neovim"
  read -r -p "Elija una opcion: " opcion
  cancelar_si_solicita "$opcion" || return 0
  
  case $opcion in 
    1) glow "$seleccion" ;;
    2) nvim "$seleccion" ;;
    *) err "Opcion invalida." ;;
  esac 
}

editar_nota(){
  seleccionar_notas || return 1

  #  Menu de accion 
    clear
    msg "Que desea hacer con  tus notas?"
    echo "1) Ver con glow"
    echo "2) Editar con neovim"
    read -r -p "Elige una opcion (1/2): " opcion
    cancelar_si_solicita "$opcion" || return 0
    clear

    case $opcion in 
      1) glow "$seleccion" ;;
      2) nvim "$seleccion" ;;
      *) err "Opcion invalida... " ;;
    esac
}

eliminar_nota(){
  clear
  seleccionar_notas || return 1

  if [[ -f "$seleccion" ]]; then
    local nombre
    nombre=$(basename "$seleccion")
    read -r -p "¿Estás seguro de que deseas eliminar '$nombre'? (s/n): " confirmacion
    if [[  "$confirmacion" == "s" || "$confirmacion" == "S" ]]; then 
      rm "$seleccion"
      msg "El archivo '$nombre' ha sido eliminado."
    else
      msg "La eliminacion de '$nombre' ha sido cancelada."
    fi 
  else 
    msg "El archivo no existe. "
  fi 

}

# --------------------------------------------------------
#         Menu Interactivo
# --------------------------------------------------------
mostrar_menu() {
  clear 
  echo -e "${CYAN}==============================${RESET}"
  echo -e "${CYAN} 🚀 Notas Mackdown      ${RESET}"
  echo -e "${CYAN}==============================${RESET}"
  echo -e "${YELLOW}1)${RESET} Crear Nota" 
  echo -e "${YELLOW}2)${RESET} Listar Notas"
  echo -e "${YELLOW}3)${RESET} Buscar por palabra"
  echo -e "${YELLOW}4)${RESET} Editar Nota"
  echo -e "${YELLOW}5)${RESET} Eliminar nota"
  echo -e "${YELLOW}0)${RESET} Salir"
  echo

}
# --------------------------------------------------------
#   FUNCIONES AUTOMATICAS
# --------------------------------------------------------
if [ $# -gt 0 ]; then
    case $1 in
        crear) crear_nota ;;
        listar) lista_notas ;;
        buscar) buscar_nota ;;
        editar) editar_nota ;;
        eliminar) eliminar_nota ;;
        *) err "Opción no válida"; exit 1 ;;
        
    esac
else 

while true; do
  mostrar_menu
  read -p "Seleccione una opcion: " opt 
  case $opt in
    1) crear_nota ;;
    2) lista_notas ;;
    3) buscar_nota ;;
    4) editar_nota ;;
    5) eliminar_nota ;;
    0) msg "Saliendo... "; exit 0 ;;
    *) err "opcion no valida." ;;
  esac 

  pausa

done
fi     
