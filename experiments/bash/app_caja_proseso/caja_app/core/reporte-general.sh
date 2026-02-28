#!/usr/bin/env bash
set -eou pipefail
IFS=$'\n\t'

# ==========================================
#   FUNCIÓN: GENERAR REPORTE HTML
# ==========================================

escape_html() {
    local s="$1"
    s="${s//&/&amp;}"
    s="${s//</&lt;}"
    s="${s//>/&gt;}"
    s="${s//\"/&quot;}"
    s="${s//\'/&#39;}"
    echo "$s"
}

    clear
    echo -e "\e[1;32m=== GENERAR REPORTE HTML ===\e[0m"

    fecha_reporte=$(date +"%Y-%m-%d_%H:%M:%S")
    archivo="$REPORTES_DIR/reporte_${fecha_reporte}.html"

    cat > "$archivo" <<'HTML_HEADER'
<html><head>
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
    </head><body>
HTML_HEADER

    echo "<h1>Reporte Caja de Ahorro</h1>" >> "$archivo"
    echo "<p>Generado el: <b>$fecha_reporte</b></p>" >> "$archivo"

    cat >> "$archivo" <<'HTML_TABLE'
<table>
        <tr>
            <th>Socio</th>
            <th>Fecha de entrega</th>
            <th>Total aportado</th>
            <th>Aportaciones</th>
            <th>Última aportación</th>
        </tr>
HTML_TABLE

    total_general=0

    while IFS=',' read -r socio fecha_entrega resto || [[ -n "$socio" ]]; do
        archivo_socio="$USUARIO_DIR/$socio/registros.csv"

        total_socio=0
        aportaciones=0
        ultima="N/A"

        if [[ -s "$archivo_socio" ]]; then
            while IFS=',' read -r f _ m e || [[ -n "$f" ]]; do
                if [[ "$m" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
                    total_socio=$(echo "$total_socio + $m" | bc)
                    aportaciones=$((aportaciones + 1))
                    ultima="$f"
                fi
            done < "$archivo_socio"

            clase="verde"
        else
            clase="rojo"
        fi

        total_general=$(echo "$total_general + $total_socio" | bc)

        socio_safe=$(escape_html "$socio")
        fecha_safe=$(escape_html "$fecha_entrega")
        ultima_safe=$(escape_html "$ultima")

        echo "<tr class='$clase'>
                <td>$socio_safe</td>
                <td class='azul'>$fecha_safe</td>
                <td>$total_socio</td>
                <td>$aportaciones</td>
                <td>$ultima_safe</td>
              </tr>" >> "$archivo"

    done < "$USUARIO_DIR/lista_usuarios.csv"

    echo "</table>" >> "$archivo"

    echo "<h2>Total general del grupo: $total_general</h2>" >> "$archivo"

    echo "</body></html>" >> "$archivo"

