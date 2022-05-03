PAGE    ,132
TITLE   TSTDIR.ASM -- DOS機能呼び出し Directory (DIR.ASM)テスト
%OUT    TSTDIR.ASM

INCLUDE CONSTANT.INC
INCL_CONSOLE    EQU     0       ; CONSOLE機能マクロ組み込み
INCL_DIR        EQU     0       ; DIR機能マクロ組み込み
INCL_DISK       EQU     0       ; DISK機能マクロ組み込み
INCL_PROCESS    EQU     0       ; PROCESS機能マクロ組み込み 
INCLUDE DosCalls.MAC
INCLUDE DosCalls.DEF

BUFFERSIZE      EQU     128
CODEBUFSIZE     EQU     6
HEXBUFSIZE      EQU     4
HEXMASK         EQU     000FH

Stack           SEGMENT PARA STACK 'STACK'
                DB      128 DUP("S")
Stack           ENDS

TstDirData      SEGMENT PARA
FooDir          DB      "A:\Foo", EOS
BarDir          DB      "A:\Bar", EOS
drvLtrA         DB      "A", DALLAR
drvLtrC         DB      "C", DALLAR
NewDrv          DB      "A", DALLAR
NewDir          DB      BUFFERSIZE DUP(SHARP), DALLAR
CurDrv          DB      BLANK
CurPath         DB      "\"
CurDir          DB      BUFFERSIZE DUP(SHARP), DALLAR
bJunk           DB      BLANK
wJunk           DW      -1
Code            DW      -1
CodeBuf         DB      CODEBUFSIZE DUP(SHARP), DALLAR 
HexBuf          DB      HEXBUFSIZE DUP(SHARP),"H", DALLAR 
HexChars        DB      "0123456789ABCDEF"
NewLine         DB      CRCHAR, LFCHAR, DALLAR
OpenMsg         DB      "DIR.ASM テストプログラム", CRCHAR, LFCHAR
                DB      "=======================================", CRCHAR, LFCHAR
                DB      "このテストプログラムではDOS機能呼び出し、", CRCHAR, LFCHAR
                DB      "機能番号          機能", CRCHAR, LFCHAR
                DB      "======== ==============================", CRCHAR, LFCHAR
                DB      "   39    ディレクトリーの作成", CRCHAR, LFCHAR 
                DB      "   3A    ディレクトリーの削除", CRCHAR, LFCHAR
                DB      "   3B    現行ディレクトリーの変更", CRCHAR, LFCHAR
                DB      "   47    現行ディレクトリー", CRCHAR, LFCHAR
                DB      "======== ==============================", CRCHAR, LFCHAR
                DB      "を　テストします。", CRCHAR, LFCHAR 
                DB      "テスト中にドライブ A にアクセスします。", CRCHAR, LFCHAR
                DB      "フォーマットしたディスケットをドライブ A に入れて下さい。", CRCHAR, LFCHAR
                DB      "テストを開始します。何かキーを押して下さい。", CRCHAR, LFCHAR, DALLAR 
Test47          DB      "機能番号47 現行ディレクトーの取得,", CRCHAR, LFCHAR
                DB      "        現行ディレクトリーは、", CRCHAR, LFCHAR, DALLAR   
Test47Msg1      DB      "                  ドライブ ", DALLAR
Test47Msg2      DB      CRCHAR, LFCHAR
                DB      "            ディレクトリー ", DALLAR         
Test47Msg3      DB      CRCHAR, LFCHAR
                DB      " です。", CRCHAR, LFCHAR, DALLAR
Test47Err       DB      "        現行ディレクトリーを取得できません。エラーコード ", DALLAR

Test391         DB      "機能番号39 ディレクトー \Foo の作成,", CRCHAR, LFCHAR, DALLAR
                DB      "        ディレクトリー \Foo を作成します。", CRCHAR, LFCHAR, DALLAR
Test391Err      DB      "        ディレクトリー \Foo を作成出来ません。エラーコード ", DALLAR 

Test392         DB      "機能番号39 ディレクトー \Bar の作成,", CRCHAR, LFCHAR, DALLAR
                DB      "        ディレクトリー \Bar を作成します。", CRCHAR, LFCHAR, DALLAR
Test392Err      DB      "        ディレクトリー \Bar を作成出来ません。エラーコード ", DALLAR 

Test3A1         DB      "機能番号3A ディレクトリー \Foo の削除,", CRCHAR, LFCHAR, DALLAR
Test3A1Err1     DB      "        ディレクトリー \Foo を削除出来ません。エラーコード ", DALLAR 
Test3A1Msg1     DB      "        現行ディレクトリーは、", CRCHAR, LFCHAR, DALLAR 

Test3B1         DB      "機能番号3B 現行ディレクトリーを \Foo に変更,", CRCHAR, LFCHAR, DALLAR
Test3B1Err1     DB      "        ディレクトリー \Foo に変更出来ません。エラーコード ", DALLAR 

Test3B2         DB      "機能番号3B 現行ディレクトリーを \Bar に変更,", CRCHAR, LFCHAR, DALLAR
Test3B2Err1     DB      "        ディレクトリー \Bar を作成出来ません。エラーコード ", DALLAR 

