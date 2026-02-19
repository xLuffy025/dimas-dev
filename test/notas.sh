#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

DATA_DIR="$HOME/nota"
LOG_DIR="$DATA_DIR/logs"
LOG_FILE="$LOG_DIR/notas.log"


mkdir -p "$DATA_DIR" "$LOG_DIR"
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
  notas=("$DATA_DIR"/*.md) 
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
    read -p "Seleccione una nota por numero: " opt

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
  read -p "Presione Enter para continuar... "
}

log_info() {
  local mensaje="$1"
  echo "[INFO] $(date '+%F %T') - $mensaje" >> "$LOG_FILE"
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
    read -p "Nombre de Titulo: " texto 
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
    if [[ -f "$HOME/nota/$nota.md" ]]; then
        err "Aviso: la nota ya existe. No se puede Sobrescribirá.."
      pausa && 
      continue

    fi 

    break 
  done

  
  FILENAME="$DATA_DIR/$nota.md"
  TITLE="$nota"
  log_info "Nota creada: $nota.md"

  echo "# $TITLE" > "$FILENAME"

  nvim "$FILENAME"
}

lista_notas() {
  clear

  obtener_notas
  msg "Notas disponibles:"
  imprimir_notas

}

buscar_nota(){
  local notas 

  read -p "Ingresa palabra a buscar: " palabra

  [[ -z "$palabra" ]] && {
    err "Debes ingresar una palabra."
    return 1
  }
  
  obtener_notas
  validar_notas || { err "No hay notas disponibles. "; return 1; }

  resultados=()
  
  for archivo in "${notas[@]}"; do 
    if grep -qi  "$palabra" "$archivo"; then
      resultados+=("$archivo")
    fi 
  done

  if (( ${#resultados[@]} == 0 )); then
    warn "No se encontro conincidencias:"
    pausa 
    return 1 
  fi 

  echo 
  msg "Conincidencias encontrada:"
  for i in "${!resultados[@]}"; do
    nombre=$(basename "${resultados[$i]%.md}")
    echo "$((i+1)) $nombre"
  done 

  while true; do 
    read -p "Seleccione una nota por numero: " opt

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
  msg "Que desea hacer?"
  echo "1) Ver con glow"
  echo "2) Editar con neovim"
  read -p "Elija una opcion: " opcion

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
    read -p "Elige una opcion (1/2): " opcion
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
    read -p "¿Estás seguro de que deseas eliminar '$seleccion'? (s/n): " confirmacion
    if [[  "$confirmacion" == "s" || "$confirmacion" == "S" ]]; then 
      rm "$seleccion"
      msg "El archivo '$seleccion' ha sido eliminado."
    else 
      msg " La eliminacion de '$seleccion'  ha sido cancelada."
    fi 
  else 
    msg "El archivo '$seleccion' no existe. "
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
