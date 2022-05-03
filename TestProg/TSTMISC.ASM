PAGE    ,132
TITLE   TSTMISC.ASM -- DOS機能呼び出し Misceriouse (MISC.ASM)テスト
%OUT    TSTMISC.ASM

INCLUDE CONSTANT.INC
INCL_CONSOLE    EQU     0       ; CONSOLE機能マクロ組み込み
INCL_MISC       EQU     0       ; MISC機能マクロ組み込み
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

TstMiscData     SEGMENT PARA
major           DB      0
minor           DB      0
intType         DB      0FFH
CurVector       DW      0
                DW      0
NewVector       DW      OFFSET SampleIntr
                DW      SEG SampleIntr
VeriStat        DB      DOSOFF
BreakStat       DB      DOSOFF
drvLtr          DB      "A", DALLAR
bJunk           DB      BLANK
cInfo           @DosPSP <>
CurPSPSeg       DW      -1
GetPSPSeg       DW      -1
wJunk           DW      -1
Code            DW      -1
CodeBuf         DB      CODEBUFSIZE DUP(SHARP), DALLAR 
HexBuf          DB      HEXBUFSIZE DUP(SHARP), "H",  DALLAR 
HexChars        DB      "0123456789ABCDEF"
NewLine         DB      CRCHAR, LFCHAR, DALLAR
DStringBuf      DB      BUFFERSIZE DUP(DALLAR)
PauseMsg        DB      "何かキーを押して下さい。", DALLAR
OpenMsg         DB      "MISC.ASM テストプログラム", CRCHAR, LFCHAR
                DB      "=======================================", CRCHAR, LFCHAR
                DB      "このテストプログラムではDOS機能呼び出し、", CRCHAR, LFCHAR
                DB      "機能番号          機能", CRCHAR, LFCHAR
                DB      "======== ==============================", CRCHAR, LFCHAR
                DB      "   33    ブート・ドライブの取得", CRCHAR, LFCHAR
                DB      "   30    DOS バージョンの読取り", CRCHAR, LFCHAR
                DB      "   25    割り込みベクトルの設定", CRCHAR, LFCHAR 
                DB      "   35    割り込みベクトルを得る", CRCHAR, LFCHAR
                DB      "   2E    検査 (VERIFY) スイッチのオン", CRCHAR, LFCHAR
                DB      "   2E    検査 (VERIFY) スイッチのオフ", CRCHAR, LFCHAR
                DB      "   54    VERIFY 状態を得る", CRCHAR, LFCHAR
                DB      "   33    BREAK 状態", CRCHAR, LFCHAR
                DB      "   33    BREAK リセット", CRCHAR, LFCHAR
                DB      "   33    BREAK セット", CRCHAR, LFCHAR
                DB      "   33    BREAK チェック", CRCHAR, LFCHAR
                DB      "   38    各国別情報", CRCHAR, LFCHAR
                DB      "   62    プログラム・セグメント・プリフィックス (PSP) アドレスの取得", CRCHAR, LFCHAR
                DB      "======== ==============================", CRCHAR, LFCHAR
                DB      "を　テストします。", CRCHAR, LFCHAR 
                DB      "テストを開始します。", CRCHAR, LFCHAR, DALLAR
               
Test30          DB      "機能番号30 DOS バージョンの読取り", CRCHAR, LFCHAR, DALLAR
Test30Msg1      DB      "        読み取れませんでした。 エラーコード ", DALLAR
Test30Msg2      DB      "        現在の DOS バージョン", CRCHAR, LFCHAR
                DB      "            整数部 ", DALLAR
Test30Msg3      DB      "            少数部 ", DALLAR

Test35          DB      "機能番号35 割り込みベクトルを得る", CRCHAR, LFCHAR, DALLAR
Test35Msg1      DB      "        割り込みベクトルを得られませんでした。 エラーコード ", DALLAR
Test35Msg2      DB      "        割り込み番号 0FFH の割り込みベクトル ", DALLAR
Test35Msg3      DB      " : ", DALLAR
                
Test25          DB      "機能番号25 割り込みベクトルの設定", CRCHAR, LFCHAR
                DB      "        割り込み番号 0FFH にベクトル ", DALLAR
Test25Msg1      DB      " : ", DALLAR
Test25Msg2      DB      "        を設定します。", CRCHAR, LFCHAR, DALLAR
Test25Msg3      DB      "        設定できませんでした。 エラーコード ", DALLAR
Test25Msg4      DB      "        設定を確認します。", CRCHAR, LFCHAR, DALLAR
Test25Msg5      DB      "        設定されたベクトル ", DALLAR
Test25Msg6      DB      " : ", DALLAR
Test25Msg7      DB      "        割り込みベクトルを元に戻します。", CRCHAR, LFCHAR, DALLAR
Test25Msg8      DB      "        現在の割り込みベクトル ", DALLAR
Test25Msg9      DB      " : ", DALLAR

