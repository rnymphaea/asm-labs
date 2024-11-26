AStack SEGMENT STACK
    DW 512 DUP(?)
AStack ENDS

DATA SEGMENT
    INPUT_BUFFER DB 253, 0, 254 DUP (' ') ; Входной буфер для строки
    OUTPUT_BUFFER DB 254 DUP (' ')        ; Выходной буфер для обработанной строки
    CRLF DB 0Dh, 0Ah, '$'                 ; Символы перевода строки
    
    KEEP_CS DW ?            ; Переменные для хранения
    KEEP_IP DW ?            ; оригинального вектора прерывания
DATA ENDS

CODE SEGMENT
    ASSUME CS:CODE, DS:DATA, SS:AStack
    
; Обработчик прерывания 60h
MY_INT PROC FAR
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI

    ; Настройка указателей на входной и выходной буферы
    LEA SI, INPUT_BUFFER + 2      ; SI указывает на начало введённой строки
    LEA DI, OUTPUT_BUFFER         ; DI указывает на начало выходного буфера
    MOV CL, [INPUT_BUFFER + 1]    ; Длина введённой строки в CL
    
PROCESS_LOOP:
    CMP CL, 0                    ; Если длина строки = 0, завершение обработки
    JE PROCESS_END

    MOV AL, [SI]                 ; Читаем символ из входного буфера
    
    ; Проверяем, является ли символ цифрой
    CMP AL, '0'
    JB COPY_CHAR                 ; Если меньше '0', просто копируем
    CMP AL, '9'
    JBE CONVERT_TO_DECIMAL       ; Если от '0' до '9', продолжаем преобразование

    ; Проверяем, является ли символ буквой от 'A' до 'F'
    CMP AL, 'A'
    JB COPY_CHAR                 ; Если меньше 'A', просто копируем
    CMP AL, 'F'
    JBE CONVERT_TO_DECIMAL       ; Если от 'A' до 'F', продолжаем преобразование
    
COPY_CHAR:
    MOV [DI], AL                 ; Копируем символ без изменений
    INC DI
    JMP NEXT_CHAR

CONVERT_TO_DECIMAL:
    ; Преобразуем символ в десятичное число
    ; Если символ от '0' до '9', то просто вычитаем '0'
    ; Если символ от 'A' до 'F', то вычитаем 'A' и прибавляем 10
    CMP AL, '9'
    JBE DECIMAL_DIGIT            ; Если от '0' до '9', обрабатываем как цифру
    SUB AL, 'A'                  ; Преобразуем 'A'..'F' в 0..5
    ADD AL, 10                   ; Прибавляем 10, чтобы получить 10 для 'A', 11 для 'B' и так далее
    JMP STORE_DECIMAL

DECIMAL_DIGIT:
    SUB AL, '0'                  ; Преобразуем цифру в число

STORE_DECIMAL:
    ; Если число больше или равно 10, преобразуем его в два символа
    CMP AL, 10
    JL SINGLE_DIGIT              ; Если число меньше 10, просто сохраняем как один символ

    ; Преобразуем десятки в символ и сохраняем
    MOV BL, AL                   ; Сохраняем число в BL (для деления на 10)
    MOV AH, 0                    ; Очищаем AH (чтобы результат деления в AL был правильным)
    MOV BH, 10                   ; Загружаем 10 в BH для деления
    DIV BH                       ; Делим на 10, результат (десятки) в AL, остаток (единицы) в AH
    ADD AL, '0'                  ; Преобразуем десятки в символ
    MOV [DI], AL                 ; Сохраняем десятки
    INC DI

    ADD AH, '0'                  ; Преобразуем единицы в символ
    MOV [DI], AH                 ; Сохраняем единицы
    INC DI
    JMP NEXT_CHAR

SINGLE_DIGIT:
    ADD AL, '0'                  ; Преобразуем число в символ
    MOV [DI], AL                 ; Сохраняем результат в выходной буфер
    INC DI

NEXT_CHAR:
    INC SI                       ; Переходим к следующему символу входного буфера
    DEC CL                       ; Уменьшаем счётчик длины строки
    JMP PROCESS_LOOP             ; Возвращаемся к началу цикла


PROCESS_END:
    ; Завершаем выходную строку символом '$'
    MOV BYTE PTR [DI], '$'
    
    ; Перевод строки
    LEA DX, CRLF
    MOV AH, 09h
    INT 21h

    ; Вывод обработанной строки
    LEA DX, OUTPUT_BUFFER
    MOV AH, 09h
    INT 21h
    
    MOV AL, 20h
    OUT 20h, AL

    ; Восстановление регистров и завершение обработчика
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    
    IRET

MY_INT ENDP

Main PROC FAR
    ; Инициализация сегментов
    PUSH DS
    SUB AX, AX
    PUSH AX
    MOV AX, DATA
    MOV DS, AX
    
    ; Сохранение оригинального вектора прерывания 60h
    MOV AH, 35h
    MOV AL, 60h
    INT 21h
    MOV KEEP_IP, BX
    MOV KEEP_CS, ES
    
    ; Установка нового вектора прерывания 60h
    PUSH DS
    MOV DX, OFFSET MY_INT
    MOV AX, SEG MY_INT
    MOV DS, AX
    MOV AH, 25h
    MOV AL, 60h
    INT 21h
    POP DS

    ; Ввод строки
    LEA DX, INPUT_BUFFER
    MOV AH, 0Ah
    INT 21h
    
    ; Генерация прерывания для обработки строки
    INT 60h
    
    ; Восстановление оригинального вектора прерывания 60h
    CLI
    PUSH DS
    MOV DX, KEEP_IP
    MOV AX, KEEP_CS
    MOV DS, AX
    MOV AH, 25h
    MOV AL, 60h
    INT 21h
    POP DS
    STI

    ; Завершение программы
    MOV AX, 4C00h
    INT 21h

Main ENDP
CODE ENDS
END Main