all: gtable clean

gtable:
	fontforge -quiet -script wfonts.pe
ifdef YACC
	asmc64 -fpic gtable.asm
	gcc -o gtable gtable.o
	./gtable ../../src/build/glyphs.sfd glyphs.inc
	./gtable ../../src/build/caudex.sfd modify.inc
	./gtable ../../src/caudex-2.0.sfd caudex.inc
	asmc64 -fpic glyphs.asm
	asmc64 -fpic modify.asm
	asmc64 -fpic caudex.asm
	asmc64 -fpic uexchg.asm
	asmc64 -fpic urange.asm
	asmc64 -fpic utohtm.asm
	gcc -o gtable gtable.o
	gcc -o modify modify.o
	gcc -o caudex caudex.o
	./glyphs "https://cdn.jsdelivr.net/gh/nidud/caudex/css/glyphs.css"
	./modify "https://cdn.jsdelivr.net/gh/nidud/caudex/css/modify.css"
	./caudex "https://cdn.jsdelivr.net/gh/nidud/caudex/css/caudex.css"
else
	asmc64 -pe gtable.asm
	gtable ../../src/build/glyphs.sfd glyphs.inc
	gtable ../../src/build/caudex.sfd modify.inc
	gtable ../../src/caudex-2.0.sfd caudex.inc
	asmc64 -pe glyphs.asm
	asmc64 -pe modify.asm
	asmc64 -pe caudex.asm
	asmc64 -pe uexchg.asm
	asmc64 -pe urange.asm
	asmc64 -pe utohtm.asm
	glyphs "https://cdn.jsdelivr.net/gh/nidud/caudex/css/glyphs.css"
	modify "https://cdn.jsdelivr.net/gh/nidud/caudex/css/modify.css"
	caudex "https://cdn.jsdelivr.net/gh/nidud/caudex/css/caudex.css"
endif


clean:
ifdef YACC
	rm *.o
endif

