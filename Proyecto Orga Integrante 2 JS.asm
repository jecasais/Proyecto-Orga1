# --- SECCIÓN INTEGRANTE 2: VALIDACIONES Y LÓGICA DE PARSEO ---

.data
    # Variables globales compartidas definidas por el Integrante 2 [cite: 7, 10]
    int_mag:    .word 0      # Magnitud de la parte entera (sin signo) [cite: 12, 16]
    frac_bits:  .word 0      # 8 bits de la parte fraccionaria (0 si no hay) [cite: 13, 16]
    sign_flag:  .word 0      # 0 = positivo, 1 = negativo [cite: 14, 17]

.text

# --- PARSE BINARIO ---
# Convierte cadena de '0' y '1' y determina signo por complemento a 2 
parse_bin:
    la $t0, input_buffer
    li $t1, 0                # Acumulador
    sw $zero, frac_bits      # Binario no suele tener fracción en este proyecto [cite: 72]
    
    lbu $t2, ($t0)           # Leer primer bit para el signo 
    subi $t3, $t2, 48        # Convertir ASCII '0'/'1' a int
    sw $t3, sign_flag        # En complemento a 2, el MSB indica el signo 

loop_bin:
    lbu $t2, ($t0)
    beq $t2, $zero, end_bin
    beq $t2, 10, end_bin
    beq $t2, 32, next_bin    # Ignorar espacios 
    
    subi $t2, $t2, 48
    sll $t1, $t1, 1          # Desplazar para el siguiente bit
    or  $t1, $t1, $t2        # Agregar bit
next_bin:
    addi $t0, $t0, 1
    j loop_bin
end_bin:
    sw $t1, int_mag
    jr $ra

# --- PARSE BCD ---
# El PDF indica que puede ser igual que el parse_bin [cite: 36, 37]
parse_bcd:
    j parse_bin

# --- PARSE DECIMAL (Anteriormente parse_input) --- [cite: 38]
parse_dec:
    la $t0, input_buffer
    li $t1, 0                
    sw $zero, sign_flag      
    sw $zero, frac_bits      

    lbu $t2, ($t0)
    bne $t2, 45, check_plus_dec
    li $t3, 1
    sw $t3, sign_flag        
    addi $t0, $t0, 1
    j loop_dec
check_plus_dec:
    bne $t2, 43, loop_dec    
    addi $t0, $t0, 1

loop_dec:
    lbu $t2, ($t0)
    beq $t2, $zero, end_dec
    beq $t2, 10, end_dec
    beq $t2, 46, parse_fraccion # Salta a lógica de fracción si detecta '.' [cite: 78]
    
    blt $t2, 48, skip_dec
    bgt $t2, 57, skip_dec
    
    subi $t2, $t2, 48
    li $t4, 10
    mul $t1, $t1, $t4
    add $t1, $t1, $t2
skip_dec:
    addi $t0, $t0, 1
    j loop_dec

# --- PARSE OCTAL ---
# Signo obligatorio y dígitos 0-7 [cite: 39]
parse_oct:
    la $t0, input_buffer
    lbu $t1, ($t0)
    # Validar signo obligatorio [cite: 39]
    beq $t1, 43, oct_pos     # '+'
    beq $t1, 45, oct_neg     # '-'
    j error_parse            # Si no tiene signo, es error [cite: 39]
oct_pos:
    li $t2, 0
    j oct_start
oct_neg:
    li $t2, 1
oct_start:
    sw $t2, sign_flag
    addi $t0, $t0, 1
    li $t3, 0                # Acumulador
loop_oct:
    lbu $t1, ($t0)
    beq $t1, $zero, end_oct
    beq $t1, 10, end_oct
    
    subi $t1, $t1, 48        # ASCII a int
    sll $t3, $t3, 3          # Multiplicar por 8
    add $t3, $t3, $t1
    addi $t0, $t0, 1
    j loop_oct
end_oct:
    sw $t3, int_mag
    sw $zero, frac_bits
    jr $ra

# --- PARSE HEXADECIMAL ---
# Signo obligatorio, dígitos 0-9, A-F [cite: 40, 41]
parse_hex:
    la $t0, input_buffer
    lbu $t1, ($t0)
    # Validar signo [cite: 46, 47]
    bne $t1, 43, check_neg_hex
    li $t2, 0                # Positivo [cite: 48]
    addi $t0, $t0, 1
    j hex_digits
check_neg_hex:
    bne $t1, 45, error_parse # [cite: 52]
    li $t2, 1                # Negativo [cite: 53]
    addi $t0, $t0, 1
hex_digits:
    li $t3, 0                # Valor acumulado [cite: 56]
hex_loop:
    lbu $t1, ($t0)
    beq $t1, $zero, hex_end  # [cite: 59]
    beq $t1, 10, hex_end     # [cite: 60]
    
    # Lógica de conversión de carácter hex a valor [cite: 61, 62]
    blt $t1, 58, hex_num     # 0-9
    blt $t1, 91, hex_upper   # A-F
    subi $t4, $t1, 87        # a-f
    j hex_step
hex_num:
    subi $t4, $t1, 48
    j hex_step
hex_upper:
    subi $t4, $t1, 55
hex_step:
    sll $t3, $t3, 4          # Multiplicar por 16 [cite: 64, 65]
    add $t3, $t3, $t4        # [cite: 66, 67]
    addi $t0, $t0, 1         # [cite: 68]
    j hex_loop
hex_end:
    sw $t3, int_mag          # [cite: 71]
    sw $zero, frac_bits      # [cite: 72]
    sw $t2, sign_flag        # [cite: 73]
    jr $ra                   # [cite: 74]

# --- LÓGICA DE FRACCIÓN COMÚN --- [cite: 38, 79]
parse_fraccion:
    addi $t0, $t0, 1       
    li $t4, 0                # Acumulador decimal
    li $t5, 1                # Divisor potencia 10
loop_frac_digits:
    lbu $t2, ($t0)
    beq $t2, $zero, calc_bits
    beq $t2, 10, calc_bits
    subi $t2, $t2, 48
    li $t6, 10
    mul $t4, $t4, $t6
    add $t4, $t4, $t2
    mul $t5, $t5, $t6        
    addi $t0, $t0, 1
    j loop_frac_digits
calc_bits:
    li $t6, 0                # Registro para bits
    li $t7, 8                # 8 bits [cite: 81]
frac_loop_math:
    beqz $t7, store_frac
    sll $t4, $t4, 1          
    sll $t6, $t6, 1          
    blt $t4, $t5, bit_zero
    ori $t6, $t6, 1          
    sub $t4, $t4, $t5        
bit_zero:
    addi $t7, $t7, -1
    j frac_loop_math
store_frac:
    sw $t6, frac_bits        
    j end_dec

end_dec:
    sw $t1, int_mag          
    jr $ra

error_parse:
    # Aquí puedes añadir un mensaje de error o simplemente salir
    jr $ra