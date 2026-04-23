ión 1 — Tu primer script 🎓

---

## ¿Qué es un script de bash?

Un script es simplemente un **archivo de texto** con una lista de comandos que la computadora ejecuta uno por uno. En lugar de escribir comandos a mano, los automatizas.

---

## El Shebang `#!/bin/bash`

La **primera línea** de todo script debe ser:
```bash
#!/bin/bash
```
Esto le dice al sistema **"usa bash para ejecutar este archivo"**. Sin esta línea el script puede fallar.

---

## Tu primer script

Crea el archivo en nvim:
```bash
nvim hola.sh
```

Escribe esto:
```bash
#!/bin/bash

# Esto es un comentario, bash lo ignora
echo "¡Hola mundo!"
echo "Mi primer script funciona"
```

Guarda con `:wq`

---

## Ejecutarlo

```bash
# Primero dale permisos
chmod +x hola.sh

# Ejecútalo
./hola.sh
```

Debes ver:
```
¡Hola mundo!
Mi primer script funciona
```

---

## ¿Qué es `echo`?

`echo` simplemente **imprime texto** en la pantalla. Es el comando más básico y lo usarás constantemente.

```bash
echo "Hola"          # imprime: Hola
echo "Tengo 20 años" # imprime: Tengo 20 años
```

---

## 🏋️ Ejercicio

Crea un script llamado `yo.sh` que imprima:
- Tu nombre
- Tu edad
- Por qué quieres aprender bash