Test54          DB      "機能番号54 VERIFY 状態を得る", CRCHAR, LFCHAR, DALLAR
Test54Msg1      DB      "        状態を得られませんでした。", CRCHAR, LFCHAR, DALLAR
Test54Msg2      DB      "        現在の VERIFY 状態 ON", CRCHAR, LFCHAR, DALLAR
Test54Msg3      DB      "        現在の VERIFY 状態 OFF", CRCHAR, LFCHAR, DALLAR
                
Test2Ea         DB      "機能番号2E 検査 (VERIFY) スイッチのオフ", CRCHAR, LFCHAR
                DB      "        検査 (VERIFY) スイッチをオフにします。", CRCHAR, LFCHAR, DALLAR
Test2EaMsg1     DB      "        設定できませんでした。 エラーコード ", DALLAR
Test2EaMsg2     DB      "        現在の VERIFY 状態 ON", CRCHAR, LFCHAR, DALLAR
Test2EaMsg3     DB      "        現在の VERIFY 状態 OFF", CRCHAR, LFCHAR, DALLAR
                
Test2Eb         DB      "機能番号2E 検査 (VERIFY) スイッチのオン", CRCHAR, LFCHAR
                DB      "        検査 (VERIFY) スイッチをオンにします。", CRCHAR, LFCHAR, DALLAR
Test2EbMsg1     DB      "        設定できませんでした。 エラーコード ", DALLAR
Test2EbMsg2     DB      "        現在の VERIFY 状態 ON", CRCHAR, LFCHAR, DALLAR
Test2EbMsg3     DB      "        現在の VERIFY 状態 OFF", CRCHAR, LFCHAR, DALLAR

Test33a         DB      "機能番号33a ブート・ドライブの取得", CRCHAR, LFCHAR, DALLAR
Test33aMsg1     DB      "        取得できませんでした。 エラーコード ", DALLAR
Test33aMsg2     DB      "        ブート・ドライブ ", DALLAR
                
Test33b         DB      "機能番号33b BREAK 状態", CRCHAR, LFCHAR, DALLAR
Test33bMsg1     DB      "        取得できませんでした。 エラーコード ", DALLAR
Test33bMsg2     DB      "        現在の BREAK 状態 オン", CRCHAR, LFCHAR, DALLAR
Test33bMsg3     DB      "        現在の BREAK 状態 オフ", CRCHAR, LFCHAR, DALLAR
                
Test33c         DB      "機能番号33c BREAK リセット", CRCHAR, LFCHAR
                DB      "        BREAK をリセットします。", CRCHAR, LFCHAR, DALLAR
Test33cMsg1     DB      "        リセット出来ませんでした。 エラーコード ", DALLAR
Test33cMsg2     DB      "        現在の BREAK 状態 オン", CRCHAR, LFCHAR, DALLAR
Test33cMsg3     DB      "        現在の BREAK 状態 オフ", CRCHAR, LFCHAR, DALLAR

Test33d         DB      "機能番号33d BREAK セット", CRCHAR, LFCHAR
                DB      "        BREAK をセットします。", CRCHAR, LFCHAR, DALLAR
Test33dMsg1     DB      "        セット出来ませんでした。 エラーコード ", DALLAR
Test33dMsg2     DB      "        現在の BREAK 状態 オン", CRCHAR, LFCHAR, DALLAR
Test33dMsg3     DB      "        現在の BREAK 状態 オフ", CRCHAR, LFCHAR, DALLAR

Test38          DB      "機能番号38 各国別情報", CRCHAR, LFCHAR
                DB      "        現在の各国別情報", CRCHAR, LFCHAR, DALLAR
