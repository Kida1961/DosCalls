PAGE    ,132
TITLE   TSTFILE1.ASM -- DOS機能呼び出し File (FILE.ASM)テスト パート 1
%OUT    TSTFILE1.ASM
        
INCLUDE CONSTANT.INC
INCL_CONSOLE    EQU     0       ; CONSOLE機能マクロ組み込み
INCL_DISK       EQU     0       ; DISK機能マクロ組み込み
INCL_FILE       EQU     0       ; FILE機能マクロ組み込み
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

TstFile1Data    SEGMENT PARA
drvLtrA         DB      "A", DALLAR
drvLtrC         DB      "C", DALLAR
NewDTA          @DosDTA <>
DefaultDTA      DW      -1
                DW      -1
CurDTA          DW      -1
                DW      -1
ErrorFileName   DB      "@Error@.DAT", EOS
FileName        DB      "Sample.DAT", EOS
FileAttribute   DW      0
FileAccess      DW      0
FileHandle      DW      -1
WriteFileName   DB      "Sample.DAT", EOS
WriteFileAttribute DW   DOSWRITEACCESS
WriteFileHandle DW      -1
WriteData       DB      "ABCDEFGHIJKLMNOPQRSTUVWXYZ", DALLAR
WriteDataSize   DW      $-WriteData-1
ReadFileName    DB      "Sample.DAT", EOS
ReadFileAttribute DW    DOSREADACCESS
ReadFileHandle  DW      -1
ReadBuffer      DB      BUFFERSIZE DUP(SHARP)
ReadChars       DW      BUFFERSIZE
bJunk           DB      BLANK
wJunk           DW      -1
Code            DW      -1
CodeBuf         DB      CODEBUFSIZE DUP(SHARP), DALLAR 
HexBuf          DB      HEXBUFSIZE DUP(SHARP), "H", DALLAR 
HexChars        DB      "0123456789ABCDEF"
NewLine         DB      CRCHAR, LFCHAR, DALLAR
PauseMsg        DB      "何かキーを押して下さい。", DALLAR
OpenMsg         DB      "FILE.ASM テストプログラム パート 1", CRCHAR, LFCHAR
                DB      "====================================================", CRCHAR, LFCHAR
                DB      "このテストプログラムではDOS機能呼び出し、", CRCHAR, LFCHAR
                DB      "機能番号          機能", CRCHAR, LFCHAR
                DB      "======== ===========================================", CRCHAR, LFCHAR
                DB      "   1A    ディスク転送アドレスの設定", CRCHAR, LFCHAR
                DB      "   2F    ディスク転送アドレスの読取り", CRCHAR, LFCHAR
                DB      "   3C    ファイルの作成", CRCHAR, LFCHAR
                DB      "   3D    ファイルのオープン", CRCHAR, LFCHAR        
                DB      "   3E    ファイルのクローズ", CRCHAR, LFCHAR 
                DB      "   41    ファイルの削除", CRCHAR, LFCHAR
                DB      "   40    ファイルまたは装置への書込み", CRCHAR, LFCHAR
                DB      "   3F    ファイルまたは装置からの読取り", CRCHAR, LFCHAR
                DB      "======== ===========================================", CRCHAR, LFCHAR
                DB      "を　テストします。", CRCHAR, LFCHAR 
                DB      "テスト中にドライブ A をアクセスします。", CRCHAR, LFCHAR
                DB      "フォーマットしたディスケットをドライブ A に入れて下さい。", CRCHAR, LFCHAR, DALLAR
;;                DB      "テストを開始します。何かキーを押して下さい。", CRCHAR, LFCHAR, DALLAR 

Test2F          DB      "機能番号2F ディスク転送アドレスの読取り", CRCHAR, LFCHAR, DALLAR
Test2FErr       DB      "        ディスク転送アドレスの読取りに失敗しました。エラーコード ", DALLAR 
Test2FMsg1      DB      "        現在のディスク転送アドレスは, ", DALLAR 
Test2FMsg2      DB      ":", DALLAR 
Test2FMsg3      DB      " です。", CRCHAR, LFCHAR, DALLAR 

Test1A          DB      "機能番号1A ディスク転送アドレスの設定", CRCHAR, LFCHAR, DALLAR
Test1AErr       DB      "        ディスク転送アドレスの読取りに失敗しました。エラーコード ", DALLAR
Test1AMsg1      DB      "        新たなディスク転送アドレスは、", DALLAR 
Test1AMsg2      DB      ":", DALLAR 
Test1AMsg3      DB      " です。", CRCHAR, LFCHAR, DALLAR 

