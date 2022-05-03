PAGE    ,132
TITLE   TSTDISK.ASM -- DOS機能呼び出し Disk (DISK.ASM)テスト
%OUT    TSTDISK.ASM
        
INCLUDE CONSTANT.INC
INCL_CONSOLE    EQU     0       ; CONSOLE機能マクロ組み込み
INCL_DISK       EQU     0       ; DISK機能マクロ組み込み
INCL_PROCESS    EQU     0       ; PROCESS機能マクロ組み込み 
INCLUDE DosCalls.MAC
INCLUDE DosCalls.DEF

BUFFERSIZE      EQU     128
HEXBUFSIZE      EQU     4
HEXMASK         EQU     000FH
CODEBUFSIZE     EQU     6

Stack           SEGMENT PARA STACK 'STACK'
                DB      128 DUP("S")
Stack           ENDS

TstDiskData     SEGMENT PARA
drvLtr          DB      BLANK, DALLAR
drvLtrA         DB      "A", DALLAR
drvLtrB         DB      "B", DALLAR
drvLtrC         DB      "C", DALLAR
drives          DW      0
bJunk           DB      BLANK
wJunk           DW      -1
cluster         DW      -1      ; 空き空間割り振り単位
totalCluster    DW      -1      ; 全割り振り単位数
bytePerSector   DW      -1      ; 1セクターのバイト数
sector          DW      -1      ; セクター数
Code            DW      -1
CodeBuf         DB      CODEBUFSIZE DUP(SHARP), DALLAR 
HexCode         DW      -1
HexBuf          DB      HEXBUFSIZE DUP(SHARP), "H",  DALLAR 
HexChars        DB      "0123456789ABCDEF"
PauseMsg        DB      "何かキーを押して下さい。", DALLAR
NewLine         DB      CRCHAR, LFCHAR, DALLAR
OpenMsg         DB      "DISK.ASM テストプログラム", CRCHAR, LFCHAR
                DB      "====================================================", CRCHAR, LFCHAR
                DB      "このテストプログラムではDOS機能呼び出し、", CRCHAR, LFCHAR
                DB      "機能番号          機能", CRCHAR, LFCHAR
                DB      "======== ===========================================", CRCHAR, LFCHAR
                DB      "   0D    ディスク・リセット", CRCHAR, LFCHAR 
                DB      "   0E    ディスク選択", CRCHAR, LFCHAR
                DB      "   19    現ディスク", CRCHAR, LFCHAR
                DB      "   1B    ファイル割り振りテーブル情報", CRCHAR, LFCHAR 
                DB      "   1C    指定ドライブのファイル割り振りテーブル情報", CRCHAR, LFCHAR 
                DB      "   36    ディスクの空き空間を得る", CRCHAR, LFCHAR
                DB      "======== ===========================================", CRCHAR, LFCHAR
                DB      "を　テストします。", CRCHAR, LFCHAR 
                DB      "テスト中にドライブ A をアクセスします。", CRCHAR, LFCHAR
                DB      "フォーマットしたディスケットをドライブ A に入れて下さい。", CRCHAR, LFCHAR
                DB      "テストを開始します。何かキーを押して下さい。", CRCHAR, LFCHAR, DALLAR 
Test0D          DB      "機能番号0D ディスク・リセットを行います。", CRCHAR, LFCHAR, DALLAR
Test0DErr       DB      "        リセットに失敗しました。エラーコード ", DALLAR 
Test0DMsg       DB      "        リセットが成功しました。", DALLAR 

Test0E          DB      "機能番号0E ディスク選択を行います。", CRCHAR, LFCHAR, DALLAR
Test0EErr       DB      "        ディスク A を選択できません。エラーコード ", DALLAR 
Test0EMsg       DB      "        ディスク A を選択しました。 ドライブ数 ", DALLAR 

Test19          DB      "機能番号19 現ディスクを取得します。", CRCHAR, LFCHAR
                DB      "        現ディスクを B に変更しました。", CRCHAR, LFCHAR, DALLAR 
Test19Err       DB      "        現ディスクを取得できません。エラーコード ", DALLAR 
Test19Msg1      DB      "        現ディスク ", DALLAR 
Test19Msg3      DB      "        現ディスクを A に変更しました。", CRCHAR, LFCHAR, DALLAR 

Test36          DB      "機能番号36 ディスク空き空間を得る。", CRCHAR, LFCHAR, DALLAR
Test36Err       DB      "        空き空間を得られませんでした。 エラーコード ", DALLAR 
Test36Msg1      DB      "        空き空間", CRCHAR, LFCHAR
                DB      "              空き割り振り単位(クラスター) ", DALLAR
