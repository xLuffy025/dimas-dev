#!/usr/bin/env python3
"""Rifa: registra números, nombres y estado de pago, y sortea ganadores.
Los datos se guardan en rifa.json (junto al script)."""
import json
import os
import random

RONDAS = 10  # cuántos números se sacan; el último en salir gana

ARCHIVO = os.path.join(os.path.dirname(os.path.abspath(__file__)), "rifa.json")


def cargar():
    if os.path.exists(ARCHIVO):
        with open(ARCHIVO, encoding="utf-8") as f:
            return json.load(f)
    return {}


def guardar(datos):
    with open(ARCHIVO, "w", encoding="utf-8") as f:
        json.dump(datos, f, ensure_ascii=False, indent=2)


def pedir_numero(msg):
    while True:
        t = input(msg).strip()
        if t.isdigit() and int(t) > 0:
            return t
        print("  Escribe un número válido (entero mayor a 0).")


def agregar(datos):
    num = pedir_numero("Número: ")
    if num in datos:
        print(f"  El #{num} ya lo tiene {datos[num]['nombre']}.")
        return
    nombre = input("Nombre: ").strip()
    if not nombre:
        print("  El nombre no puede estar vacío.")
        return
    pagado = input("¿Pagado? (s/n): ").strip().lower() == "s"
    datos[num] = {"nombre": nombre, "pagado": pagado}
    guardar(datos)
    print(f"  Registrado #{num} - {nombre} ({'PAGADO' if pagado else 'NO pagado'})")


def cambiar_pago(datos):
    num = pedir_numero("Número a modificar: ")
    if num not in datos:
        print("  Ese número no existe.")
        return
    datos[num]["pagado"] = not datos[num]["pagado"]
    guardar(datos)
    estado = "PAGADO" if datos[num]["pagado"] else "NO pagado"
    print(f"  #{num} ahora está {estado}.")


def eliminar(datos):
    num = pedir_numero("Número a eliminar: ")
    if datos.pop(num, None):
        guardar(datos)
        print("  Eliminado.")
    else:
        print("  Ese número no existe.")


def listar(datos):
    if not datos:
        print("  No hay números registrados.")
        return
    pagados = 0
    print(f"\n{'#':>5}  {'Nombre':<25} Estado")
    print("-" * 42)
    for num in sorted(datos, key=int):
        d = datos[num]
        pagados += d["pagado"]
        print(f"{num:>5}  {d['nombre']:<25} {'PAGADO' if d['pagado'] else 'NO pagado'}")
    print("-" * 42)
    print(f"Total: {len(datos)} | Pagados: {pagados} | Sin pagar: {len(datos) - pagados}")


def sortear(datos):
    participantes = [n for n, d in datos.items() if d["pagado"]]
    if not participantes:
        print("  No hay números pagados para sortear.")
        return
    rondas = min(RONDAS, len(participantes))
    if rondas < RONDAS:
        print(f"  Solo hay {rondas} pagados: el último en salir será el ganador.")

    restantes = participantes[:]
    print("\n🎉 SORTEO 🎉")
    for i in range(1, rondas + 1):
        input(f"  Enter para sacar el número {i} de {rondas}...")
        num = random.choice(restantes)
        restantes.remove(num)  # no se repite
        if i < rondas:
            print(f"  Salió el {num} ({datos[num]['nombre']}) -> sigue el sorteo")
        else:
            print(f"\n  🏆 GANADOR: número {num} -> {datos[num]['nombre']} 🏆")


def menu():
    datos = cargar()
    opciones = {
        "1": ("Agregar número", agregar),
        "2": ("Cambiar pagado/no pagado", cambiar_pago),
        "3": ("Ver lista", listar),
        "4": ("Eliminar número", eliminar),
        "5": ("Sortear", sortear),
    }
    while True:
        print("\n=== RIFA ===")
        for k, (txt, _) in opciones.items():
            print(f"{k}. {txt}")
        print("0. Salir")
        op = input("Opción: ").strip()
        if op == "0":
            break
        if op in opciones:
            opciones[op][1](datos)
        else:
            print("  Opción inválida.")


if __name__ == "__main__":
    menu()
