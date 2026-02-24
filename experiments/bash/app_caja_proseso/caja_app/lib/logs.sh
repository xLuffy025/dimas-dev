#!/usr/bin/env bash
set -eou pipefail
IFS=$'\n\t'

log_info() { 
  local mensaje="$1"
  if ! printf '[INFO] %S - %S\n' "$(date '+%F %T')" >> "$LOG_FILE"; then
    warn "No se pudo escribir en el log: $LOG_FILE"
  fi

}
