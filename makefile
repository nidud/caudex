version = 2.0

Caudex-Regular.ttf:
	cd source
	fontforge -script Regular.pe $(version)
	fontforge -script Bold.pe $(version)
	fontforge -script Italic.pe $(version)
	fontforge -script BoldItalic.pe $(version)
