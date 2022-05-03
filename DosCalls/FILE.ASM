PAGE    ,132
TITLE   FILE.ASM -- File I/O related functions
%OUT    FILE.ASM
INCLUDE CONSTANT.INC

@@DosCallsData  SEGMENT PARA
DriveLetters    DB      "ABCDEFGHIJKLMNOPQRSTUVWXYZ", EOS
DriveNumbers    DB      0,1,2,3,4,5,6,7,8,9
                DB      10,11,12,13,14,15,16,17,18,19
                DB      20,21,22,23,24,25
SaveBP          DW      -1
SaveBX          DW      -1
SaveCX          DW      -1
SaveDX          DW      -1
SaveSI          DW      -1
SaveDI          DW      -1
SaveDS          DW      -1
SaveES          DW      -1
@@DosCallsData  ENDS

@@DosCallsStack SEGMENT PARA STACK 'STACK'
                DB      16 DUP('$')
@@DosCallsStack ENDS

@@FileCode      SEGMENT PARA
                ASSUME  CS:@@FileCode, DS:@@DosCallsData, ES:@@DosCallsData, SS:@@DosCallsStack
        
DrvNumToLtr     PROC    ; AL: DriveNumber/DriveLetter
                MOV     BX, 0
                MOV     BL, AL
                MOV     AX, SEG DriveLetters
                MOV     ES, AX
                MOV     SI, OFFSET DriveLetters
                MOV     AL, BYTE PTR ES:[SI+BX]
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

                PUBLIC  @@DosSetDTA
@@DosSetDTA     PROC    FAR     ; @newDTA
                PUSH    DS
                MOV     AX, SEG SaveDS
                MOV     DS, AX
                POP     AX
                MOV     SaveDS, AX
                MOV     SaveBP, BP
                MOV     SaveBX, BX

                MOV     BP, SP
                MOV     AX, [BP+4]      ; SEGMENT @newDTA
                MOV     DS, AX
                MOV     DX, [BP+6]      ; OFFSET @newDta
                MOV     AH, 1AH
                INT     21H

                MOV     BX, SEG SaveDS
                MOV     DS, BX
                MOV     BP, SaveBP
                MOV     BX, SaveBX
                MOV     DS, SaveDS
                RET     4
@@DosSetDTA     ENDP

                PUBLIC  @@DosGetDTA
@@DosGetDTA     PROC    FAR     ; @curDTA
                PUSH    DS
                MOV     AX, SEG SaveDS
                MOV     DS, AX
                POP     AX
                MOV     SaveDS, AX
                MOV     SaveBP, BP
                MOV     SaveBX, BX

                MOV     BP, SP
                MOV     AH, 2FH
                INT     21H
                PUSH    ES              ; Save ES
                MOV     AX, [BP+4]      ; SEGMENT @curDTA
                MOV     DS, AX
                MOV     DI, [BP+6]      ; OFFSET @curDTA
                MOV     DS:[DI], BX     ; Current DTA SEGMENT
                POP     ES              ; Restore ES
                MOV     DS:[DI+2], ES   ; Current DTA OFFSET

                MOV     BX, SEG SaveDS
                MOV     ES, BX
                MOV     BP, ES:SaveBP
                MOV     BX, ES:SaveBX
                MOV     DS, ES:SaveDS
                RET     4
@@DosGetDTA     ENDP

                PUBLIC  @@DosCreat
@@DosCreat      PROC    FAR     ; @name, @attribure, @handle
                PUSH    DS
                MOV     AX, SEG SaveDS
                MOV     DS, AX
                POP     AX
                MOV     SaveDS, AX
                MOV     SaveBP, BP

                MOV     BP, SP
                MOV     AX, [BP+8]      ; SEGMENT @attribute 
                MOV     ES, AX
                MOV     SI, [BP+10]     ; OFFSET @attribute
                MOV     CX, ES:[SI]     ; Set @attribute
                MOV     DX, [BP+14]     ; OFFSET @name
                MOV     AX, [BP+12]     ; SEGMENT @name
                MOV     DS, AX
                MOV     AH, 3CH
                INT     21H
                MOV     BX, [BP+4]      ; SEGMENT @handle
                MOV     ES, BX
                MOV     DI, [BP+6]      ; OFFSET @handle
                MOV     ES:[DI], AX

                MOV     BX, SEG SaveDS
                MOV     ES, BX
                MOV     BP, ES:SaveBP
                MOV     DS, ES:SaveDS
                RET     12
@@DosCreat      ENDP

                PUBLIC  @@DosOpen 
