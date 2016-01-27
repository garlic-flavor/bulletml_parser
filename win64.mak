## MACRO
TARGET = bulletml.exe
AUTHORS = KUMA
LICENSE = CC0
VERSION = 0.0003(dmd2.069)

MAKEFILE = win64.mak
DC = dmd
MAKE = make
TO_COMPILE = src\sworks\bulletml\ctbml.d src\sworks\base\aio.d src\sworks\base\ctfe.d src\sworks\base\dump_members.d src\sworks\base\factory.d src\sworks\base\matrix.d src\sworks\gl\bo.d src\sworks\gl\glsl.d src\sworks\gl\port.d src\sworks\gl\texture_2drgba32.d src\sworks\gl\util.d src\sworks\sdl\gl.d src\sworks\sdl\image.d src\sworks\sdl\port.d src\sworks\sdl\util.d src\sworks\util\cached_buffer.d src\sworks\xml.d
TO_LINK = src\sworks\bulletml\ctbml.obj src\sworks\base\aio.obj src\sworks\base\ctfe.obj src\sworks\base\dump_members.obj src\sworks\base\factory.obj src\sworks\base\matrix.obj src\sworks\gl\bo.obj src\sworks\gl\glsl.obj src\sworks\gl\port.obj src\sworks\gl\texture_2drgba32.obj src\sworks\gl\util.obj src\sworks\sdl\gl.obj src\sworks\sdl\image.obj src\sworks\sdl\port.obj src\sworks\sdl\util.obj src\sworks\util\cached_buffer.obj src\sworks\xml.obj
COMPILE_FLAG = -debug=bulletml -m64 -Jsample -Isrc;import
LINK_FLAG = -m64
EXT_LIB = lib64\DerelictGL3.lib lib64\DerelictSDL2.lib lib64\DerelictUtil.lib
DDOC_FILE = doc\src\main.ddoc
DOC_FILES = src\sworks\bulletml\ctbml.html src\sworks\base\aio.html src\sworks\base\ctfe.html src\sworks\base\dump_members.html src\sworks\base\factory.html src\sworks\base\matrix.html src\sworks\gl\bo.html src\sworks\gl\glsl.html src\sworks\gl\port.html src\sworks\gl\texture_2drgba32.html src\sworks\gl\util.html src\sworks\sdl\gl.html src\sworks\sdl\image.html src\sworks\sdl\port.html src\sworks\sdl\util.html src\sworks\util\cached_buffer.html src\sworks\xml.html
DOC_HEADER = doc\src\header.txt
DOC_FOOTER = doc\src\footer.txt
DOC_TARGET = doc/index.html
FLAG =

## LINK COMMAND
$(TARGET) : $(TO_LINK) $(EXT_LIB)
	$(DC) -g $(LINK_FLAG) $(FLAG) $(EXT_LIB) -of$@ $**

## COMPILE RULE
.d.obj :
	$(DC) -c -g -op -debug $(COMPILE_FLAG) $(FLAG) $<

## DEPENDENCE
$(TO_LINK) : $(MAKEFILE) $(EXT_LIB)
src\sworks\bulletml\ctbml.obj : src\sworks\sdl\port.d src\sworks\xml.d src\sworks\util\cached_buffer.d src\sworks\gl\port.d src\sworks\sdl\gl.d src\sworks\base\matrix.d src\sworks\gl\texture_2drgba32.d src\sworks\bulletml\ctbml.d src\sworks\gl\util.d src\sworks\base\factory.d src\sworks\base\aio.d src\sworks\gl\glsl.d src\sworks\sdl\util.d src\sworks\base\dump_members.d src\sworks\sdl\image.d src\sworks\base\ctfe.d src\sworks\gl\bo.d
src\sworks\base\aio.obj : src\sworks\base\aio.d
src\sworks\base\ctfe.obj : src\sworks\base\ctfe.d
src\sworks\base\dump_members.obj : src\sworks\base\dump_members.d
src\sworks\base\factory.obj : src\sworks\base\factory.d
src\sworks\base\matrix.obj : src\sworks\base\matrix.d
src\sworks\gl\bo.obj : src\sworks\gl\port.d src\sworks\gl\bo.d
src\sworks\gl\glsl.obj : src\sworks\gl\port.d src\sworks\gl\bo.d src\sworks\util\cached_buffer.d src\sworks\base\aio.d src\sworks\gl\glsl.d
src\sworks\gl\port.obj : src\sworks\gl\port.d
src\sworks\gl\texture_2drgba32.obj : src\sworks\gl\port.d src\sworks\gl\texture_2drgba32.d
src\sworks\gl\util.obj : src\sworks\util\cached_buffer.d src\sworks\gl\port.d src\sworks\base\matrix.d src\sworks\gl\util.d src\sworks\base\aio.d src\sworks\gl\glsl.d src\sworks\gl\bo.d
src\sworks\sdl\gl.obj : src\sworks\sdl\port.d src\sworks\util\cached_buffer.d src\sworks\gl\port.d src\sworks\sdl\gl.d src\sworks\base\matrix.d src\sworks\gl\texture_2drgba32.d src\sworks\gl\util.d src\sworks\sdl\util.d src\sworks\base\aio.d src\sworks\gl\glsl.d src\sworks\sdl\image.d src\sworks\gl\bo.d
src\sworks\sdl\image.obj : src\sworks\sdl\port.d src\sworks\base\aio.d src\sworks\sdl\util.d src\sworks\util\cached_buffer.d src\sworks\sdl\image.d
src\sworks\sdl\port.obj : src\sworks\sdl\port.d
src\sworks\sdl\util.obj : src\sworks\sdl\port.d src\sworks\sdl\util.d src\sworks\util\cached_buffer.d src\sworks\base\aio.d
src\sworks\util\cached_buffer.obj : src\sworks\util\cached_buffer.d src\sworks\base\aio.d
src\sworks\xml.obj : src\sworks\xml.d src\sworks\base\ctfe.d src\sworks\util\cached_buffer.d src\sworks\base\aio.d

## PHONY TARGET
debug-all :
	$(DC) -g -debug -of$(TARGET) $(COMPILE_FLAG) $(LINK_FLAG) $(TO_COMPILE) $(EXT_LIB) $(FLAG)
release :
	$(DC) -release -O -inline -of$(TARGET) $(COMPILE_FLAG) $(LINK_FLAG) $(TO_COMPILE) $(EXT_LIB) $(FLAG)
clean :
	del $(TARGET) $(TO_LINK)
clean_obj :
	del $(TO_LINK)
vwrite :
	vwrite --setversion "$(VERSION)" --project "$(TARGET)" --authors "$(AUTHORS)" --license "$(LICENSE)" $(TO_COMPILE)
ddoc :
	$(DC) -c -o- -op -D $(COMPILE_FLAG) $(DDOC_FILE) $(TO_COMPILE) $(FLAG)
	@type $(DOC_HEADER) $(DOC_FILES) $(DOC_FOOTER) > $(DOC_TARGET) 2>nul
      	@del $(DOC_FILES)
show :
	@echo ROOT = src\sworks\bulletml\ctbml.d
	@echo TARGET = $(TARGET)
	@echo VERSION = 0.0003(dmd2.069)
edit :
	emacs $(TO_COMPILE)
remake :
	amm -debug=bulletml -m64 win64.mak -Jsample bulletml.exe .\src\sworks\bulletml\ctbml.d "v=0.0003(dmd2.069)" AUTHORS=KUMA LICENSE=CC0 doc\src\main.ddoc doch=doc\src\header.txt docf=doc\src\footer.txt $(FLAG)

debug :
	ddbg $(TARGET)

## generated by amm.