Test38Msg1a     DB      "            日付と時刻の形式 米国式", CRCHAR, LFCHAR, DALLAR 
Test38Msg1b     DB      "            日付と時刻の形式 ヨーロッパ式", CRCHAR, LFCHAR, DALLAR 
Test38Msg1c     DB      "            日付と時刻の形式 日本式", CRCHAR, LFCHAR, DALLAR 
Test38Msg2      DB      "                    通貨記号 ", DALLAR 
Test38Msg3      DB      "          3 桁ごとの分離記号 ", DALLAR
Test38Msg4      DB      "                  小数点文字 ", DALLAR
Test38Msg5      DB      "              日付の分離記号 ", DALLAR
Test38Msg6      DB      "              時刻の分離記号 ", DALLAR
Test38Msg7      DB      "             ビットフィールド", CRCHAR, LFCHAR, DALLAR
Test38Msg7a     DB      "                通貨記号の配置 右に配置", CRCHAR, LFCHAR, DALLAR 
Test38Msg7b     DB      "                通貨記号の配置 左に配置", CRCHAR, LFCHAR, DALLAR 
Test38Msg7c     DB      "                通貨記号と金額の間に スペースを入れる", CRCHAR, LFCHAR, DALLAR 
Test38Msg7d     DB      "                通貨記号と金額の間に スペースを入れない", CRCHAR, LFCHAR, DALLAR 
Test38Msg8      DB      "      金額の小数点以下の桁数 ", DALLAR 
Test38Msg9a     DB      "                  時刻の形式 12 時間形式", CRCHAR, LFCHAR, DALLAR 
Test38Msg9b     DB      "                  時刻の形式 24 時間形式", CRCHAR, LFCHAR, DALLAR 
Test38Msg10     DB      "        データリストの分離符 ", DALLAR

Test62          DB      "機能番号62 プログラム・セグメント・プリフィックス (PSP) アドレスの取得", CRCHAR, LFCHAR, DALLAR
Test62Msg1      DB      "        取得できませんでした。エラーコード ", DALLAR
Test62Msg2      DB      "        プログラム開始時の PSP セグメント ", DALLAR
Test62Msg3      DB      "        機能番号 62 で取得した セグメント ", DALLAR
                
rc              DW      0         
TstMiscData     ENDS

TstMiscCode     SEGMENT PARA
                ASSUME  CS:TstMiscCode, DS:TstMiscData, ES:TstMiscData, SS:Stack

asciiz2dallarstring PROC NEAR
                LEA     SI, DStringBuf
asciiz2dallarstring2:
                MOV     AL, BYTE PTR [DI]
                CMP     AL, BYTE PTR EOS
                JE      asciiz2dallarstring1
                MOV     BYTE PTR [SI], AL
                INC     SI
                INC     DI
                JMP     asciiz2dallarstring2
asciiz2dallarstring1:
                MOV     BYTE PTR [SI], DALLAR
                RET
asciiz2dallarstring ENDP

SampleIntr      PROC    NEAR
                IRET
SampleIntr      ENDP

dispCInfo       PROC    NEAR
                MOV     AX, CInfo.@@DTTMFmt
                CMP     AX, WORD PTR @DOSCINFODTTMFMTUS
                JNE     dispCInfo1
                @DosDispString Test38Msg1a
                JMP     dispCInfo4
dispCInfo1:      
                CMP     AX, WORD PTR @DOSCINFODTTMFMTEURO
                JNE     dispCInfo2
                @DosDispString Test38Msg1b
                JMP     dispCInfo4
dispCInfo2:      
                CMP     AX, WORD PTR @DOSCINFODTTMFMTJPN
                JNE     dispCInfo3
                @DosDispString Test38Msg1c
                JMP     dispCInfo4
dispCInfo3:      
                @DosDispString Test38Msg1c
dispCInfo4:      
                @DosDispString Test38Msg2
                LEA     DI, CInfo.@@CurrSym
                CALL    asciiz2dallarstring
                @DosDispString DStringBuf 
                @DosDispString NewLine
                @DosDispString Test38Msg3
                LEA     DI, CInfo.@@Sep1000
                CALL    asciiz2dallarstring
                @DosDispString DStringBuf 
                @DosDispString NewLine
                
                @DosDispString Test38Msg4
                LEA     DI, CInfo.@@Sep1
                CALL    asciiz2dallarstring
                @DosDispString DStringBuf 
                @DosDispString NewLine
                
                @DosDispString Test38Msg5
                LEA     DI, CInfo.@@SepDate
                CALL    asciiz2dallarstring
                @DosDispString DStringBuf 
                @DosDispString NewLine
                
                @DosDispString Test38Msg6
                LEA     DI, CInfo.@@SepTime
                CALL    asciiz2dallarstring
                @DosDispString DStringBuf
                @DosDispString NewLine
                
                @DosDispString Test38Msg7
                MOV     AL, BYTE PTR CInfo.@@BitField
                AND     AL, BYTE PTR @DOSCINFOCURFMTLRMASK
                CMP     AL, BYTE PTR @DOSCINFOCURFMTLEFT
                JNZ     dispCInfo5
                @DosDispString Test38Msg7a
                JMP     dispCInfo6
dispCInfo5:       
                @DosDispString Test38Msg7b
