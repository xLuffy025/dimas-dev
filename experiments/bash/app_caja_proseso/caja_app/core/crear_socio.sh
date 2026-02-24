#!/usr/bin/env bash

set -eou pipefail
IFS=$'\n\t'  

#crear_socio() {
  clear
  printf "%b=========================%b\n" "$CYAN" "$RESET"
  printf "%b  Registro de socio nuevo %b\n" "$MAGENTA" "$RESET"
  printf "%b=========================%b\n" "$CYAN" "$RESET"

    # -----------------------------
    # 1. Pedir nombre corto
    # -----------------------------
    while true; do
      read -r -p "Nombre corto (0 cancelar): " nombre
      cancelar_si_solicita "$nombre" || return 0

    # Validación: no vacío
        [[ -z "$nombre" ]] && 
        err "Error: El nombre no puede estar vacío." &&
        continue

    # Validación: longitud
        [[ ${#nombre} -gt 12 ]] &&
        err "Error: Máximo 12 caracteres permitidos." &&
        continue

    # Validación: caracteres permitidos
       [[ ! "$nombre" =~ ^[A-Za-z0-9_]+$ ]] &&
        err "Error: Solo letras/números/_ " &&
        continue

    # Validación: existencia previa
    grep -q "^$nombre," "$USUARIO_DIR/lista_usuarios.csv" &&
        warn "Aviso: Ese nombre ya está registrado." &&
        continue
      break 
    done

    # -----------------------------
    # 2. Selección de fecha de entrega
    # -----------------------------
    while true; do 
    clear 
    printf "%b=========================%b\n" "$CYAN" "$RESET"
      printf "%b  Fecha de entrega  %b\n" "$MAGENTA" "$RESET"
      printf "%b=========================%b\n" "$CYAN" "$RESET"

      echo -e "1) 13 de Junio"
      echo -e "2) 12 de Noviembre"
      echo -e "3) 20 de Diciembre"
      echo -e "0) Cancelar"
      read -r -p "Opción (1/2/3/0): " opt

      case "$opt" in 
        1) fecha="13-Junio" ;;
        2) fecha="12-Noviembre" ;;
        3) fecha="20-Diciembre" ;;
        *) err "Error: Opción invalida."
          cancelar_si_solicita "$opt" || return 0 
          sleep 2;
          continue
      esac
      break
    done

    while true; do 
      clear 
      printf "%b=========================%b\n" "$CYAN" "$RESET"
      printf "%b Contraseña %b\n" "$MAGENTA" "$RESET" 
      printf "%b=========================%b\n" "$CYAN" "$RESET" 
      read -r -p "Defina una contraseña (minimo 4 caracteres sin espacio.): " clave 
      cancelar_si_solicita "$clave" || return 0 

      if [[ -z "$clave" || ${#clave} -lt 4 || "$clave" =~ [[:space:]] ]]; then
      err "Error: Contraseña inválida."; sleep 2; continue
      fi
      break
    done 

    while true; do 
      clear
      printf "%b=========================%b\n" "$CYAN" "$RESET"
      printf "%b Número de telefono %b\n" "$MAGENTA" "$RESET"
      printf "%b=========================%b\n" "$CYAN" "$RESET"

      read -r -p "Ingresa un numero de telefono:" tel
      cancelar_si_solicita "$tel" || return 0

      # Validación: no vacio
      if [[ -z "$tel" ]]; then        
        err "Error: El numero no puede estar vacio."
        sleep 2 
        continue 
      fi  

      # Validación: longitud
      [[ ! "$tel" =~ ^[0-9]{10}$ ]] &&
        err "Error: Maximo 10 caracteres permitidos." &&
        continue
      
      #Validación: caracteres permitidos
      if [[ ! "$tel" =~ ^[0-9]+$ ]]; then
        err "Error: solo numero."
        sleep 2 
        continue
      fi 

      # Validación: existencia previa
      cut -d',' -f4 "$USUARIO_DIR/lista_usuarios.csv" | grep -qx "$tel" &&
        warn "Aviso: Ese numero ya esta en existencia." &&
        continue
      break
    done

      # -----------------------------
      # 3. Crear estructura del socio
      # -----------------------------

      clave_hash=$(echo -n "$clave" | sha256sum | cut -d' ' -f1)

      mkdir -p "$USUARIO_DIR/$nombre/evidencias"
      touch "$USUARIO_DIR/$nombre/registros.csv"

      # -----------------------------
      # 4. Registrar en archivo maestro
      # -----------------------------
      echo "$nombre,$fecha,$clave_hash,$tel" >> "$USUARIO_DIR/lista_usuarios.csv"

      msg "Socio '$nombre' registrado exitosamente con fecha de entrega: $fecha."
      pausa

      log_info "Registro Socio $nombre"
#}