Test3C          DB      "機能番号3C ファイルの作成", CRCHAR, LFCHAR, DALLAR
Test3CErr       DB      "        ファイル SAMPLE.DAT の作成に失敗しました。エラーコード ", DALLAR 
Test3CMsg1      DB      "        作成したファイル SAMPLE.DAT のハンドルは、", DALLAR 
Test3CMsg2      DB      " です。", CRCHAR, LFCHAR, DALLAR 

Test3E          DB      "機能番号3E ファイルのクローズ", CRCHAR, LFCHAR, DALLAR
Test3EErr       DB      "        作成したファイル SAMPLE.DAT のクローズに失敗しました。エラーコード ", DALLAR 
Test3EMsg1      DB      "        作成したファイル SAMPLE.DAT をクローズしました。", CRCHAR, LFCHAR, DALLAR 

Test3D          DB      "機能番号3D ファイルのオープン", CRCHAR, LFCHAR, DALLAR
Test3DMsg1      DB      "        存在しないファイル @Error@.DAT のオープンに失敗しました。エラーコード ", DALLAR 
Test3DMsg2      DB      "        存在しないファイル @Error@.DAT のオープンに成功しました。ファイルハンドル ", DALLAR
Test3DMsg3      DB      "        存在しないファイル @Error@.DAT をクローズしました。", DALLAR
Test3DMsg4      DB      "        存在するファイル SAMPLE.DAT のオープンに失敗しました。エラーコード ", DALLAR
Test3DMsg5      DB      "        存在するファイル SAMPLE.DAT のオープンに成功しました。ファイルハンドル ", DALLAR 
Test3DMsg6      DB      "        存在するファイル SAMPLE.DAT をクローズしました。", CRCHAR, LFCHAR, DALLAR 

Test41          DB      "機能番号41 ファイルの削除", CRCHAR, LFCHAR, DALLAR
Test41Msg1      DB      "        存在しないファイル @Error@.DAT を削除します。", CRCHAR, LFCHAR, DALLAR 
Test41Msg2      DB      "        存在しないファイル @Error@.DAT の削除に失敗しました。エラーコード ", DALLAR 
Test41Msg3      DB      "        存在しないファイル @Error@.DAT の削除に成功しました。", DALLAR
Test41Msg4      DB      "        存在するファイル SAMPLE.DAT をオープンしました。ファイルハンドル ", DALLAR
Test41Msg5      DB      "        オープン済みファイル SAMPLE.DAT の削除に失敗しました。エラーコード ", DALLAR
Test41Msg6      DB      "        オープン済みファイル SAMPLE.DAT の削除に成功しました。", DALLAR 
Test41Msg7      DB      "        ファイル SAMPLE.DAT をクローズしました。", DALLAR 
Test41Msg8      DB      "        ファイル SAMPLE.DAT の削除に失敗しました。エラーコード ", DALLAR
Test41Msg9      DB      "        ファイル SAMPLE.DAT の削除に成功しました。", DALLAR 
Test41Msg10     DB      "        削除済みファイル SAMPLE.DAT のオープンに失敗しました。エラーコード ", DALLAR
Test41Msg11     DB      "        削除済みファイル SAMPLE.DAT のオープンに成功しました。ファイルハンドル ", DALLAR

Test40          DB      "機能番号40 ファイルまたは装置への書込み", CRCHAR, LFCHAR, DALLAR
Test40Msg1      DB      "        書込み先ファイル SAMPLE.DAT を作成しました。 ", CRCHAR, LFCHAR, DALLAR 
Test40Msg2      DB      "        書込み先ファイル SAMPLE.DAT にデータを書込みます。", CRCHAR, LFCHAR
                DB      "              書込みデータ ", DALLAR
Test40Msg3      DB      "        データを書込めませんでした。 エラーコード ", DALLAR
Test40Msg4      DB      "        データを書込みました。", CRCHAR, LFCHAR
                DB      "              書込んだデータ数 ", DALLAR
Test40Msg5      DB      "        ファイル SAMPLE.DAT をクローズしました。",CRCHAR, LFCHAR, DALLAR 

Test3F          DB      "機能番号3F ファイルまたは装置からの読取り", CRCHAR, LFCHAR, DALLAR
Test3FMsg1      DB      "        読取り元ファイル SAMPLE.DAT をオープン出来ませんでした。エラーコード ", DALLAR
Test3FMsg2      DB      "        読取り元ファイル SAMPLE.DAT をオープンしました。ファイルハンドル ", DALLAR 
Test3FMsg3      DB      "        読取り元ファイル SAMPLE.DAT からデータを読取ります。", CRCHAR, LFCHAR, DALLAR
Test3FMsg4      DB      "              データを読取れませんでした。 エラーコード ", DALLAR
Test3FMsg5      DB      "              データを読取りました。", CRCHAR, LFCHAR
                DB      "              読取りデータ ", DALLAR
