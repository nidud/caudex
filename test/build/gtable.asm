; TABLE.ASM--
;
; Copyright (c) The Asmc Contributors. All rights reserved.
; Consult your license regarding permissions and restrictions.
;
; Creates a sorted glyph table from a .sfd file
;
include stdio.inc
include stdlib.inc
include string.inc
include tchar.inc

define MAXGLYPS 3000

.template GLYPH
    uni     int_t ?
    color   int_t ?
    width   int_t ?
    refs    int_t ?
    spline  int_t ?
    name    string_t ?
   .ends

.data
 table GLYPH MAXGLYPS dup(<0>)
 count int_t 0

.code

_xtol proc string:string_t

    ldr rdx,string
    xor eax,eax
    xor ecx,ecx

    .while 1

        mov cl,[rdx]
        add rdx,1
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
    .endw
    ret

_xtol endp

    assume rbx:ptr GLYPH

addglyph proc uses rbx b:string_t, fp:ptr FILE

    .if ( count >= MAXGLYPS )
        .return
    .endif

    lea rbx,table
    imul eax,count,GLYPH
    add rbx,rax
    inc count
    mov [rbx].color,-2
    mov [rbx].refs,0
    mov [rbx].spline,0

    ldr rdi,b
    .if ( strchr(rdi, ' ') )

        .for ( rax++, rcx = rax : byte ptr [rax] : rax++ )
            .if ( byte ptr [rax] <= ' ' )
                mov byte ptr [rax],0
                .break
            .endif
        .endf
        mov [rbx].name,_strdup(rcx)
    .endif

    .while ( fgets(b, 1024, fp) )

        .ifd ( memcmp(b, "EndChar", 7) == 0 )
            .break
        .endif
        .ifd ( memcmp(b, "Encoding:", 9) == 0 )

            mov [rbx].uni,atol(&[rdi+10])
        .endif
        .ifd ( memcmp(rdi, "Width:", 6) == 0 )

            mov [rbx].width,atol(&[rdi+7])
        .endif
        .ifd ( memcmp(rdi, "Colour:", 7) == 0 )

            mov [rbx].color,_xtol(&[rdi+8])
        .endif
        .ifd ( memcmp(rdi, "Refer:", 6) == 0 )

            inc [rbx].refs
        .endif
        .ifd ( memcmp(rdi, "SplineSet", 9) == 0 )

            inc [rbx].spline
        .endif

    .endw
    ret

addglyph endp

compare proc a:ptr, b:ptr

    ldr rcx,a
    ldr rdx,b
    xor eax,eax
    mov ecx,[rcx]
    cmp ecx,[rdx]
    mov ecx,-1
    seta al
    cmovb eax,ecx
    ret

compare endp

main proc argc:int_t, argv:array_t

    .new b[1024]:char_t
    .new target[256]:char_t

    .if ( argc < 2 )

        printf(
            "This creates a sorted glyph table from a .sfd file.\n"
            "Usage: table <source> [<target>]\n"
            "\n\n"
            "Example:\n"
            "table ../../src/build/glyphs.sfd glyphs.inc\n\n")
        .return( 0 )
    .endif

    mov rdx,argv
    mov rbx,[rdx+size_t]

    .if ( argc == 3 )

        strcpy(&target, [rdx+size_t*2])
    .else
        .if ( strrchr(strcpy(&target, rbx), '.') )
            mov byte ptr [rax],0
        .endif
        strcat(&target, ".inc")
        .if ( strrchr(rax, '/') )
            strcpy(&target, &[rax+1])
        .endif
        .if ( strrchr(&target, '\') )
            strcpy(&target, &[rax+1])
        .endif
    .endif

    .if ( fopen(rbx, "rt") == NULL )

        perror(rbx)
       .return 1
    .endif
    .new fp:ptr FILE = rax

    .while ( fgets(&b, lengthof(b), fp) )

        .ifd ( memcmp(&b, "StartChar:", 10) == 0 )

            addglyph(&b, fp)
        .endif
    .endw
    fclose(fp)

    qsort(&table, count, GLYPH, &compare)

    .if ( fopen(&target, "wt") == NULL )

        perror(&target)
       .return 1
    .endif
    mov fp,rax

    fprintf(fp,
        "include libc.inc\n"
        ".template GLYPH\n"
        "    uni     int_t ?\n"
        "    color   int_t ?\n"
        "    width   int_t ?\n"
        "    refs    int_t ?\n"
        "    spline  int_t ?\n"
        "    name    string_t ?\n"
        "   .ends\n"
        "T macro s\n"
        " exitm<@CStr(s)>\n"
        " endm\n"
        ".data\n"
        "glyphs GLYPH \\\n")

    .for ( rbx = &table : count : rbx+=GLYPH, count-- )


        .if ( [rbx].color == -2 )
            fprintf(fp, "{ 0x%04X, %8d, %4d, %d, %d, T(\"%s\") }",
                [rbx].uni, [rbx].color, [rbx].width, [rbx].refs, [rbx].spline, [rbx].name )
        .else
            fprintf(fp, "{ 0x%04X, 0x%06X, %4d, %d, %d, T(\"%s\") }",
                [rbx].uni, [rbx].color, [rbx].width, [rbx].refs, [rbx].spline, [rbx].name )
        .endif

        .if ( [rbx].uni >= 0xFB06 )

            fprintf(fp, "\n")
           .break
        .endif
        fprintf(fp, ",\n")
    .endf
    fclose(fp)
    xor eax,eax
    ret

main endp

    end _tstart
