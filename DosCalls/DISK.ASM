PAGE    ,132
TITLE   DISK.ASM -- Disk I/O functions
%OUT    DISK.ASM
INCLUDE CONSTANT.INC

@@DiskData      SEGMENT PARA
DriveLetters    DB      "ABCDEFGHIJKLMNOPQRSTUVWXYZ", EOS
DriveNumbers    DB      0,1,2,3,4,5,6,7,8,9
                DB      10,11,12,13,14,15,16,17,18,19
                DB      20,21,22,23,24,25
                        ; Disk Info tempolary save area
SectAU          DW      0      
AvailAU         DW      0
SectSize        DW      0
TotalSize       DW      0
TotalAU         DW      0
SaveAX          DW      -1
SaveBX          DW      -1
SaveCX          DW      -1
SaveDX          DW      -1
SaveSI          DW      -1
SaveDI          DW      -1
SaveBP          DW      -1
SaveDS          DW      -1
SaveES          DW      -1
@@DiskData      ENDS

@@DosCallsStack SEGMENT PARA STACK 'STACK'
                DB      16 DUP('$')
@@DosCallsStack ENDS

@@DiskCode      SEGMENT PARA PUBLIC '@@DosCallsCode'
                ASSUME  CS:@@DiskCode, DS:@@DiskData, ES:@@DiskData, SS:@@DosCallsStack
        
DrvNumToLtr     PROC    ; AL: DriveNumber/DriveLetter
                MOV     BX, 0
                MOV     BL, AL
                MOV     AX, SEG DriveLetters
                MOV     ES, AX
                MOV     SI, OFFSET DriveLetters
                MOV     AL, ES:[SI+BX]
                RET
DrvNumToLtr     ENDP
        
DrvLtrToNum     PROC    ; AL: DriveLetter/DriveNumber
                CMP     AL,'Z'
                JLE     Skip1
                CMP     AL, 'a'
                JL      Skip1
                CMP     AL, 'z'
                JG      Skip1
                SUB     AL, 'a'-'A'     ; To Upper
Skip1:
                SUB     AL,'A'
                RET
DrvLtrToNum     ENDP

                PUBLIC  @@DosDiskReset
@@DosDiskReset  PROC    FAR
                MOV     AH, 0DH
                INT     21H
                RET     
@@DosDiskReset  ENDP

                PUBLIC  @@DosSelDisk
@@DosSelDisk    PROC    FAR     ; @drvLtr @drives
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
                MOV     BX, [BP+8]      ; SEGMENT @drive
                MOV     ES, BX
                MOV     DI, [BP+10]     ; OFFSET @drive
                MOV     AL, BYTE PTR ES:[DI]
                CALL    DrvLtrToNum
                MOV     DL, AL
                MOV     AH, 0EH
                INT     21H
                MOV     BX, [BP+4]      ; SEGMENT @drive
                MOV     ES, BX
                MOV     DI, [BP+6]      ; OFFSET @drive
                MOV     BYTE PTR ES:[DI], AL

                MOV     BX, SEG SaveDS
                MOV     ES, BX
                MOV     BP, ES:SaveBP
                MOV     DX, ES:SaveDX
                MOV     DI, ES:SaveDI
                MOV     DS, ES:SaveDS
                MOV     ES, ES:SaveES
                RET     8
@@DosSelDisk    ENDP

                PUBLIC  @@DosCurDisk
@@DosCurDisk    PROC    FAR             ; @drvLtr
                PUSH    DS
                MOV     AX, SEG SaveDS
                MOV     DS, AX
                POP     AX
                MOV     SaveDS, AX
                MOV     SaveES, ES
                MOV     SaveDI, DI
                MOV     SaveBP, BP

                MOV     BP, SP
                MOV     AH, 19H
                INT     21H
                CALL    DrvNumToLtr
                MOV     BX, [BP+4]      ; SEGMENT @drvLtr
                MOV     ES, BX
                MOV     DI, [BP+6]      ; OFFSET @drvLtr
                MOV     BYTE PTR ES:[DI], AL

                MOV     BX, SEG SaveDS
                MOV     ES, BX
                MOV     BP, ES:SaveBP
                MOV     DI, ES:SaveDI
                MOV     DS, ES:SaveDS
                MOV     ES, ES:SaveES
                RET     4
@@DosCurDisk    ENDP

                PUBLIC  @@DosDiskFree
@@DosDiskFree   PROC    FAR ; @drvLtr, @cluster, @totalCluster, @bytePerSector, @sector ; Function 36H
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
                MOV     BX, [BP+20]     ; SEGMENT @drvLtr
                MOV     ES, BX
                MOV     DI, [BP+22]     ; OFFSET @drvLtr
                MOV     AL, BYTE PTR ES:[DI]
                CMP     AL, BYTE PTR BLANK      ; BLANK = Current Drive
                JNE     Skip3
                MOV     AL, 0
                JMP     Skip4
Skip3:                
                CALL    DrvLtrToNum
                INC     AL
Skip4:
                MOV     DL, AL
                MOV     AH, 36H
                INT     21H
 
                MOV     SaveAX, AX      ; Save AX
                MOV     AX, [BP+4]      ; SEGMENT @sector
                MOV     ES, AX
                MOV     DI, [BP+6]      ; OFFSET @sector
                MOV     AX, SaveAX      ; Restore AX
                MOV     ES:[DI], AX
                MOV     AX, [BP+8]      ; SEGMENT @bytePerSector
                MOV     ES, AX
                MOV     DI, [BP+10]     ; OFFSET @bytePerSector
                MOV     ES:[DI], CX
                MOV     AX, [BP+12]     ; SEGMENT @totalCluster
                MOV     ES, AX
                MOV     DI, [BP+14]     ; OFFSET @totalCluster
                MOV     ES:[DI], DX
                MOV     AX, [BP+16]     ; SEGMENT @cluster
                MOV     ES, AX
                MOV     DI, [BP+18]     ; OFFSET @cluster
                MOV     ES:[DI], BX
                MOV     BX, SEG SaveDS
                MOV     ES, BX
                MOV     BP, ES:SaveBP
                MOV     BX, ES:SaveBX
                MOV     CX, ES:SaveCX
                MOV     DX, ES:SaveDX
                MOV     DI, ES:SaveDI
                MOV     DS, ES:SaveDS
                MOV     ES, ES:SaveES
                RET     20  
@@DosDiskFree   ENDP
@@DiskCode      ENDS
                END
