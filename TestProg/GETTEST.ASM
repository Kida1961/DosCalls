PAGE    ,132
TITLE   GETTEST.ASM -- get/getchar/getline test
%OUT    GETTEST.ASM

INCLUDE CONSTANT.INC

INCL_CONSOLE    EQU     0    
INCL_FILELIB    EQU     0    
INCL_PROCESS    EQU     0    
INCLUDE DosCalls.MAC
INCLUDE DosCalls.DEF

BUFSIZE         EQU     20
LINEBUFSIZE     EQU     30
DECBUFSIZ       EQU     6
LBUFSIZ         EQU     256

Stack           SEGMENT PARA STACK
                DB      128 DUP("S")
Stack           ENDS

GetTestData     SEGMENT PARA
FileHandle      DW      0
FileAccess      DW      FL_WRITE
FileName        DB      "A:GETTEST.DAT", EOS
                        ;0123456789012345678901234567890123456789
Block           DB      "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ", CRCHAR, LFCHAR
                DB      "!#$%&()=~*", CRCHAR, LFCHAR
                DB      "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
                DB      "!#$%&()=~+abcdefghijklmnopqrstuvwxyz", DALLAR
BlockSize       DW      $-Block-1
LargeBuf        DB      LBUFSIZ DUP(SHARP)
LargeBufSize    DW      LBUFSIZ
ReadBuffer      DB      LINEBUFSIZE DUP(SHARP)
ReadBufferSize  DW      BUFSIZE
pos             DW      0
OutChar         DB      BLANK
Char            DB      BLANK
DecBuf          DB      DECBUFSIZ DUP('0'), DALLAR
ErrCode         DW      0
MsgCreate1      DB      "<テストファイル作成 FileName:=[", DALLAR
MsgCreate2      DB      "]>", CRCHAR, LFCHAR, DALLAR
MsgTestData     DB      "テストデータ", CRCHAR, LFCHAR, DALLAR
MsgReadData     DB      "読だしデータ", CRCHAR, LFCHAR, DALLAR
MsgLeft         DB      "この左から=>", DALLAR
MsgRight        DB      "<=この右まで", CRCHAR, LFCHAR, DALLAR
MsgFileData     DB      "読だしテストファイルの内容", CRCHAR, LFCHAR, DALLAR
MsgOpen1        DB      "<OPEN File Name:=[", DALLAR
MsgOpen2        DB      "]>", CRCHAR, LFCHAR, DALLAR
MsgGet          DB      "<GET>", CRCHAR, LFCHAR, DALLAR
MsgGetChar      DB      "<GETCHAR>", CRCHAR, LFCHAR, DALLAR
MsgGetLine      DB      "<GETLINE>", CRCHAR, LFCHAR, DALLAR
MsgClose        DB      "<CLOSE>", CRCHAR, LFCHAR, DALLAR
NewLine         DB      CRCHAR, LFCHAR, DALLAR
OpenMsg         DB      "GETTEST は、ドライブ A にテストファイルを作成します。"
                DB      CRCHAR, LFCHAR 
                DB      "ドライブ A にフォーマットしたディスケットを入れて下さい。"
                DB      CRCHAR, LFCHAR, DALLAR 
PauseMsg        DB      "何かキーを押して下さい。", DALLAR
bJunk           DB      BLANK
Num             DW      0
rc              DW      0
FLIBError00     DB      "[NOERROR ]", CRCHAR, LFCHAR, DALLAR
FLIBError01     DB      "[NOTFOUND]", CRCHAR, LFCHAR, DALLAR
FLIBError02     DB      "[OPEN    ]", CRCHAR, LFCHAR, DALLAR
FLIBError03     DB      "[INUSE   ]", CRCHAR, LFCHAR, DALLAR
FLIBError04     DB      "[CANT    ]", CRCHAR, LFCHAR, DALLAR
FLIBError05     DB      "[TOOMANY ]", CRCHAR, LFCHAR, DALLAR
FLIBError06     DB      "[EOF     ]", CRCHAR, LFCHAR, DALLAR
FLIBError07     DB      "[INVALID ]", CRCHAR, LFCHAR, DALLAR
FLIBError08     DB      "[DISKFULL]", CRCHAR, LFCHAR, DALLAR
pFLIBError      DW      FLIBError00, FLIBError01, FLIBError02, FLIBError03
                DW      FLIBError04, FLIBError05, FLIBError06, FLIBError07
                DW      FLIBError08
