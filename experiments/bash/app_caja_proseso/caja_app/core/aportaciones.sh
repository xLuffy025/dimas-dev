#!/usr/bin/env bash
set -eou pipefail
IFS=$'\n\t'

while true; do 
  clear
  titulo "Registrar aportaciones"

  confirmar_socios 

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
  printf "%b\nResumen de la aportación:%b\n" "$VERDE" "$RESET"

  mostrar_datos "Socio:" "$socio" 
  mostrar_datos "Monto:" "$monto"
  mostrar_datos "Evidencia:" "$destino"

  echo ""
  
  if confirmar "Confirmar registro de la aportación"; then
    
    # Si el usuario dijo "s", entra quí 
    msg "Aportación registrada exitosamente."
    sleep 2
    break 
    
  else
    
    # si el usuario dijo "n" o cualquier otra cosa, entra aquí
    warn "Registro cancelado. Volviendo al inicio"
    pausa
    continue

  fi
done