@@DosOpen       PROC    FAR     ; @name, @mode, @handle
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
                MOV     AX, [BP+12]     ; SEGMENT @name
                MOV     DS, AX
                MOV     DX, [BP+14]     ; OFFSET @name
                MOV     AX, [BP+8]      ; SEGMENT @mode      
                MOV     ES, AX
                MOV     DI, [BP+10]     ; OFFSET @mode
                MOV     AL, BYTE PTR ES:[DI]    ; Set @mode
                MOV     AH, 3DH
                INT     21H
                MOV     BX, [BP+4]      ; SEGMENT @handle
                MOV     ES, BX
                MOV     DI, [BP+6]      ; OFFSET @handle
                MOV     ES:[DI], AX

                MOV     BX, SEG SaveDS
                MOV     ES, BX
                MOV     BP, ES:SaveBP
                MOV     BX, ES:SaveBX
                MOV     DI, ES:SaveDI
                MOV     DS, ES:SaveDS
                MOV     ES, ES:SaveES
                RET     12
@@DosOpen       ENDP

                PUBLIC  @@DosClose
@@DosClose      PROC    FAR     ; @handle
                PUSH    DS
                MOV     AX, SEG SaveDS
                MOV     DS, AX
                POP     AX
                MOV     SaveDS, AX
                MOV     SaveES, ES
                MOV     SaveBP, BP
                MOV     SaveBX, BX
                MOV     SaveSI, SI

                MOV     BP, SP
                MOV     AX, [BP+4]      ; SEGMENT @handle
                MOV     ES, AX
                MOV     SI, [BP+6]      ; OFFSET @handle
                MOV     BX, ES:[SI]   
                MOV     AH, 3EH
                INT     21H

                MOV     AX, SEG SaveDS
                MOV     DS, AX
                MOV     BP, SaveBP
                MOV     BX, SaveBX
                MOV     SI, SaveSI
                MOV     ES, SaveES
                MOV     DS, SaveDS
                RET     4
@@DosClose      ENDP

                PUBLIC  @@DosRead
@@DosRead       PROC    FAR     ; @handle, @buffer, @chars
                PUSH    DS
                MOV     AX, SEG SaveDS
                MOV     DS, AX
                POP     AX
                MOV     SaveDS, AX
                MOV     SaveBP, BP
                MOV     SaveBX, BX
                MOV     SaveCX, CX
                MOV     SaveDX, DX
                MOV     SaveDI, DI
                MOV     SaveES, ES

                MOV     BP, SP
                MOV     AX, [BP+4]      ; 読みだしバイト数設定   
                MOV     ES, AX
                MOV     DI, [BP+6]    
                MOV     CX, ES:[DI]     ; 読みだしバイト数設定
                MOV     AX, [BP+8]    
                MOV     DS, AX
                MOV     DX, [BP+10]     ; 書込み先バッファー設定
                MOV     AX, [BP+12]   
                MOV     ES, AX
                MOV     AX, [BP+14]     ; ハンドル設定
                MOV     DI, AX
                MOV     BX, ES:[DI]   
                MOV     AH, 3FH
                INT     21H
                MOV     BX, [BP+4]      ; SEGMENT @chars
                MOV     ES, BX
                MOV     DI, [BP+6]      ; OFFSET @chars
                MOV     ES:[DI], AX     ; 読みだしたバイト数を保管

                MOV     BX, SEG SaveDS
                MOV     DS, BX
                MOV     BP, SaveBP
                MOV     BX, SaveBX
                MOV     CX, SaveCX
                MOV     DX, SaveDX
                MOV     DI, SaveDI
                MOV     ES, SaveES
                MOV     DS, SaveDS
                RET     12
@@DosRead       ENDP

                PUBLIC  @@DosWrite
@@DosWrite      PROC    FAR     ; @handle, @buffer, @chars
                PUSH    DS
                MOV     AX, SEG SaveDS
                MOV     DS, AX
                POP     AX
                MOV     SaveDS, AX
                MOV     SaveBP, BP
                MOV     SaveBX, BX
                MOV     SaveCX, CX
                MOV     SaveES, ES
                MOV     SaveSI, SI

                MOV     BP, SP
                MOV     AX, [BP+4]      ; SEGMENT @chars
                MOV     ES, AX
                MOV     SI, [BP+6]      ; OFFSET @chars
                MOV     CX, ES:[SI]
                MOV     AX, [BP+8]      ; SEGMENT @buffer 
                MOV     DS, AX
                MOV     DX, [BP+10]     ; OFFSET @buffer
                MOV     AX, [BP+12]     ; SEGMENT @handle
                MOV     ES, AX
                MOV     AX, [BP+14]     ; OFFSET @handle
                MOV     SI, AX
                MOV     BX, ES:[SI]
                MOV     AH, 40H
                INT     21H
                MOV     BX, [BP+4]      ; SEGMENT @chars
                MOV     ES, BX
                MOV     SI, [BP+6]      ; OFFSET @chars
                MOV     ES:[SI], AX

                MOV     BX, SEG SaveDS
                MOV     DS, BX
                MOV     BP, SaveBP
                MOV     BX, SaveBX 
                MOV     CX, SaveCX 
                MOV     ES, SaveES 
                MOV     SI, SaveSI
                MOV     DS, SaveDS
                RET     12
