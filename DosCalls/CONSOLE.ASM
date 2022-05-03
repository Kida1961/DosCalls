PAGE    ,132
TITLE   CONSOLE.ASM -- DOS Console I/O functions
%OUT    CONSOLE.ASM
INCLUDE CONSTANT.INC

@@ConsoleData   SEGMENT PARA
Buffer          DB      0
                DB      0
                DB      255 DUP(BLANK)
SaveBX          DW      -1
SaveCX          DW      -1
SaveDX          DW      -1
SaveSI          DW      -1
SaveDI          DW      -1
SaveBP          DW      -1
SaveDS          DW      -1
SaveES          DW      -1
@@ConsoleData   ENDS

@@DosCallsStack SEGMENT PARA STACK 'STACK'
                DB      6 DUP('#')
@@DosCallsStack ENDS

@@ConsoleCode   SEGMENT PARA PUBLIC '@@DosCallsCode'
                ASSUME  CS:@@ConsoleCode, DS:@@ConsoleData, ES:@@ConsoleData, SS:@@DosCallsStack

                PUBLIC  @@DosConInEcho
@@DosConInEcho  PROC    FAR     ; @char
                PUSH    DS
                MOV     AX, SEG SaveDS
                MOV     DS, AX
                POP     AX
                MOV     SaveDS, AX
                MOV     SaveBX, BX
                MOV     SaveBP, BP
                MOV     SaveDI, DI
                MOV     SaveES, ES

                MOV     BP, SP
                MOV     AH, 01H
                INT     21H
                MOV     BX, [BP+4]      ; SEGMENT @char
                MOV     ES, BX
                MOV     DI, [BP+6]      ; OFFSET @char
                MOV     BYTE PTR ES:[DI], AL

                MOV     BX, SEG SaveDS
                MOV     ES, BX
                MOV     DI, ES:SaveDI
                MOV     BX, ES:SaveBX
                MOV     BP, ES:SaveBP
                MOV     DS, ES:SaveDS
                MOV     ES, ES:SaveES
                RET     4
@@DosConInEcho  ENDP

                PUBLIC  @@DosDispOut
@@DosDispOut    PROC    FAR     ; @char
                PUSH    DS
                MOV     AX, SEG SaveDS
                MOV     DS, AX
                POP     AX
                MOV     SaveDS, AX
                MOV     SaveBX, BX
                MOV     SaveDX, DX
                MOV     SaveBP, BP
                MOV     SaveDI, DI
                MOV     SaveES, ES
                
                MOV     BP, SP
                MOV     AX, [BP+4]      ; SEGMENT @char
                MOV     ES, AX
                MOV     DI, [BP+6]      ; OFFSET @char
                MOV     DL, BYTE PTR ES:[DI]
                MOV     AH, 02H
                INT     21H
                
                MOV     BX, SEG SaveDS
                MOV     ES, BX
                MOV     DI, ES:SaveDI
                MOV     BP, ES:SaveBP
                MOV     DX, ES:SaveDX
                MOV     BX, ES:SaveBX
                MOV     DS, ES:SaveDS
                MOV     ES, ES:SaveES
                RET     4
@@DosDispOut    ENDP

                PUBLIC  @@DosAuxIn
@@DosAuxIn      PROC    FAR     ; @char
                PUSH    DS
                MOV     AX, SEG SaveDS
                MOV     DS, AX
                POP     AX
                MOV     SaveDS, AX
                MOV     SaveES, ES
                MOV     SaveDI, DI
                MOV     SaveBP, BP

                MOV     BP, SP
                MOV     AH, 03H
                INT     21H
                PUSH    AX              ; Save AL
                MOV     AX, [BP+4]      ; SEGMENT @char
                MOV     ES, AX
                MOV     DI, [BP+6]      ; OFFSET @char
                POP     AX              ; Restore AL
                MOV     BYTE PTR ES:[DI], AL

                MOV     BX, SEG SaveDS
                MOV     ES, BX
                MOV     BP, ES:SaveBP
                MOV     DI, ES:SaveDI
                MOV     DS, ES:SaveDS
                MOV     ES, ES:SaveES
                RET     4
@@DosAuxIn      ENDP

                PUBLIC  @@DosAuxOut
