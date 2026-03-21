# Proyecto-Orga1

# Proyecto Conversor Sistemas Numericos - Integrante 3

En este modulo se implementa la conversión del valor numérico interno a los formatos de salida (binario, decimal empaquetado, hexadecimal, octal) y se realiza la impresión en terminal

## Componentes Incluidos:
- **Macros Obligatorios:** `print_bit`, `print_nible`, `print_sign`.
- **Rutina `output_bin` salida binario:** maneja numeros de 40 bits (32 enteros mas 8 fraccionarios), aplica complemento a 2 si el numero es negativo y imprime los bits enteros uno a uno, luego punto (si hay fracción) y los 8 bits fraccionarios.
- **Rutina `output_bcd` salida en decimal empaquetado:** convierte la magnitud entera a BCD mediante divisiones sucesivas por 10 y almacena los 8 digitos en un registro (4 bits por digito) e imprime cada nible.
- **Rutina `output_hex` salida en hexadecimal con signo:** imprime el signo con `print_sign`, si el numero es negativo, lo convierte a complemento a 2 y extrae cada nible de 4 bits (desde el MSB) y lo convierte a carácter ASCII.
- **Rutina `output_oct` salida en octal con signo:** imprime el signo y aplica complemento a 2 si es negativo, imprime los primeros 2 bits como un dígito octal y luego recorre grupos de 3 bits hasta el LSB, convirtiendo cada grupo a dígito octal (0‑7).
