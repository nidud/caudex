; UEXCHG.ASM--
;
; Change glyps in codex.txt
;
; Example: UEXCHG EFE7 A739+0301
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

dumpwc proc uses rbx fp:LPFILE, wp:ptr wchar_t, count:int_t

    .for ( rbx = wp : count > 0 : count-- )

        movzx eax,word ptr [rbx]
        add rbx,2
        fputwc(ax, fp)
    .endf
    ret

dumpwc endp

_tmain proc argc:int_t, argv:array_t

    .new fp:ptr FILE
    .new ft:ptr FILE
    .new file:string_t = "..\\codex.txt"
    .new bak[256]:char_t
    .new tmp[256]:char_t
    .new wc1[16]:wchar_t
    .new wct[16]:wchar_t
    .new wc2[16]:wchar_t
    .new cnt1:int_t = 1
    .new cnt2:int_t = 1
    .new numc:int_t = 0

    .if ( argc != 3 )

        printf("UEXCHG UTF16[+UTF16..] UTF16[+UTF16..]\n")
       .return( 1 )
    .endif

    .if ( strrchr(strcpy(&bak, file), '.') )
        mov byte ptr [rax],0
    .endif
    strcpy(&tmp, &bak)
    strcat(&tmp, ".tmp")
    strcat(&bak, ".bak")

    mov rbx,argv
    _xtol([rbx+size_t])
    lea rbx,wc1
    mov [rbx],ax
    add rbx,2
    .while ( byte ptr [rdx] == '+' )

        inc rdx
        _xtol(rdx)
        mov [rbx],ax
        add rbx,2
        inc cnt1
    .endw

    mov rbx,argv
    _xtol([rbx+size_t*2])
    lea rbx,wc2
    mov [rbx],ax
    add rbx,2
    .while ( byte ptr [rdx] == '+' )

        inc rdx
        _xtol(rdx)
        mov [rbx],ax
        add rbx,2
        inc cnt2
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

        .if ( ax == wc1 )


            .for ( wct = ax, ebx = 1 : ebx < cnt1 : ebx++ )

                fgetwc(fp)
                mov wct[rbx*2],ax

                .if ( ax == WEOF || ax != wc1[rbx*2] )


                    dumpwc(ft, &wct, ebx)

                   .break( 1 ) .if ( wct[rbx*2] == WEOF )
                   .continue( 1 )
                .endif
            .endf
            dumpwc(ft, &wc2, cnt2)
            add numc,cnt2
           .continue
        .endif
        fputwc(ax, ft)
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
