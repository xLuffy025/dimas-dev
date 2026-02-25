#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_ROOT"

# ==========================================
#   SISTEMA CAJA DE AHORRO 2026
#   Modelo 3 + Sistema 2
#   Autor: xLuffy025
# ==========================================

# ==========================================
# VARIABLES GLOBALES
# ==========================================
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/config.sh"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/utils.sh"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/logs.sh"

# ==========================================
#     DEPENDENCIAS
# ==========================================
command -v bc >/dev/null || {
  echo "Error: bc no está instalado (install bc)"
  exit 1
}

# ==========================================
#     FUNCIONES GENERALES
# ==========================================
pausa() {
  read -p "Presione ENTER para continuar..."
}

log() {
  echo "$(date '+%F %T') - $1" >> "$LOG_FILE"
}

cancelar_si_solicita() {
  local valor="$1"
  if [[ "$valor" == "0" ]]; then 
    return 1 
  fi 
  return 0 
}

# ==========================================
#   FUNCIÓN: REGISTRAR SOCIO
# ==========================================
crear_socio() {
  source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/core/crear_socio.sh"
}

# ==========================================
#   FUNCIÓN: REGISTRAR APORTACIÓN
# ==========================================
registrar_aportacion() {
  source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/core/aportaciones.sh"
}
  
# ==========================================
#   FUNCIÓN: CONSULTAR HISTORIAL
# ==========================================
consultar_historial() {
    clear
    echo -e "\e[1;35m=== CONSULTAR HISTORIAL DE UN SOCIO ===\e[0m"

    # -----------------------------------------
    # 1. Verificar si hay socios registrados
    # -----------------------------------------
    if [[ ! -s "$USUARIO_DIR/lista_usuarios.csv" ]]; then
        echo -e "\e[1;31mNo hay socios registrados.\e[0m"
        sleep 2
        return
    fi

    echo -e "\e[1;36mSoci:;os disponibles:\e[0m"
    nl -w2 -s") " "$USUARIO_DIR/lista_usuarios.csv" | cut -d',' -f1

    # -----------------------------------------
    # 2. Seleccionar socio
    # -----------------------------------------
    echo ""
    read -p "Ingrese el nombre corto del socio: " socio

    if ! grep -E "^$socio," "$USUARIO_DIR/lista_usuarios.csv" >/dev/null 2>&1; then
        echo -e "\e[1;31mError: El socio no existe.\e[0m"
        sleep 2
        return
    fi

    archivo="$USUARIO_DIR/$socio/registros.csv"

    # -----------------------------------------
    # 3. Validar si tiene registros
    # -----------------------------------------
    if [[ ! -s "$archivo" ]]; then
        echo -e "\e[1;33mEl socio '$socio' no tiene aportaciones registradas.\e[0m"
        sleep 3
        return
    fi

    # -----------------------------------------
    # 4. Mostrar historial
    # -----------------------------------------
    echo ""
    echo -e "\e[1;34mHistorial de aportaciones de: $socio\e[0m"
    echo -e "\e[1;34m----------------------------------------\e[0m"

    total=0
    contador=0
    ultima_fecha="N/A"

    while IFS=',' read -r fecha monto evidencia; do
        echo -e "\e[1;32mFecha:\e[0m $fecha"
        echo -e "\e[1;32mMonto:\e[0m $monto"
        echo -e "\e[1;32mEvidencia:\e[0m $evidencia"
        echo "----------------------------------------"

        total=$(echo "$total + $monto" | bc)
        contador=$((contador + 1))
        ultima_fecha="$fecha"
    done < "$archivo"

    # -----------------------------------------
    # 5. Resumen final
    # -----------------------------------------
    echo ""
    echo -e "\e[1;36mResumen del socio: $socio\e[0m"
    echo -e "\e[1;33mTotal aportado:\e[0m $total"
    echo -e "\e[1;33mNúmero de aportaciones:\e[0m $contador"
    echo -e "\e[1;33mÚltima aportación:\e[0m $ultima_fecha"

    echo ""
    pausa
}