dispCInfo6:                
                MOV     AL, BYTE PTR CInfo.@@BitField
                AND     AL, BYTE PTR @DOSCINFOCURFMTSPCMASK
                CMP     AL, BYTE PTR @DOSCINFOCURFMTSPACE
                JNZ     dispCInfo7
                @DosDispString Test38Msg7c
                JMP     dispCInfo8
dispCInfo7:       
                @DosDispString Test38Msg7d
dispCInfo8:       
                @DosDispString Test38Msg8
                MOV     AX, 0
                MOV     AL, CInfo.@@SigDigits
                MOV     Code, AX
                CALL    uint2dec
                @DosDispString CodeBuf
                @DosDispString NewLine

                MOV     AL, BYTE PTR CInfo.@@TimeFmt
                CMP     AL, BYTE PTR @DOSCINFOTIMEFMT12
                JNE     dispCInfo9
                @DosDispString Test38Msg9a
dispCInfo9:       
                CMP     AL, BYTE PTR @DOSCINFOTIMEFMT24
                JNE     dispCInfo10
                @DosDispString Test38Msg9b
dispCInfo10:       
                @DosDispString Test38Msg10
                LEA     DI, CInfo.@@SepData
                CALL    asciiz2dallarstring
                @DosDispString DStringBuf 
                @DosDispString NewLine
                RET
dispCInfo       ENDP

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
                MOV     CurPSPSeg, ES

                @DosDispString OpenMsg
                @DosClrKbdBuf
                @DosDirectInWOEcho bJunk

                @DosDispString Test30
                @DosVersion major, minor
                JNC     main1
                MOV     Code, AX
                @DosDispString Test30Msg1
                CALL    uint2dec
                @DosDispString CodeBuf
                @DosDispString NewLine
                JMP     main2
main1:          
                @DosDispString Test30Msg2
                MOV     AX, 0
                MOV     AL, major
                MOV     Code, AX
                CALL    uint2dec
                @DosDispString CodeBuf
                @DosDispString NewLine
                @DosDispString Test30Msg3
                MOV     AX, 0
                MOV     AL, minor
                MOV     Code, AX
                CALL    uint2dec
                @DosDispString CodeBuf
                @DosDispString NewLine
main2:          
                CALL    pause
                @DosDispString Test35
                @DosGetIntVect intType, CurVector
                JNC     main3
                MOV     Code, AX
                @DosDispString Test35Msg1
                CALL    uint2dec
                @DosDispString CodeBuf
                @DosDispString NewLine
                JMP     main4
main3:          
                @DosDispString Test35Msg2
                MOV     AX, CurVector+2
                MOV     Code, AX
                CALL    uint2hex
                @DosDispString HexBuf
                @DosDispString Test35msg3
                MOV     AX, CurVector
                MOV     Code, AX
                CALL    uint2hex
                @DosDispString HexBuf
                @DosDispString NewLine
main4:          
                CALL    pause
                @DosDispString Test25
                MOV     AX, NewVector+2
                MOV     Code, AX
                CALL    uint2hex
                @DosDispString HexBuf
                @DosDispString Test25Msg1
                MOV     AX, NewVector
                MOV     Code, AX
                CALL    uint2hex
                @DosDispString HexBuf
                @DosDispString NewLine
                @DosDispString Test25Msg2
                @DosSetIntVect intType, NewVector
                JNC     main5
                MOV     Code, AX
                @DosDispString Test25Msg3
                CALL    uint2dec
                @DosDispString CodeBuf
                @DosDispString NewLine
                JMP     main6
main5:                
                @DosDispString Test25Msg4
                MOV     NewVector, 0
                MOV     NewVector+2, 0
                @DosGetIntVect intType, NewVector
                @DosDispString Test25Msg5
                MOV     AX, NewVector+2
                MOV     Code, AX
                CALL    uint2hex
                @DosDispString HexBuf
                @DosDispString Test25Msg6
                MOV     AX, NewVector
                MOV     Code, AX
                CALL    uint2hex
                @DosDispString HexBuf
                @DosDispString NewLine

                @DosDispString Test25Msg7
                @DosDispString Test25Msg8
                @DosSetIntVect intType, CurVector
                MOV     AX, CurVector+2
                MOV     Code, AX
                CALL    uint2hex
                @DosDispString HexBuf
                @DosDispString Test25Msg9
                MOV     AX, CurVector
                MOV     Code, AX
                CALL    uint2hex
                @DosDispString HexBuf
                @DosDispString NewLine
