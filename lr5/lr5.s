.text # раздел с инструкциями программы
.global _start
_start:
.equ a, 17 # задаются константы
.equ b, 5
.equ c, 9

addi s0, x0, a # константы a, b, c размещаются
addi s1, x0, b # в регистры s0, s1
addi s2, x0, c # и s2 соответственно

li a2, 345 # размещение переменных
li a3, 256 # x1, y1, z1 в регистры
li a4, 17456 # a2, a3, a4 соответственно
li a5, 185 # размещение переменных
li a6, 126 # x2, y2, z2 в регистры
li a7, -6877 # a5, a6, a7 соответственно

mv s4, a7 # сохранение значения из а7
la a0, formula # вывод строки по адресу в а0
addi a7, x0, 4 # с помощью системного вызова PrintString
ecall # (a7=4)

mv a0, a2 # перенос числа из а2 в а0
addi a7, zero, 1 # вывод его в 10-чной сс системным вызовом
ecall # PrintInt (a7=1)

li a0, 32 # в а0 ascii код пробела
addi a7, x0, 11 # вывод символа системным вызовом
ecall # PrintChar (a7=11)

mv a0, a3 # вывод числа из а3
addi a7, zero, 1
ecall

li a0, 32 # пробел
addi a7, zero, 11
ecall # PrintChar

mv a0, a4 # вывод числа из а4
addi a7, zero, 1
ecall

li a0, 10 # вывод символа переноса строки
addi a7, zero, 11
ecall

la a0, second_set # вывод строки
addi a7, zero, 4
ecall

mv a0, a5 # вывод числа из а5
addi a7, zero, 1
ecall

li a0, 32 # пробел
addi a7, zero, 11
ecall

mv a0, a6 # вывод числа из а6
addi a7, zero, 1
ecall

li a0, 32 # пробел
addi a7, zero, 11
ecall

mv a7, s4 # восстановление значения в а7
mv a0, a7 # вывод числа из а7
addi a7, zero, 1
ecall

li a0, 10 # перенос строки
addi a7, zero, 11
ecall

mv a7, s4
mv t0, a2 # x
mv t1, a3 # y
mv t2, a4 # z
neg s2, s2 # теперь в s2 находится (-с)

call calc_expression # вызов процедуры calc_expression

la a0, results # вывод строки
addi a7, zero, 4
ecall

mv a1, t0
mv a0, a1 # вывод числа из а1
addi a7, zero, 1
ecall

li a0, 10
addi a7, zero, 11
ecall

mv a7, s4
mv t0, a5 # x
mv t1, a6 # y
mv t2, a7 # z
call calc_expression

mv a2, t0
mv a0, a2 # вывод числа из а2
addi a7, zero, 1
ecall

addi a0, zero, 0 # завершение программы системным вызовом
addi a7, zero, 93 # Exit (a7=93) с кодом возврата врегистре а0
ecall

calc_expression:


# вычисление выражения для {x1, y1, z1}
and t0, t0, s2 # t0 = x1 & (-c)
sub t2, t2, s0 # t2 = z1 - a
or t0, t0, t2 # t0 = (x1 & (-c)) | (z1 - a)
add t1, t1, s1 # a3 = y1 + b
sub t0, t0, t1 # a1 = ((x1 & (-c)) | (z1 - a)) - (y1 + b)


ret # возврат из процедуры

.data # раздел с данными для переменных программы
formula: .asciz "Formula: ((x & (-9)) | (z - 17)) - (y + 5)\nInputdata:\n{x1, y1, z1} = "
second_set: .asciz "{x2, y2, z2} = "
results: .asciz "Results:\n"