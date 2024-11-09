ASTACK SEGMENT STACK
    DW 12 DUP(?)
ASTACK ENDS

DATA SEGMENT 
    A DW 3
    B DW 2        
    I DW 3       
    K DW 1
    I1 DW ?     
    I2 DW ?      
    RES DW ?     
DATA ENDS

CODE SEGMENT 
    ASSUME CS:CODE, DS:DATA, SS:ASTACK

MAIN PROC FAR 
    PUSH DS        ; Сохраняем DS в стек
    SUB AX, AX     ; Обнуляем AX (AX = 0)
    PUSH AX        ; Сохраняем AX в стек (AX = 0)
    MOV AX, DATA   ; Загружаем адрес сегмента данных в AX (AX = адрес DATA)
    MOV DS, AX     ; Загружаем AX в DS (DS = адрес DATA)

    MOV DX, I      ; Загружаем значение I в DX (DX = значение I)
    SHL DX, 1      ; Сдвигаем DX влево на 1 бит (DX = 2 * I)
    ADD DX, I      ; Добавляем значение I к DX (DX = 2 * I + I = 3 * I)
    NEG DX         ; Инвертируем знак DX (DX = -3 * I)
    MOV CX, DX     ; CX = -3 * I
    SHL CX, 1;     ; CX = -6 * I

    ; Сравниваем A и B
    MOV AX, A      ; Загружаем значение A в AX (AX = 1)
    CMP AX, B      ; Сравниваем A с B (AX = 1, B = 2)
    JLE less       ; Переходим на метку less, если A <= B

    ; случай A > B
    ADD CX, 4      ; Добавляем 4 к CX (CX = -6 * I + 4)
    MOV I2, CX     ; Сохраняем CX в I2 (I2 = -6 * I + 4)
    SUB DX, I      ; Вычитаем I из DX (DX = -3 * I - I = -4 * I)
    ADD DX, 7      ; Добавляем 7 к DX (DX = -4 * I + 7)
    MOV I1, DX     ; Сохраняем DX в I1 (I1 = -4 * I + 7)
    JMP f3         ; Переходим на метку f3, чтобы пропустить код в less

less:
    ADD CX, 8      ; Добавляем 8 к CX (CX = -6 * I + 8)
    MOV I1, CX     ; Сохраняем CX в I1 (I1 = -6 * I + 8)
    NEG DX         ; Инвертируем знак DX (DX = 3 * I)
    ADD DX, 6      ; Добавляем 6 к DX (DX = 3 * I + 6)
    MOV I2, DX     ; Сохраняем DX в I2 (I2 = 3 * I + 6)

f3:
    MOV AX, I1     ; Загружаем значение I1 в AX (AX = I1)
    MOV BX, I2     ; Загружаем значение I2 в BX (BX = I2)
    CMP K, 0       ; Сравниваем K с 0 (K = 1)
    JGE kgez       ; Переходим на метку kgez, если K >= 0
    NEG BX         ; Инвертируем знак BX (BX = -I2)
    ADD BX, 10     ; Добавляем 10 к BX (BX = -I2 + 10)
    CMP AX, BX     ; Сравниваем AX с BX (AX = I1, BX = -I2 + 10)
    JGE exit       ; Переходим на метку exit, если AX >= BX
    MOV AX, BX     ; AX = BX = -I2 + 10
    JMP exit       ; Переходим на метку exit, чтобы завершить программу

kgez:
    SUB AX, BX     ; Вычитаем BX из AX (AX = I1 - I2)
    JNS exit       ; Переходим на метку exit, если результат не отрицательный
    NEG AX         ; Инвертируем знак AX (AX = |I1 - I2|)

exit:
    MOV RES, AX    ; Сохраняем AX в RES (RES = AX)
    RET            ; Возвращаем управление вызывающей программе
MAIN ENDP
CODE ENDS
END MAIN