Test3B3         DB      "機能番号3B 現行ディレクトリーを 元のディレクトリーに変更,", CRCHAR, LFCHAR, DALLAR
Test3B3Err1     DB      "        ディレクトリー を変更出来ません。エラーコード ", DALLAR 

rc              DW      0         
TstDirData      ENDS

TstDirCode      SEGMENT PARA
                ASSUME  CS:TstDirCode, DS:TstDirData, ES:TstDirData, SS:Stack

uint2hex        PROC    NEAR
                MOV     AX, Code
                LEA     BX, HexBuf
                MOV     DI, HEXBUFSIZE-1
                MOV     CL, 4
uint2hex2:        
                CMP     DI, 0
                JL      uint2hex1
                AND     AX, HEXMASK
                LEA     SI, HexChars
                ADD     SI, AX
                MOV     AL, [SI]
                MOV     BYTE PTR [BX+DI], AL
                MOV     AX, Code
                SHR     AX, CL
                MOV     Code, AX
                DEC     DI
                JMP     uint2hex2
uint2hex1:        
                RET
uint2hex        ENDP

dispDrv         PROC    NEAR
                @DosDispString NewDrv
                RET
dispDrv         ENDP

dispDir         PROC    NEAR
                LEA     DI, NewDir 
dispDir2:
                MOV     AL, BYTE PTR [DI]
                CMP     AL, BYTE PTR EOS
                JE      dispDir1
                CMP     AL, BYTE PTR DALLAR
                JE      dispDir3
                INC     DI
                JMP     dispDir2
dispDir1:
                MOV     BYTE PTR [DI], DALLAR
dispDir3:
                @DosDispString NewDir
                RET
dispDir         ENDP

showNewDir      PROC    NEAR
                @DosDispString Test47Msg1       ; 現行ディレクトーの表示
                CALL    dispDrv
                @DosDispString Test47Msg2
                CALL    dispDir
                @DosDispString Test47Msg3
                RET
showNewDir      ENDP

saveCurDrvDir   PROC    NEAR
                MOV     AL, NewDrv
                MOV     CurDrv, AL
                MOV     CX, BUFFERSIZE
                REP MOVS CurDir, NewDir
                RET
saveCurDrvDir   ENDP

main            PROC
                MOV     AX, SEG rc      ; setup DS
                MOV     DS, AX

                @DosDispString OpenMsg
                @DosClrKbdBuf
                @DosDirectInWOEcho bJunk
                @DosSelDisk drvLtrA, wJunk

                @DosDispString Test47           ; 現行ディレクトリーを取得
                @DosCurdir NewDrv, NewDir
                JNC     main1
                MOV     Code, AX
                CALL    uint2hex
                @DosDispString test47Err
                @DosDispString HexBuf
                @DosDispString NewLine
                JMP     main2
main1:
                CALL    showNewDir
                @DosCurdir CurDrv, CurDir       ; 現行ディレクトリーを保管
main2:
                @DosDispString Test391          ; ディレクトリーの作成
                @DosMkdir FooDir
                JNC     main3    
                MOV     Code, AX
                CALL    uint2hex
                @DosDispString Test391Err
                @DosDispString HexBuf
                @DosDispString NewLine
main3:

                @DosChdir FooDir                ; 作成したディレクトリーに移動
                JNC     main4    
                MOV     Code, AX
                CALL    uint2hex
                @DosDispString Test3B1Err1
                @DosDispString HexBuf
                @DosDispString NewLine
main4:
                @DosCurdir NewDrv, NewDir
                CALL    showNewDir

                @DosDispString Test392          ; ディレクトリーの作成
                @DosMkdir BarDir
                JNC     main5    
                MOV     Code, AX
                CALL    uint2hex
                @DosDispString test392Err
                @DosDispString HexBuf
                @DosDispString NewLine
main5:
                @DosChdir BarDir                ; 作成したディレクトリーに移動
                @DosCurdir NewDrv, NewDir
                CALL    showNewDir
      
                @DosDispString Test3A1 　       ; ディレクトリーを削除
                @DosRmdir FooDir
                JNC     main7    
                MOV     Code, AX
                CALL    uint2hex
                @DosDispString test3A1Err1
                @DosDispString HexBuf
                @DosDispString NewLine
main7:
                @DosDispString Test3A1Msg1
                @DosCurdir NewDrv, NewDir
                CALL    showNewDir

                @DosDispString Test3B3 　       ; 現行ディレクトリーを移動
                @DosChdir CurPath
                JNC     main8    
                MOV     Code, AX
                CALL    uint2hex
                @DosDispString test3B3Err1
                @DosDispString HexBuf
                @DosDispString NewLine
main8:
                @DosCurdir NewDrv, NewDir       ; 現行ディレクトリーを取得
                CALL    showNewDir
                
                @DosSelDisk drvLtrC, wJunk

                MOV     rc, 00H
                @DosExit rc
main            ENDP
TstDirCode      ENDS
                END     main
