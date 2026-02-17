#!/usr/bin/env bash
set -eou pipefail
IFS=$'\n\t'

# ===================================
#   COLORES
# ===================================
RESET="\e[0m"
ROJO="\e[31m"
VERDE="\e[ 32m"
AMARILLO="\e[33"
AZUL="\e[34"
MAGENTA="\e[35"
CYAN="\e[36"
BLANCO="\e[97"

# ====================================
#   FUNCIOES GENERALES
# ====================================
pausa() {
    read -p "Presione ENTER para continuar... "
}

cancelar_si_solicita(){
  local valor="$1"
  if [[ "$valor" == "0" ]]; then
    return 1
  fi 
  return 0
}

# ====================================
#   FUNCIONES DE MENSAJES
# ====================================
msg(){ echo -e "${CYAN}===>${RESET} $1"; }
ok(){ echo -e "${VERDE}[✔️ ]${RESET} $1"; }
warn(){ echo -e "${AMARILLO}[!]${RESET} $1"; }
err(){ echo -e "${ROJO}[ ❌ ]>${RESET} $1"; }

# ====================================
#   FUNCIONES PRINCIPALES
# ====================================

crear_nota(){
  while true; do 
    read -p "Nombre de la Nota: " nota
    cancelar_si_solicita "$nota" || return

  # Validación: no vacío
    [[ -z "$nota" ]] && 
      err "El Titulo no puede estar vacío"
      continue
    

  # Validación: caracteres permitidos 
    [[ ! "$nota" =~ ^[A-Za-z0-9_]+$ ]] &&
      err "Solo letras/numeros/_" &&
      continue
      
  # Validación: exitencia previa 
    grep -q "^$nota" "$dir" &&
      err "La nota ya existe.." &&
      continue
    break 
  done



  mkdir -p "$HOME/nota"

  dir="$HOME/nota"
  filename="$dir/$nota.md"
  title="$nota"

  echo "# $title" > "$filename"

  nvim "$fileneme"

}

# ========================================
#   Menu
# ========================================
while true; do 
  clear
  echo -e "${CYAN}=========================${RESET}"
  echo -e "${MAGENTA} SISTEMA DE NOTA MARKDOWN ${RESET}"
  echo -e "${CYAN}=========================${RESET}"
  echo -e "${AZUL}1)${RESET} Crear Nota"
  echo -e "${ROJO}0)${RESET} Salir"
  echo -e "${CYAN} ---------------------------${RESET}"
  read -p "Seleccione una opcion: " opcion

  case "opcion" in 
    1) crear_nota ;;
    0) exit ;;
    *) err "Opcion invalida"; sleep 1 ;;
  esac
done  










