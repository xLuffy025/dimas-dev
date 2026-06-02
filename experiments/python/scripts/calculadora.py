#!/usr/bin/env python3

print("=== Calculadora simple ===")
num1 = float(input("Primer número: "))
num2 = float(input("Segundo número: "))
operacion = input("¿Que operacion (+,-,*,/): ")

if operacion == "+":
    resultado = num1 + num2
elif operacion == "-":
    resultado = num1 - num2
elif operacion == "*":
    resultado = num1 * num2
elif operacion == "/":
    resultado = num1 / num2
else: 
    resultado = "Operación no válida"

print(f"Resultado: {resultado}")
