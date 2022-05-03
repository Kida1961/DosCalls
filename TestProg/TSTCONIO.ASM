PAGE    ,132
TITLE   TSTCONIO.ASM -- DOS機能呼び出し Console I/O (CONSOLE.ASM)テスト
%OUT    TSTCONIO.ASM

INCLUDE CONSTANT.INC
INCL_CONSOLE    EQU     0       ; CONSOLE機能マクロ組み込み
INCL_PROCESS    EQU     0       ; PROCESS機能マクロ組み込み 
INCLUDE DosCalls.MAC
INCLUDE DosCalls.DEF

BUFFERSIZE      EQU     128
CODEBUFSIZE     EQU     6

Stack           SEGMENT PARA STACK 'STACK'
                DB      128 DUP("S")
Stack           ENDS

TstConioData    SEGMENT PARA
Buffer          DB      BUFFERSIZE DUP('%'), DALLAR
Char            DB      BLANK
Chars           DW      0
Code            DW      0
CodeBuf         DB      CODEBUFSIZE DUP(BLANK), DALLAR
KbdStatus       DW      0
NewLine         DB      CRCHAR, LFCHAR, DALLAR
Blanks          DB      BLANK, BLANK, BLANK, BLANK, BLANK, DALLAR 
Arrow           DB      " ==> ", DALLAR
OpenMsg         DB      "Console.ASM テストプログラム", CRCHAR, LFCHAR
                DB      "============================", CRCHAR, LFCHAR
                DB      "このテストプログラムではDOS機能呼び出し、", CRCHAR, LFCHAR
                DB      "機能番号          機能", CRCHAR, LFCHAR
                DB      "======== ==============================", CRCHAR, LFCHAR
                DB      "    1    キーボード入力", CRCHAR, LFCHAR
                DB      "    2    ディスプレー出力", CRCHAR, LFCHAR
                DB      "    3    補助(RS-232Cポート)入力", CRCHAR, LFCHAR
                DB      "    4    補助(RS-232Cポート)出力", CRCHAR, LFCHAR
                DB      "    5    プリンター出力", CRCHAR, LFCHAR
                DB      "    6    直接コンソール入力", CRCHAR, LFCHAR
                DB      "    6    直接コンソール出力", CRCHAR, LFCHAR
                DB      "    7    エコーなしの直接コンソール入力", CRCHAR, LFCHAR
                DB      "    8    エコーなしのコンソール入力", CRCHAR, LFCHAR
                DB      "    9    ストリングの表示", CRCHAR, LFCHAR
                DB      "    A    バッファー付キーボード入力", CRCHAR, LFCHAR
                DB      "    B    キーボード状況のチェック", CRCHAR, LFCHAR
                DB      "    C    キーボード・バッファーの消去", CRCHAR, LFCHAR
                DB      "======== ==============================", CRCHAR, LFCHAR
                DB      "を　テストします。", CRCHAR, LFCHAR 
                DB      "注意", CRCHAR, LFCHAR 
                DB      "機能番号 3,4のテストには、RS-232Cポートで接続された、"
                DB      "コンピューターが必要です。", CRCHAR, LFCHAR
                DB      "通信パラメーターは、2400ボー、パリティーなし、"
                DB      "1ストップビット、8ビット長です。", CRCHAR, LFCHAR
                DB      "機能番号 5のテストには、接続されたプリンターが必要です。", CRCHAR, LFCHAR
                DB      "これらのテストは、スキップできます。", CRCHAR, LFCHAR, CRCHAR, LFCHAR 
                DB      "テストを開始します。何かキーを押して下さい。", CRCHAR, LFCHAR, DALLAR 
Test1           DB      "機能番号1 キーボード入力テスト. 文字をタイプ(# 文字で終了) ", CRCHAR, LFCHAR, DALLAR
Test2           DB      "機能番号2 ディスプレー出力テスト. 文字列 ABCDEFG を表示します。"
                DB      CRCHAR, LFCHAR, DALLAR
