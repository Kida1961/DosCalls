PAGE    ,132
TITLE   MISC.ASM -- Miscellaneous functions
%OUT    MISC.ASM
INCLUDE CONSTANT.INC

@@MiscData      SEGMENT PARA
DriveLetters    DB      "ABCDEFGHIJKLMNOPQRSTUVWXYZ", EOS
DriveNumbers    DB      0,1,2,3,4,5,6,7,8,9
                DB      10,11,12,13,14,15,16,17,18,19
                DB      20,21,22,23,24,25
IntVec          DW      -1
                DW      -1
SaveBP          DW      -1
SaveBX          DW      -1
SaveCX          DW      -1
SaveDX          DW      -1
SaveSI          DW      -1
SaveDI          DW      -1
SaveDS          DW      -1
SaveES          DW      -1
@@MiscData      ENDS

@@DosCallsStack SEGMENT PARA STACK 'STACK'
                DB      16 DUP('$')
@@DosCallsStack ENDS

@@MiscCode      SEGMENT PARA 
                ASSUME  CS:@@MiscCode, DS:@@MiscData, ES:@@MiscData, SS:@@DosCallsStack
        
DrvNumToLtr     PROC    ; AL: DriveNumber/DriveLetter
                MOV     BX, 0
                MOV     BL, AL
                DEC     BL
                LEA     DI, DriveLetters
                MOV     AL, BYTE PTR [DI+BX]
                RET
DrvNumToLtr     ENDP
        
DrvLtrToNum     PROC    ; AL: DriveLetter/DriveNumber
                CMP     AL,'Z'
                JLE     Skip1
                CMP     AL, 'a'
                JL      Skip1
                CMP     AL, 'z'
                JG      Skip1
                SUB     AL, 'a'-'A'
Skip1:
                SUB     AL,'A'
                RET
DrvLtrToNum     ENDP

                PUBLIC  @@DosSetIntVect
@@DosSetIntVect PROC    FAR     ; @intType @vect
                PUSH    DS
                MOV     AX, SEG SaveDS
                MOV     DS, AX
                POP     AX
                MOV     SaveDS, AX
                MOV     SaveES, ES
                MOV     SaveDI, DI
                MOV     SaveBP, BP
                
                MOV     BP, SP
                MOV     AX, [BP+4]      ; SEGMENT @vect
                MOV     ES, AX
                MOV     DI, [BP+6]      ; OFFSET @vect
                MOV     DX, ES:[DI]
                MOV     AX, ES:[DI+2]
                MOV     DS, AX
                MOV     AX, [BP+8]      ; SEGMENT @intType
                MOV     ES, AX
                MOV     DI, [BP+10]     ; OFFSET @intType
                MOV     AL, BYTE PTR ES:[DI] 
                MOV     AH, 25H
                INT     21H
                
                MOV     BX, SEG SaveDS
                MOV     ES, BX
                MOV     BP, ES:SaveBP
                MOV     DI, ES:SaveDI
                MOV     DS, ES:SaveDS
                MOV     ES, ES:SaveES
                RET     8
@@DosSetIntVect ENDP
        
                PUBLIC  @@DosGetBreak
@@DosGetBreak   PROC    FAR     ; @status
                PUSH    DS
                MOV     AX, SEG SAveDS
                MOV     DS, AX
                POP     AX
                MOV     SaveDS, AX
                MOV     SaveES, ES
                MOV     SaveDI, DI
                MOV     SaveBX, BX
                MOV     SaveBP, BP
                
                MOV     BP, SP
                MOV     AL, 00H
                MOV     AH, 33H
                INT     21H
                MOV     BX, [BP+4]      ; SEGMENT @status
                MOV     ES, BX
                MOV     DI, [BP+6]      ; OFFSET @status
                MOV     BYTE PTR ES:[DI], DL
                
                MOV     BX, SEG SaveDS
                MOV     ES, BX
                MOV     BP, ES:SaveBP
                MOV     DI, ES:SaveDI
                MOV     BX, ES:SaveBX
                MOV     DS, ES:SaveDS
                MOV     ES, ES:SaveES
                RET     4   
@@DosGetBreak   ENDP

                PUBLIC  @@DosSetVerify