DOSError00      DB      "<FLIBERROR >", CRCHAR, LFCHAR, DALLAR
DOSError01      DB      "<無効な機能番号>", CRCHAR, LFCHAR, DALLAR
DOSError02      DB      "<ファイルが見つからない>", CRCHAR, LFCHAR, DALLAR
DOSError03      DB      "<パスが見つからない>", CRCHAR, LFCHAR, DALLAR
DOSError04      DB      "<オープン・ファイルが多すぎる>", CRCHAR, LFCHAR, DALLAR
DOSError05      DB      "<アクセスが拒絶された>", CRCHAR, LFCHAR, DALLAR
DOSError06      DB      "<無効なハンドル>", CRCHAR, LFCHAR, DALLAR
DOSError07      DB      "<メモリー制御ブロックが破壊された>", CRCHAR, LFCHAR, DALLAR
DOSError08      DB      "<十分なメモリーがない>", CRCHAR, LFCHAR, DALLAR
DOSError09      DB      "<無効なメモリー・ブロック・アドレス>", CRCHAR, LFCHAR, DALLAR
DOSError10      DB      "<無効な環境>", CRCHAR, LFCHAR, DALLAR
DOSError11      DB      "<無効な形式>", CRCHAR, LFCHAR, DALLAR
DOSError12      DB      "<無効なアクセス・コード>", CRCHAR, LFCHAR, DALLAR
DOSError13      DB      "<無効なデータ>", CRCHAR, LFCHAR, DALLAR
DOSError14      DB      "<>", CRCHAR, LFCHAR, DALLAR
DOSError15      DB      "<無効なドライブが指定された>", CRCHAR, LFCHAR, DALLAR
DOSError16      DB      "<現在使っているディレクトリーを削除しようとした>", CRCHAR, LFCHAR, DALLAR
DOSError17      DB      "<同じ装置でない>", CRCHAR, LFCHAR, DALLAR
DOSError18      DB      "<もうファイルがない>", CRCHAR, LFCHAR, DALLAR
pDOSError       DW      DOSError00, DOSError01, DOSError02, DOSError03
                DW      DOSError04, DOSError05, DOSError06, DOSError07
                DW      DOSError08, DOSError09, DOSError10, DOSError11
                DW      DOSError12, DOSError13, DOSError14, DOSError15
                DW      DOSError16, DOSError17, DOSError18 
GetTestData     ENDS

GetTestCode     SEGMENT PARA
                ASSUME  CS:GetTestCode, DS:GetTestData, ES:GetTestData, SS:Stack

printFLIBError  PROC    NEAR
                AND     AX, 00FFH
                ADD     AX, AX
                MOV     DI, AX
                LEA     BX, pFLIBError
                MOV     AX, [BX+DI]
                PUSH    AX
                PUSH    DS
                EXTRN   @@DosDispString: FAR
                CALL    @@DosDispString
                RET
printFLIBError  ENDP

printDOSError   PROC    NEAR
                ADD     AX, AX
                MOV     DI, AX
                LEA     BX, pDOSError
                MOV     AX, [BX+DI]
                PUSH    AX
                PUSH    DS
                EXTRN   @@DosDispString: FAR
                CALL    @@DosDispString
                RET
printDOSError   ENDP

fillBlanks      PROC    NEAR
fillBlanks2:      
                CMP     BYTE PTR [DI], DALLAR
                JE      fillBlanks1
                MOV     BYTE PTR [DI], BLANK
                INC     DI
                JMP     fillBlanks2
fillBlanks1:      
                RET
fillBlanks      ENDP

uint2dec        PROC    NEAR
                LEA     DI, DecBuf
                CALL    fillBlanks
                MOV     DI, DECBUFSIZ-1
                LEA     BX, DecBuf
                MOV     CX, 10
uint2dec2:       
                MOV     AX, Num
                CMP     AX, 10
                JL      uint2dec1
                CWD
                DIV     CX
                MOV     Num, AX
                ADD     DL, '0'
                MOV     BYTE PTR [BX+DI], DL
                DEC     DI
                JMP     uint2dec2
