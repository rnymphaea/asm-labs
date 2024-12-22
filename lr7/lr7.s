.text
li a0 LED_MATRIX_0_BASE   
li a1 LED_MATRIX_0_WIDTH  
li a2 LED_MATRIX_0_HEIGHT 
li a3 SWITCHES_0_BASE   
li a4 SWITCHES_0_SIZE   

# s0 - color[0] - красный
# s1 - color[1] - зеленый
# s2 - color[2] - синий
# s3 - color[3]
# t0 - switch[0]
# t1 - switch[1]
# t2 - switch[2]
# t3 - switch[3]
# a5 - слово состояния ключей

loop:
    lw a5, 0[a3] # чтение состояния переключателя
    mv s0, zero  # y2
    mv s1, zero  # y1
    mv s2, zero  # y9
    mv s3, zero  
    mv t0, zero  # x1
    mv t1, zero  # x2
    mv t2, zero  # x3
    mv t3, zero  # x4
    
    andi t0, a5, 1  # X1 
    andi t1, a5, 2  # X2 
    andi t2, a5, 4  # X3 
    andi t3, a5, 8  # X4 
    
    beqz t0, not_x1
    li t0, 1

not_x1:
    beqz t1, not_x2
    li t1, 1

not_x2:
    beqz t2, not_x3
    li t2, 1

not_x3:
    beqz t3, not_x4
    li t3, 1
    
not_x4:
    # y1 = (x4 and not x2) or (x1 and x2 and not x4) or (x1 and x4 and not x3) or (x2 and not x3 and not x4)
    
    # x4 and not x2
    not t4, t1
    and t4, t4, t3
     
    # x1 and x2 and not x4
    and t5, t0, t1
    not t6, t3
    and t5, t5, t6
    or t4, t4, t5

    # x1 and x4 and not x3
    and t5, t0, t3
    not t6, t2
    and t5, t5, t6
    or t4, t4, t5
    
    # x2 and not x3 and not x4
    not t5, t2
    and t5, t5, t1
    not t6, t3
    and t5, t5, t6
    or s1, t4, t5   
    

    # y2 = (x1 and x2 and x4) or (x2 and x3 and not x4) or (x2 and not x1 and not x3) or (x3 and not x1 and not x2) or (x1 and not x2 and not x3 and not x4)
    
    # x1 and x2 and x4
    and t4, t0, t1
    and t4, t4, t3
    
    # x2 and x3 and not x4
    not t5, t3
    and t5, t5, t1
    and t5, t5, t2
    or t4, t4, t5
    
    # x2 and not x1 and not x3
    not t5, t0
    not t6, t2
    and t5, t5, t1
    and t5, t5, t6
    or t4, t4, t5
    
    # x3 and not x1 and not x2
    not t5, t0
    not t6, t1
    and t5, t5, t2
    and t5, t5, t6
    or t4, t4, t5
    
    # x2 and not x1 and not x3
    not t5, t0
    not t6, t2
    and t5, t5, t1
    and t5, t5, t6
    or t4, t4, t5
    
    # x1 and not x2 and not x3 and not x4
    not t5, t1
    not t6, t2
    not a2, t3
    and t5, t5, a2
    and t5, t5, t6
    and t5, t5, t0
    or s0, t4, t5
    
    
    # y9 = (x1 or x2) and (x2 or x4) and (x4 or not x3) and (not x1 or not x2)
    
    # x1 or x2
    or t4, t0, t1
    
    # x2 or x4
    or t5, t1, t3
    and t4, t4, t5
    
    # x4 or not x3
    not t5, t2
    or t5, t5, t3
    and t4, t4, t5
    
    # not x1 or not x2
    not t5, t0
    not t6, t1
    or t5, t5, t6
    and s2, t4, t5
    
save_colors:
    beqz s0, skip_red
    li s0, 0xFF0000
    
skip_red:
    beqz s1, skip_green
    li s1, 0x00FF000

skip_green:
    beqz s2, skip_blue
    li s2, 0x00000FF

skip_blue:
    # пишем цвета в память для окраса
    sw s0, 0(a0)  # y2
    sw s1, 4(a0)  # y1
    sw s2, 8(a0)  # y9
    
    or s3, s3, s0
    or s3, s3, s1
    or s3, s3, s2
    
    sw s3, 12(a0)

    j loop   # бесконечный цикл
