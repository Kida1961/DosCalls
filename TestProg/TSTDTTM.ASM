PAGE    ,132
TITLE   TSTDTTM.ASM -- DOS機能呼び出し Date/Time (DATETIME.ASM)テスト
%OUT    TSTDTTM.ASM

INCLUDE CONSTANT.INC
INCL_CONSOLE    EQU     0       ; CONSOLE機能マクロ組み込み
INCL_DATETIME   EQU     0       ; DATETIME機能マクロ組み込み
INCL_PROCESS    EQU     0       ; PROCESS機能マクロ組み込み 
INCLUDE DosCalls.MAC
INCLUDE DosCalls.DEF

BUFFERSIZE      EQU     128
CODEBUFSIZE     EQU     6
HEXBUFSIZE      EQU     4
HEXMASK         EQU     000FH

Stack         SEGMENT PARA STACK 'STACK'
                DB      128 DUP("S")
Stack           ENDS

TstDTTMData     SEGMENT PARA
CurDate         @DosDate <0,0,0>
NewDate         @DosDate <2021,11,7> 
TestDate        @DosDate <0,0,0>
ErrDate         @DosDate <2020,13,31>
CurTime         @DosTime <0,0,0,0>
NewTime         @DosTime <1,23,34,45> 
TestTime        @DosTime <0,0,0,0>
ErrTime         @DosTime <25,23,34,45> 
Code            DW      0
CodeBuf         DB      CODEBUFSIZE DUP(SHARP), DALLAR 
HexBuf          DB      HEXBUFSIZE DUP(SHARP), "H",  DALLAR 
HexChars        DB      "0123456789ABCDEF"
newline         DB      CRCHAR, LFCHAR, "$"
PauseMsg        DB      "何かキーを押して下さい。", DALLAR
bjunk           DB      BLANK
rc              DW      0       
OpenMsg         DB      "DateTime.ASM テストプログラム", CRCHAR, LFCHAR
                DB      "=============================", CRCHAR, LFCHAR
                DB      "このテストプログラムではDOS機能呼び出し、", CRCHAR, LFCHAR
                DB      "機能番号          機能", CRCHAR, LFCHAR
                DB      "======== ==============================", CRCHAR, LFCHAR
                DB      "   2A    日付の読取り", CRCHAR, LFCHAR    
                DB      "   2B    日付の設定", CRCHAR, LFCHAR
                DB      "   2C    時刻の読取り", CRCHAR, LFCHAR
                DB      "   2D    時刻の設定", CRCHAR, LFCHAR
                DB      "======== ==============================", CRCHAR, LFCHAR
                DB      "を　テストします。", CRCHAR, LFCHAR 
                DB      "テストを開始します。何かキーを押して下さい。", CRCHAR, LFCHAR, DALLAR 
Test2A          DB      "機能番号2A 日付の読取り.", CRCHAR, LFCHAR
                DB      "        現在の日付 ", DALLAR
Test2AMsg1      DB      " 年 ", DALLAR
Test2AMsg2      DB      " 月 ", DALLAR
Test2AMsg3      DB      " 日", CRCHAR, LFCHAR, DALLAR
Test2B          DB      "機能番号2B 日付の設定", CRCHAR, LFCHAR
                DB      "        2021 年 11 月 7 日に設定します。", CRCHAR, LFCHAR
Test2BMsg       DB      "        現在の日付 ", DALLAR
Test2BMsg4      DB      "        現在の日付を元に戻します。", CRCHAR, LFCHAR
                DB      "        現在の日付 ", DALLAR
Test2BErr1      DB      "        間違った日付 2020 年 13 月 31 日を設定します。", CRCHAR, LFCHAR, DALLAR
Test2BErr2      DB      "        間違った日付を設定しようとしました。 エラーコード ", DALLAR
Test2BErr3      DB      "        現在の日付 ", DALLAR
Test2C          DB      "機能番号2C 時刻の読取り", CRCHAR, LFCHAR
                DB      "        現在の時刻 ", DALLAR
Test2CMsg1      DB      " 時 ", DALLAR
Test2CMsg2      DB      " 分 ", DALLAR
Test2CMsg3      DB      " 秒 ", DALLAR
Test2D          DB      "機能番号2D 時刻の設定", CRCHAR, LFCHAR
                DB      "        時刻 1 時 23 分 34 秒 45 を設定します。", CRCHAR, LFCHAR
Test2DMsg       DB      "        現在の時刻 ", DALLAR
Test2DMsg4      DB      "        現在の時刻を元に戻します。", CRCHAR, LFCHAR
                DB      "        現在の時刻 ", DALLAR
