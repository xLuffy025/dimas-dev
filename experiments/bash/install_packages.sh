#!/usr/bin/env bash

# ============================================================
# Multi-Distro Package Manager Detector
# Soporta: Debian/Ubuntu, Arch, Fedora, openSUSE, Alpine, Termux
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
# 🔍 DETECCIÓN DE DISTRO
# ============================================================

detectar_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        OS_VERSION=$VERSION_ID
    elif [ -f /etc/lsb-release ]; then
        . /etc/lsb-release
        OS=$(echo $DISTRIB_ID | tr '[:upper:]' '[:lower:]')
    else
        OS="unknown"
    fi
    
    # Normalizar nombres de distro
    case "$OS" in
        ubuntu|debian) OS="debian" ;;
        fedora|rhel|centos) OS="fedora" ;;
        arch|manjaro) OS="arch" ;;
        opensuse*) OS="opensuse" ;;
        alpine) OS="alpine" ;;
        termux) OS="termux" ;;
        *) OS="unknown" ;;
    esac
    
    echo "$OS"
}

# ============================================================
# 📦 DEFINICIÓN DE PAQUETES POR DISTRO
# ============================================================

# Array asociativo con paquetes (ajusta según necesites)
declare -A PAQUETES_DEBIAN=(
    [git]="git"
    [curl]="curl"
    [wget]="wget"
    [zsh]="zsh"
    [vim]="vim"
    [neovim]="neovim"
    [tmux]="tmux"
    [nodejs]="nodejs npm"
    [python]="python3 python3-pip python3-dev"
    [build_tools]="build-essential"
    [openssl]="openssl libssl-dev"
    [sqlite]="sqlite3 libsqlite3-dev"
)

declare -A PAQUETES_FEDORA=(
    [git]="git"
    [curl]="curl"
    [wget]="wget"
    [zsh]="zsh"
    [vim]="vim"
    [neovim]="neovim"
    [tmux]="tmux"
    [nodejs]="nodejs npm"
    [python]="python3 python3-pip python3-devel"
    [build_tools]="gcc g++ make"
    [openssl]="openssl openssl-devel"
    [sqlite]="sqlite sqlite-devel"
)

declare -A PAQUETES_ARCH=(
    [git]="git"
    [curl]="curl"
    [wget]="wget"
    [zsh]="zsh"
    [vim]="vim"
    [neovim]="neovim"
    [tmux]="tmux"
    [nodejs]="nodejs npm"
    [python]="python python-pip"
    [build_tools]="base-devel"
    [openssl]="openssl"
    [sqlite]="sqlite"
)

declare -A PAQUETES_OPENSUSE=(
    [git]="git"
    [curl]="curl"
    [wget]="wget"
    [zsh]="zsh"
    [vim]="vim"
    [neovim]="neovim"
    [tmux]="tmux"
    [nodejs]="nodejs npm"
    [python]="python3 python3-pip python3-devel"
    [build_tools]="gcc gcc-c++ make"
    [openssl]="openssl libopenssl-devel"
    [sqlite]="sqlite3 sqlite3-devel"
)

declare -A PAQUETES_ALPINE=(
    [git]="git"
    [curl]="curl"
    [wget]="wget"
    [zsh]="zsh"
    [vim]="vim"
    [neovim]="neovim"
    [tmux]="tmux"
    [nodejs]="nodejs npm"
    [python]="python3 py3-pip"
    [build_tools]="build-base"
    [openssl]="openssl openssl-dev"
    [sqlite]="sqlite sqlite-dev"
)

declare -A PAQUETES_TERMUX=(
    [git]="git"
    [curl]="curl"
    [wget]="wget"
    [zsh]="zsh"
    [vim]="vim"
    [neovim]="neovim"
    [tmux]="tmux"
    [nodejs]="nodejs"
    [python]="python"
    [build_tools]="clang make"
    [openssl]="openssl"
    [sqlite]="sqlite"
)

# ============================================================
# 🎯 FUNCIONES DE INSTALACIÓN POR DISTRO
# ============================================================

instalar_debian() {
    msg "Detectado: Debian/Ubuntu"
    msg "Actualizando índice de paquetes..."
    sudo apt-get update -qq || { err "Falló apt-get update"; return 1; }
    
    msg "Instalando paquetes esenciales..."
    local paquetes=(
        "${PAQUETES_DEBIAN[git]}"
        "${PAQUETES_DEBIAN[curl]}"
        "${PAQUETES_DEBIAN[wget]}"
        "${PAQUETES_DEBIAN[build_tools]}"
        "${PAQUETES_DEBIAN[openssl]}"
        "${PAQUETES_DEBIAN[sqlite]}"
    )
    
    sudo apt-get install -y "${paquetes[@]}" || { err "Falló la instalación"; return 1; }
    ok "Paquetes esenciales instalados"
}