Test2Chars      DB      "ABCDEFG", CRCHAR, LFCHAR, DALLAR
Test3           DB      "機能番号3 補助(RS-232Cポート)入力テスト. (スキップするには S)", DALLAR
Test3Msg        DB      "    接続したコンピューターから、文字を入力して下さい。(# 文字で終了)", CRCHAR, LFCHAR, DALLAR
Test4           DB      "機能番号4 補助(RS-232Cポート)出力テスト. (スキップするには S)", DALLAR
Test4Msg        DB      "    ABCDEFG を送信します。", CRCHAR, LFCHAR, DALLAR
Test4Chars      DB      "ABCDEFG", SHARP, CRCHAR, LFCHAR, DALLAR
Test5           DB      "機能番号5 プリンター出力テスト. (スキップするには S)", DALLAR
Test5Msg        DB      "    ABCDEFG を印字します。", CRCHAR, LFCHAR, DALLAR 
Test5Chars      DB      "ABCDEFG", CRCHAR, LFCHAR, DALLAR
Test6a          DB      "機能番号6 直接コンソール入力テスト", CRCHAR, LFCHAR
                DB      "    文字をタイプして下さい。(# 文字で終了) >", CRCHAR, LFCHAR, DALLAR
Test6b          DB      "機能番号6 直接コンソール出力テスト. ABCDEFG を表示します。", CRCHAR, LFCHAR, DALLAR 
Test6bChars     DB      "ABCDEFG", CRCHAR, LFCHAR, DALLAR
Test7           DB      "機能番号7 エコーなしの直接コンソール入力テスト. ", CRCHAR, LFCHAR
                DB      "    文字をタイプして下さい。(# 文字で終了) >", CRCHAR, LFCHAR, DALLAR
Test8           DB      "機能番号8 エコーなしのコンソール入力テスト", CRCHAR, LFCHAR
                DB      "    文字をタイプして下さい。(# 文字で終了) >", CRCHAR, LFCHAR, DALLAR
Test9           DB      "機能番号9 ストリングの表示テスト. 文字列 ABCDEFG を表示します。"
Test9Msg        DB      "ABCDEF", CRCHAR, LFCHAR, DALLAR
TestA           DB      "機能番号A バッファー付キーボード入力テスト", CRCHAR, LFCHAR
                DB      "    文字をタイプして下さい。 > ", DALLAR
TestAMsg1       DB      "    読み込んだ文字数  ", DALLAR
TestAMsg2       DB      " 文字", CRCHAR, LFCHAR, DALLAR
TestAMsg3       DB      "    読み込んだ文字列 ", DALLAR
TestAMsg4       DB      CRCHAR, LFCHAR, DALLAR
TestB           DB      "機能番号B キーボード状況のチェックテスト. キーを押して下さい。 >", CRCHAR, LFCHAR, DALLAR
TestBMsg        DB      "    キーが押されました。", CRCHAR, LFCHAR, DALLAR
TestC           DB      "機能番号C キーボード・バッファーの消去", CRCHAR, LFCHAR, DALLAR
TestCMsg        DB      "    キーボード・バッファーの内容を消去しました", CRCHAR, LFCHAR, DALLAR
rc              DW      0         
TstConioData    ENDS

TstConioCode    SEGMENT PARA
                ASSUME  CS:TstConioCode, DS:TstConioData, ES:TstConioData, SS:Stack

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
                @DosClrKbdBuf
                @DosDirectInWOEcho Char

                @DosDispString Test1
main2:
                @DosConInEcho Char
                CMP     BYTE PTR Char, SHARP
                JE      main1
                @DosDispString Arrow   
                @DosDirectOut Char
                @DosDispString Newline
                JMP     main2
main1:
                @DosDispString Newline

                @DosDispString Test2
                LEA     DI, Test2Chars
main3:                
                MOV     AL, BYTE PTR [DI]
                CMP     AL, BYTE PTR DALLAR
                JE      main4
                MOV     Char, AL
                @DosDispOut Char
                INC     DI
                JMP     main3