Test3FMsg6      DB      "              データ長 ", DALLAR
Test3FMsg7      DB      " バイト", CRCHAR, LFCHAR, DALLAR
Test3FMsg8      DB      "        ファイル SAMPLE.DAT をクローズしました。",CRCHAR, LFCHAR, DALLAR 

rc              DW      0         
TstFile1Data    ENDS

TstFile1Code    SEGMENT PARA
                ASSUME  CS:TstFile1Code, DS:TstFile1Data, ES:TstFile1Data, SS:Stack

pause           PROC    NEAR
                @DosDispString PauseMsg
                @DosClrKbdBuf
                @DosDirectInWOEcho bJunk
                @DosDispString NewLine
                @DosDispString NewLine
                RET
pause           ENDP

makeDallarString PROC   NEAR
                LEA     BX, ReadBuffer
                MOV     DI, ReadChars
                MOV     BYTE PTR [BX+DI], DALLAR
                RET
makeDallarString ENDP

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

main            PROC
                MOV     AX, SEG rc      ; setup DS
                MOV     DS, AX

                @DosDispString OpenMsg
                CALL    pause
                @DosSelDisk drvLtrA, wJunk

                @DosDispString Test2F
                @DosGetDTA DefaultDTA
                JNC     main1
                @DosDispString Test2FErr
                MOV     Code, AX
                CALL    uint2hex
                @DosDispString HexBuf
                @DosDispString NewLine
                JMP     main2
main1:
                @DosDispString Test2FMsg1
                MOV     AX, DefaultDTA+2
                MOV     Code, AX
                CALL    uint2dec
                @DosDispString CodeBuf
                @DosDispString Test2FMsg2
                MOV     AX, DefaultDTA
                MOV     Code, AX
                CALL    uint2hex
                @DosDispString HexBuf
                @DosDispString Test2FMsg3
                @DosDispString NewLine
main2:
                CALL    pause
                
                @DosDispString Test1A
                @DosSetDTA NewDTA
                JNC     main3
                MOV     Code, AX
                @DosDispString Test1AErr
                CALL    uint2hex
                @DosDispString NewLine
                JMP     main4
main3:
                @DosGetDTA CurDTA
                @DosDispString Test1AMsg1
                MOV     AX, CurDTA+2
                MOV     Code, AX
                CALL    uint2hex
                @DosDispString HexBuf
                @DosDispString Test1AMsg2
                MOV     AX, CurDTA
                MOV     Code, AX
                CALL    uint2hex
                @DosDispString HexBuf
                @DosDispString Test1AMsg3
                @DosDispString NewLine
main4:
                CALL    pause
                
                @DosDispString Test3C
                @DosCreat FileName, FileAttribute, FileHandle
                JNC     main5
                MOV     Code, AX
                @DosDispString Test3CErr
                CALL    uint2hex
                @DosDispString HexBuf
                @DosDispString NewLine
                JMP     main6
main5:
                @DosDispString Test3CMsg1
                MOV     AX, FileHandle
                MOV     Code, AX
                CALL    uint2dec
                @DosDispString CodeBuf
                @DosDispString Test3CMsg2
                @DosDispString NewLine
main6:
                CALL    pause
                
                @DosDispString Test3E
                @DosClose FileHandle
                JNC     main7
                MOV     Code, AX
                @DosDispString Test3EErr
                CALL    uint2hex
                @DosDispString HexBuf
                @DosDispString NewLine
                JMP     main8
main7:
                @DosDispString Test3EMsg1
                @DosDispString NewLine
main8:
                CALL    pause

                @DosDispString Test3D
                @DosOpen ErrorFileName, FileAccess, FileHandle
                JNC     main9
                MOV     Code, AX
                @DosDispString Test3DMsg1
                CALL    uint2hex
                @DosDispString HexBuf
                @DosDispString NewLine
                JMP     main10
main9:
                @DosDispString Test3DMsg2
                MOV     AX, FileHandle
                MOV     Code, AX
                CALL    uint2dec
                @DosDispString CodeBuf
                @DosDispString NewLine
                @DosClose FileHandle
                @DosDispString Test3DMsg3
main10:
                @DosOpen FileName, FileAccess, FileHandle
                JNC     main11
                MOV     Code, AX
                @DosDispString Test3DMsg4
                CALL    uint2hex
                @DosDispString HexBuf
                @DosDispString NewLine