@@DosAuxOut     PROC    FAR     ; @char
                PUSH    DS
                MOV     AX, SEG SaveDS
                MOV     DS, AX
                POP     AX
                MOV     SaveDS, AX
                MOV     SaveBX, BX
                MOV     SaveDX, DX
                MOV     SaveDI, DI
                MOV     SaveES, ES
                MOV     SaveBP, BP

                MOV     BP, SP
                MOV     AX, [BP+4]      ; SEGMENT @char
                MOV     ES, AX
                MOV     DI, [BP+6]      ; OFFSET @char
                MOV     DL, BYTE PTR ES:[DI]
                MOV     AH, 04H
                INT     21H

                MOV     BX, SEG SaveDS
                MOV     ES, BX
                MOV     BP, ES:SaveBP
                MOV     BX, ES:SaveBX
                MOV     DX, ES:SaveDX
                MOV     DI, ES:SaveDI
                MOV     DS, ES:SaveDS
                MOV     ES, ES:SaveES
                RET     4
@@DosAuxOut     ENDP

                PUBLIC  @@DosPrnOut
@@DosPrnOut     PROC    FAR     ; @char
                PUSH    DS
                MOV     AX, SEG SaveDS
                MOV     DS, AX
                POP     AX
                MOV     SaveDS, AX
                MOV     SaveES, ES
                MOV     SaveBX, BX
                MOV     SaveDX, DX
                MOV     SaveDI, DI
                MOV     SaveBP, BP

                MOV     BP, SP
                MOV     AX, [BP+4]      ; SEGMENT @char
                MOV     ES, AX
                MOV     DI, [BP+6]      ; OFFSET @char
                MOV     DL, BYTE PTR ES:[DI]
                MOV     AH, 05H
                INT     21H

                MOV     BX, SEG SaveDS
                MOV     ES, BX
                MOV     BP, ES:SaveBP
                MOV     BX, ES:SaveBX
                MOV     DX, ES:SaveDX
                MOV     DI, ES:SaveDI
                MOV     BP, ES:SaveBP
                MOV     DS, ES:SaveDS
                MOV     ES, ES:SaveES
                RET     4
@@DosPrnOut    ENDP

                PUBLIC  @@DosDirectIn
@@DosDirectIn   PROC    FAR     ; @char
                PUSH    DS
                MOV     AX, SEG SaveDS
                MOV     DS, AX
                POP     AX
                MOV     SaveDS, AX
                MOV     SaveBX, BX
                MOV     SaveDI, DI
                MOV     SaveES, ES
                MOV     SaveBP, BP

                MOV     BP, SP
                MOV     DL, 0FFH
                MOV     AH, 06H
                INT     21H
                PUSH    AX              ; Save AL
                MOV     AX, [BP+4]      ; SEGMENT @char
                MOV     ES, AX
                MOV     DI, [BP+6]      ; OFFSET @char
                POP     AX              ; Restore AL
                MOV     BYTE PTR ES:[DI], AL

                MOV     BX, SEG SaveDS
                MOV     ES, BX
                MOV     BP, ES:SaveBP
                MOV     BX, ES:SaveBX
                MOV     DI, ES:SaveDI
                MOV     DS, ES:SaveDS 
                MOV     ES, ES:SaveES
                RET     4   
@@DosDirectIn   ENDP

                PUBLIC  @@DosDirectOut
@@DosDirectOut  PROC    FAR     ; @char
                PUSH    DS
                MOV     AX, SEG SaveDS
                MOV     DS, AX
                POP     AX
                MOV     SaveDS, AX
                MOV     SaveES, ES
                MOV     SaveDX, DX
                MOV     SaveDI, DI
                MOV     SaveBP, BP

                MOV     BP, SP
                MOV     AX, [BP+4]      ; SEGMENT @char
                MOV     ES, AX
                MOV     DI, [BP+6]      ; OFFSET @char
                MOV     DL, BYTE PTR ES:[DI]
                MOV     AH, 06H
                INT     21H

                MOV     BX, SEG SaveDS
                MOV     ES, BX
                MOV     BP, ES:SaveBP
                MOV     DX, ES:SaveDX
                MOV     DI, ES:SaveDI
                MOV     DS, ES:SaveDS
                MOV     ES, ES:SaveES
                RET     4
@@DosDirectOut  ENDP

                PUBLIC  @@DosDirectInWOEcho
@@DosDirectInWOEcho PROC FAR     ; @char
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
                MOV     AH, 07H
                INT     21H
                MOV     BX, [BP+4]      ; SEGMENT @char
                MOV     ES, BX
                MOV     DI, [BP+6]      ; OFFSET @char
                MOV     BYTE PTR ES:[DI], AL

                MOV     BX, SEG SaveDS
                MOV     ES, BX
                MOV     BP, ES:SaveBP
                MOV     BX, ES:SaveBX
                MOV     DI, ES:SaveDI
                MOV     DS, ES:SaveDS
                MOV     ES, ES:SaveES
                RET     4
@@DosDirectInWOEcho ENDP

                PUBLIC  @@DosConInWOEcho