@@DosWrite      ENDP

                PUBLIC  @@DosDelete
@@DosDelete     PROC    FAR     ; @name
                PUSH    DS
                MOV     AX, SEG SaveDS
                MOV     DS, AX
                POP     AX
                MOV     SaveDS, AX
                MOV     SaveBX, BX
                MOV     SaveBP, BP
                
                MOV     BP, SP
                MOV     AX, [BP+4]      ; SEGMENT @name
                MOV     DS, AX
                MOV     DX, [BP+6]      ; OFFSET @name
                MOV     AH, 41H
                INT     21H
                
                MOV     BX, SEG SaveDS
                MOV     ES, BX
                MOV     BP, ES:SaveBP
                MOV     DS, ES:SaveDS
                RET     4
@@DosDelete     ENDP

                PUBLIC  @@DosLSeek
@@DosLSeek      PROC    FAR     ; @handle, @offset, @methods
                PUSH    DS
                MOV     AX, SEG SaveDS
                MOV     DS, AX
                POP     AX
                MOV     SaveDS, AX
                MOV     SaveBP, BP
                MOV     BP, SP
                MOV     AX, [BP+12]     ; SEGMENT @handle
                MOV     ES, AX
                MOV     DI, [BP+14]     ; OFFSET @handle
                MOV     BX, ES:[DI]
                MOV     AX, [BP+8]      ; SEGMENT @offset
                MOV     ES, AX
                MOV     DI, [BP+10]     ; OFFSET @offset
                MOV     DX, ES:[DI] 
                MOV     CX, ES:[DI+2]
                MOV     AX, [BP+4]      ; SEGMENT @methods
                MOV     ES, AX
                MOV     DI, [BP+6]      ; OFFSET @methods
                MOV     AL, BYTE PTR ES:[DI]
                MOV     AH, 42H
                INT     21H
                PUSH    AX              ; Save AX
                MOV     AX, [BP+8]      ; SEGMENT @offset
                MOV     ES, AX
                MOV     DI, [BP+10]     ; OFFSET @offset
                POP     AX              ; Restore AX
                MOV     ES:[DI], AX 
                MOV     ES:[DI+2], DX
                MOV     BX, SEG SaveDS
                MOV     ES, BX
                MOV     BP, ES:SaveBP
                MOV     DS, ES:SaveDS
                RET     12
@@DosLSeek      ENDP

                PUBLIC  @@DosChmod
@@DosChmod      PROC    FAR     ; @name, @mod
                PUSH    DS
                MOV     AX, SEG SaveDS
                MOV     DS, AX
                POP     AX
                MOV     SaveDS, AX
                MOV     SaveES, ES
                MOV     SaveDI, DI
                MOV     SaveBX, BX
                MOV     SaveCX, CX
                MOV     SaveDX, DX
                MOV     SaveBP, BP
                
                MOV     BP, SP
                MOV     BX, [BP+4]      ; SEGMENT @mod  
                MOV     ES, BX
                MOV     DI, [BP+6]      ; OFFSET @mod
                MOV     CX, ES:[DI]
                MOV     BX, [BP+8]      ; SEGMENT @name
                MOV     DS, BX
                MOV     DX, [BP+10]     ; OFFSET @neme
                MOV     AL, 1
                MOV     AH, 43H
                INT     21H
                
                MOV     BX, SEG SaveDS
                MOV     ES, BX
                MOV     BP, ES:SaveBP
                MOV     DI, ES:SaveDI
                MOV     DX, ES:SaveDX
                MOV     CX, ES:SaveCX
                MOV     BX, ES:SaveBX
                MOV     DS, ES:SaveDS
                MOV     ES, ES:SaveES
                RET     8
@@DosChmod      ENDP

                PUBLIC  @@DosGetmod
@@DosGetmod     PROC    FAR     ; @name, @mode
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
                MOV     BX, [BP+8]      ; SEGMENT @name
                MOV     DS, BX
                MOV     DX, [BP+10]     ; OFFSET @name
                MOV     AL, 0
                MOV     AH, 43H
                INT     21H
                MOV     BX, [BP+4]      ; SEGMENT @mode
                MOV     ES, BX
                MOV     DI, [BP+6]      ; OFFSET @mode
                MOV     ES:[DI], CX
                
                MOV     BX, SEG SaveDS
                MOV     ES, BX
                MOV     BP, ES:SaveBP
                MOV     DI, ES:SaveDI
                MOV     BX, ES:SaveBX
                MOV     DS, ES:SaveDS
                MOV     ES, ES:SaveES
                RET     8