main11:
                @DosDispString Test3DMsg5
                MOV     AX, FileHandle
                MOV     Code, AX
                CALL    uint2dec
                @DosDispString CodeBuf
                @DosDispString NewLine
                @DosClose FileHandle
                @DosDispString Test3DMsg6
                @DosDispString NewLine
main12:
                CALL    pause
                
                @DosDispString Test41
                @DosDispString Test41Msg1
                @DosDelete ErrorFileName
                JNC     main13
                MOV     Code, AX
                @DosDispString Test41Msg2
                CALL    uint2hex
                @DosDispString HexBuf
                @DosDispString NewLine
                JMP     main14
main13:
                @DosDispString Test41Msg3
                @DosDispString NewLine
main14:
                MOV     FileAccess, DOSREADACCESS
                @DosOpen FileName, FileAccess, FileHandle
                @DosDispString Test41Msg4
                MOV     AX, FileHandle
                MOV     Code, AX
                CALL    uint2dec
                @DosDispString CodeBuf
                @DosDispString NewLine

                @DosDelete FileName
                JNC     main15
                MOV     Code, AX
                @DosDispString Test41Msg5
                CALL    uint2hex
                @DosDispString HexBuf
                @DosDispString NewLine
                JMP     main16
main15:
                @DosDispString Test41Msg6
                @DosDispString NewLine
                JMP     main18
main16:
                @DosClose FileHandle
                @DosDispString Test41Msg7
                @DosDispString NewLine

                @DosDelete FileName
                JNC     main17
                MOV     Code, AX
                @DosDispString Test41Msg8
                CALL    uint2hex
                @DosDispString HexBuf
                @DosDispString NewLine
                JMP     main18
main17:
                @DosDispString Test41Msg9
                @DosDispString NewLine
main18:
                @DosOpen FileName, FileAccess, FileHandle
                JNC     main19
                MOV     Code, AX
                @DosDispString Test41Msg10
                CALL    uint2hex
                @DosDispString HexBuf
                @DosDispString NewLine
                JMP     main20
main19:
                @DosDispString Test41Msg11
                MOV     AX, FileHandle
                MOV     Code, AX
                CALL    uint2dec
                @DosDispString CodeBuf
                @DosDispString NewLine
                @DosClose FileHandle
main20:
                @DosDispString NewLine

                CALL    pause
                
                @DosDispString Test40
                @DosCreat FileName, FileAttribute, FileHandle
                @DosClose FileHandle
                @DosDispString Test40Msg1
                @DosDispString Test40Msg2
                @DosDispString WriteData
                @DosDispString NewLine
                @DosOpen WriteFileName, WriteFileAttribute, WriteFileHandle
                @DosWrite WriteFileHandle, WriteData, WriteDataSize
                JNC     main21
                MOV     Code, AX
                @DosDispString Test40Msg3
                CALL    uint2hex
                @DosDispString HexBuf
                @DosDispString NewLine
                JMP     main22
main21:
                @DosDispString Test40Msg4
                MOV     AX, WriteDataSize
                MOV     Code, AX
                CALL    uint2dec
                @DosDispString CodeBuf
                @DosDispString NewLine
main22:
                @DosClose WriteFileHandle
                @DosDispString Test40Msg5
                @DosDispString NewLine

                CALL    pause
                
                @DosDispString Test3F
                @DosOpen ReadFileName, READFileAttribute, ReadFileHandle
                JNC     main23
                MOV     Code, AX
                @DosDispString Test3FMsg1
                CALL    uint2hex
                @DosDispString HexBuf
                @DosDispString NewLine
                JMP     main25
main23:
                @DosDispString Test3FMsg2
                MOV     AX, ReadFileHandle
                MOV     Code, AX
                CALL    uint2dec
                @DosDispString CodeBuf
                @DosDispString NewLine

                @DosDispString Test3FMsg3
                @DosRead ReadFileHandle, ReadBuffer, ReadChars
                JNC     main24
                MOV     Code, AX
                @DosDispString Test3FMsg4
                CALL    uint2hex
                @DosDispString HexBuf
                @DosDispString NewLine
                JMP     main26
main24:
                @DosDispString Test3FMsg5
                CALL    makeDallarString
                @DosDispString ReadBuffer
                @DosDispString NewLine
                @DosDispString Test3FMsg6
                MOV     AX, ReadChars
                MOV     Code, AX
                CALL    uint2dec
                @DosDispString CodeBuf
                @DosDispString Test3FMsg7
main26:
                @DosClose ReadFileHandle
                @DosDispString Test3FMsg8
                @DosDispString NewLine
main25:
                @DosSelDisk drvLtrC, wJunk
      
                MOV     rc, 00H
                @DosExit rc
main            ENDP
TstFile1Code    ENDS
                END     main
