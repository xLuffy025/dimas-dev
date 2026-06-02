#!/usr/bin/env python3

import requests

print("=== Probando una API ===\n")

# Solicitar información de una API pública
respuesta = requests.get("https://api.github.com")

print(f"Código de respuesta:{respuesta.status_code}")
print(f"Tipo de contenido:{respuesta.headers['content-type']}")

if respuesta.status_code == 200:
    datos = respuesta.json()
    print(f"\nAPI de GitHub responde correctamente! 🎉")
    print(f"Puedes explorar:{list(datos.keys())}")
