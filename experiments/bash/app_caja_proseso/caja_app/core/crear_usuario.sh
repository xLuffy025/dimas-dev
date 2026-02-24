#!/usr/bin/env bash

set -eou pipefail
IFS=$'\n\t'  

registrar_socio() {
  clear
  printf "%b=========================%b\n" "$CYAN" "$RESET"
  printf "%b  Registro de socio nuevo %b\n" "$MAGENTA" "$RESET"
  printf "%b=========================%b\n" "$CYAN" "$RESET"

  # ------ 1. Pedir nombre corto ------
  
  while true; do 
    read -r -p "Nombre corto (0 pata cancelar): " nombre
    cancelar_si_solicita "$nombre" || return 0

    # ------ Validación: no vacio -------
    [[ -z "$nombre" ]] && { err "El nombre no puede estar vacio." pausa; continue; }

    # ----- Validación: longitud ------
    [[ ${#nombre} -gt 12 ]] && { err "Error maximo 12 caracteres permitidos." pausa; continue; }

    # ------ Validación: caracteres permitidos ------
    [[ ! "$nombre" =~ ^[A-Za-z0-9_]+$ ]] && { err "Error: Solo letras/números/_" pausa; continue; }

    # ------ Validación: existencia previa
    grep -q "^$nombre," "$USUARIO_DIR/lista_usuarios.csv" && 
      warn "Aviso: Ese nombre ya está registrado" 
      pausa
      continue
      break
    done

    # ------ 2. Selección de fecha de entrega ------
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
          sleep 2 
          continue
      esac
      break
    done

    while true; do 
      clear
      printf "%b=========================%b\n" "$CYAN" "$RESET"
      printf "%b Número de telefono %b\n" "$MAGENTA" "$RESET"
      printf "%b=========================%b\n" "$CYAN" "$RESET"

      read -r -p "Ingresa un número de telefono: " telefono
      cancelar_si_solicita "$telefono" || return 0 

      # ------ Validación: no vacio ------
      if  [[ -z "$telefono" ]]; then
        err "El numero no puede estar vacio." &&
        pausa 
        continue
      fi

      # ------ Validación: longitud ------
      [[ ! "telefono" =~ ^[0-9]{10}$ ]] && 
      err "Error: Maximo 10 caracteres permitidos."
      pausa 
      continue

      # ------ Validación: caracteres permitidos ------
      if [[ ! "telefono" =~ ^[0-9]+$ ]]; then 
        err "Error: Solo numeros."
        pausa 
        continue
      fi
      
      # ------ Validación: Existencia previa ------
      cut -d',' -f4 "$USUARIO_DIR/lista_usuarios.scv" | grep -qx "telefono" &&
        warn "Aviso: Ese numero ya esta en eistencia." &&
        pause 
        continue
        break
    done

    # ------ 3. Crear estructura del socio ------
    clave_hash=$(echo -n "$clave" | sha256sum | cut -d' ' -f1)

    mkdir -p "$USUARIO_DIR/$nombre/evidencias"
    touch "$USUARIO_DIR/$nombre/registros.csv"

    # ------ 4. Registrar en archivo maestro ------
    echo "$nombre,$fecha,$clave_hash,$telefono" >> "$USUARIO_DIR/lista_usuarios.csv"

    msg "Socio '$nombre' registro exitosamente con fecha de entrega: $fecha."
    pausa 

  log_info "Registro Socio $nombre"


}
