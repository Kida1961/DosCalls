PAGE    ,132
TITLE   MEMORY.ASM -- DOS Memory Managemnt
%OUT    MEMORY.ASM

@@MemoryData    SEGMENT PARA
SaveDS          DW      -1
SaveES          DW      -1
SaveBX          DW      -1
SaveCX          DW      -1
SaveDX          DW      -1
SaveSI          DW      -1
SaveDI          DW      -1
SaveBP          DW      -1
@@MemoryData    ENDS

@@DosCallsStack SEGMENT PARA STACK 'STACK'
                DB      6 dup('#')
@@DosCallsStack ENDS

@@MemoryCode    SEGMENT PARA PUBLIC '@@DosCallsCode'
                ASSUME  CS:@@MemoryCode, DS:@@MemoryData, ES:@@MemoryData, SS:@@DosCallsStack

                PUBLIC  @@DosAlloc
@@DosAlloc      PROC    FAR     ; @size @memseg @maxparas
                PUSH    DS
                MOV     AX, SEG SaveDS
                MOV     DS, AX
                POP     AX
                MOV     SaveDS, AX
                MOV     SaveES, ES
                MOV     SaveBX, BX
                MOV     SaveCX, CX
                MOV     SaveDI, DI
                MOV     SaveBP, BP
                
                MOV     BP, SP
                MOV     AX, [BP+12]      ; SEGMENT @size
                MOV     ES, AX
                MOV     DI, [BP+14]      ; OFFSET @size
                MOV     BX,ES:[DI]
                MOV     AH, 48H
                INT     21H
                MOV     CX, [BP+8]      ; SEGMENT @memseg
                MOV     ES, CX
                MOV     DI, [BP+10]     ; OFFSET @memseg
                MOV     WORD PTR ES:[DI], AX
                MOV     CX, [BP+4]      ; SEGMENT @maxparas
                MOV     ES, CX
                MOV     DI, [BP+6]      ; OFFSET @maxparas
                MOV     WORD PTR ES:[DI], BX

                MOV     BX, SEG SaveDS
                MOV     ES, BX
                MOV     BX, ES:SaveBX
                MOV     CX, ES:SaveCX
                MOV     DI, ES:SaveDI
                MOV     DS, ES:SaveDS
                MOV     ES, ES:SaveES
                RET     12 
@@DosAlloc      ENDP

                PUBLIC  @@DosDealloc
@@DosDealloc    PROC    FAR     ; @block
                PUSH    DS
                MOV     AX, SEG SaveDS
                MOV     DS, AX
                POP     AX
                MOV     SaveDS, AX
                MOV     SaveES, ES
                MOV     SaveBX, BX
                MOV     SaveDI, DI
                MOV     SaveBP, BP
                
                MOV     BP, SP
                MOV     AX, [BP+4]      ; SEGMENT @block
                MOV     ES, AX
                MOV     DI, [BP+6]      ; OFFSET @block
                MOV     ES, ES:[DI]
                MOV     AH, 49H
                INT     21H
                
                MOV     BX, SEG SaveDS
                MOV     ES, BX
                MOV     BP, ES:SaveBP
                MOV     BX, ES:SaveBX
                MOV     DI, ES:SaveDI
                MOV     DS, ES:SaveDS
                MOV     ES, ES:SaveES
                RET     4
@@DosDealloc    ENDP

                PUBLIC  @@DosSetblock
@@DosSetblock   PROC    FAR     ; @block, @newsize, @maxparas
                PUSH    DS
                MOV     AX, SEG SaveDS
                MOV     DS, AX
                POP     AX
                MOV     SaveDS, AX
                MOV     SaveES, ES
                MOV     SaveBX, BX
                MOV     SaveCX, CX
                MOV     SaveDI, DI
                MOV     SaveBP, BP
                
                MOV     BP, SP
                MOV     AX, [BP+8]      ; SEGMENT @newsize
                MOV     ES, AX
                MOV     AX, [BP+10]     ; OFFSET @newsize
                MOV     DI, AX
                MOV     BX, ES:[DI]
                MOV     AX, [BP+12]      ; SEGMENT @block
                MOV     ES, AX
                MOV     AX, [BP+14]     ; OFFSET @block
                MOV     DI, AX
                MOV     ES, ES:[DI]
                MOV     AH, 4AH
                INT     21H
                MOV     CX, [BP+4]      ; SEGMENT @maxparas
                MOV     ES, CX
                MOV     DI, [BP+6]      ; OFFSET @maxparas
                MOV     WORD PTR ES:[DI], BX

                MOV     BX, SEG SaveDS
                MOV     ES, BX
                MOV     DS, ES:SaveDS
                MOV     BX, ES:SaveBX
                MOV     CX, ES:SaveCX
                MOV     DI, ES:SaveDI
                MOV     ES, ES:SaveES
                MOV     BP, ES:SaveBP
                RET     12
@@DosSetblock   ENDP
@@MemoryCode    ENDS
                END
