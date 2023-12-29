; URANGE.ASM--
;
; Creates a range list (range.txt) of glyphs used in codex.txt
;

include stdio.inc
include stdlib.inc
include tchar.inc

.data
 table wchar_t 1000 dup(0)
 count int_t 0

.code

addwc proc wc:int_t

    ldr eax,wc
    lea rdx,table

    .for ( ecx = 0 : ecx < count : ecx++ )

        .return .if ( ax == [rdx+rcx*2] )
    .endf
    .if ( ecx < 1000 )

        mov [rdx+rcx*2],ax
        inc count
    .endif
    ret

addwc endp

compare proc a:ptr, b:ptr

    ldr rcx,a
    ldr rdx,b
    xor eax,eax
    mov ax,[rcx]
    cmp ax,[rdx]
    mov eax,0
    mov ecx,-1
    seta al
    cmovb eax,ecx
    ret

compare endp

_tmain proc

    .if ( fopen("..\\codex.txt", "rt, ccs=UTF-16LE") == NULL )

        perror("..\\codex.txt")
       .return 1
    .endif
    .new fp:ptr FILE = rax
    .while 1

        fgetwc(fp)
        .break .if ( ax == 0xFFFF )

        addwc(eax)
    .endw

    fclose(fp)
    qsort(&table, count, 2, &compare)

    .if ( fopen("range.txt", "wt, ccs=UTF-16LE") == NULL )

        perror("range.txt")
       .return 1
    .endif
    .for ( ebx = 0 : ebx < count : ebx++ )

        lea rdx,table
        movzx eax,wchar_t ptr [rdx+rbx*2]
        fwprintf(fp, L"%04X %c\n", eax, eax)
    .endf

    fclose(fp)
    ret

_tmain endp

    end _tstart