main6:                
                CALL    pause
                @DosDispString Test54
                @DosVerifyStatus VeriStat
                JNC     main7
                MOV     Code, AX
                @DosDispString Test54Msg1
                CALL    uint2dec
                @DosDispString CodeBuf
                @DosDispString NewLine
                JMP     main8
main7:                
                CMP     VeriStat, DOSOFF
                JE      main9
                @DosDispString Test54Msg2
                JMP     main10
main9:               
                @DosDispString Test54Msg3
main10:                
main8:                
                CALL    pause
                @DosDispString Test2Ea
                @DosResetVerify
                JNC     main11
                MOV     Code, AX
                @DosDispString Test2EaMsg1
                CALL    uint2dec
                @DosDispString CodeBuf
                @DosDispString NewLine
                JMP     main12
main11:
                MOV     VeriStat, DOSON
                @DosVerifyStatus VeriStat
                CMP     VeriStat, DOSOFF
                JE      main13
                @DosDispString Test2EaMsg2
                JMP     main14
main13:
                @DosDispString Test2EaMsg3
main14:
main12:
                CALL    pause
                @DosDispString Test2Eb
                @DosSetVerify
                JNC     main15
                MOV     Code, AX
                @DosDispString Test2EbMsg1
                CALL    uint2dec
                @DosDispString CodeBuf
                @DosDispString NewLine
                JMP     main16
main15:
                MOV     VeriStat, DOSON
                @DosVerifyStatus VeriStat
                CMP     VeriStat, DOSOFF
                JE      main17
                @DosDispString Test2EbMsg2
                JMP     main18
main17:
                @DosDispString Test2EbMsg3
main18:
main16:                
                CALL    pause
                @DosDispString Test33a
                @DosBootDrive drvLtr
                JNC     main19
                MOV     Code, AX
                @DosDispString Test33aMsg1
                CALL    uint2dec
                @DosDispString CodeBuf
                @DosDispString NewLine
                JMP     main20
main19:
                @DosDispString Test33aMsg2
                @DosDispString drvLtr
                @DosDispString NewLine
main20:
                CALL    pause
                @DosDispString Test33b
                @DosGetBreak BreakStat
                JNC     main21
                MOV     Code, AX
                @DosDispString Test33bMsg1
                CALL    uint2dec
                @DosDispString CodeBuf
                @DosDispString NewLine
                JMP     main22
main21:
                CMP     BreakStat, DOSOFF
                JE      main23
                @DosDispString Test33bMsg2
                JMP     main24
main22:
                @DosDispString Test33bMsg3
main23:
main24:
                CALL    pause
                @DosDispString Test33c
                @DosGetBreak BreakStat
                JNC     main25
                MOV     Code, AX
                @DosDispString Test33cMsg1
                CALL    uint2dec
                @DosDispString CodeBuf
                @DosDispString NewLine
                JMP     main27
main25:
                CMP     BreakStat, DOSOFF
                JE      main26
                @DosDispString Test33cMsg2
                JMP     main27
main26:
                @DosDispString Test33cMsg3
main27:
                CALL    pause
                @DosDispString Test33d
                @DosGetBreak BreakStat
                JNC     main28
                MOV     Code, AX
                @DosDispString Test33dMsg1
                CALL    uint2dec
                @DosDispString CodeBuf
                @DosDispString NewLine
                JMP     main29
main28:
                CMP     BreakStat, DOSOFF
                JE      main30
                @DosDispString Test33dMsg2
                JMP     main31
main30:
                @DosDispString Test33dMsg3
main31:
main29:
                CALL    pause
                @DosDispString Test38
                @DosGetCountryInfo cInfo
                JNC     main32
                MOV     Code, AX
                CALL    uint2dec
                @DosDispString CodeBuf
                @DosDispString NewLine
                JMP     main32
main32:
                CALL    dispCInfo
main33:
                CALL    pause
                @DosDispString Test62
                @DosGetPSP GetPSPSeg
                JNC     main34
                MOV     Code, AX
                @DosDispString Test62Msg1
                CALL    uint2dec
                @DosDispString CodeBuf
                @DosDispString NewLine
                JMP     main35
main34:
                @DosDispString Test62Msg2
                MOV     AX, CurPSPSeg
                MOV     Code, AX
                CALL    uint2hex
                @DosDispString HexBuf
                @DosDispString NewLine
                @DosDispString Test62Msg3
                MOV     AX, GetPSPSeg
                MOV     Code, AX
                CALL    uint2hex
                @DosDispString HexBuf
                @DosDispString NewLine
main35:
                MOV     rc, 00H
                @DosExit rc
main            ENDP
TstMiscCode     ENDS
                END     main
