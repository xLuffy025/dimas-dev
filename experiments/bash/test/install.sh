#!/usr/bin/env bash

# ============================================================
# Termux Setup Complete - Instalador principal (MEJORADO)
# Autor: xLuffy025
# Versión: 2.0 - Compatible con git clone --bare
# ============================================================

# 🎨 Colores
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
CYAN="\033[1;36m"
RED="\033[1;31m"
RESET="\033[0m"

# 🧩 Funciones de mensajes
msg(){ echo -e "${CYAN}==>${RESET} $1"; }
ok(){ echo -e "${GREEN}[✔]${RESET} $1"; }
warn(){ echo -e "${YELLOW}[!]${RESET} $1"; }
err(){ echo -e "${RED}[✖]${RESET} $1"; }

# ============================================================
# 📂 DETECCIÓN DE DIRECTORIOS (Compatible con bare repos)
# ============================================================

# Obtener el directorio del script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Obtener el directorio raíz del repositorio (un nivel arriba de bootstrap)
REPO_DIR="$(cd "$SCRIPT_DIR/" && pwd)"



# Verificar que el repositorio es válido
if [ ! -d "$REPO_DIR" ]; then
    err "No se puede encontrar el directorio raíz del repositorio"
    exit 1
fi

# Cambiar al directorio del repositorio
cd "$REPO_DIR" || exit 1

msg "Directorio de trabajo: $REPO_DIR"
msg "Directorio de scripts: $REPO_DIR/scripts"

# ============================================================
# ✅ VALIDACIÓN DE DEPENDENCIAS
# ============================================================

validar_archivos() {
    local archivo=$1
    if [ ! -f "$REPO_DIR/$archivo" ]; then
        err "Archivo no encontrado: $REPO_DIR/$archivo"
        return 1
    fi
    return 0
}

validar_directorio() {
    local directorio=$1
    if [ ! -d "$REPO_DIR/$directorio" ]; then
        err "Directorio no encontrado: $REPO_DIR/$directorio"
        return 1
    fi
    return 0
}

# ============================================================
# 📦 FUNCIONES PRINCIPALES
# ============================================================

# Cargar el gestor de paquetes multi-distro
source "$REPO_DIR/utils/package-manager.sh"

instalar_basicos(){
    msg "Instalando paquetes esenciales..."
    
    if validar_archivos "scripts/install_packages.sh"; then
        bash "$REPO_DIR/scripts/install_packages.sh" || err "Error al instalar paquetes básicos"
        ok "Dependencias básicas instaladas."
    else
        err "Script de paquetes no encontrado"
        return 1
    fi
}

instalar_zsh(){
    msg "Instalando y configurando Zsh..."
    
    # Buscar el script correcto (install_zsh.sh en lugar de install_zshxit.sh)
    if validar_archivos "scripts/install_zsh.sh"; then
        bash "$REPO_DIR/scripts/install_zsh.sh"
    elif validar_archivos "scripts/install_zshxit.sh"; then
        warn "Usando install_zshxit.sh (considera renombrarlo a install_zsh.sh)"
        bash "$REPO_DIR/scripts/install_zshxit.sh"
    else
        err "Script de zsh no encontrado"
        return 1
    fi
    
    ok "Zsh configurado."
}

instalar_distros(){
    msg "Instalando distribuciones Proot..."
    
    if validar_archivos "scripts/install_pr-dis.sh"; then
        bash "$REPO_DIR/scripts/install_pr-dis.sh"
        ok "Proot distros instaladas."
    else
        err "Script de proot-distro no encontrado"
        return 1
    fi
}

instalar_python_dev(){
    msg "Configurando entorno Python..."
    
    if validar_archivos "scripts/install_python.sh"; then
        bash "$REPO_DIR/scripts/install_python.sh"
        ok "Python dev configurado."
    else
        err "Script de python no encontrado"
        return 1
    fi
}

instalar_node_js(){
    msg "Instalando Node.js..."
    
    if validar_archivos "scripts/install_nodejs.sh"; then
        bash "$REPO_DIR/scripts/install_nodejs.sh"
        ok "Node.js instalado."
    else
        err "Script de nodejs no encontrado"
        return 1
    fi
}

instalar_vim_nvim(){
    msg "Instalando vim-plug y plugins para Vim/Neovim..."
    
    # vim-plug for vim
    curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim 2>/dev/null || \
        warn "Falló instalar vim-plug para vim"

    # Run PlugInstall for vim
    if command -v vim >/dev/null 2>&1; then
        msg "Ejecutando PlugInstall en vim (headless)..."
        vim +'PlugInstall --sync' +qa || warn "vim PlugInstall falló"
    fi

    # Copiar .vimrc
    if [ -f "$REPO_DIR/configs/.vimrc" ]; then
        cp "$REPO_DIR/configs/.vimrc" ~/.vimrc
        ok "Archivo .vimrc instalado."
    else
        warn "Archivo .vimrc no encontrado en $REPO_DIR/configs/"
    fi

    # Instalar NvChad Starter
    if validar_archivos "scripts/install_nvim.sh"; then
        bash "$REPO_DIR/scripts/install_nvim.sh"
        ok "Neovim/NvChad configurado."
    else
        warn "Script de neovim no encontrado"
    fi
}

