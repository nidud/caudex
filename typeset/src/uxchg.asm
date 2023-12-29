; UXCHG.ASM--
;
; Change glyps in codex.txt
;
; Example: UXCHG EFE7 A739+0301
;

include io.inc
include stdio.inc
include stdlib.inc
include string.inc
include tchar.inc

define WEOF 0xFFFF

.code

_xtol proc string:LPSTR

    ldr rdx,string
    xor eax,eax
    xor ecx,ecx

    .while 1

        mov cl,[rdx]
        and cl,0xDF

        .break .if cl < 0x10
        .break .if cl > 'F'

        .if cl > 0x19

            .break .if cl < 'A'
            sub cl,'A' - 0x1A
        .endif
        sub cl,0x10
        shl eax,4
        add eax,ecx
        add rdx,1
    .endw
    ret

_xtol endp

_tmain proc argc:int_t, argv:array_t

    .new fp:ptr FILE
    .new ft:ptr FILE
    .new file:string_t = "..\\codex.txt"
    .new bak[256]:char_t
    .new tmp[256]:char_t
    .new wc[6]:wchar_t
    .new count:int_t = 1
    .new numc:int_t = 0

    .if ( argc != 3 )

        printf("UXCHG UTF16 UTF16[+UTF16..]\n")
       .return( 1 )
    .endif
    ldr rsi,argv
    .if ( strrchr(strcpy(&bak, file), '.') )
        mov byte ptr [rax],0
    .endif
    strcpy(&tmp, &bak)
    strcat(&tmp, ".tmp")
    strcat(&bak, ".bak")
    _xtol([rsi+size_t])
    lea rdi,wc
    stosw
    _xtol([rsi+size_t*2])
    stosw
    .while ( byte ptr [rdx] == '+' )

        inc rdx
        _xtol(rdx)
        stosw
        inc count
    .endw

    .if ( fopen(file, "rb, ccs=UTF-16LE") == NULL )

        perror(file)
       .return 1
    .endif
    mov fp,rax

    .if ( fopen(&tmp, "wb, ccs=UTF-16LE") == NULL )

        perror(&tmp)
        fclose(fp)
       .return 1
    .endif
    mov ft,rax

    .while 1

        fgetwc(fp)
        .break .if ( ax == WEOF )
        .if ( ax == wc )
            .for ( rsi = &wc[2], ebx = 0 : ebx < count : ebx++ )

                movzx eax,word ptr [rsi]
                add rsi,2
                fputwc(ax, ft)
                inc numc
            .endf
        .else
            fputwc(ax, ft)
        .endif
    .endw

    fclose(ft)
    fclose(fp)
    remove(&bak)
    rename(file, &bak)
    rename(&tmp, file)
    printf("%d changed\n", numc)
    xor eax,eax
    ret

_tmain endp

    end _tstart
