#!/usr/bin/env bash
set -eou pipefail
IFS=$'\n\t'

log_info() { 
  local mensaje="$1"
  if ! printf '[INFO] %s - %s\n' "$(date '+%F %T')" "$mensaje" >> "$LOG_FILE"; then
    log_error "No se pudo escribir en el log: $LOG_FILE"
  fi 

}

log_warn() {
  local mensaje="$1"
  if ! printf '[WARN] %s - %s\n' "$(date '+%F %T')" "$mensaje" >> "$LOG_FILE"; then
    printf '[ERROR] No se pudo escribir en el log: %s\n' "$LOG_FILE" >&2
  fi
}

log_error() {
  local mensaje="$1"
  if ! printf '[ERROR] %s - %s\n' "$(date '+%F %T')" "$mensaje" >> "$LOG_FILE"; then
    printf '[ERROR] No se pudo escribir en el log: %s\n' "$LOG_FILE" >&2
  fi
}

log_debug() {
  local mensaje="$1"
  if ! printf '[DEBUG] %s - %s\n' "$(date '+%F %T')" "$mensaje" >> "$LOG_FILE"; then
    printf '[ERROR] No se pudo escribir en el log: %s\n' "$LOG_FILE" >&2
  fi
}