@@DosGetmod     ENDP

                PUBLIC  @@DosFindFirst
@@DosFindFirst  PROC    FAR     ; @name, @attr
                PUSH    DS
                MOV     AX, SEG SaveDS
                MOV     DS, AX
                POP     AX
                MOV     SaveDS, AX
                MOV     SaveBP, BP
                MOV     BP, SP
                MOV     AX, [BP+8]      ; SEGMENT @name
                MOV     DS, AX
                MOV     DX, [BP+10]     ; OFFSET @name
                MOV     AX, [BP+4]      ; SEGMENT @attr
                MOV     ES, AX
                MOV     DI, [BP+6]      ; OFFSET @attr
                MOV     CX, ES:[DI]
                MOV     AH, 4EH
                INT     21H
                MOV     BX, SEG SaveDS
                MOV     ES, BX
                MOV     BP, ES:SaveBP
                MOV     DS, ES:SaveDS
                RET     8
@@DosFindFirst  ENDP

                PUBLIC  @@DosFindNext
@@DosFindNext   PROC    FAR     
                MOV     AH, 4FH
                INT     21H
                RET     
@@DosFindNext   ENDP

                PUBLIC  @@DosRename
@@DosRename     PROC    FAR     ; @curName, @newName
                PUSH    DS
                MOV     AX, SEG SaveDS
                MOV     DS, AX
                POP     AX
                MOV     SaveDS, AX
                MOV     SaveBP, BP
                MOV     BP, SP
                MOV     AX, [BP+8]      ; SEGMENT @curName
                MOV     DS, AX
                MOV     DX, [BP+10]     ; OFFSET @curName
                MOV     AX, [BP+4]      ; SEGMENT @newName
                MOV     ES, AX
                MOV     DI, [BP+6]      ; OFFSET @newName
                MOV     AH, 56H
                INT     21H
                MOV     BX, SEG SaveDS
                MOV     ES, BX
                MOV     BP, ES:SaveBP
                MOV     DS, ES:SaveDS
                RET     8
@@DosRename     ENDP

                PUBLIC  @@DosSetTimeStamp
@@DosSetTimestamp PROC FAR      ; @handle, @Date, @time
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
                MOV     AX, [BP+4]      ; SEGMENT @time
                MOV     ES, AX
                MOV     DI, [BP+6]      ; OFFSET @time
                MOV     CX, ES:[DI]     ; Time
                MOV     AX, [BP+8]      ; SEGMENT @Date
                MOV     ES, AX
                MOV     DI, [BP+10]     ; OFFSET @Date
                MOV     DX, ES:[DI]     ; Date
                MOV     AX, [BP+12]     ; SEGMENT @handle
                MOV     ES, AX
                MOV     DI, [BP+14]     ; OFFSET @handle
                MOV     BX, ES:[DI]     ; Handle
                MOV     AL, 1
                MOV     AH, 57H
                INT     21H
                
                MOV     BX, SEG SaveDS
                MOV     ES, BX
                MOV     BP, ES:SaveBP
                MOV     BX, ES:SaveBX
                MOV     CX, ES:SaveCX
                MOV     DX, ES:SaveDX
                MOV     DI, ES:SaveDI
                MOV     DS, ES:SaveDS
                MOV     ES, ES:SaveES
                RET     12
@@DosSetTimestamp ENDP

                PUBLIC  @@DosGetTimeStamp
@@DosGetTimestamp PROC FAR      ; @handle, @Date, @time
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
                MOV     AX, [BP+12]      ; SEGMENT @handle
                MOV     ES, AX
                MOV     DI, [BP+14]     ; OFFSET @handle
                MOV     BX, ES:[DI]
                MOV     AL, 0
                MOV     AH, 57H
                INT     21H
                MOV     BX, [BP+4]      ; SEGMENT @time
                MOV     ES, BX
                MOV     DI, [BP+6]      ; OFFSET @time
                MOV     ES:[DI], CX     ; Time
                MOV     BX, [BP+8]      ; SEGMENT @Date
                MOV     ES, BX
                MOV     DI, [BP+10]     ; OFFSET @Date
                MOV     ES:[DI], DX     ; Date

                MOV     BX, SEG SaveDS
                MOV     ES, BX
                MOV     BP, ES:SaveBP
                MOV     BX, ES:SaveBX
                MOV     CX, ES:SaveCX
                MOV     DX, ES:SaveDX
                MOV     DI, ES:SaveDI
                MOV     DS, ES:SaveDS
                MOV     ES, ES:SaveES
                RET     12
@@DosGetTimestamp ENDP
@@FileCode      ENDS
                END
