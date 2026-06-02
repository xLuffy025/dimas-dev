import yt_dlp
import os

CALIDADES = {
    "1": ("4K (2160p)", "bestvideo[height<=2160]+bestaudio/best[height<=2160]"),
    "2": ("1440p", "bestvideo[height<=1440]+bestaudio/best[height<=1440]"),
    "3": ("1080p", "bestvideo[height<=1080]+bestaudio/best[height<=1080]"),
    "4": ("720p", "bestvideo[height<=720]+bestaudio/best[height<=720]"),
    "5": ("480p", "bestvideo[height<=480]+bestaudio/best[height<=480]"),
    "6": ("Mejor disponible", "bestvideo+bestaudio/best"),
}


def pedir_url():
    while True:
        url = input("Pega la URL del video: ").strip()
        if url:
            return url
        print("La URL no puede estar vacía.")

def pedir_modo():
    print("Elige el tipo de descarga:")
    print("1. Video + audio")
    print("2. Solo audio")
    while True:
        opcion = input("Opción: ").strip()
        if opcion in ("1", "2"):
            return opcion
        print("Opción inválida. Intenta de nuevo.")
def mostrar_formatos(url):
    print("Formatos disponibles:")
    ydl_opts = {"ignoreerrors": True, "quiet": True, "no_warnings": True}
    try:
        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
            info = ydl.extract_info(url, download=False)
            if info is None:
                print("No se pudo obtener información del video o lista.")
                return
    except Exception as e:
        print(f"Error al obtener formatos: {e}")
        return

    # Si es una lista de reproducción, mostramos formatos del primer video disponible
    if "entries" in info:
        print("Nota: Es una lista de reproducción. Mostrando formatos del primer video válido.")
        info = next((e for e in info["entries"] if e), None)
        if not info:
            print("No hay videos disponibles en esta lista.")
            return

    formats = info.get("formats", [])
    if not formats:
        print("No se encontraron formatos disponibles.")
        return

    for f in formats:
        fmt_id = f.get("format_id", "?")
        ext = f.get("ext", "?")
        height = f.get("height") or ""
        vcodec = f.get("vcodec") or ""
        acodec = f.get("acodec") or ""
        note = f.get("format_note") or ""
        print(f"- {fmt_id} | {ext} | {height} | v:{vcodec} a:{acodec} | {note}")



def pedir_calidad():
    print("Elige la calidad de descarga:")
    for clave, (nombre, _) in CALIDADES.items():
        print(f"{clave}. {nombre}")
    while True:
        opcion = input("Opción: ").strip()
        if opcion in CALIDADES:
            return CALIDADES[opcion][1]
        print("Opción inválida. Intenta de nuevo.")

def pedir_nombre_archivo():
    nombre = input("Nombre de archivo (deja vacío para usar el título): ").strip()
    if not nombre:
        return "%(title)s.%(ext)s"
    return f"{nombre}.%(ext)s"
def pedir_carpeta_salida():
    carpeta = input("Carpeta de salida (deja vacío para la actual): ").strip()
    if not carpeta:
        return ""
    carpeta = os.path.expanduser(os.path.expandvars(carpeta)).rstrip("/")
    if not os.path.isdir(carpeta):
        crear = input("La carpeta no existe. ¿Crear? (s/n): ").strip().lower()
        if crear in ("s", "si", "sí"):
            os.makedirs(carpeta, exist_ok=True)
        else:
            print("Se usará la carpeta actual.")
            return ""
    return carpeta


def pedir_audio_formato():
    print("Formato de audio:")
    print("1. M4A (mejor)")
    print("2. MP3")
    while True:
        opcion = input("Opción: ").strip()
        if opcion in ("1", "2"):
            return "m4a" if opcion == "1" else "mp3"
        print("Opción inválida. Intenta de nuevo.")


def descargar(url, formato, outtmpl, postprocessors=None):
    ydl_opts = {
        "format": formato,
        "outtmpl": outtmpl,
        "ignoreerrors": True,
    }
    if postprocessors:
        ydl_opts["postprocessors"] = postprocessors
    with yt_dlp.YoutubeDL(ydl_opts) as ydl:
        ydl.download([url])


if __name__ == "__main__":
    url = pedir_url()
    modo = pedir_modo()
    ver_formatos = input("¿Mostrar formatos disponibles? (s/n): ").strip().lower()
    if ver_formatos in ("s", "si", "sí"):
        mostrar_formatos(url)
    if modo == "2":
        formato = "bestaudio/best"
        audio_ext = pedir_audio_formato()
        postprocessors = [
            {
                "key": "FFmpegExtractAudio",
                "preferredcodec": audio_ext,
                "preferredquality": "0",
            }
        ]
    else:
        formato = pedir_calidad()
        postprocessors = None
    outtmpl = pedir_nombre_archivo()
    carpeta = pedir_carpeta_salida()
    if carpeta:
        outtmpl = f"{carpeta}/{outtmpl}"
    descargar(url, formato, outtmpl, postprocessors)