Test36Msg2      DB      "              全割り振り単位数(クラスター) ", DALLAR
Test36Msg3      DB      "              1セクターのバイト数 ", DALLAR
Test36Msg4      DB      "              割り振り単位当たりのセクター数 ", DALLAR

rc              DW      0         
TstDiskData     ENDS

TstDiskCode     SEGMENT PARA
                ASSUME  CS:TstDiskCode, DS:TstDiskData, ES:TstDiskData, SS:Stack

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

ClrBuf          PROC    NEAR
                LEA     BX, CodeBuf
                MOV     DI, 0
                MOV     CX, CODEBUFSIZE
ClrBuf2:
                JCXZ    ClrBuf1
                MOV     BYTE PTR [BX+DI], BLANK
                INC     DI
                DEC     CX
                JMP     ClrBuf2
ClrBuf1:                
                RET
ClrBuf          ENDP

uint2dec        PROC    NEAR
                CALL    ClrBuf
uint2dec1:
                LEA     BX, CodeBuf
                MOV     DI, CODEBUFSIZE-1
                MOV     AX, Code
                MOV     CX, 10
uint2dec4:
                CMP     AX, 10
                JL      uint2dec3
                CWD     
                DIV     CX
                ADD     DL, '0'
                MOV     BYTE PTR [BX+DI], DL
                DEC     DI
                JMP     uint2dec4
uint2dec3:
                ADD     AL, '0'
                MOV     BYTE PTR [BX+DI], AL
                RET
uint2dec        ENDP

pause           PROC    NEAR
                @DosDispString PauseMsg
                @DosClrKbdBuf
                @DosDirectInWOEcho bJunk
                @DosDispString NewLine
                @DosDispString NewLine
                RET
pause           ENDP

main            PROC
                MOV     AX, SEG rc      ; setup DS
                MOV     DS, AX

                @DosDispString OpenMsg
                CALL    pause
                @DosSelDisk drvLtrA, wJunk

                @DosDispString Test0D
                @DosDiskReset
                JNC     main1
                @DosDispString Test0DErr
                MOV     Code, AX
                CALL    uint2hex
                @DosDispString NewLine
                JMP     main2
main1:
                @DosDispString Test0DMsg
                @DosDispString NewLine
main2:
                CALL    pause
                
                @DosDispString Test0E
                @DosSelDisk drvLtrA, drives
                JNC     main3
                @DosDispString Test0EErr
                MOV     Code, AX
                CALL    uint2hex
                @DosDispString HexBuf
                @DosDispString NewLine
                JMP     main4
main3:
                @DosDispString Test0EMsg
                MOV     AX, drives
                MOV     Code, AX
                CALL    uint2dec
                @DosDispString CodeBuf
                @DosDispString NewLine
main4:
                CALL    pause

                @DosDispString Test19
                @DosSelDisk drvLtrB, wJunk
                @DosCurDisk drvLtr
                JNC     main5
                @DosDispString Test19Err
                MOV     Code, AX
                CALL    uint2hex
                @DosDispString HexBuf
                @DosDispString NewLine
                JMP     main6
main5:
                @DosDispString Test19Msg1
                @DosDispString drvLtr
                @DosDispString NewLine
                @DosSelDisk drvLtrA, wJunk
                @DosDispString Test19Msg3
main6:
                CALL    pause

                @DosDispString Test36
                @DosDiskFree drvLtrA, cluster, totalCluster, bytePerSector, sector
                JNC     main11
                @DosDispString Test36Err
                MOV     Code, AX
                CALL    uint2hex
                @DosDispString HexBuf
                @DosDispString NewLine
                JMP     main12
main11:
                @DosDispString Test36Msg1
                MOV     AX, cluster
                MOV     Code, AX
                CALL    uint2dec
                @DosDispString CodeBuf
                @DosDispString NewLine

                @DosDispString Test36Msg2
                MOV     AX, totalCluster
                MOV     Code, AX
                CALL    uint2dec
                @DosDispString CodeBuf
                @DosDispString NewLine

                @DosDispString Test36Msg3
                MOV     AX, bytePerSector
                MOV     Code, AX
                CALL    uint2dec
                @DosDispString CodeBuf
                @DosDispString NewLine

                @DosDispString Test36Msg4
                MOV     AX, sector
                MOV     Code, AX
                CALL    uint2dec
                @DosDispString CodeBuf
                @DosDispString NewLine
main12:
                @DosSelDisk drvLtrC, wJunk

                MOV     rc, 00H
                @DosExit rc
main            ENDP
TstDiskCode     ENDS
                END     main
