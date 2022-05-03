PAGE    ,132
TITLE   DIR.ASM -- Disk I/O functions
%OUT    DIR.ASM
INCLUDE CONSTANT.INC

@@DosCallsData  SEGMENT PARA
DriveLetters    DB      "ABCDEFGHIJKLMNOPQRSTUVWXYZ", EOS
DriveNumbers    DB      0,1,2,3,4,5,6,7,8,9
                DB      10,11,12,13,14,15,16,17,18,19
                DB      20,21,22,23,24,25
SaveBP          DW      -1
SaveBX          DW      -1
SaveDX          DW      -1
SaveSI          DW      -1
SaveDI          DW      -1
SaveDS          DW      -1
SaveES          DW      -1
@@DosCallsData  ENDS

@@DosCallsStack SEGMENT PARA STACK 'STACK'
                DB      16 DUP('$')
@@DosCallsStack ENDS

@@DirCode       SEGMENT PARA
                ASSUME  CS:@@DirCode, DS:@@DosCallsData, ES:@@DosCallsData, SS:@@DosCallsStack
        
DrvNumToLtr     PROC    ; AL: DriveNumber/DriveLetter
                MOV     BX, 0
                MOV     BL, AL
                MOV     AX, SEG DriveLetters
                MOV     ES, AX
                MOV     SI, OFFSET DriveLetters
                ADD     SI, BX
                MOV     AL, ES:[SI]
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

                PUBLIC  @@DosMkdir
@@DosMkdir      PROC    FAR     ; @path
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
                MOV     AX, [BP+4]      ; SEGMENT @path
                MOV     DX, [BP+6]      ; OFFSET @path
                MOV     DS, AX
                MOV     AH, 39H
                INT     21H

                MOV     BX, SEG SaveDS
                MOV     ES, BX
                MOV     BP, ES:SaveBP
                MOV     BX, ES:SaveBX  
                MOV     DX, ES:SaveDX  
                MOV     DS, ES:SaveDS
                MOV     ES, ES:SaveES  
                RET     4
@@DosMkdir      ENDP
        
                PUBLIC  @@DosRmdir
@@DosRmdir      PROC    FAR     ; @path
                PUSH    DS
                MOV     AX, SEG SaveDS
                MOV     DS, AX
                POP     AX
                MOV     SaveDS, AX
                MOV     SaveBP, BP
                MOV     BP, SP
                MOV     AX, [BP+4]      ; SEGMENT @path
                MOV     DS, AX
                MOV     DX, [BP+6]      ; OFFSET @path
                MOV     AH, 3AH
                INT     21H
                MOV     BX, SEG SaveDS
                MOV     ES, BX
                MOV     BP, ES:SaveBP
                MOV     DS, ES:SaveDS
                RET     4
@@DosRmdir      ENDP
        
                PUBLIC  @@DosChdir
@@DosChdir      PROC    FAR     ; @path
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
                MOV     AX, [BP+4]      ; SEGMENT @path
                MOV     DX, [BP+6]      ; OFFSET @path
                MOV     DS, AX
                MOV     AH, 3BH
                INT     21H

                MOV     BX, SEG SaveDS
                MOV     ES, BX
                MOV     BP, ES:SaveBP
                MOV     BX, ES:SaveBX
                MOV     DX, ES:SaveDX
                MOV     DS, ES:SaveDS
                MOV     ES, ES:SaveES
                RET     4
@@DosChdir      ENDP

                PUBLIC  @@DosCurDir
@@DosCurDir     PROC    FAR     ; @drive @directory
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
                MOV     AX, [BP+8]      ; SEGMENT @drive 
                MOV     ES, AX
                MOV     DI, [BP+10]     ; OFFSET @drive
                MOV     AL, BYTE PTR ES:[DI]
                CMP     AL, BYTE PTR BLANK
                JNE     DosCurDir1
                MOV     AL, BYTE PTR 0
                JMP     DosCurDir2
DosCurDir1:
                CALL    DrvLtrToNum
                INC     AL
DosCurDir2:   
                MOV     DL, AL
                MOV     SI, [BP+6]      ; OFFSET @directory
                MOV     AX, [BP+4]      ; SEGMENT @directory
                MOV     DS, AX
                MOV     AH, 47H
                INT     21H

                MOV     BX, SEG SaveDS
                MOV     ES, BX
                MOV     BP, ES:SaveBP
                MOV     BX, ES:SaveBX
                MOV     DX, ES:SaveDX
                MOV     SI, ES:SaveSI
                MOV     DI, ES:SaveDI
                MOV     DS, ES:SaveDS
                MOV     ES, ES:SaveES
                RET     8
@@DosCurDir     ENDP
@@DirCode       ENDS
                END
