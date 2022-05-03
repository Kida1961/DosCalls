PAGE    ,132
TITLE   TSTFILE2.ASM -- DOS機能呼び出し File (FILE.ASM)テスト パート2
%OUT    TSTFILE2.ASM
        
INCLUDE CONSTANT.INC
INCL_CONSOLE    EQU     0       ; CONSOLE機能マクロ組み込み
INCL_DISK       EQU     0       ; DISK機能マクロ組み込み
INCL_FILE       EQU     0       ; FILE機能マクロ組み込み
INCL_PROCESS    EQU     0       ; PROCESS機能マクロ組み込み 
INCLUDE DosCalls.MAC
INCLUDE DosCalls.DEF

BUFFERSIZE      EQU     128
CODEBUFSIZE     EQU     6
DWORDBUFSIZE    EQU     10
HEXBUFSIZE      EQU     4
HEXMASK         EQU     000FH

Stack           SEGMENT PARA STACK 'STACK'
                DB      128 DUP("S")
Stack           ENDS

TstFile2Data    SEGMENT PARA
drvLtrA         DB      "A", DALLAR
drvLtrB         DB      "B", DALLAR
drvLtrC         DB      "C", DALLAR
FileName        DB      "DUPFILE.DAT", EOS
FileAttribute   DW      0
FileAccess      DW      0
FileHandle      DW      -1
ReadBuffer      DB      BUFFERSIZE DUP(SHARP), DALLAR
ReadChars       DW      BUFFERSIZE
SeekFileName    DB      "SEEKFILE.DAT", EOS
SeekFileAttribute DW    DOSREADWRITEACCESS
SeekFileHandle  DW      -1
SeekSampleData  DB      "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ", DALLAR
SeekSampleChars DW      $-SeekSampleData-1
SeekPos         DD      0
SeekOffset      DD      0
SeekMethod      DW      0
SeekBuffer      DB      BUFFERSIZE DUP(SHARP)
SeektoHead      DW      0
SeektoTail      DW      0
SeekPosBuffer   DB      DWORDBUFSIZE DUP(SHARP), DALLAR
ChmodFileName   DB      "CHMODFIL.DAT", EOS
ChmodFileAttribute DW   0
ChmodFileAccess DW      DOSREADACCESS
ChmodFileHandle DW      -1
ChmodFlagOn     DB      "ON", DALLAR
ChmodFlagOff    DB      "OFF", DALLAR
FileMod         DW      0
DupFileName     DB      "DUPFILE.DAT", EOS
DupFileAttribute DW     0
DupFileAccess   DW      0
DupFileHandle   DW      -1
DupFileData     DB      "ABCDEFGHIJKLMNOPQRSTUVWXYZ", DALLAR
DupFileDataChars DW     $-DupFileData-1
NewFileHandle   DW      -1
DupFileBuffer   DB      BUFFERSIZE DUP(SHARP), DALLAR
DupFileChars    DB      10
NewFileBuffer   DB      BUFFERSIZE DUP(SHARP), DALLAR
NewFileChars    DB      5
bJunk           DB      BLANK
wJunk           DW      -1
Code            DW      -1
CodeBuf         DB      CODEBUFSIZE DUP(SHARP), DALLAR 
HexBuf          DB      HEXBUFSIZE DUP(SHARP), "H",  DALLAR 
HexChars        DB      "0123456789ABCDEF"
NewLine         DB      CRCHAR, LFCHAR, DALLAR
PauseMsg        DB      "何かキーを押して下さい。", DALLAR
OpenMsg         DB      "FILE.ASM テストプログラム パート 2", CRCHAR, LFCHAR
                DB      "====================================================", CRCHAR, LFCHAR
                DB      "このテストプログラムではDOS機能呼び出し、", CRCHAR, LFCHAR
                DB      "機能番号          機能", CRCHAR, LFCHAR
                DB      "======== ===========================================", CRCHAR, LFCHAR
                DB      "   42    ファイル読み書きポインターの移動", CRCHAR, LFCHAR 
                DB      "   43    ファイルの属性読み取り", CRCHAR, LFCHAR
                DB      "   43    ファイルの属性設定", CRCHAR, LFCHAR        
                DB      "======== ===========================================", CRCHAR, LFCHAR
                DB      "を　テストします。", CRCHAR, LFCHAR 
                DB      "テスト中にドライブ A をアクセスします。", CRCHAR, LFCHAR
                DB      "フォーマットしたディスケットをドライブ A に入れて下さい。", CRCHAR, LFCHAR
                DB      "テストを開始します。", CRCHAR, LFCHAR, DALLAR