@@DosSetVerify  PROC    FAR
                PUSH    DS
                MOV     AX, SEG SaveDS
                MOV     DS, AX
                POP     AX
                MOV     SaveDS, AX
                MOV     SaveES, ES
                MOV     SaveBX, BX
                MOV     SaveDX, DX
                
                MOV     DL, 0
                MOV     AL, 1
                MOV     AH, 2EH
                INT     21H
                
                MOV     BX, SEG SaveDS
                MOV     ES, BX
                MOV     DX, ES:SaveDX
                MOV     BX, ES:SaveBX
                MOV     DS, ES:SaveDS
                MOV     ES, ES:SaveES
                RET
@@DosSetVerify  ENDP

                PUBLIC  @@DosResetVerify
@@DosResetVerify PROC   FAR
                PUSH    DS
                MOV     AX, SEG SaveDS
                MOV     DS, AX
                POP     AX
                MOV     SaveDS, AX
                MOV     SaveES, ES
                MOV     SaveBX, BX
                MOV     SaveDX, DX
                
                MOV     DL, 0
                MOV     AL, 0
                MOV     AH, 2EH
                INT     21H
                
                MOV     BX, SEG SaveDS
                MOV     ES, BX
                MOV     BX, ES:SaveBX
                MOV     DX, ES:SaveDX
                MOV     DS, ES:SaveDS
                MOV     ES, ES:SaveES
                RET
@@DosResetVerify ENDP

                PUBLIC  @@DosVersion
@@DosVersion    PROC    FAR     ; @major @minor
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
                MOV     AH, 30H
                INT     21H
                MOV     BX, [BP+4]      ; SEGMENT @minor
                MOV     ES, BX
                MOV     DI, [BP+6]      ; OFFSET @minor
                MOV     BYTE PTR ES:[DI], AH
                MOV     BX, [BP+8]      ; SEGMENT @major
                MOV     ES, BX
                MOV     DI, [BP+10]     ; OFFSET @major
                MOV     BYTE PTR ES:[DI], AL
                
                MOV     BX, SEG SaveDS
                MOV     ES, BX
                MOV     BP, ES:SaveBP
                MOV     BX, ES:SaveBX
                MOV     DI, ES:SaveDI
                MOV     DS, ES:SaveDS
                MOV     ES, ES:SaveES
                RET     8   
@@DosVersion    ENDP

                PUBLIC  @@DosSetBreak
@@DosSetBreak   PROC    FAR     ; @status
                PUSH    DS
                MOV     AX, SEG SaveDS
                MOV     DS, AX
                POP     AX
                MOV     SaveDS, AX
                MOV     SaveES, ES
                MOV     SaveDI, DI
                MOV     SaveBX, BX
                MOV     SaveDX, DX
                MOV     SaveBP, BP
                
                MOV     BP, SP
                MOV     AL, 01H
                MOV     DL, 01H
                MOV     AH, 33H
                INT     21H
                MOV     AX, [BP+4]      ; SEGMENT @status
                MOV     ES, AX
                MOV     DI, [BP+6]      ; OFFSET @status
                MOV     BYTE PTR ES:[DI], DL
                
                MOV     BX, SEG SaveDS
                MOV     ES, BX
                MOV     BP, ES:SaveBP
                MOV     BX, ES:SaveBX
                MOV     DX, ES:SaveDX
                MOV     DI, ES:SaveDI
                MOV     DS, ES:SaveDS
                MOV     ES, ES:SaveES
                RET     4   
@@DosSetBreak   ENDP

                PUBLIC  @@DosResetBreak
@@DosResetBreak PROC    FAR     ; @status
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
                MOV     AL, 01H
                MOV     DL, 00H
                MOV     AH, 33H
                INT     21H
                MOV     BX, [BP+4]      ; SEGMENT @status
                MOV     ES, BX
                MOV     DI, [BP+6]      ; OFFSET @status
                MOV     BYTE PTR ES:[DI], DL
                
                MOV     BX, SEG SaveDS
                MOV     ES, BX
                MOV     BP, ES:SaveBP
                MOV     DX, ES:SaveDX
                MOV     DI, ES:SaveDI
                MOV     DS, ES:SaveDS
                MOV     ES, ES:SaveES
                RET    
@@DosResetBreak ENDP

                PUBLIC  @@DosBootDrive
