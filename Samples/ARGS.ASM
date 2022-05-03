PAGE    ,132
TITLE   ARGS.ASM -- getArgc, getArgv sample
%OUT ARGS.ASM

INCLUDE CONSTANT.INC
INCL_CONSOLE    EQU     0       
INCL_GETARGS    EQU     0       
INCL_PROCESS    EQU     0       
INCLUDE DOSCALLS.MAC
INCLUDE DOSCALLS.DEF
                
BUFSIZ          EQU     80
CODEBUFSIZE     EQU     6

Stack           SEGMENT PARA STACK 'STACK'
                DB      128 DUP("@")
Stack           ENDS

ArgsData        SEGMENT PARA
Argc            DW      0
ArgIndex        DW      0FFFFH
Argv            DB      BUFSIZ+1 DUP("$"), "$"
ArgMsg1         DB      "[", "$"
ArgMsg2         DB      "]", CRCHAR, LFCHAR, "$"
Code            DW      -1
CodeBuf         DB      CODEBUFSIZE DUP(SHARP), DALLAR 
rc              DW      0
ArgsData        ENDS

ArgsCode        SEGMENT PARA
                ASSUME  CS:ArgsCode, DS:ArgsData, ES:ArgsData, SS:Stack

;       uint2dec -- 二進から数字列に変換
uint2dec        PROC    NEAR
                LEA     DI, CodeBuf
                MOV     CX, CODEBUFSIZE
uint2dec2:
                JCXZ    uint2dec1
                MOV     BYTE PTR [DI], BLANK
                INC     DI
                DEC     CX
                JMP     uint2dec2
uint2dec1:
                LEA     BX, CodeBuf
                MOV     DI, CODEBUFSIZE-1
                MOV     AX, Code
                CMP     AX, 0
                JE      uint2dec6
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
                CMP     AL, 0
                JE      uint2dec5
uint2dec6:
                ADD     AL, '0'
                MOV     BYTE PTR [BX+DI], AL
uint2dec5:
                RET
uint2dec        ENDP

;       putArg -- 取得した引数を括弧付で表示する
putArg          PROC    NEAR

                @DosDispString  ArgMsg1

                ; コマンドラインの引数を取得
                @getArgv ArgIndex, Argv
                MOV     SI, OFFSET Argv
putArg1:
                ; EOS を見つける
                CMP     BYTE PTR [SI], EOS
                JE      putArg2
                INC     SI
                JMP     putArg1
putArg2:
                ; EOS を DALLAR に置き換え、表示
                MOV     BYTE PTR DS:[SI], DALLAR
                @DosDispString  Argv
                @DosDispString  ArgMsg2
                RET
putArg          ENDP

;       main -- メイン
;       INPUT  : なし
;       OUTPUT : なし
main            PROC
                MOV     AX, SEG rc
                MOV     DS, AX

                ; コマンドラインの引数の数を取得
                MOV     Argc, 0
                MOV     ArgIndex, 1
                @getArgc Argc       
main2:
                ; 全ての引数を順に取得し、表示
                MOV     AX, ArgIndex
                CMP     AX, Argc
                JG      main1

                MOV     AX, ArgIndex
                MOV     Code, AX
                CALL    uint2dec
                @DosDispString CodeBuf

                CALL    putArg

                INC     ArgIndex        ; 次の引数
                JMP     main2
main1:
                MOV     rc, 0
                @DosExit rc
main            ENDP
ArgsCode        ENDS
                END     main