Test42          DB      "機能番号42 ファイル読み書きポインターの移動", CRCHAR, LFCHAR, DALLAR
Test42Msg1      DB      "        テストファイル SEEKFILE.DAT を作成します。", CRCHAR, LFCHAR, DALLAR
Test42Msg2      DB      "        テストファイル SEEKFILE.DAT を作成出来ませんでした。 エラーコード ", DALLAR
Test42Msg3      DB      "        テストファイル SEEKFILE.DAT を作成しました。 ファイルハンドル ", DALLAR
Test42Msg4      DB      "        テストデータ ", DALLAR
Test42Msg5      DB      " を書き込めません。 エラーコード ", DALLAR
Test42Msg6      DB      " を書き込みました。", CRCHAR, LFCHAR
                DB      "        データ長 ", DALLAR
Test42Msg8      DB      "        先頭に移動します。", CRCHAR, LFCHAR, DALLAR
Test42Msg9      DB      "        移動出来ません。 エラーコード ", DALLAR
Test42Msg10     DB      "        移動しました。 現在位置 ", DALLAR
Test42Msg11     DB      "        現在位置から読み取り", CRCHAR, LFCHAR, DALLAR
Test42Msg12     DB      "        読み取り出来ません。エラーコード ", DALLAR                      
Test42Msg13     DB      "        読み取りデータ ", DALLAR
Test42Msg14     DB      "        データ長 ", DALLAR
Test42Msg16     DB      "        ファイル先頭から 10 バイト目に移動します。", CRCHAR, LFCHAR, DALLAR
Test42Msg17     DB      "        移動出来ません。 エラーコード ", DALLAR
Test42Msg18     DB      "        移動しました。 現在位置 ", DALLAR
Test42Msg19     DB      "        現在位置から読み取り", CRCHAR, LFCHAR, DALLAR
Test42Msg20     DB      "        読み取り出来ません。エラーコード ", DALLAR
Test42Msg21     DB      "        読み取りデータ ", DALLAR
Test42Msg22     DB      "        データ長 ", DALLAR
Test42Msg24     DB      "        テストファイル SEEKFILE.DAT をクローズしました。",CRCHAR, LFCHAR, DALLAR

Test43          DB      "機能番号43 ファイルの属性設定/読み取り", CRCHAR, LFCHAR, DALLAR
Test43Msg1      DB      "        テストファイル CHMODFIL.DAT を作成します。", CRCHAR, LFCHAR, DALLAR
Test43Msg2      DB      "        テストファイル CHMODFIL.DAT を作成出来ませんでした。 エラーコード ", DALLAR 
Test43Msg3      DB      "        テストファイル CHMODFIL.DAT を作成しました。 ", CRCHAR, LFCHAR, DALLAR
Test43Msg4      DB      "        ファイルの属性を読取ります。", CRCHAR, LFCHAR, DALLAR
Test43Msg5      DB      "        ファイルの属性の読取りに失敗しました。エラーコード ", CRCHAR, LFCHAR, DALLAR
Test43Msg6      DB      "        ファイルの属性の読取りました。", CRCHAR, LFCHAR, DALLAR
Test43Msg7      DB      "        現在の属性", CRCHAR, LFCHAR, DALLAR
Test43Msg8      DB      "            読取り専用ファイル (READONLY)       ", DALLAR
Test43Msg9      DB      "            隠しファイル (HIDDEN)               ", DALLAR
Test43Msg10     DB      "            システム・ファイル (SYSTEM)         ", DALLAR 
Test43Msg11     DB      "            ボリュームラベル (LABEL)            ", DALLAR 
Test43Msg12     DB      "            サブ・ディレクトリー (SUBDIRECTORY) ", DALLAR 
Test43Msg13     DB      "            保存ビット (ARCHIVE)                ", DALLAR 
Test43Msg15     DB      "        ファイルの属性を設定します。", CRCHAR, LFCHAR
                DB      "            隠しファイル (HIDDEN)", CRCHAR, LFCHAR
                DB      "            システム・ファイル (SYSTEM)", CRCHAR, LFCHAR
                DB      "            保存ビット(ARCHIVE)", CRCHAR, LFCHAR, DALLAR