@@DosConInWOEcho PROC   FAR     ; @char
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
                MOV     AH, 08H
                INT     21H
                MOV     BX, [BP+4]      ; SEGMENT @char
                MOV     ES, BX
                MOV     DI, [BP+6]      ; OFFSET @char
                MOV     BYTE PTR ES:[DI], AL

                MOV     BX, SEG SaveDS
                MOV     ES, BX
                MOV     BX, ES:SaveBX
                MOV     DI, ES:SaveDI
                MOV     BP, ES:SaveBP
                MOV     DS, ES:SaveDS
                MOV     ES, ES:SaveES
                RET     4
@@DosConInWOEcho ENDP

                PUBLIC  @@DosDispString
@@DosDispString PROC    FAR     ; @string
                PUSH    DS
                MOV     AX, SEG SaveDS
                MOV     DS, AX
                POP     AX
                MOV     SaveDS, AX
                MOV     SaveES, ES
                MOV     SaveBX, BX
                MOV     SaveDX, DX
                MOV     SaveBP, BP

                MOV     BP, SP
                MOV     AX, [BP+4]      ; SEGMENT @string
                MOV     DS, AX
                MOV     DX, [BP+6]      ; OFFSET @string
                MOV     AH, 09H
                INT     21H

                MOV     BX, SEG SaveDS
                MOV     ES, BX
                MOV     BX, ES:SaveBX
                MOV     DX, ES:SaveDX
                MOV     BP, ES:SaveBP
                MOV     DS, ES:SaveDS
                MOV     ES, ES:SaveES
                RET     4
@@DosDispString ENDP

                PUBLIC  @@DosBufKbdIn
@@DosBufKbdIn   PROC    FAR     ; @buffer @chars
                PUSH    DS
                MOV     AX, SEG SaveDS
                MOV     DS, AX
                POP     AX
                MOV     SaveDS, AX
                MOV     SaveES, ES 
                MOV     SaveBX, BX
                MOV     SaveCX, CX
                MOV     SaveDX, DX
                MOV     SaveSI, SI
                MOV     SaveDI, DI
                MOV     SaveBP, BP

                MOV     BP, SP
                MOV     Buffer, BYTE PTR MAXBUFFER
                LEA     DX, Buffer
                MOV     AH, 0AH
                INT     21H
                MOV     CX, 0
                MOV     CL, BYTE PTR Buffer+1
                MOV     BX, [BP+4]      ; SEGMENT @chars
                MOV     ES, BX
                MOV     DI, [BP+6]      ; OFFSET @chars
                MOV     ES:[DI], CX     ; Save character count
                LEA     SI, Buffer+2
                MOV     BX, [BP+8]      ; SEGMENT @buffer
                MOV     ES, BX
                MOV     DI, [BP+10]     ; OFFSET @buffer
                CLD
                REP MOVS BYTE PTR ES:[DI], DS:[SI]

                MOV     BX, SEG SaveDS
                MOV     ES, BX
                MOV     BX, ES:SaveBX
                MOV     CX, ES:SaveCX
                MOV     DX, ES:SaveDX
                MOV     SI, ES:SaveSI
                MOV     DI, ES:SaveDI
                MOV     BP, ES:SaveBP
                MOV     DS, ES:SaveDS
                MOV     ES, ES:SaveES 
                RET     8   
@@DosBufKbdIn   ENDP

                PUBLIC  @@DosKbdStatus
@@DosKbdStatus  PROC    FAR     ; @status
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
                MOV     AH, 0BH
                INT     21H
                MOV     BX, [BP+4]      ; SEGMENT @status
                MOV     ES, BX
                MOV     DI, [BP+6]      ; OFFSET @status
                MOV     BYTE PTR ES:[DI], AL

                MOV     BX, SEG SaveDS
                MOV     ES, BX
                MOV     BX, ES:SaveBX
                MOV     DI, ES:SaveDI
                MOV     BP, ES:SaveBP
                MOV     DS, ES:SaveDS
                MOV     ES, ES:SaveES
                RET     4   
@@DosKbdStatus  ENDP

                PUBLIC  @@DosClrKbdBuf
@@DosClrKbdBuf  PROC    FAR
                PUSH    DS
                MOV     AX, SEG SaveDS
                MOV     DS, AX
                POP     AX
                MOV     SaveDS, AX
                MOV     SaveDX, DX

                MOV     DL, 0FFH
                MOV     AL, 06H
                MOV     AH, 0CH
                INT     21H

                MOV     DX, SaveDX
                MOV     DS, SaveDS
                RET 
@@DosClrKbdBuf  ENDP
@@ConsoleCode   ENDS
                END
