; UTOHTM.ASM--
;
; Converts a Unicode text file (codex.txt) to codex.htm
;
include io.inc
include stdio.inc
include stdlib.inc
include tchar.inc

.code

main proc

    .new buf[256]:wchar_t
    .new htm:ptr FILE = 0
    .new txt:ptr FILE = 0
    .new c:uint_t
    .new page:int_t = 0
    .new line:int_t = 1
    .new xl:int_t = 0

    .if ( fopen("../codex.txt", "rt, ccs=UTF-16LE") == NULL )

        perror("../codex.txt")
       .return 1
    .endif
    mov txt,rax

    .if ( fopen("../codex.htm", "wt+") == NULL )

        perror("../codex.htm")
        fclose(txt)
       .return 1
    .endif
    mov htm,rax

    ;
    ;
    ; "<title>GKS 2365 4to</title>\n"
    ; "<link href='http://fonts.googleapis.com/css?family=Caudex' rel='stylesheet' type='text/css'>\n"
    ;
    fprintf(htm,
        "<html>\n"
        "<head>\n"
        "<title>GKS 2365 4to</title>\n"
        "<link href='https://github.com/nidud/caudex/raw/main/css/style.css' rel='stylesheet' type='text/css'>\n"
        "<style>\n"
        " body  { font-family: 'Caudex', serif; font-size: 48px; }\n"
        " table { font-size: 38px; }\n"
        " a     { text-decoration:none; }\n"
        "</style>\n"
        "</head>\n"
        "<body>\n"
        "GKS 2365 4to\n"
        "<blockquote>\n"
        )

    .while ( fgetws(&buf, lengthof(buf), txt) )

        lea rsi,buf

        .continue .if buf == 10

        .while ( wchar_t ptr [rsi] )

            movzx eax,wchar_t ptr [rsi]
            add rsi,wchar_t

            .switch eax
            .case 0x0D
               .endc
            .case 0x0A
                inc xl
                fprintf(htm, "<br>\n")
               .endc
            .case 0x09
                fprintf(htm, "&#x2003;")
               .endc
            .case '{'
                mov xl,0
                mov line,1
                .if ( page )
                    fprintf(htm, "</table>\n<br>\n")
                .endif
                inc page
                fprintf(htm,
                    "<table border=0 cellspacing=0 cellpadding=5>\n"
                    "<tr valign=top>\n"
                    "<td align=right><a href=\"https://github.com/nidud/caudex/raw/main/typeset/img/page_%02d.jpg\">%d</a></td>\n"
                    "<td align=left>&#x2003;\n"
                    "<br><br><br><br>&#xF735;<br>\n"
                    "<br><br><br><br>&#xF731;&#xF730;<br>\n"
                    "<br><br><br><br>&#xF731;&#xF735;<br>\n"
                    "<br><br><br><br>&#xF732;&#xF730;<br>\n",
                    page, page)
                .if ( page != 90 )
                    fprintf(htm,
                        "<br><br><br><br>&#xF732;&#xF735;<br>\n"
                        "<br><br><br><br>&#xF733;&#xF730;<br>\n")
                .endif
                fprintf(htm, "<td nowrap>\n<a name=\"R%02d01\"></a>", page)
               .break
            .default
                mov c,eax
                .if ( xl )
                    mov xl,0
                    inc line
                    fprintf(htm, "<a name=\"R%02d%02d\"></a>", page, line)
                .endif
                .if ( c < 128 )
                    fputc(c, htm)
                .else
                    fprintf(htm, "&#x%04X;", c)
                .endif
            .endsw
        .endw
    .endw

    fprintf(htm, "</table>\n</body>\n</html>\n")
    fclose(htm)
    fclose(txt)
    ret

main endp

    end _tstart