# ==========================================
#   FUNCIÓN: GENERAR REPORTE HTML
# ==========================================
generar_reporte() {
    clear
    echo -e "\e[1;32m=== GENERAR REPORTE HTML ===\e[0m"

    fecha_reporte=$(date +"%Y-%m-%d_%H:%M:%S")
    archivo="$REPORTES_DIR/reporte_${fecha_reporte}.html"

    echo "<html><head>
    <meta charset='UTF-8'>
    <title>Reporte Caja de Ahorro</title>
    <style>
        body { font-family: Arial; background: #f4f4f4; padding: 20px; }
        h1 { color: #333; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th, td { border: 1px solid #999; padding: 8px; text-align: center; }
        th { background: #333; color: white; }
        .verde { background: #c8f7c5; }
        .rojo { background: #f7c5c5; }
        .azul { background: #c5d8f7; }
    </style>
    </head><body>" > "$archivo"

    echo "<h1>Reporte Caja de Ahorro</h1>" >> "$archivo"
    echo "<p>Generado el: <b>$fecha_reporte</b></p>" >> "$archivo"

    echo "<table>
        <tr>
            <th>Socio</th>
            <th>Fecha de entrega</th>
            <th>Total aportado</th>
            <th>Aportaciones</th>
            <th>Última aportación</th>
        </tr>" >> "$archivo"

    total_general=0

    while IFS=',' read -r socio fecha_entrega resto; do
        archivo_socio="$USUARIO_DIR/$socio/registros.csv"

        total_socio=0
        aportaciones=0
        ultima="N/A"

        if [[ -s "$archivo_socio" ]]; then
            while IFS=',' read -r f m e; do
                total_socio=$(echo "$total_socio + $m" | bc)
                aportaciones=$((aportaciones + 1))
                ultima="$f"
            done < "$archivo_socio"

            clase="verde"
        else
            clase="rojo"
        fi

        total_general=$(echo "$total_general + $total_socio" | bc)

        echo "<tr class='$clase'>
                <td>$socio</td>
                <td class='azul'>$fecha_entrega</td>
                <td>$total_socio</td>
                <td>$aportaciones</td>
                <td>$ultima</td>
              </tr>" >> "$archivo"

    done < "$USUARIO_DIR/lista_usuarios.csv"

    echo "</table>" >> "$archivo"

    echo "<h2>Total general del grupo: $total_general</h2>" >> "$archivo"

    echo "</body></html>" >> "$archivo"

    echo -e "\e[1;32mReporte generado exitosamente:\e[0m"
    echo -e "\e[1;36m$archivo\e[0m"
    sleep 3
}

# ==========================================
#   FUNCIÓN: REPORTE INDIVIDUAL 
# ==========================================
generar_reporte_individual() {
    clear
    echo -e "\e[1;36m=== REPORTE INDIVIDUAL ===\e[0m"

    # -----------------------------------------
    # 1. Verificar si hay socios registrados
    # -----------------------------------------
    if [[ ! -s "$USUARIO_DIR/lista_usuarios.csv" ]]; then
        echo -e "\e[1;31mNo hay socios registrados.\e[0m"
        sleep 2
        return
    fi

    echo -e "\e[1;36mSocios disponibles:\e[0m"
    nl -w2 -s") " "$USUARIO_DIR/lista_usuarios.csv" | cut -d',' -f1

    # -----------------------------------------
    # 2. Seleccionar socio
    # -----------------------------------------
    echo ""
    read -p "Ingrese el nombre corto del socio: " socio

    if ! grep -E "^$socio," "$USUARIO_DIR/lista_usuarios.csv" >/dev/null 2>&1; then
        echo -e "\e[1;31mError: El socio no existe.\e[0m"
        sleep 2
        return
    fi
    
    bash reporte_individual.sh "$socio"
    pausa
}

# ==========================================
#   FUNCIÓN: ENVIAR POR WHATSAPP
# ==========================================
enviar_whatsapp() {
  while true; do 
    clear

    enviar_reporte_individual() {
    clear
    echo "=== ENVIAR REPORTE INDIVIDUAL ==="
    echo "0) Cancelar"

    cut -d',' -f1 "$USUARIO_DIR/lista_usuarios.csv"
    
    read -p "Nombre corto del socio: " socio

    [[ "$socio" == "0" ]] && return

    tel=$(grep "^$socio," "$USUARIO_DIR/lista_usuarios.csv" | cut -d',' -f4)

    if [[ -z "$tel" ]]; then
        echo "No se encontró teléfono para $socio"
        sleep 2
        return
    fi

    archivo=$(./reporte_individual.sh "$socio")

    if [[ ! -f "$archivo" ]]; then
      echo -e "${ROJO}❌ Error: el archivo no existe o la ruta es inválida.${RESET}"
      echo "Ruta recibida: $archivo"
      sleep 2
      return
    fi 
    
    if [[ "$archivo" == "ERROR_SOCIO" || -z "$archivo" ]]; then
        echo "Error al generar el reporte."
        sleep 2
        return
    fi 

    mkdir -p "$REPO_GITHUB_REPORTES"

    if [[ ! -f "$archivo" ]]; then
      echo -e "${ROJO}❌ Error: el archivo no existe.${RESET}"
      echo "Ruta recibida: $archivo"
      return
    fi

    if [[ ! -d "$REPO_GITHUB_REPORTES" ]]; then
      echo -e "${ROJO}❌ Error: la carpeta destino no existe.${RESET}"
      echo "Ruta esperada: $REPO_GITHUB_REPORTES"
      return
    fi 

    

    cp "$archivo" "$REPO_GITHUB_REPORTES/"
 
    cd "$REPO_GITHUB_REPORTES" || return
    git pull
    git add .
    git commit -m "Reporte actualizado para $socio" >/dev/null 2>&1
    git push >/dev/null 2>&1

    nombre_archivo=$(basename "$archivo")
    link="https://xluffy025.github.io/caja-2026-reportes/reportes/$nombre_archivo"

    mensaje="Hola $socio, aquí está tu estado de cuenta: $link"
    enviar_whatsapp "$tel" "$mensaje"

    cd - >/dev/null 2>&1
}
    enviar_reportes_todos() {
      clear
      echo "=== ENVIAR REPORTES A TODOS LOS SOCIOS ==="
      read -p "¿Continuar? (s/n): " resp
      [[ "$resp" != "s" && "$resp" != "S" ]] && return

    REPO=~/caja-2026-reportes
    mkdir -p "$REPO/reportes"

    while IFS=',' read -r socio fecha clave tel resto; do
      [[ -z "$socio" || "$socio" == "socio" ]] && continue
      
      echo "Procesando: $socio"
      
      archivo=$(./reporte_individual.sh "$socio")

      if [[ "$archivo" == "ERROR_SOCIO" || -z "$archivo" ]]; then
        echo "  Error, se omite."
        continue
      fi

      cp "$archivo" "$REPO/reportes/"

      nombre_archivo=$(basename "$archivo")
      link="https://xluffy025.github.io/caja-2026-reportes/reportes/$nombre_archivo"

      mensaje="Hola $socio, aquí está tu estado de cuenta: $link"

      if [[ -n "$tel" ]]; then
        enviar_whatsapp "$tel" "$mensaje"
      else
        echo "  No hay teléfono registrado."
      fi 

      echo

    done < "$USUARIO_DIR/lista_usuarios.csv"

    cd "$REPO" || return
    git pull 
    git add .
    git commit -m "Reportes masivos actualizados" >/dev/null 2>&1
    git push >/dev/null 2>&1
    cd - >/dev/null 2>&1

    echo "Todos los reportes fueron generados y enviados."
    read -p "Enter para continuar..."
}

  # Detectar entorno
if grep -qi "android" /proc/version; then
    OPEN_URL="termux-open-url"
elif grep -qi "microsoft" /proc/version; then
    OPEN_URL="wslview"
else
    OPEN_URL="xdg-open"
fi

enviar_whatsapp() {
    tel="$1"
    mensaje="$2"
    url="https://wa.me/52$tel?text=$mensaje"
    echo "Abriendo WhatsApp Web..."
    $OPEN_URL "$url"
}

    probar_conexion_whatsapp() {
      echo -e "${VERDE}Abriendo WhatsApp Web...${RESET}"
      sleep 1 
      termux-open-url "https://wa.me/528996750648?text=Prueba%20de%20conexion"
    }
        clear
    echo -e "${CYAN}===========================${RESET}"
    echo -e "${MAGENTA}=== ENVÍO POR WHATSAPP ===${RESET}"
    echo -e "${CYAN}===========================${RESET}"
    echo "1) Enviar mansaaje individual"
    echo "2) Enviar reporte a todos los socios"
    echo "3) Probar conexion"
    echo -e "${ROJO}(0 para cancelar)${RESET}"
    read -p "Solicitar una opción: " opcion
    cancelar_si_solicita "$opcion" || return 0

    case "$opcion" in 
      1) enviar_reporte_individual ;;
      2) enviar_reportes_todos ;;
      3) probar_conexion_whatsapp ;;
      0) return;;
      *) echo -e "${ROJO}Opción inválida.${RESET}"; sleep 1 ;;
    esac
     break
  done
}
    
# ==========================================
#   FUNCIÓN: RESPALDOS
# ==========================================
respaldar() {
    clear
    echo -e "\e[1;34m=== RESPALDOS AUTOMÁTICOS ===\e[0m"
    echo "Módulo en construcción..."
    sleep 2
}

# ==========================================
#   FUNCIÓN: CONFIGURACIÓN
# ==========================================
configuracion() {
    clear
    echo -e "\e[1;37m=== CONFIGURACIÓN ===\e[0m"
    echo "Módulo en construcción..."
    sleep 2
}

# ==========================================
#   MENÚ PRINCIPAL
# ==========================================
while true; do
    clear
    echo -e "${CYAN}==========================================${RESET}"
    echo -e "${MAGENTA}    SISTEMA CAJA DE AHORRO 2026 ${RESET}"
    echo -e "${CYAN}==========================================${RESET}"
    echo -e "${AZUL}1)${RESET} Registrar socio"
    echo -e "${AZUL}2)${RESET} Registrar aportación"
    echo -e "${AZUL}3)${RESET} Consultar historial"
    echo -e "${AZUL}4)${RESET} Generar reporte del periodo"
    echo -e "${AZUL}5)${RESET} Generar reporte individual"
    echo -e "${AZUL}6)${RESET} Enviar reporte por WhatsApp"
    echo -e "${AZUL}7)${RESET} Respaldar información"
    echo -e "${AMARILLO}8)${RESET} Configuración"
    echo -e "${ROJO}0)${RESET} Salir"
    echo -e "${CYAN}------------------------------------------${RESET}"
    read -p "Seleccione una opción: " opcion

    case "$opcion" in
        1) crear_socio ;;
        2) registrar_aportacion ;;
        3) consultar_historial ;;
        4) generar_reporte ;;
        5) generar_reporte_individual;;
        6) enviar_whatsapp ;;
        7) respaldar ;;
        8) configuracion ;;
        0) exit ;;
        *) err "Opción inválida."; sleep 1 ;;
    esac
done


