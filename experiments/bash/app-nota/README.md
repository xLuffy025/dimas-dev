# app-nota (experiments/bash/app-nota)

Pequeña utilidad de notas en Markdown para aprendizaje personal.

Características añadidas:
- Modo debug: `--debug` o `-d` (activa `set -x`).
- Soporta títulos con acentos/ñ; genera slug seguro para filename (usa `iconv` si está instalado).
- Eliminar mueve a `.trash` en lugar de borrar.
- Visualización con `glow` si está disponible, fallback a `less`.

Uso:
- Ejecutar interactivo:
  ./experiments/bash/app-nota/notas.sh
- Comandos directos:
  ./experiments/bash/app-nota/notas.sh crear
  ./experiments/bash/app-nota/notas.sh listar
  ./experiments/bash/app-nota/notas.sh buscar
  ./experiments/bash/app-nota/notas.sh editar
  ./experiments/bash/app-nota/notas.sh eliminar
- Modo debug (trazado):
  ./experiments/bash/app-nota/notas.sh --debug crear
  o
  ./experiments/bash/app-nota/notas.sh -d listar

Slug / títulos:
- Si `iconv` está instalado, el script translitera acentos (´á → a´, ñ→n) y crea un slug ASCII seguro.
- Si `iconv` no está disponible, el script reemplaza espacios por `_`, elimina `/` y conserva caracteres UTF-8 (advertencia mostrada).

Pruebas manuales sugeridas:
1. Crear nota con acentos:
   - crear -> título: "Prueba acción ñ"
   - Ver que exista `DATA_DIR/prueba_accion_n.md` (o similar) y que el contenido tenga el título original al inicio.
2. Buscar:
   - buscar -> introducir palabra que exista dentro de la nota (p. ej. "acción") y verificar preview.
3. Editar:
   - editar -> seleccionar la nota -> ver/editar con editor.
4. Eliminar:
   - eliminar -> seleccionar -> confirmar -> comprobar que el archivo esté en `.trash`.
5. Debug:
   - Ejecutar con `--debug` y reprobar un flujo que antes daba problemas para ver la traza completa.

Logs:
- `LOG_FILE` por defecto: `$HOME/dimas-dev/nota/logs/notas.log`

Notas:
- Recomiendo instalar `iconv` (paquetes libc-bin/libiconv según distro) y `glow` para mejor experiencia.
