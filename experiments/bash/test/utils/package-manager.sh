#!/usr/bin/env bash

# ============================================================
# Utilidad Global - Gestor de Paquetes Multi-Distro
# Uso: source utils/package-manager.sh
# ============================================================

# 🔍 Detectar distro y setup del package manager
detectar_pm() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
    else
        OS="unknown"
    fi
    
    case "$OS" in
        ubuntu|debian)
            PM_UPDATE="sudo apt-get update -qq"
            PM_INSTALL="sudo apt-get install -y"
            PM_REMOVE="sudo apt-get remove -y"
            PM_CLEAN="sudo apt-get autoclean && sudo apt-get clean"
            ;;
        fedora|rhel|centos)
            PM_UPDATE="sudo dnf update -y -q 2>/dev/null || sudo yum update -y -q"
            PM_INSTALL="sudo dnf install -y 2>/dev/null || sudo yum install -y"
            PM_REMOVE="sudo dnf remove -y 2>/dev/null || sudo yum remove -y"
            PM_CLEAN="sudo dnf clean all 2>/dev/null || sudo yum clean all"
            ;;
        arch|manjaro)
            PM_UPDATE="sudo pacman -Sy --noconfirm"
            PM_INSTALL="sudo pacman -S --noconfirm"
            PM_REMOVE="sudo pacman -R --noconfirm"
            PM_CLEAN="sudo pacman -Scc --noconfirm"
            ;;
        opensuse*)
            PM_UPDATE="sudo zypper refresh -q"
            PM_INSTALL="sudo zypper install -y"
            PM_REMOVE="sudo zypper remove -y"
            PM_CLEAN="sudo zypper clean"
            ;;
        alpine)
            PM_UPDATE="sudo apk update -q"
            PM_INSTALL="sudo apk add"
            PM_REMOVE="sudo apk del"
            PM_CLEAN="sudo apk cache clean"
            ;;
        termux)
            PM_UPDATE="pkg update -y && pkg upgrade -y -q"
            PM_INSTALL="pkg install -y"
            PM_REMOVE="pkg uninstall -y"
            PM_CLEAN="pkg clean"
            ;;
        *)
            return 1
            ;;
    esac
    
    return 0
}

# 🔧 Instalar paquete (uso flexible)
instalar_paquete() {
    local paquete=$1
    detectar_pm || return 1
    
    msg "Instalando: $paquete"
    eval "$PM_INSTALL $paquete" || { err "Falló instalar $paquete"; return 1; }
    ok "Instalado: $paquete"
}

# 📦 Instalar múltiples paquetes
instalar_paquetes() {
    detectar_pm || return 1
    
    msg "Actualizando índice de paquetes..."
    eval "$PM_UPDATE" || { err "Falló la actualización"; return 1; }
    
    msg "Instalando paquetes..."
    eval "$PM_INSTALL $@" || { err "Falló la instalación"; return 1; }
    ok "Paquetes instalados"
}

# 🗑️ Limpiar sistema
limpiar_sistema() {
    detectar_pm || return 1
    
    msg "Limpiando sistema..."
    eval "$PM_CLEAN" 2>/dev/null || true
    ok "Sistema limpio"
}
