PAGE    ,132
TITLE   TSTPROC.ASM -- DOS機能呼び出し Process (PROCCESS.ASM)テスト
%OUT    TSTPROC.ASM

INCLUDE CONSTANT.INC
INCL_CONSOLE    EQU     0       ; CONSOLE機能マクロ組み込み
INCL_PROCESS    EQU     0       ; PROCESS機能マクロ組み込み
INCL_GETARGS    EQU     0       ; GETARGS機能マクロ組み込み
INCLUDE DosCalls.MAC
INCLUDE DosCalls.DEF

ARGBUFSIZE      EQU     80
CODEBUFSIZE     EQU     6
HEXBUFSIZE      EQU     4
HEXMASK         EQU     000FH
YES             EQU     0

Stack           SEGMENT PARA STACK 'STACK'
                DB      128 DUP("S")
Stack           ENDS

TstProcData     SEGMENT PARA
rc              DW      0         
argc            DW      0
argv            DB      ARGBUFSIZE DUP(BLANK), DALLAR
bJunk           DB      -1
wJunk           DW      -1
Code            DW      -1
CodeBuf         DB      CODEBUFSIZE DUP(SHARP), DALLAR 
NewLine         DB      CRCHAR, LFCHAR, DALLAR
PauseMsg        DB      "何かキーを押して下さい。", DALLAR
Digits          DB      "0123456789", EOS
DigitFlag       DW      NOT YES
OpenMsg         DB      "PROCESS.ASM テストプログラム", CRCHAR, LFCHAR
                DB      "=======================================", CRCHAR, LFCHAR
                DB      "このテストプログラムではDOS機能呼び出し、", CRCHAR, LFCHAR
                DB      "機能番号          機能", CRCHAR, LFCHAR
                DB      "======== ==============================", CRCHAR, LFCHAR
                DB      "   4C    プログラムの終了", CRCHAR, LFCHAR
                DB      "======== ==============================", CRCHAR, LFCHAR
                DB      "を　テストします。", CRCHAR, LFCHAR 
                DB      "テストを開始します。", CRCHAR, LFCHAR, DALLAR
               
Test4C          DB      "機能番号4C プログラムの終了", CRCHAR, LFCHAR, DALLAR
Test4CUsage     DB      "    テストの仕方", CRCHAR, LFCHAR
                DB      "    TSTPROC nnn", CRCHAR, LFCHAR
                DB      "            nnn は、0 から 255 の数字", CRCHAR, LFCHAR
                DB      "            256 以上の場合、数字列でない場合は、0 と見なされます。", CRCHAR, LFCHAR
                DB      "            数字列は数字以外の文字が出現するまで有効です。", CRCHAR, LFCHAR, DALLAR 
                DB      "            2番以降の引数は無視されます。", CRCHAR, LFCHAR
Test4CMsg1      DB      "        出口コード ", DALLAR
Test4CMsg2      DB      " で終了します。", CRCHAR, LFCHAR, DALLAR

TstProcData     ENDS

TstProcCode     SEGMENT PARA
                ASSUME  CS:TstProcCode, DS:TstProcData, ES:TstProcData, SS:Stack

isDigit         PROC    NEAR
                MOV     DigitFlag, NOT YES
                LEA     SI, digits
isDigit2:         
                CMP     BYTE PTR [SI], EOS
                JE      isDigit1
                CMP     AL, BYTE PTR [SI]
                JE      isDigit3
                INC     SI
                JMP     isDigit2
isDigit3:
                MOV     DigitFlag, YES
isDigit1:         
                RET
isDigit         ENDP

asc2int         PROC    NEAR
                MOV     rc, 0
                LEA     DI, argv
                MOV     AX, 0
                MOV     BX, 0
                MOV     CX, 10
asc2int2:                
                MOV     AL, BYTE PTR [DI]
                CALL    isDigit
                CMP     DigitFlag, NOT YES
                JE      asc2int1
                SUB     AL, '0'
                MOV     BL, AL
                MOV     AX, rc
                MUL     CX
                ADD     AX, BX
                MOV     rc, AX
                INC     DI
                JMP     asc2int2
asc2int1:                
                RET
asc2int         ENDP

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

                MOV     rc,-1

                @DosDispString OpenMsg
                @DosClrKbdBuf
                @DosDirectInWOEcho bJunk

                @getArgc argc
                CMP     argc, 0
                JE      main1
                @getArgv argc, argv
                CALL    asc2int
                CMP     rc, 255
                JG      main2
                JMP     main3
main1:            
                @DosDispString Test4CUsage
                JMP     main4
main2:                
                MOV     rc, 0
main3:
                MOV     argc, 1
                @DosDispString Test4CMsg1
                MOV     AX, rc
                MOV     Code, AX
                CALL    uint2dec
                @DosDispString CodeBuf
                @DosDispString Test4CMsg2
                @DosDispString NewLine
main4:
                @DosExit rc
main            ENDP
TstProcCode     ENDS
                END     main
