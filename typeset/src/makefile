static = 0

utohtm.exe:
!if $(static)
    asmc -win64 utohtm.asm
    linkw system con_64 file utohtm.obj
    asmc -win64 urange.asm
    linkw system con_64 file urange.obj
    asmc -win64 uxchg.asm
    linkw system con_64 file uxchg.obj
!else
    asmc -win64 -pe utohtm.asm
    asmc -win64 -pe urange.asm
    asmc -win64 -pe uxchg.asm
!endif
