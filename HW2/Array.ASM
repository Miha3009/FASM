; Вариант №7
; Разработать программу, которая вводит одномерный массив A[N],
; формирует из элементов массива A новый массив B по правилам,
; указанным ниже, и выводит его.
; Память под массивы выделятся динамически.
; Задача должна быть разбита на подпрограммы (процедуры).
; Массив B должен содержать индесксы положительных элементов массива A.

format PE console

entry start

include 'win32a.inc'

section '.data' data readable writable

        strN db 'Enter array length: ', 0
        strA db 'Enter array A: ', 0
        strB db 'Array B: ', 0

        strErrorLength db 'Length of array must be positive number', 10, 0
        strErrorInput db 'Incorrect format of integer', 10,\
                      'Program finished with exit code 0...', 0
        strErrorEmpty db 'empty', 0

        strNumber db '%d', 0
        strSpace db ' ', 0

        A dd ?
        B dd ?
        N dd ?
        M dd ?
        TEMP dd ?
        HEAPMEM dd ?

        NULL = 0

section '.code' code readable executable

        start:
                invoke GetProcessHeap
                mov [HEAPMEM],eax

                call readArrayA
                call genB
                call printArrayB

                call [getch]

                push NULL
                call [ExitProcess]

section '.proc' code readable executable
        proc readArrayA
                readArrayLength:
                invoke printf, strN

                invoke scanf, strNumber, N

                cmp eax, 0
                je readArrayError
                jmp noReadArrayError

                readArrayError:
                        invoke printf, strErrorInput
                        invoke getch
                        invoke ExitProcess, NULL
                noReadArrayError:

                cmp [N], 1
                jl readArrayError2
                jmp noReadArrayError2

                readArrayError2:
                        invoke printf, strErrorLength
                        add esp, 16
                        jmp readArrayLength
                noReadArrayError2:

                invoke printf, strA

                mov ecx, 4
                imul ecx, [N]
                invoke HeapAlloc,[HEAPMEM],0,ecx
                mov [A], eax

                mov edi, 0
                loop1:
                        readElement:
                        invoke scanf, strNumber, TEMP
                        add esp, 8

                        cmp eax, 0
                        je readElementError
                        jmp noReadElementError

                        readElementError:
                                invoke printf, strErrorInput
                                invoke getch
                                invoke ExitProcess, NULL
                        noReadElementError:

                        mov eax, [TEMP]
                        mov ebx, [A]
                        mov [ebx+edi*4], eax

                        inc edi
                        cmp edi, [N]
                        jne loop1
                end1:

                add esp, 16
                ret
        endp

        proc genB
             ; Выделяем на массив B столько же, сколько на A, чтобы данные гарантированно влезли
             mov ecx, 4
             imul ecx, [N]
             invoke HeapAlloc,[HEAPMEM],0,ecx
             mov [B], eax

             mov edi, 0
             mov [M], edi
             loop2:
                        mov ebx, [A]
                        mov eax, [ebx+edi*4]
                        cmp eax, 1
                        jl notPositive

                        mov ebx, [B]
                        mov ecx, [M]
                        mov [ebx+ecx*4], edi
                        inc [M]

                        notPositive:
                        inc edi
                        cmp edi, [N]
                        jne loop2
             ret
        endp

        proc printArrayB
                invoke printf, strB

                cmp [M], 0
                je arrayEmptyError
                jmp noArrayEmptyError

                arrayEmptyError:
                        invoke printf, strErrorEmpty
                        add esp, 8
                        ret
                noArrayEmptyError:

                mov edi, 0
                loop3:
                        mov ebx, [B]
                        mov ecx, [ebx+edi*4]
                        invoke printf, strNumber, ecx

                        invoke printf, strSpace
                        add esp, 12

                        inc edi
                        cmp edi, [M]
                        jne loop3

                add esp, 4
                ret
        endp

section '.idata' import data readable

        library kernel, 'kernel32.dll',\
                msvcrt, 'msvcrt.dll'

        import kernel,\
               ExitProcess, 'ExitProcess',\
               HeapAlloc, 'HeapAlloc',\
               GetProcessHeap, 'GetProcessHeap'

        import msvcrt,\
               printf, 'printf',\
               scanf, 'scanf',\
               getch, '_getch'