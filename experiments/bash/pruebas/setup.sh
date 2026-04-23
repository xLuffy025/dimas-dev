#!/usr/bin/env bash 

echo "Cambiar repos"
termux-change-repo

echo "Actualizar Termux"
pkg upgrade -y

echo "Permiso storage"
termux-setup-storage 

