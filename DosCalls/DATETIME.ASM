PAGE    ,132
TITLE   DATETIME.ASM -- Disk I/O functions
%OUT    DATETIME.ASM

INCLUDE DosCalls.def

@@DateTimeData  SEGMENT PARA
SaveBX          DW      -1
SaveCX          DW      -1
SaveDX          DW      -1
SaveSI          DW      -1
SaveDI          DW      -1
SaveDS          DW      -1
SaveES          DW      -1
SaveBP          DW      -1
@@DateTimeData  ENDS

@@DosCallsStack SEGMENT PARA STACK 'STACK'
                DB      16 DUP('$')
@@DosCallsStack ENDS

@@DateTimeCode  SEGMENT PARA PUBLIC '@@DosCallsCode'
                ASSUME  CS:@@DateTimeCode, DS:@@DateTimeData, ES:@@DateTimeData, SS:@@DosCallsStack

                PUBLIC  @@DosGetDate
@@DosGetDate    PROC    FAR     ; @DosDate
                PUSH    DS
                MOV     AX, SEG SaveDS
                MOV     DS, AX
                POP     AX
                MOV     SaveDS, AX
                MOV     SaveES, ES
                MOV     SaveBX, BX
                MOV     SaveCX, CX
                MOV     SaveDX, DX
                MOV     SaveDI, DI
                MOV     SaveBP, BP

                MOV     BP, SP
                MOV     AH, 2AH
                INT     21H
                MOV     BX, [BP+4]      ; SEGMENT @date
                MOV     ES, BX
                MOV     DI, [BP+6]      ; OFFSET @date
                MOV     WORD PTR ES:[DI], CX
                MOV     BYTE PTR ES:[DI+2], DH
                MOV     BYTE PTR ES:[DI+3], DL

                MOV     BX, SEG SaveDS
                MOV     ES, BX
                MOV     BP, ES:SaveBP
                MOV     BX, ES:SaveBX
                MOV     CX, ES:SaveCX
                MOV     DX, ES:SaveDX
                MOV     DI, ES:SaveDI
                MOV     DS, ES:SaveDS
                MOV     ES, ES:SaveES
                RET     4
@@DosGetDate    ENDP

                PUBLIC  @@DosSetDate
@@DosSetDate    PROC    FAR     ; @date
                PUSH    DS
                MOV     AX, SEG SaveDS
                MOV     DS, AX
                POP     AX
                MOV     SaveDS, AX
                MOV     SaveBP, BP
                MOV     SaveDI, DI
                MOV     SaveCX, CX
                MOV     SaveDX, DX
                MOV     SaveES, ES

                MOV     BP, SP
                MOV     BX, [BP+4]      ; SEGMENT @date
                MOV     ES, BX
                MOV     DI, [BP+6]      ; OFFSET @date
                MOV     CX, WORD PTR ES:[DI]
                MOV     DH, BYTE PTR ES:[DI+2]
                MOV     DL, BYTE PTR ES:[DI+3]
                MOV     AH, 2BH
                INT     21H

                MOV     BX, SEG SaveDS
                MOV     ES, BX
                MOV     BP, ES:SaveBP
                MOV     DI, ES:SaveDI
                MOV     CX, ES:SaveCX
                MOV     DX, ES:SaveDX
                MOV     DS, ES:SaveDS
                MOV     ES, ES:SaveES
                RET     4  
@@DosSetDate    ENDP

                PUBLIC  @@DosGetTime
@@DosGetTime    PROC    FAR     ; @time
                PUSH    DS
                MOV     AX, SEG SaveDS
                MOV     DS, AX
                POP     AX
                MOV     SaveDS, AX
                MOV     SaveBP, BP
                
                MOV     AH, 2CH
                INT     21H
                MOV     BX, AX          ; Save AX
                MOV     BP, SP
                MOV     AX, [BP+4]      ; SEGMENT @time
                MOV     ES, AX
                MOV     SI, [BP+6]      ; OFFSET @time
                MOV     BYTE PTR ES:[SI], CH
                MOV     BYTE PTR ES:[SI+1], CL
                MOV     BYTE PTR ES:[SI+2], DH
                MOV     BYTE PTR ES:[SI+3], DL
                
                MOV     BX, SEG SaveDS
                MOV     ES, BX
                MOV     BP, ES:SaveBP
                MOV     DS, ES:SaveDS
                RET     4
@@DosGetTime    ENDP

                PUBLIC  @@DosSetTime
@@DosSetTime    PROC    FAR     ; @time
                PUSH    DS
                MOV     AX, SEG SaveDS
                MOV     DS, AX
                POP     AX
                MOV     SaveDS, AX
                MOV     SaveES, ES
                MOV     SaveBX, BX
                MOV     SaveCX, CX
                MOV     SaveDX, DX
                MOV     SaveDI, DI
                MOV     SaveBP, BP

                MOV     BP, SP
                MOV     BX, [BP+4]      ; SEGMENT @time
                MOV     ES, BX
                MOV     DI, [BP+6]      ; OFFSET @time
                MOV     CH, BYTE PTR ES:[DI]
                MOV     CL, BYTE PTR ES:[DI+1]
                MOV     DH, BYTE PTR ES:[DI+2]
                MOV     DL, BYTE PTR ES:[DI+3]
                MOV     AH, 2DH
                INT     21H

                MOV     BX, SEG SaveDS
                MOV     ES, BX
                MOV     BX, ES:SaveBX
                MOV     CX, ES:SaveCX
                MOV     DX, ES:SaveDX
                MOV     DI, ES:SaveDI
                MOV     DS, ES:SaveDS
                MOV     ES, ES:SaveES
                MOV     BP, ES:SaveBP
                RET     4
@@DosSetTime    ENDP
@@DateTimeCode  ENDS
                END