uint2dec1:       
                ADD     AL, '0'
                MOV     BYTE PTR [BX+DI], AL
                RET
uint2dec        ENDP

DumpBlock       PROC    NEAR
DumpBlock2:        
                JCXZ    DumpBlock1
                MOV     AL, BYTE PTR [DI]
                MOV     OutChar, AL
                @DosDispOut OutChar
                INC     DI
                DEC     CX
                JMP     DumpBlock2
DumpBlock1:
                RET
DumpBlock       ENDP

DispAsciizString PROC   NEAR
DispAsciizString2:
                MOV     AL, BYTE PTR [DI]
                CMP     AL, BYTE PTR EOS
                JE      DispAsciizString1
                MOV     Char, AL
                @DosDispOut Char
                INC     DI
                JMP     DispAsciizString2
DispAsciizString1:
                RET
DispAsciizString ENDP

pause           PROC    NEAR
                @DosDispString PauseMsg
                @DosClrKbdBuf
                @DosConInEcho bJunk
                @DosDispString NewLine
                @DosDispString NewLine
                RET
pause           ENDP

main            PROC
                MOV     AX, SEG rc      ; setup DS
                MOV     DS, AX
                
                @DosDispString OpenMsg
                CALL    pause

                @DosDispString MsgCreate1
                LEA     DI, FileName
                CALL    DispAsciizString
                @DosDispString MsgCreate2
                MOV     FileAccess, FL_WRITE
                @open   FileHandle, FileName, FileAccess
                @put    FileHandle, Block, BlockSize
                @close  FileHandle
                MOV     FileAccess, FL_READ
                MOV     LargeBufSize, LBUFSIZ
                @open   FileHandle, FileName, FileAccess
                @get    FileHandle, LargeBuf, LargeBufSize
                @close  FileHandle
                @DosDispString MsgTestData
                @DosDispString MsgLeft
                LEA     DI, LargeBuf
                MOV     CX, LargeBufSize
                CALL    DumpBlock
                @DosDispString MsgRight
                @DosDispString MsgOpen1
                LEA     DI, FileName
                CALL    DispAsciizString
                @DosDispString MsgOpen2
                @open   FileHandle, FileName, FileAccess
                JC      main1
                CMP     AX, WORD PTR FL_NOERROR
                JNE     main2
                JMP     main3
main1:
                CALL    printDOSError
                JMP     main99
main2:                
                CALL    printFLIBError
                JMP     main98
main3: 
                @DosDispString MsgGet
                MOV     BlockSize, BUFSIZE
                @get    FileHandle, Block, BlockSize
                JC      main4
                CMP     AX, WORD PTR FL_NOERROR
                JNE     main5
                JMP     main6
main4:          
                CALL    printDOSError
                JMP     main98
main5:          
                CALL    printFLIBError
                JMP     main98
main6:          
                @DosDispString MsgReadData
                @DosDispString MsgLeft
                LEA     DI, Block
                MOV     CX, BlockSize
                CALL    DumpBlock
                @DosDispString MsgRight

                @DosDispString MsgGetChar
                @getchar FileHandle, Char
                JC      main7
                CMP     AX, WORD PTR FL_NOERROR
                JNE     main8
                JMP     main9
main7:                
                CALL    printDOSError
                JMP     main98
main8:                
                CALL    printFLIBError
                JMP     main98
main9:                
                @DosDispString MsgReadData
                @DosDispString MsgLeft
                @DosDispOut Char
                @DosDispString MsgRight

                @DosDispString MsgGetLine
                MOV     ReadBufferSize, LINEBUFSIZE
                @getLine FileHandle, ReadBuffer, ReadBufferSize
                JC      main10
                JNE     main11
                JMP     main12
main10:
                CALL    printDOSError
                JMP     main98
main11:                
                CALL    printFLIBError
                JMP     main98
main12:
                @DosDispString MsgReadData
                @DosDispString MsgLeft
                LEA     DI, ReadBuffer
                CALL    DispAsciizString
                @DosDispOut Char
                @DosDispString MsgRight
main98:
                @DosDispString MsgClose
                @close FileHandle

main99:
                MOV     rc, 00H
                @DosExit rc
main            ENDP
GetTestCode     ENDS
                END     main
