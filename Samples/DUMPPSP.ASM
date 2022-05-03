PAGE    ,132
TITLE   DUMPPSP.ASM -- Dump out PSP
%OUT    DUMPPSP.ASM

INCLUDE CONSTANT.INC
INCL_CONSOLE    EQU     0    
INCL_MISC       EQU     0    
INCL_PROCESS    EQU     0    
INCLUDE DosCalls.MAC
INCLUDE DosCalls.DEF

CMDLINESIZE     EQU     127
DECBUFSIZE      EQU     6
HEXBUFSIZE      EQU     4
HEXMASK         EQU     000FH

Stack           SEGMENT PARA STACK 'STACK'
                DB      128 DUP("S")
Stack           ENDS

DumpPSPData     SEGMENT PARA
ptrPSP          DW      -1
ErrCode         DW      -1
Num             DW      -1
CmdParmBuf      DB      CMDLINESIZE DUP(SHARP), DALLAR
DecBuf          DB      DECBUFSIZE DUP(SHARP), DALLAR
DecChar         DB      "0123456789", EOS
HexBuf          DB      HEXBUFSIZE DUP(SHARP), DALLAR
HexChars        DB      "0123456789ABCDEF", EOS
NewLine         DB      CRCHAR, LFCHAR, DALLAR
OpenMsg         DB      "          DumpPSP -- "
                DB      "プログラム・セグメント接頭部 (PSP) ダンプアウト"
                DB      CRCHAR, LFCHAR, DALLAR
Msg1            DB      "                                Int 21H ", DALLAR
Msg2            DB      "               空メモリーの開始アドレス ", DALLAR 
MSG3            DB      "                           終了アドレス ", DALLAR 
MSG4            DB      "                     Break 出口アドレス ", DALLAR 
MSG5            DB      "               致命的エラー出口アドレス ", DALLAR 
MSG6            DB      "                     環境変数ポインター ", DALLAR 
MSG7            DB      "                             DOS コール ", DALLAR 
MSG8            DB      "           コマンド・パラメーター文字数 ", DALLAR 
MSG9            DB      "                 コマンド・パラメーター [", DALLAR
MSG10           DB      "]", DALLAR
HexSepa         DB      " : ", DALLAR
rc              DW      0
bJunk           DB      BLANK
wJunk           DW      -1
DumpPSPData     ENDS

DumpPSPCode     SEGMENT PARA
                ASSUME  CS:DumpPSPCode, DS:DumpPSPData, ES:DumpPSPData, SS:Stack

fillBlanks      PROC    NEAR
fillBlanks2:
                MOV     AL, [DI]
                CMP     AL, BYTE PTR DALLAR
                JE      fillBlanks1
                MOV     BYTE PTR [DI], BLANK
                INC     DI
                JMP     fillBlanks2
fillBlanks1:
                RET
fillBlanks      ENDP

;       二進から十六進文字変換
byte2HexChar    PROC    NEAR
                LEA     BX, HexChars
                ADD     BX, AX
                MOV     AL, [BX]
                RET
byte2HexChar    ENDP

;       二進から十六進文字列変換
uint2hex        PROC    NEAR
                LEA     DI, HexBuf
                CALL    fillBlanks
                MOV     DI, HEXBUFSIZE-1
                MOV     DX, HEXBUFSIZE
                MOV     CL, 4
uint2hex2:
                CMP     DX, 0
                JE      uint2hex1
                MOV     AX, Num
                AND     AX, HEXMASK
                CALL    byte2HexChar
                LEA     BX, HexBuf
                MOV     BYTE PTR [BX+DI], AL
                MOV     AX, Num
                SHR     AX, CL
                MOV     Num, AX
                DEC     DI
                DEC     DX
                JMP     uint2hex2
uint2hex1:
                RET
uint2hex        ENDP

;       二進から十進文字変換
bin2DecChar     PROC    NEAR
                LEA     BX, DecChar
                ADD     BX, AX
                MOV     AL, BYTE PTR [BX]
                RET
