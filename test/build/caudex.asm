; CAUDEX.ASM--
;
; Copyright (c) The Caudex Contributors. All rights reserved.
; Consult your license regarding permissions and restrictions.
;

include stdio.inc
include stdlib.inc
include string.inc
include tchar.inc

include caudex.inc

.code

header proc fp:LPFILE, css:string_t

    fprintf(fp,
        "<!DOCTYPE html>\n"
        "<html>\n"
        "<head>\n"
        "<title>Caudex</title>\n"
        "<link href='%s' rel='stylesheet' type='text/css'>\n"
        "<style>\n"
        "td {\n"
        "  text-align: center;\n"
        "  color: black;\n"
        "  background: white;\n"
        "}\n"
        "body:has(input[value='Regular']:checked) {\n"
        "  font-family: 'caudex';\n"
        "  font-weight: 400;\n"
        "  font-style: normal;\n"
        "}\n"
        "body:has(input[value='Bold']:checked) {\n"
        "  font-family: 'Caudex', serif;\n"
        "  font-weight: 700;\n"
        "  font-style: normal;\n"
        "}\n"
        "body:has(input[value='Italic']:checked) {\n"
        "  font-family: 'Caudex', serif;\n"
        "  font-weight: 400;\n"
        "  font-style: italic;\n"
        "}\n"
        "body:has(input[value='BoldItalic']:checked) {\n"
        "  font-family: 'Caudex', serif;\n"
        "  font-weight: 700;\n"
        "  font-style: italic;\n"
        "}\n"
        ".c {\n"
        "  font-size: 300%%;\n"
        "  width: 12%;\n"
        "}\n"
        ".u {\n"
        "  padding: 0;\n"
        "}\n"
        ".r {\n"
        "  padding: 0;\n"
        "  background: #FF0000;\n"
        "}\n"
        ".g {\n"
        "  padding: 0;\n"
        "  background: #00FF00;\n"
        "}\n"
        ".b {\n"
        "  padding: 0;\n"
        "  background: #00FFFF;\n"
        "}\n"
        ".y {\n"
        "  padding: 0;\n"
        "  background: #FFFF00;\n"
        "}\n"
        "</style>\n"
        "</head>\n"
        "<body>\n"
        "Caudex Version 2.0\n"
        "<div class='c'>Caudex Font</div>\n"
        "<input type='radio' id='font' name='font' value='Regular' checked='checked' ><label>Regular</label>\n"
        "<input type='radio' id='font' name='font' value='Bold'><label>Bold</label>\n"
        "<input type='radio' id='font' name='font' value='Italic'><label>Italic</label>\n"
        "<input type='radio' id='font' name='font' value='BoldItalic'><label>Bold Italic</label>\n", css )
    ret

header endp

main proc argc:int_t, argv:array_t

    .new n:int_t
    .new css:string_t = "../css/local/caudex.css"

    .if ( argc > 1 )
        mov rdx,argv
        mov css,[rdx+string_t]
    .endif
    .if ( fopen("../caudex.htm", "wt") == NULL )

        perror("../caudex.htm")
       .return 1
    .endif
    .new fp:ptr FILE = rax

    header(fp, css)
    fprintf(fp, "<table border=1 cellspacing=0 cellpadding=20>\n")

    .new i:int_t, j:int_t
    .for ( i = 0 : i < lengthof(glyphs) : i += 8 )

        mov eax,i
        add eax,8
        .while ( eax >= lengthof(glyphs) )
           dec eax
        .endw
        sub eax,i
        mov n,eax

        assume rbx:ptr GLYPH

        fprintf(fp, "<tr>\n")

        imul ebx,i,GLYPH
        lea rax,glyphs
        add rbx,rax
        .for ( j = 0 : j < n : j++, rbx+=GLYPH )

            mov eax,[rbx].color
            mov ecx,'u'
            .switch pascal eax
            .case 0xFF0000 : mov ecx,'r'
            .case 0x00FF00 : mov ecx,'g'
            .case 0x00FFFF : mov ecx,'b'
            .case 0xFFFF00 : mov ecx,'y'
            .endsw
            fprintf(fp, " <td class='%c'>%04X</td>\n", ecx, [rbx].uni)
        .endf
        fprintf(fp, "</tr>\n")

        fprintf(fp, "<tr>\n")
        imul ebx,i,GLYPH
        lea rax,glyphs
        add rbx,rax
        .for ( j = 0 : j < n : j++, rbx+=GLYPH )

            fprintf(fp, " <td class='c'>&#x%04X;</td>\n", [rbx].uni)
        .endf
        fprintf(fp, "</tr>\n")
    .endf
    fprintf(fp,
        "</table>\n"
        "</body>\n"
        "</html>\n")
    fclose(fp)
    ret

main endp

    end _tstart
