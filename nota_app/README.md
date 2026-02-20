# nota_app (nota_app)

Pequeña utilidad de notas en Markdown para aprendizaje personal.

Características añadidas:
- Modo debug: `--debug` o `-d` (activa `set -x`).
- Soporta títulos con acentos/ñ; genera slug seguro para filename (usa `iconv` si está instalado).
- Eliminar mueve a `.trash` en lugar de borrar.
- Visualización con `glow` si está disponible, fallback a `less`.

Uso:
- Ejecutar interactivo:
  ./dimas-dev/nota_app/notas.sh 

- Comandos directos:
  ./dimas-dev/nota_app/notas.sh crear
  ./dimas-dev/nota_app/notas.sh listar
  ./dimas-dev/nota_app/notas.sh buscar
  ./dimas-dev/nota_app/notas.sh editar
  ./dimas-dev/nota_app/notas.sh elimina
- Modo debug (trazado):
  ./dimas-dev/nota_app/notas.sh --debug crear
  o
  ./dimas-dev/nota_app/notas.sh -d listar

Pruebas manuales sugeridas
1. Crear nota con acentos:
   - `crear` -> título: "Prueba acción ñ"
   - Ver que exista `DATA_DIR/prueba_accion_n.md` (o similar) y que el contenido tenga el título original.

2. Buscar:
   - `buscar` -> introducir palabra que exista (p. ej. "acción") y verificar preview.

3. Editar:
   - `editar` -> seleccionar la nota -> ver/editar con editor.

4. Eliminar:
   - `eliminar` -> seleccionar -> confirmar -> comprobar que el archivo esté en `.trash`.

5. Debug:
   - Ejecutar con `--debug` y repetir un flujo para ver la traza completa.

Logs
- `LOG_FILE` por defecto: `$HOME/dimas-dev/nota/logs/notas.log`

Recomendaciones
- Instala `iconv` para mejor transliteración y `glow` para mejor preview.
- Ejecuta `shellcheck` localmente (o usa el workflow) para mantener calidad.