Test43Msg16     DB      "        ファイルの属性の設定に失敗しました。エラーコード ", DALLAR
Test43Msg17     DB      "        ファイルの属性の設定しました。", CRCHAR, LFCHAR, DALLAR
Test43Msg18     DB      "        現在のファイルの属性を読取ります。", CRCHAR, LFCHAR, DALLAR
Test43Msg19     DB      "        ファイルの属性の読取れませんでした。エラーコード ", DALLAR
Test43Msg20     DB      "        ファイルの属性の読取りました。", CRCHAR, LFCHAR, DALLAR
Test43Msg21     DB      "        ファイルの属性を設定します。", CRCHAR, LFCHAR
                DB      "            保存ビット(ARCHIVE)", CRCHAR, LFCHAR, DALLAR

rc              DW      0         
TstFile2Data    ENDS

TstFile2Code    SEGMENT PARA
                ASSUME  CS:TstFile2Code, DS:TstFile2Data, ES:TstFile2Data, SS:Stack

pause           PROC    NEAR
                @DosDispString PauseMsg
                @DosClrKbdBuf
                @DosDirectInWOEcho bJunk
                @DosDispString NewLine
                @DosDispString NewLine
                RET
pause           ENDP

dispMod         PROC    NEAR
                MOV     FileMod, AX
                @DosDispString Test43Msg7
                @DosDispString Test43Msg8
                MOV     AX, FileMod
                AND     AX, WORD PTR DOSREADONLY
                JZ      dispMod1
                @DosDispString ChmodFlagOn
                JMP     dispMod2
dispMod1:                
                @DosDispString ChmodFlagOff
dispMod2:                
                @DosDispString NewLine
                @DosDispString Test43Msg9
                MOV     AX, FileMod
                AND     AX, WORD PTR DOSHIDDEN
                JZ      dispMod3
                @DosDispString ChmodFlagOn
                JMP     dispMod4
dispMod3:                
                @DosDispString ChmodFlagOff
dispMod4:                
                @DosDispString NewLine
                @DosDispString Test43Msg10
                MOV     AX, FileMod
                AND     AX, WORD PTR DOSSYSTEM
                JZ      dispMod5
                @DosDispString ChmodFlagOn
                JMP     dispMod6
dispMod5:                
                @DosDispString ChmodFlagOff
dispMod6:                
                @DosDispString NewLine
                @DosDispString Test43Msg11
                MOV     AX, FileMod
                AND     AX, WORD PTR DOSLABEL
                JZ      dispMod7
                @DosDispString ChmodFlagOn
                JMP     dispMod8
dispMod7:                
                @DosDispString ChmodFlagOff
dispMod8:                
                @DosDispString NewLine
                @DosDispString Test43Msg12
                MOV     AX, FileMod
                AND     AX, WORD PTR DOSSUBDIR
                JZ      dispMod9
                @DosDispString ChmodFlagOn
                JMP     dispMod10
dispMod9:                
                @DosDispString ChmodFlagOff
dispMod10:                
                @DosDispString NewLine
                @DosDispString Test43Msg13
                MOV     AX, FileMod
                AND     AX, WORD PTR DOSARCHIVE
                JZ      dispMod11
                @DosDispString ChmodFlagOn
                JMP     dispMod12
