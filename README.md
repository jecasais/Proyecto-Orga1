# Proyecto-Orga1

# Proyecto Conversor Sistemas Numericos - Integrante 3

En este modulo se implementa la conversión del valor numérico interno a los formatos de salida (binario, decimal empaquetado, hexadecimal, octal) y se realiza la impresión en terminal

## Componentes Incluidos:
- **Macros Obligatorios:** `print_bit`, `print_nible`, `print_sign`
- **Rutina `output_bin` salida binario:** maneja numeros de 40 bits (32 enteros mas 8 fraccionarios), aplica complemento a 2 si el numero es negativo y imprime los bits enteros uno a uno, luego punto (si hay fracción) y los 8 bits fraccionarios.
