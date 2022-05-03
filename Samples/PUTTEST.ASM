PAGE    ,132
TITLE   PUTTEST.ASM -- put/putchar/putline test
%OUT    PUTTEST.ASM
                   
INCLUDE CONSTANT.INC

INCL_CONSOLE    EQU     0    
INCL_FILELIB    EQU     0    
INCL_PROCESS    EQU     0    
INCLUDE DosCalls.MAC
INCLUDE DosCalls.DEF

MAXFILES        EQU     10
BUFSIZ          EQU     10
LBUFSIZ         EQU     256

myStack         SEGMENT PARA STACK
                DB      128 DUP("S")
myStack         ENDS

myData          SEGMENT PARA
FileHandle      DW      0
FileAccess      DW      FL_WRITE
FileName        DB      "A:\PUTTEST.DAT", EOS  
Block           DB      BUFSIZ DUP("0123456789"), EOS
Bytes           DW      BUFSIZ
LBuf            DB      LBUFSIZ DUP(BLANK)
LSize           DW      LBUFSIZ
NewLine         DB      CRCHAR, LFCHAR, DALLAR
Char            DB      BLANK
Mark            DB      "@"
MsgOpen1        DB      "<@OPEN FILENAME:=[", DALLAR
MsgOpen2        DB      "]>", CRCHAR, LFCHAR, DALLAR
MsgPut          DB      "<@PUT>", CRCHAR, LFCHAR, DALLAR 
MsgPutChar      DB      "<@PUTCHAR>", CRCHAR, LFCHAR, DALLAR 
MsgPutLine      DB      "<@PUTLINE>", CRCHAR, LFCHAR, DALLAR 
MsgCose         DB      "<@CLOSE>", CRCHAR, LFCHAR, DALLAR
MsgWriteData    DB      "書き出しデータ", CRCHAR, LFCHAR, DALLAR
MsgLeft         DB      "この左から=>", DALLAR
MsgRight        DB      "<=この右まで", DALLAR
MsgFileData     DB      "書き出したファイルの内容", CRCHAR, LFCHAR, DALLAR
OpenMsg         DB      "PUTTEST は、ドライブ A にテストファイルを作成します。"
                DB      CRCHAR, LFCHAR 
                DB      "ドライブ A にフォーマットしたディスケットを入れて下さい。"
                DB      CRCHAR, LFCHAR, DALLAR 
PauseMsg        DB      "何かキーを押して下さい。", DALLAR
bJunk           DB      BLANK
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
myData          ENDS

mainCode        SEGMENT PARA
                ASSUME  CS:mainCode, DS:myData, ES:myData, SS:myStack

;       FILELIB エラー表示
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

;       DOS エラー表示
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

;       ブロックのダンプアウト
DispBlock       PROC    NEAR
DispBlock2:       
                JCXZ    DispBlock1
                MOV     AL, BYTE PTR [DI]
                MOV     Char, AL
                @DosDispOut Char
                INC     DI
                DEC     CX
                JMP     DispBlock2
DispBlock1:        
                RET
DispBlock       ENDP

;       ASCIIZ 文字列を表示
DispAsciizString PROC    NEAR
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

;       一時停止
pause           PROC    NEAR
                @DosDispString PauseMsg
                @DosClrKbdBuf
                @DosConInEcho bJunk
                @DosDispString NewLine
                @DosDispString NewLine
                RET
pause           ENDP

main            PROC
                MOV     AX, SEG myData  ; setup DS
                MOV     DS, AX

                @DosDispString OpenMsg
                CALL    pause
                
                ; テスト用ファイル作成
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
                JMP     main99
main3:          
                ; putline で書込み
                @DosDispString MsgPutLine
                MOV     bytes, BUFSIZ
                @putline FileHandle, Block
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
                ; putline で書込み
                @DosDispString MsgWriteData
                @DosDispString MsgLeft
                LEA     DI, Block
                CALL    DispAsciizString
                @DosDispString MsgRight
                @DosDispString NewLine
                
                ; putchar で書込み
                @DosDispString MsgPutChar
                @putchar FileHandle, Mark
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
                @DosDispString MsgWriteData
                @DosDispString MsgLeft
                @DosDispOut Mark
                @DosDispString MsgRight
                @DosDispString NewLine

                ; put で書込み
                @DosDispString MsgPut
                MOV     Bytes, BUFSIZ
                @put    FileHandle, Block, Bytes
                JC      main10
                CMP     AX, WORD PTR FL_NOERROR
                JNE     main11
                JMP     main12
main10:                
                CALL    printDOSError
                JMP     main98
main11:                
                CALL    printFLIBError
                JMP     main98
main12:                
                @DosDispString MsgWriteData
                @DosDispString MsgLeft
                LEA     DI, Block
                MOV     CX, BUFSIZ
                CALL    DispBlock
                @DosDispString MsgRight
                @DosDispString NewLine
main98:         
                @close  FileHandle
                JC      main13
                CMP     AX, WORD PTR FL_NOERROR
                JNE     main14
                JMP     main15
main13:                
                CALL    printDOSError
                JMP     main99
main14:                
                CALL    printFLIBError
                JMP     main99
main15:         
                ; 書き込んだファイルを読みだして、内容確認
                @DosDispString MsgFileData
                MOV     FileAccess, FL_READ
                @open   FileHandle, FileName, FileAccess
                @get    FileHandle, LBuf, LSize
                @DosDispString MsgLeft
                LEA     DI, LBuf
                MOV     CX, LSize
                CALL    DispBlock
                @DosDispString MsgRight
                @DosDispString NewLine
                @close  FileHandle
main99:         
                MOV     rc, 00H
                @DosExit rc
main            ENDP
mainCode        ENDS
                END     main
