.text:
.global _start
_start:
.equ a, 17
.equ b, 5
.equ c, 9
.equ threshold, 1000

addi s0, zero, a # сохранение a, b,
addi s1, zero, b # c, threshold
addi s2, zero, c #  в регистры s0, s1, s2, a1
addi a1, zero, threshold # соответственно

add t1, s0, s1 # t1 = a + b
add t1, t1, s2 # t1 = a + b + c

la a0, condition # вывод условия на экран
addi a7, zero, 4
ecall

addi t0, zero, 10 # счетчик оставшихся элементов в массиве
sw t1, 0x0(t2) # сохраняем a+b+c в 0 элемент массива

sub t1, t1, s2
sub t1, t1, s2 # t1 = a + b - c

la a0, res_array
addi a7, zero, 4
ecall

loop:
    lw t3, 0x0(t2) # t3 = arr[i]
    mv a0, t3
    addi a7, zero, 1
    ecall
    li a0, 32 # пробел
    addi a7, x0, 11
    ecall
    addi t2, t2, 4
    add t3, t3, t1 # t3 = arr[i] + a + b + c 
    sw t3, 0x0(t2) # сохранение t3 в память
    addi t0, t0, -1 # уменьшение счетчика
    bnez t0, loop
    
add t0, zero, zero # сброс значения t3
lw s3, 0x8(t0)  # s3 = arr[2]
lw s4, 0xc(t0)  # s4 = arr[3]
lw s5, 0x24(t0) # s5 = arr[9]

li a0, 10 # \n
addi a7, zero, 11
ecall

la a0, str_threshold 
addi a7, zero, 4
ecall

mv a0, a1 # вывод значения threshold
addi a7, zero, 1
ecall

li a0, 10
addi a7, zero, 11
ecall

add s3, s3, s4 # s3 = arr[2] + arr[3]
add s5, s3, s5 # s5 = arr[2] + arr[3] + arr[9]
sub s3, s3, s4 # s3 = arr[2]
la a0, sum
addi a7, zero, 4
ecall

mv a0, s5 # вывод arr[2] + arr[3] + arr[9]
addi a7, zero, 1
ecall

li a0, 10
addi a7, zero, 11
ecall

la a0, result
addi a7, zero, 4
ecall

blt a1, s5, sum_greater # if threshold < arr[2] + arr[3] + arr[9]
sub s4, s3, s2 # s4 = arr[2] - c
mv a0, s4 # вывод arr[2] - c
addi a7, zero, 1
ecall
j end


sum_greater:
    lw t3, 0x0(t0) # t3 = arr[0]
    lw t4, 0x4(t0) # t4 = arr[1]
    sub t6, t3, t4 # t6 = arr[0] - arr[1]
    mv a0, t6 # вывод arr[0] - arr[1]
    addi a7, zero, 1
    ecall

end:
    addi a0, x0, 0 # завершение программы системным вызовом
    addi a7, x0, 93 # Exit (a7=93) с кодом возврата в регистре а0
    ecall



.data:
    condition: .asciz "if arr[9] + arr[3] + arr[2] > threshold\n then res1 = arr[0] - arr[1]\n else res2 = arr[2] - c\n"
    res_array: .asciz "array: "
    str_threshold: .asciz "threshold: "
    sum: .asciz "arr[9] + arr[3] + arr[2] = "
    result: .asciz "result: "