@@DosBootDrive  PROC    FAR     ; @drvLtr
                PUSH    DS                               
                MOV     AX, SEG SaveDS
                MOV     DS, AX
                POP     AX
                MOV     SaveDS, AX
                MOV     SaveES, ES
                MOV     SaveBX, BX
                MOV     SaveDX, DX
                MOV     SaveSI, SI
                MOV     SaveDI, DI
                MOV     SaveBP, BP
                
                MOV     BP, SP
                MOV     AL, 05H
                MOV     AH, 33H
                INT     21H
                PUSH    AX              ; Save AX
                MOV     AL, DL
                CALL    DrvNumToLtr
                MOV     BX, [BP+4]
                MOV     ES, BX
                MOV     DI, [BP+6]
                MOV     BYTE PTR ES:[DI], AL
                POP     AX              ; Restore AX
                
                MOV     BX, SEG SaveDS
                MOV     ES, BX
                MOV     BP, ES:SaveBP
                MOV     BX, ES:SaveBX
                MOV     DX, ES:SaveDX
                MOV     SI, ES:SaveSI
                MOV     DI, ES:SaveDI
                MOV     DS, ES:SaveDS
                MOV     ES, ES:SaveES
                RET     4   
@@DosBootDrive  ENDP

                PUBLIC  @@DosGetIntVect
@@DosGetIntVect PROC    FAR     ; @intType @vect
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
                MOV     AX, [BP+8]      ; SEGMENT @intType
                MOV     ES, AX
                MOV     DI, [BP+10]     ; OFFSET @intType
                MOV     AL, BYTE PTR ES:[DI]
                MOV     AH, 35H
                INT     21H
                MOV     IntVec, BX      ; Save BX
                MOV     IntVec+2, ES    ; Save ES
                MOV     BX, [BP+4]      ; SEGMENT @vect
                MOV     ES, BX
                MOV     DI, [BP+6]      ; OFFSET @vect
                MOV     BX, IntVec
                MOV     ES:[DI], BX
                MOV     BX, IntVec+2
                MOV     ES:[DI+2], BX
                
                MOV     BX, SEG SaveDS
                MOV     ES, BX
                MOV     BP, ES:SaveBP
                MOV     BX, ES:SaveBX
                MOV     DI, ES:SaveDI
                MOV     DS, ES:SaveDS
                MOV     ES, ES:SaveES
                RET     8
@@DosGetIntVect ENDP

                PUBLIC  @@DosGetCountryInfo
@@DosGetCountryInfo PROC FAR    ; @countryInfo
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
                MOV     AX, [BP+4]      ; SEGMENT @countryInfo
                MOV     DS, AX
                MOV     DX, [BP+6]      ; OFFSET @countryInfo
                MOV     AL, 00H
                MOV     AH, 38H
                INT     21H
                
                MOV     BX, SEG SaveDS
                MOV     ES, BX
                MOV     BP, ES:SaveBP
                MOV     BX, ES:SaveBX
                MOV     DX, ES:SaveDX
                MOV     DS, ES:SaveDS
                MOV     ES, ES:SaveES
                RET     4
@@DosGetCountryInfo ENDP

                PUBLIC  @@DosVerifyStatus
@@DosVerifyStatus PROC  FAR     ; @status
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
                MOV     AH, 54H
                INT     21H
                MOV     BX, [BP+4]      ; SEGMENT @status
                MOV     ES, BX
                MOV     DI, [BP+6]      ; OFFSET @status
                MOV     BYTE PTR ES:[DI], AL
                
                MOV     BX, SEG SaveDS
                MOV     ES, BX
                MOV     BP, ES:SaveBP
                MOV     BX, ES:SaveBX
                MOV     DI, ES:SaveDI
                MOV     DS, ES:SaveDS
                MOV     ES, ES:SaveES
                RET     4
@@DosVerifyStatus ENDP

                PUBLIC  @@DosGetPSP
@@DosGetPSP     PROC    FAR     ; @psp
                PUSH    DS                               
                MOV     AX, SEG SaveDS
                MOV     DS, AX
                POP     AX
                MOV     SaveDS, AX
                MOV     SaveES, ES
                MOV     SaveDI, DI
                MOV     SaveBX, BX
                MOV     SaveCX, CX
                MOV     SaveBP, BP
                
                MOV     BP, SP
                MOV     AH, 62H
                INT     21H
                MOV     CX, [BP+4]      ; SEGMENT @psp
                MOV     ES, CX
                MOV     DI, [BP+6]      ; OFFSET @psp
                MOV     ES:[DI], BX
                
                MOV     BX, SEG SaveDS
                MOV     ES, BX
                MOV     BP, ES:SaveBP
                MOV     DI, ES:SaveDI
                MOV     BX, ES:SaveBX
                MOV     CX, ES:SaveCX
                MOV     DS, ES:SaveDS
                MOV     ES, ES:SaveES
                RET     4   
@@DosGetPSP     ENDP
@@MiscCode      ENDS
                END