instalar_fedora() {
    msg "Detectado: Fedora/RHEL/CentOS"
    msg "Actualizando índice de paquetes..."
    sudo dnf update -y -q || sudo yum update -y -q || { err "Falló la actualización"; return 1; }
    
    msg "Instalando paquetes esenciales..."
    local paquetes=(
        "${PAQUETES_FEDORA[git]}"
        "${PAQUETES_FEDORA[curl]}"
        "${PAQUETES_FEDORA[wget]}"
        "${PAQUETES_FEDORA[build_tools]}"
        "${PAQUETES_FEDORA[openssl]}"
        "${PAQUETES_FEDORA[sqlite]}"
    )
    
    sudo dnf install -y "${paquetes[@]}" 2>/dev/null || sudo yum install -y "${paquetes[@]}" || { err "Falló la instalación"; return 1; }
    ok "Paquetes esenciales instalados"
}

instalar_arch() {
    msg "Detectado: Arch/Manjaro"
    msg "Actualizando índice de paquetes..."
    sudo pacman -Sy --noconfirm >/dev/null || { err "Falló pacman -Sy"; return 1; }
    
    msg "Instalando paquetes esenciales..."
    local paquetes=(
        "${PAQUETES_ARCH[git]}"
        "${PAQUETES_ARCH[curl]}"
        "${PAQUETES_ARCH[wget]}"
        "${PAQUETES_ARCH[build_tools]}"
        "${PAQUETES_ARCH[openssl]}"
        "${PAQUETES_ARCH[sqlite]}"
    )
    
    sudo pacman -S --noconfirm "${paquetes[@]}" || { err "Falló la instalación"; return 1; }
    ok "Paquetes esenciales instalados"
}

instalar_opensuse() {
    msg "Detectado: openSUSE"
    msg "Actualizando índice de paquetes..."
    sudo zypper refresh -q || { err "Falló zypper refresh"; return 1; }
    
    msg "Instalando paquetes esenciales..."
    local paquetes=(
        "${PAQUETES_OPENSUSE[git]}"
        "${PAQUETES_OPENSUSE[curl]}"
        "${PAQUETES_OPENSUSE[wget]}"
        "${PAQUETES_OPENSUSE[build_tools]}"
        "${PAQUETES_OPENSUSE[openssl]}"
        "${PAQUETES_OPENSUSE[sqlite]}"
    )
    
    sudo zypper install -y "${paquetes[@]}" || { err "Falló la instalación"; return 1; }
    ok "Paquetes esenciales instalados"
}

instalar_alpine() {
    msg "Detectado: Alpine Linux"
    msg "Actualizando índice de paquetes..."
    sudo apk update -q || { err "Falló apk update"; return 1; }
    
    msg "Instalando paquetes esenciales..."
    local paquetes=(
        "${PAQUETES_ALPINE[git]}"
        "${PAQUETES_ALPINE[curl]}"
        "${PAQUETES_ALPINE[wget]}"
        "${PAQUETES_ALPINE[build_tools]}"
        "${PAQUETES_ALPINE[openssl]}"
        "${PAQUETES_ALPINE[sqlite]}"
    )
    
    sudo apk add "${paquetes[@]}" || { err "Falló la instalación"; return 1; }
    ok "Paquetes esenciales instalados"
}

instalar_termux() {
    msg "Detectado: Termux"
    msg "Actualizando índice de paquetes..."
    pkg update -y -q || { err "Falló pkg update"; return 1; }
    
    msg "Instalando paquetes esenciales..."
    local paquetes=(
        "${PAQUETES_TERMUX[git]}"
        "${PAQUETES_TERMUX[curl]}"
        "${PAQUETES_TERMUX[wget]}"
        "${PAQUETES_TERMUX[build_tools]}"
        "${PAQUETES_TERMUX[openssl]}"
        "${PAQUETES_TERMUX[sqlite]}"
    )
    
    pkg install -y "${paquetes[@]}" || { err "Falló la instalación"; return 1; }
    ok "Paquetes esenciales instalados"
}

# ============================================================
# 🚀 EJECUCIÓN PRINCIPAL
# ============================================================

main() {
    msg "Detectando distribución Linux..."
    local DISTRO=$(detectar_distro)
    
    msg "Distro detectada: ${GREEN}$DISTRO${RESET}"
    
    case "$DISTRO" in
        debian) instalar_debian ;;
        fedora) instalar_fedora ;;
        arch) instalar_arch ;;
        opensuse) instalar_opensuse ;;
        alpine) instalar_alpine ;;
        termux) instalar_termux ;;
        *)
            err "Distro no soportada: $DISTRO"
            err "Distros soportadas: Debian, Ubuntu, Fedora, RHEL, CentOS, Arch, Manjaro, openSUSE, Alpine, Termux"
            return 1
            ;;
    esac
}

main "$@"