main4:                
                @DosDispString Test3
                @DosConInEcho Char
                CMP     BYTE PTR Char, "S"
                JE      main5
                CMP     BYTE PTR Char, "s"
                JE      main5
                @DosDispString Newline
                @DosDispString Test3Msg
main6:          
                @DosAuxIn Char
                CMP     BYTE PTR Char, SHARP
                JE      main5
                @DosDirectOut Char
                JMP     main6
main5:
                @DosDispString Newline
                @DosDispString Test4
                @DosConInEcho Char
                CMP     BYTE PTR Char, "S"
                JE      main7
                CMP     BYTE PTR Char, "s"
                JE      main7
                @DosDispString Newline
                @DosDispString Test4Msg
                LEA     DI, Test4Chars
main8:          
                MOV     AL, BYTE PTR [DI]
                CMP     AL, BYTE PTR SHARP
                JE      main7
                MOV     BYTE PTR Char, AL
                @DosAuxOut Char
                INC     DI
                JMP     main8
main7:
                @DosDispString Newline
                @DosDispString Test5
                @DosConInEcho Char
                CMP     BYTE PTR Char, "S"
                JE      main9
                CMP     BYTE PTR Char, "s"
                JE      main9
                @DosDispString Newline
                @DosDispString Test5Msg
                LEA     DI, Test5Chars
main10:                
                MOV     AL, BYTE PTR [DI]
                CMP     AL, BYTE PTR DALLAR
                JE      main9
                MOV     BYTE PTR Char, AL
                @DosPrnOut Char
                INC     DI
                JMP     main10
main9:
                @DosDispString Newline
                @DosDispString Test6a
main12a:
                @DosDirectIn Char
                MOV     AL, BYTE PTR Char
                CMP     AL, BYTE PTR SHARP
                JE      main11a
                CMP     AL, 00
                JE      main12a
                @DosDispString Arrow   
                @DosDirectOut Char
                @DosDispString Newline
                JMP     main12a
main11a:
                @DosDispString Newline
                @DosDispString Test6b
                LEA     DI, Test6bChars
main12b:
                MOV     AL, BYTE PTR [DI]
                CMP     AL, BYTE PTR DALLAR
                JE      main11b
                MOV     BYTE PTR Char, AL
                @DosDirectOut Char
                INC     DI
                JMP     main12b
main11b:
                @DosDispString Newline
                @DosDispString Test7
main14:
                @DosDirectInWOEcho Char
                MOV     AL, BYTE PTR Char
                CMP     AL, BYTE PTR SHARP
                JE      main13
                @DosDispString Arrow   
                @DosDirectOut Char
                @DosDispString Newline
                JMP     main14
main13:
                @DosDispString Newline
                @DosDispString Test8
main16:
                @DosConInWOEcho Char
                MOV     AL, BYTE PTR Char
                CMP     AL, BYTE PTR SHARP
                JE      main15
                @DosDispString Arrow   
                @DosDirectOut Char
                @DosDispString Newline
                JMP     main16
main15:
                @DosDispString Newline
                @DosDispString Test9
                @DosDispString Test9Msg

                @DosDispString Newline
                @DosDispString TestA
                @DosBufKbdIn Buffer, Chars
                @DosDispString Newline
                LEA     BX, Buffer
                MOV     DI, WORD PTR Chars
                MOV     BYTE PTR [BX+DI], DALLAR
                MOV     Code, DI
                CALL    uint2Dec
                @DosDispString TestAMsg1
                @DosDispString CodeBuf
                @DosDispString TestAMsg2
                @DosDispString TestAMsg3
                @DosDispString Buffer
                @DosDispString TestAMsg4

                @DosDispString Newline
                @DosDispString TestC
                @DosClrKbdBuf
                @DosDispString TestCMsg
                
                @DosDispString TestB
main17:
                @DosKbdStatus KbdStatus
                CMP     KbdStatus, DOSKBDREADY
                JNE     main17
                @DosDispString TestBMsg
                @DosClrKbdBuf
                
                MOV     rc, 00H
                @DosExit rc
main            ENDP
TstConioCode    ENDS
                END     main
