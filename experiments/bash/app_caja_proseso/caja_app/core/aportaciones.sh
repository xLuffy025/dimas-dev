#!/usr/bin/env bash
set -eou pipefail
IFS=$'\n\t'

while true; do 
  clear
  titulo "Registrar aportaciones"

  # -------------------------------------------------------
  # 1. Verificar si ahi socio registrados 
  # -------------------------------------------------------
  [[ ! -s "$USUARIO_DIR/lista_usuarios.csv" ]] &&
    warn "No hay socios registrados." &&
    pausa &&
    return 

  # ------------------------------------------------------
  # 2. Seleccionar socio por número 
  # ------------------------------------------------------
  local socios=() 
  loca i=1
  while IFS= read -r linea; do
    socio_nombre=$(echo "$linea" | cut -d',' -f1)
    socios+=("$socio_nombre")
    echo "$i) $socio_nombre"
    ((i++))
  done < "$USUARIO_DIR/lista_usuarios.csv"

  while true; do
    echo ""
    read -r -p "Seleccione el número del socio: " opcion
    cancelar_si_solicita "$opcion" || return 0 

    if [[ ! "$opcion" =~ ^[1-9]+$ ]] || ((opcion > ${#socios[@]})); then
      err "Error: Selección inválida."
      pausa
      return 0 
    fi 

    socio="${socios[$((opcion -1))]}"
    break 
  done 

  # -------------------------------------------------------
  # 3. Pedir monto 
  # -------------------------------------------------------
  while true; do 
    titulo "Aportaciones"
    read -r -p "Monto a registrar: " monto 
    cancelar_si_solicita "$monto" || return 0 

    # Validación númerica
    if [[ ! "$monto" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
      err "Error: El monto debe ser numérico" &&
      pausa
      continue

    else

      #Validación de rango 
      minimo=50
      maximo=5000
      if (( $(echo "$monto < $minimo || $monto > $maximo" | bc -l ) )); then 
        err "Error: El monto mínimo es $minimo y el máximo es $maximo." && 
          pausa 
        continue
      fi
    fi
    break 
    
  done

  # --------------------------------------------------------
  # 4. Pedir evidencia
  # --------------------------------------------------------
  while true; do
    titulo "Links de evidencia"
    read -r -p "Ruta de evidencia o link (https://): " evidencia
    cancelar_si_solicita "$evidencia" || return 0

    # Si es link, se guarda tal cual 
    if [[ "$evidencia" =~ ^https?:// ]]; then 
      destino="$evidencia"

    else 

    # Validar archivo local
    if [[ ! -f "$evidencia" ]]; then
      err "Error: El archivo no existe."
      sleep 2 
      continue
    fi 

    ts=$(date +"%F_%H_%M_%S")
    destino="$USUARIO_DIR/$socio/evidencias/$ts.${evidencia##*.}"
    cp "$evidencia" "$destino"
    fi
    break
  done

  # --------------------------------------------------------
  # 5. Copiar evidencia 
  # --------------------------------------------------------
  fecha=$(date +"%F")


  # --------------------------------------------------------
  # 6. Registrar en CSV individual
  # --------------------------------------------------------
  echo "$fecha,$socio,$monto,$destino" >> "$USUARIO_DIR/$socio/registros.csv"


  # --------------------------------------------------------
  # 7. Registrar en historial general 
  # --------------------------------------------------------
  echo "$fecha,$socio,$monto,$destino" >> "$DATA_DIR/historial_general.csv"

  log_info "Aportación $monto de $socio"

  # --------------------------------------------------------
  # 8. Confirmación final 
  # --------------------------------------------------------
  printf "%b\nResumen de la aoprtacion:%b\n" "$VERDE" "$RESET"
  printf "%bSocio:%b $socio\n" "$CYAN" "$RESET"
  printf "%bMonto:%b $monto\n" "$CYAN" "$RESET"
  printf "%bEvidencia:%b $destino\n" "$CYAN" "$RESET"
  read -r -p "Confirmar registro/(s/n): " c 
  [[ "$c" != "s" ]] &&
    warn "Registro cancelado. vuelva al inicio... " &&
    pausa &&
    continue 

  # --------------------------------------------------------
  # 9. Mensaje Final 
  # --------------------------------------------------------
  msg "Aportación registrada exitosamente."
  sleep 2
  break
done