dispMod11:                
                @DosDispString ChmodFlagOff
dispMod12:                
                @DosDispString NewLine
                RET
dispMod         ENDP

makeDallarString PROC   NEAR
                LEA     BX, ReadBuffer
                MOV     DI, ReadChars
                MOV     BYTE PTR [BX+DI], DALLAR
                RET
makeDallarString ENDP

SeekPos2dec     PROC    NEAR
                MOV     CX, DWORDBUFSIZE
                MOV     DI, 0
                LEA     BX, SeekPosBuffer
SeekPos2dec2:
                JCXZ    SeekPos2dec1
                MOV     BYTE PTR [BX+DI], '0'
                INC     DI
                DEC     CX
                JMP     SeekPos2dec2
SeekPos2dec1:
                MOV     DI, DWORDBUFSIZE-1
                MOV     AX, WORD PTR SeekOffset
                MOV     DX, WORD PTR SeekOffset+2
SeekPos2dec5:
                CMP     DX, 0
                JNE     SeekPos2dec3
                CMP     AX, 10
                JL      SeekPos2dec4
SeekPos2dec3:
                CWD
                DIV     CX
                ADD     DL, '0'
                MOV     BYTE PTR [BX+DI], DL
                DEC     DI
                JMP     SeekPos2dec5
SeekPos2dec4:
                ADD     AL, '0'
                MOV     BYTE PTR [BX+DI], AL
                RET
SeekPos2dec     ENDP

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

                @DosDispString Test42
                @DosDispString Test42msg1
                @DosCreat SeekFileName, FileAttribute, SeekFileHandle
                @DosClose SeekFileHandle
                @DosOpen SeekFileName, SeekFileAttribute, SeekFileHandle
                JNC     main1
                MOV     Code, AX
                @DosDispString Test42Msg2
                CALL    uint2hex
                @DosDispString HexBuf
                @DosDispString NewLine
                JMP     main2
main1:
                @DosDispString Test42Msg3
                MOV     AX, SeekFileHandle
                MOV     Code, AX
                CALL    uint2dec
                @DosDispString CodeBuf
                @DosDispString NewLine

                @DosDispString Test42Msg4
                @DosDispString SeekSampleData
                @DosDispString NewLine

                @DosWrite SeekFileHandle, SeekSampleData, SeekSampleChars
                JNC     main3
                MOV     Code, AX
                @DosDispString Test42Msg5
                CALL    uint2hex
                @DosDispString HexBuf
                @DosDispString NewLine
                JMP     main2
main3:
                @DosDispString Test42Msg6
                MOV     AX, SeekSampleChars
                MOV     Code, AX
                CALL    uint2dec
                @DosDispString CodeBuf
                @DosDispString NewLine

                CALL    pause

                @DosDispString Test42Msg8
                @DosLSeek SeekFileHandle, SeekOffset, SeekMethod
                JNC     main4
                MOV     Code, AX
                @DosDispString Test42Msg9
                CALL    uint2hex
                @DosDispString HexBuf
                @DosDispString NewLine
                JMP     main2
main4:
                @DosDispString Test42Msg10
                MOV     AX, WORD PTR SeekOffset
                MOV     Code, AX
                CALL    uint2dec
                @DosDispString CodeBuf
                @DosDispString NewLine

                @DosDispString Test42Msg11
                MOV     ReadChars, BUFFERSIZE
                @DosRead SeekFileHandle, ReadBuffer, ReadChars
                JNC     main5
                MOV     CODE, AX
                @DosDispString Test42Msg12
                CALL    uint2hex
                @DosDispString HexBuf
                @DosDispString NewLine
                JMP     main2
