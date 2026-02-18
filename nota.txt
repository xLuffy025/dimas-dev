#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

DATA_DIR="$HOME/nota"

mkdir -p "$DATA_DIR"

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

# --------------------------------------------------------
#   FUNCIONES GENERALES
# --------------------------------------------------------
obtener_notas(){
  notas="$DATA_DIR"/*.md
}

validar_notas(){
  obtener_notas
  [[ -e "${notas[0]}" ]] || return 1
}

imprimir_notas(){
  obtener_notas
  for i in "${!notas[@]}"; do 
    nombre=$(basename "${notas[$i]%.md}")
    echo "$((i+1))) $nombre"
  done
}

seleccionar_notas() {
  validar_notas || { err "No hay notas disponibles."; return 1; }
  imprimir_notas

  while true; do 
    read -p "Seleccione una nota por numero: " opt 

    [[ "$opt" =~ ^[0-9]+$ ]] || { err "Numero invalido."; continue; }

    idx=$((opt-1))

    if  (( idx >= 0 && idx < ${#nota[@]} )); then 
      echo "${notas[$idx]}"
      return 0 
    else 
      err "Numero fuera de rango."
    fi 
  done 
}

pausa(){
  read -p "Presione Enter para continuar... "
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
    read -p "Nombre de Titulo: " nota 
    cancelar_si_solicita "$nota" || return 0

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

  echo "# $TITLE" > "$FILENAME"

  nvim "$FILENAME"

}

lista_notas() {
  clear

  notas=("$DATA_DIR"/*.md)

  echo "Notas:"
  for i in "${!notas[@]}"; do 
    nombre=$(basename "${notas[$i]%.md}")
    echo "$((i+1))) $nombre"
  done 

}

buscar_nota(){
  msg "En proceso"

}

editar_nota(){
  #clear
  seleccion=$(seleccionar_notas) || return 1 
   
  #  Menu de accion
    clear
    msg "Que desea hacer con  tus notas?"
    echo "1) Ver con glow"
    echo "2) Editar con neovim"
    read -p "Elige una opcion (1/2): " opcion

    case $opcion in 
      1) glow "$seleccion" ;;
      2) nvim "$seleccion" ;;
      *) err "Opcion invalida... " ;;
    esac

}

eliminar_nota(){
  msg "En proceso"

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

while true; do
  mostrar_menu
  read -p "Seleccione una opcion: " opt 
  case $opt in
    1) crear_nota ;;
    2) lista_notas ;;
    3) buscar_nota ;;
    4) editar_nota ;;
    5) eliminar_nota ;;
    0) echo "Saliendo... "; exit 0 ;;
    *) err "opcion no valida." ;;
  esac
  
  read -p "Presione Enter para continuar..."

done 

    
