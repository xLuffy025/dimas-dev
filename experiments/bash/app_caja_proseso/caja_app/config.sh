#!/usr/bin/env bash

# Raíz del proyecto (funciona en cualquier dispositivo)
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Directorios
DATA_DIR="$PROJECT_ROOT/data"
USUARIO_DIR="$DATA_DIR/usuarios"
REPORTES_DIR="$PROJECT_ROOT/reportes/html"
BACKUP_DIR="$PROJECT_ROOT/backups"
LOG_DIR="$PROJECT_ROOT/logs"
LOG_FILE="$LOG_DIR/sistema.log"
REPO_GITHUB="$HOME/caja-2026-reportes"
REPO_GITHUB_REPORTES="$REPO_GITHUB/reportes"


# Crear estructura si no existe
mkdir -p "$USUARIO_DIR" "$REPORTES_DIR" "$BACKUP_DIR" "$LOG_DIR"

touch "$USUARIO_DIR/lista_usuarios.csv"
touch "$DATA_DIR/historial_general.csv"

# Archivos clave
LISTA_USUARIOS="$USUARIO_DIR/lista_usuarios.csv"
HISTORIAL_GENERAL="$DATA_DIR/historial_general.csv"

REGISTROS_CSV() {
    echo "$USUARIO_DIR/$1/registros.csv"
}