main5:
                @DosDispString Test42Msg13
                CALL    makeDallarString
                @DosDispString ReadBuffer
                @DosDispString NewLine
                @DosDispString Test42Msg14
                MOV     AX, ReadChars
                MOV     Code, AX
                CALL    uint2dec
                @DosDispString CodeBuf
                @DosDispString NewLine

                CALL    pause

                @DosDispString Test42Msg16
                MOV     WORD PTR SeekOffset, 10
                @DosLSeek SeekFileHandle, SeekOffset, SeekMethod
                JNC     main6
                MOV     Code, AX
                @DosDispString Test42Msg17
                CALL    uint2hex
                @DosDispString HexBuf
                @DosDispString NewLine
                JMP     main2
main6:
                @DosDispString Test42Msg18
                MOV     AX, WORD PTR SeekOffset
                MOV     Code, AX
                CALL    uint2dec
                @DosDispString CodeBuf
                @DosDispString NewLine

                @DosDispString Test42Msg19
                MOV     ReadChars, BUFFERSIZE
                @DosRead SeekFileHandle, ReadBuffer, ReadChars
                JNC     main7
                MOV     Code, AX
                @DosDispString Test42Msg20
                CALL    uint2hex
                @DosDispString HexBuf
                @DosDispString NewLine
                JMP     main2
main7:
                @DosDispString Test42Msg21
                CALL    makeDallarString
                @DosDispString ReadBuffer
                @DosDispString NewLine
                @DosDispString Test42Msg22
                MOV     AX, ReadChars
                MOV     Code, AX
                CALL    uint2dec
                @DosDispString CodeBuf
                @DosDispString NewLine
main2:
                @DosClose SeekFileHandle,
                @DosDispString Test42Msg24
                @DosDispString NewLine

                CALL    pause

                @DosDispString Test43
                @DosDispString Test43Msg1
                @DosCreat ChmodFileName, ChmodFileAttribute, ChmodFileHandle
                JNC     main8
                MOV     Code, AX
                @DosDispString Test43Msg2
                CALL    uint2hex
                @DosDispString HexBuf
                @DosDispString NewLine
                JMP     main9
main8:
                @DosDispString Test43Msg3
                @DosClose ChmodFileHandle
                @DosDispString Test43Msg4
                @DosGetMod ChmodFileName, ChmodFileAttribute
                JNC     main10
                MOV     Code, AX
                @DosDispString Test43Msg5
                CALL    uint2hex
                @DosDispString HexBuf
                @DosDispString NewLine
                JMP     main9
main10:
                @DosDispString Test43Msg6

                MOV     AX, ChmodFileAttribute
                CALL    dispMod
                @DosDispString NewLine
                
                CALL    pause

                MOV     AX, WORD PTR (DOSHIDDEN OR DOSSYSTEM OR DOSARCHIVE)
                OR      ChmodFileAttribute, AX
                @DosChmod ChmodFileName, ChmodFileAttribute
                JNC     main11
                MOV     Code, AX
                @DosDispString Test43Msg16
                CALL    uint2hex
                @DosDispString HexBuf
                @DosDispString NewLine
                JMP     main9
main11:
                @DosDispString Test43Msg17
                @DosDispString Test43Msg18
                @DosGetMod ChmodFileName, ChmodFileAttribute
                JNC     main12
                MOV     Code, AX
                @DosDispString Test43Msg19
                CALL    uint2hex
                @DosDispString HexBuf
                @DosDispString NewLine
                JMP     main9
main12:
                @DosDispString Test43Msg6
                @DosDispString Test43Msg20
                MOV     AX, ChmodFileAttribute
                CALL    dispMod
                
                CALL    pause
                
                @DosDispString Test43Msg21
                MOV     AX, WORD PTR DOSARCHIVE
                MOV     ChmodFileAttribute, AX
                @DosChmod ChmodFileName, ChmodFileAttribute
                MOV     AX, ChmodFileAttribute
                CALL    dispMod
                @DosDispString NewLine
                
                @DosDispString PauseMsg 
                @DosClrKbdBuf
                @DosDirectInWOEcho bJunk
                @DosDispString NewLine
main9:
                @DosSelDisk drvLtrC, wJunk
      
                MOV     rc, 00H
                @DosExit rc
main            ENDP
TstFile2Code    ENDS
                END     main