instalar_tmux(){
    msg "Instalando Tmux..."
    
    if [ -f "$REPO_DIR/configs/.tmux.conf" ]; then
        cp "$REPO_DIR/configs/.tmux.conf" ~/.tmux.conf
        ok "Archivo .tmux.conf instalado."
    else
        warn "Archivo .tmux.conf no encontrado en $REPO_DIR/configs/"
    fi
}

limpiando_sistema(){
    msg "Limpiando sistema..."
    pkg autoclean && pkg clean && rm -rf ~/storage/downloads/*.deb 2>/dev/null || true
    ok "Sistema limpio."
}

configurar_dotfiles(){
    msg "Copiando scripts personalizados (dotfile)..."
    
    # CORREGIDO: Usar el mismo nombre (dotfile, singular)
    mkdir -p "$HOME/dotfile"

    local archivos=(
        "dotfiles/eyes.bnr"
        "dotfiles/clear-termux.sh"
        "dotfiles/update.sh"
    )

    for archivo in "${archivos[@]}"; do
        if [ -f "$REPO_DIR/$archivo" ]; then
            cp "$REPO_DIR/$archivo" "$HOME/dotfile/"
            ok "Copiado: $(basename "$archivo")"
        else
            warn "No se encontró: $REPO_DIR/$archivo"
        fi
    done

    # CORREGIDO: Usar la misma ruta (dotfile, singular)
    chmod +x "$HOME/dotfile"/*.sh 2>/dev/null || true
    ok "dotfiles instalados en ~/dotfile"
    
    echo
    echo -e "${CYAN}Puedes ejecutar:${RESET}"
    echo -e "  ${GREEN}bash ~/dotfile/clear-termux.sh${RESET}"
    echo -e "  ${GREEN}bash ~/dotfile/update.sh${RESET}"
}

# ============================================================
# 🧠 INSTALACIÓN AUTOMÁTICA (modo silencioso)
# ============================================================

if [ "$1" == "--auto" ]; then
    msg "Iniciando instalación automática..."
    instalar_basicos && \
    instalar_zsh && \
    instalar_distros && \
    instalar_python_dev && \
    instalar_node_js && \
    instalar_vim_nvim && \
    instalar_tmux && \
    configurar_dotfiles && \
    limpiando_sistema && \
    ok "Instalación automática completada ✅" || \
    err "Instalación automática falló ❌"
    exit 0
fi

# ============================================================
# 🧭 MENÚ INTERACTIVO
# ============================================================

mostrar_menu() {
    clear
    echo -e "${CYAN}╔═══════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}║     🚀 TERMUX SETUP INSTALLER         ║${RESET}"
    echo -e "${CYAN}║   Directorio: $REPO_DIR${RESET}"
    echo -e "${CYAN}╚═══════════════════════════════════════╝${RESET}"
    echo -e "${YELLOW}1)${RESET} Instalar paquetes básicos"
    echo -e "${YELLOW}2)${RESET} Instalar Zsh"
    echo -e "${YELLOW}3)${RESET} Instalar Proot-Distro"
    echo -e "${YELLOW}4)${RESET} Instalar Python dev"
    echo -e "${YELLOW}5)${RESET} Instalar Node.js"
    echo -e "${YELLOW}6)${RESET} Instalar Neovim/NvChad"
    echo -e "${YELLOW}7)${RESET} Instalar Tmux"
    echo -e "${YELLOW}8)${RESET} Copiar Dotfiles"
    echo -e "${YELLOW}9)${RESET} Limpiar sistema"
    echo -e "${YELLOW}0)${RESET} Salir"
    echo
}

while true; do
    mostrar_menu
    read -r -p "Selecciona una opción: " opt
    case $opt in
        1) instalar_basicos ;;
        2) instalar_zsh ;;
        3) instalar_distros ;;
        4) instalar_python_dev ;;
        5) instalar_node_js ;;
        6) instalar_vim_nvim ;;
        7) instalar_tmux ;;
        8) configurar_dotfiles ;;
        9) limpiando_sistema ;;
        0) echo "Saliendo..."; exit 0 ;;
        *) err "Opción no válida." ;;
    esac
    read -r -p "Presiona Enter para continuar..."
done