Test2DErr1      DB      "        間違った時刻 25 時 23 分 34 秒 45 を設定します。", CRCHAR, LFCHAR, DALLAR
Test2DErr2      DB      "        間違った時刻を設定しようとしました。 エラーコード ", CRCHAR, LFCHAR, DALLAR
Test2DErr3      DB      "        現在の時刻 ", DALLAR
TstDTTMData     ENDS

TstDTTMCode     SEGMENT PARA
                ASSUME  CS:TstDTTMCode, DS:TstDTTMData, ES:TstDTTMData, SS:Stack

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

dispTime        PROC    NEAR         
                MOV     AX, 0
                MOV     AL, TestTime.@@Hours
                MOV     Code, AX
                CALL    uint2dec
                @DosDispString CodeBuf
                @DosDispString Test2CMsg1

                MOV     AX, 0
                MOV     AL, TestTime.@@Minutes
                MOV     Code, AX
                CALL    uint2dec
                @DosDispString CodeBuf
                @DosDispString Test2CMsg2

                MOV     AX, 0
                MOV     AL, TestTime.@@Seconds
                MOV     Code, AX
                CALL    uint2dec
                @DosDispString CodeBuf
                @DosDispString Test2CMsg3

                MOV     AX, 0
                MOV     AL, TestTime.@@Pseconds
                MOV     Code, AX
                CALL    uint2dec
                @DosDispString CodeBuf
                @DosDispString NewLine
                RET
dispTime        ENDP

dispDate        PROC    NEAR
                MOV     AX, TestDate.@@Year
                MOV     Code, AX
                CALL    uint2dec
                @DosDispString CodeBuf
                @DosDispString Test2AMsg1

                MOV     AX, 0
                MOV     AL, TestDate.@@Month
                MOV     Code, AX
                CALL    uint2dec
                @DosDispString CodeBuf
                @DosDispString Test2AMsg2

                MOV     AX, 0
                MOV     AL, TestDate.@@Day
                MOV     Code, AX
                CALL    uint2dec
                @DosDispString CodeBuf
                @DosDispString Test2AMsg3
                RET
dispDate        ENDP

main            PROC
                MOV     AX, SEG rc      ; setup DS
                MOV     DS, AX

                @DosDispString OpenMsg
                CALL    pause

                @DosDispString Test2A           
                @DosGetDate TestDate            ; 現在日付の読取り      
                CALL    dispDate
                MOV     AX, TestDate.@@Year     ; 日付をセーブ
                MOV     CurDate.@@Year, AX
                MOV     AX, 0
                MOV     AL, TestDate.@@Month
                MOV     CurDate.@@Month, AL
                MOV     AL, TestDate.@@Day
                MOV     CurDate.@@Day, AL

                CALL    pause

                @DosDispString Test2B
                @DosSetDate NewDate             ; 日付の設定
                @DosGetDate TestDate            ; 設定した日付の読取り     
                CALL    dispDate

                @DosDispString Test2BMsg4
                @DosSetDate CurDate             ; 日付を元に戻す
                @DosGetDate TestDate            ; 日付の確認
                CALL    dispDate

                @DosDispString Test2BErr1
                @DosSetDate ErrDate             ; 間違った日付けを設定
                JNC     main1
                MOV     Code, AX
                @DosDispString Test2BErr2
                CALL    uint2hex
                @DosDispString HexBuf
                @DosDispString NewLine
main1:
                @DosDispString Test2BErr3
                @DosGetDate TestDate            ; 日付の確認
                CALL    dispDate

                CALL    pause

                @DosDispString Test2C
                @DosGetTime TestTime            ; 時刻の読取り
                CALL    dispTime
                MOV     AX, 0                   ; 現在時刻をセーブ
                MOV     AL, TestTime.@@Hours
                MOV     CurTime.@@Hours, AL
                MOV     AL, TestTime.@@Minutes
                MOV     CurTime.@@Minutes, AL
                MOV     AL, TestTime.@@Seconds
                MOV     CurTime.@@Seconds, AL
                MOV     AL, TestTime.@@Pseconds
                MOV     CurTime.@@Pseconds, AL

                CALL    pause

                @DosDispString Test2D
                @DosSetTime NewTime             ; 時刻の設定
                @DosGetTime TestTime            ; 時刻の読取り
                CALL    dispTime

                @DosDispString Test2DMsg4
                @DosSetTime CurTime             ; 時刻の設定
                @DosGetTime TestTime            ; 時刻の読取り
                CALL    dispTime

                @DosDispString Test2DErr1
                @DosSetTime ErrTime             ; 間違った時刻を設定
                JNC     main2
                @DosDispString Test2DErr2
main2:
                @DosDispString Test2DErr3
                @DosGetTime TestTime            ; 時刻の読取り
                CALL    dispTime

                MOV     rc, 00H
                @DosExit rc
main            ENDP
TstDTTMCode     ENDS
                END     main
