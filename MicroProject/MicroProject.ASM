format PE console

entry start

include 'win32a.inc'

;------------------------------------------------------------------------------------
section '.data' data readable writable

N           dd    4
idx         dd    ?
strInput    rb    1001
strOutput   rb    5   ; N + 1
strScanStr  db    '%s', 0
strAskInput db    'Enter some string: ', 0
strShowInp  db    'Input string: %s', 10, 0
strNotFound db    'Substring with length %d not found', 10, 0
strFound    db    'Substring was found: "%s" at position %d', 10, 0

;------------------------------------------------------------------------------------
section '.code' code readable executable
start:
        invoke  printf, strAskInput
        add     esp, 4
        invoke  scanf, strScanStr, strInput
        add     esp, 8
        invoke  printf, strShowInp, strInput
        add     esp, 8

        stdcall strFindSubstring, strInput, [N], idx
        add     esp, 12

        cmp     dword [idx], -1       ; if idx == -1. strFindSubstring didn't find such substring
        je      notFound

        stdcall getSubstring, strInput, strOutput, [N], [idx]
        add     esp, 16

        invoke  printf, strFound, strOutput, [idx]
        add     esp, 8
        jmp     finish
notFound:
        invoke  printf, strNotFound, [N]
        add     esp, 8
finish:
        call    [getch]

        push    0
        call    [ExitProcess]

;------------------------------------------------------------------------------------
; The procedure finds a substring in which each element less than previos one
; void strFindSubstring(string str, int len, int& idx)
; str - input message
; len - substring length
; idx - returned value, first index of substring or -1 if substring wasn't found
strFindSubstring:
        xor     al, al            ; delimeter = '\0'

        mov     esi, [esp+4]      ; using str[0] as source
        cmp     [esi], al         ; if length(str) == 0
        je      substrNotFound    ; not found

        mov     edi, [esp+4]      ; ...
        inc     edi               ; using str[1] as destination
        cmp     [edi], al         ; if length(str) == 1
        je      substrNotFound    ; not found

        mov     ecx, -1           ; ecx < 0 for loop
        mov     ebx, [esp+8]      ; ebx = N
        mov     edx, 1            ; curLen = 1
loopStrCmp:
        cmpsb                     ; if str[i] > str[i+1]
        jg      lessPrev
        mov     edx, 1            ; else curLen = 1
        jmp     endComp

lessPrev:
        inc     edx               ; curLen++
        cmp     edx, ebx          ; if curLen == N
        je      substrFound       ; str found

endComp:
        cmp     [edi], al         ; while str[i+1] != '\0'
        loopne  loopStrCmp
        jmp     substrNotFound    ; loop didn't find a substring
substrFound:
        neg     ecx               ; ecx = -ecx. Now ecx contains last index of a substring
        sub     ecx, ebx          ; ecx -= N
        inc     ecx               ; ecx++. Now ecx contains first index of a substring

        mov     ebx, [esp+12]
        mov     [ebx], ecx        ; idx = ecx
        ret
substrNotFound:
        mov     ebx, [esp+12]
        mov     dword [ebx], -1   ; idx = -1
        ret

;------------------------------------------------------------------------------------
; The procedure finds a substring in which each element less than previos one
; void getSubstring(string strInp, string strOut, int len, int idx)
; strInp - input message
; strOut - output message
; N - substring length
; idx - first index of substring in input message
getSubstring:
        mov     esi, [esp+4]      ; ...
        add     esi, [esp+16]     ; using strInp[idx] as source

        mov     edi, [esp+8]      ; using strOut as destination
        mov     ecx, [esp+12]     ; counter = N
loopCpy:
        movsb                     ; strOut[i] = strInp[idx+i]
        loop    loopCpy           ; counter--; while counter > 0

        ret
;-------------------------------------------------------------------------------------
                                                 
section '.idata' import data readable
    library kernel, 'kernel32.dll',\
            msvcrt, 'msvcrt.dll',\
            user32,'USER32.DLL'

include 'api\user32.inc'
include 'api\kernel32.inc'
    import kernel,\
           ExitProcess, 'ExitProcess'
  include 'api\kernel32.inc'
    import msvcrt,\
           printf, 'printf',\
           scanf, 'scanf',\
           getch, '_getch'