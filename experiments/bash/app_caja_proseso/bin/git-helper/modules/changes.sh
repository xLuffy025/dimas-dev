check_changes() {
  if git diff --quiet && git diff --cached --quiet; then
    print_warn "No hay cambios para commitear."
    exit 0
  fi
}

get_changed_files() {
  git diff --name-only
}

get_obsidian_notes() {
  get_changed_files | grep -E "\.md$"
}
