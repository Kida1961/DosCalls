# makefile -- Build doscalls.lib
# tools
#       masm.exe -- IBM Macro Assembler/2 Version 1.00
#       lib.exe  -- IBM Library Manager/2 Version 1.00 
#       maketc.exe -- GNU MAKE 3.71

AS = MASM.EXE
LINK = LINK.EXE
INCDIR = ..\\DosCalls
ASM = TSTCONIO.ASM TSTDIR.ASM TSTDISK.ASM TSTDTTM.ASM TSTFILE1.ASM

OBJ = TSTCONIO.OBJ TSTDIR.OBJ TSTDISK.OBJ TSTDTTM.OBJ TSTFILE1.OBJ

EXE = TSTCONIO.EXE TSTDIR.EXE TSTDISK.EXE TSTDTTM.EXE TSTFILE1.EXE

LIB = ..\\DosCalls\\DosCalls.Lib
INC = $(INCDIR)\\CONSTANT.INC

all : $(EXE)


.obj.asm:
	$(AS) $<;
	
.exe.obj:
	-$(LINK) $<,,NUL,$(LIB);


##
##
##TSTCONIO.EXE : TSTCONIO.ASM $(LIB) $(INC) 
##      $(AS) $<;
##      -$(LINK) TSTCONIO,,NUL,$(LIB);
##
##TSTDIR.EXE : TSTDIR.ASM $(LIB) $(INC) 
##      $(AS) $<;
##      -$(LINK) TSTDIR,,NUL,$(LIB);
##
##TSTDISK.EXE : TSTDISK.ASM $(LIB) $(INC) 
##      $(AS) $<;
##      -$(LINK) TSTDISK,,NUL,$(LIB);
##
##TSTDTTM.EXE : TSTDTTM.ASM $(LIB) $(INC) 
##      $(AS) $<;
##      -$(LINK) TSTDTTM,,NUL,$(LIB);
##
##TSTFILE1.EXE : TSTFILE1.ASM $(LIB) $(INC) 
##      $(AS) $<;
##      -$(LINK) TSTFILE1,,NUL,$(LIB);

.PHONY : clean

clean :
	-rm *.obj
	-rm *.exe
