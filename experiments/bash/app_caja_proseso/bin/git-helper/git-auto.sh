#!/usr/bin/env bash

#Cargar configuración y módulos 
source "$(dirname "$0")/config/config.sh"
source "$(dirname "$0")/modules/utils.sh"
source "$(dirname "$0")/modules/messages.sh"
source "$(dirname "$0")/modules/changes.sh"

run() {
  check_changes
  local msg
  msg=$(generate_message "$1")
  local target="${2:-.}"
  local branch="${3:-$DEFAULT_BRANCH}"

  print_info "Añaiendo archivos.."
  git add "$target"

  print_info "commit: $msg"
  git push origin "$branch"
}

# Modo interactivo
if [ "$1" == "-i" ]; then
  interactive_commit
else
  run "$0"
fi 