bin2DecChar     ENDP

;       二進から十進文字列変換
uint2dec        PROC    NEAR
                LEA     DI, DecBuf
                CALL    fillBlanks
                MOV     DI, DECBUFSIZE-1
                MOV     CX, 10
uint2dec2:      
                MOV     AX, Num
                CMP     AX, 10
                JL      uint2dec1
                CWD
                DIV     CX
                MOV     Num, AX
                MOV     AX, 0
                MOV     AL, DL
                CALL    bin2DecChar
                LEA     BX, DecBuf
                MOV     BYTE PTR [BX+DI], AL
                DEC     DI
                JMP     uint2dec2
uint2dec1:                
                CALL    bin2DecChar
                LEA     BX, DecBuf
                MOV     BYTE PTR [BX+DI], AL
                RET
uint2dec        ENDP

main            PROC    NEAR
                MOV     AX, SEG rc      ; Setup DS
                MOV     DS, AX

                @DosDispString OpenMsg

                ; PSP を取得し表示
                @DosGetPSP ptrPSP
                MOV     ES, ptrPSP
                @DosDispString Msg1
                MOV     AX, ES:@@INT20H
                MOV     Num, AX
                CALL    uint2hex
                @DosDispString HexBuf
                @DosDispString NewLine
                
                @DosDispString Msg2
                MOV     AX, ES:@@TopOfMem
                MOV     Num, AX
                CALL    uint2hex
                @DosDispString HexBuf
                @DosDispString NewLine
                
                @DosDispString Msg3
                MOV     AX, ES:@@Terminate+2
                MOV     Num, AX
                CALL    uint2hex
                @DosDispString HexBuf
                @DosDispString HexSepa
                MOV     AX, ES:@@Terminate
                MOV     Num, AX
                CALL    uint2hex
                @DosDispString HexBuf
                @DosDispString NewLine
                
                @DosDispString Msg4
                MOV     AX, ES:@@BreakExit+2
                MOV     Num, AX
                CALL    uint2hex
                @DosDispString HexBuf
                @DosDispString HexSepa
                MOV     AX, ES:@@BreakExit
                MOV     Num, AX
                CALL    uint2hex
                @DosDispString HexBuf
                @DosDispString NewLine
                
                @DosDispString Msg5
                MOV     AX, ES:@@CriticalExt+2
                MOV     Num, AX
                CALL    uint2hex
                @DosDispString HexBuf
                @DosDispString HexSepa
                MOV     AX, ES:@@CriticalExt
                MOV     Num, AX
                CALL    uint2hex
                @DosDispString HexBuf
                @DosDispString NewLine
                
                @DosDispString Msg6
                MOV     AX, ES:@@EnvPtr
                MOV     Num, AX
                CALL    uint2hex
                @DosDispString HexBuf
                @DosDispString NewLine
                
                @DosDispString Msg7
                MOV     AX, ES:@@DosCall
                MOV     Num, AX
                CALL    uint2hex
                @DosDispString HexBuf
                @DosDispString NewLine
                
                @DosDispString Msg8
                MOV     AX, 0
                MOV     AL, ES:@@ParamLen
                MOV     Num, AX
                CALL    uint2dec
                @DosDispString DecBuf
                @DosDispString NewLine

                MOV     CX, 0
                MOV     CL, ES:@@ParamLen
                PUSH    DS
                MOV     DS, ptrPSP
                MOV     AX, @@Param      
                MOV     SI, AX
                MOV     AX, SEG CmdParmBuf
                MOV     ES, AX
                LEA     DI, CmdParmBuf
                CLD
                REP     MOVSB
                POP     DS
                MOV     BYTE PTR [DI], DALLAR
                @DosDispString Msg9
                @DosDispString CmdParmBuf
                @DosDispString Msg10
                @DosDispString NewLine

                MOV     rc, 0
                @DosExit rc
main            ENDP
DumpPSPCode     ENDS
                END     main
