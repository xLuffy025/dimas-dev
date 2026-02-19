generate_message() {
  local user_msg="$1"

  # Si el usuario escribió un mensaje, úsalo
  if [ -n "$user_msg" ]; then
    echo "$user_msg"
    return
  fi 

  # Detectar notas de Obsidian 
  if [ "$OBSIDIAN_MODE" =
    true ]; then
    local notes
    notes=$(get_obsidian_notes)

    if [ -n "$notes" ]; then
      echo "$TEMPLATE_UPDATE_NOTE $notes"
      return
    fi 
  fi 

  # Conventional Commits automático
  if [ "$USE_CONVENTIONAL" = true ]; then
    local files
    files=$(get_changed_files)
    echo "chore: acualiza archivos → $files"
    return
  fi 

  # Mensaje genérico
  echo "Actualiza archvos modificados"
}

interactive_commit() {
  print_info "Modo interactivo"
  
  read -rp "Mensaje de commit (enter para automatico): " user_msg
  read -rp "Ruta a añadir (default .): " path
  read -rp "Branch (default actual): " Branch

  run "$msg" "$path" "$branch"
}

