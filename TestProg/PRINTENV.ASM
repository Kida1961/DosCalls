PAGE    ,132
TITLE   PRINTENV.ASM -- sample print environment valiable
%OUT    PRINTENV.ASM

INCLUDE DOSCALLS.DEF
INCLUDE CONSTANT.INC
INCL_CONSOLE    EQU     0       
INCL_GETARGS    EQU     0       
INCL_GETENVS    EQU     0       
INCL_PROCESS    EQU     0       
INCLUDE DOSCALLS.MAC
                
BUFSIZ          EQU     80

Stack           SEGMENT PARA STACK 'STACK'
                DB      128 DUP("@")
Stack           ENDS

PrintEnvData    SEGMENT PARA
Msg0            DB      "[", EOS
Msg1            DB      "]=[", EOS
Msg2            DB      "]", CRCHAR, LFCHAR, EOS
Argc            DW      0
ArgIndex        DW      0
EnvName         DB      BUFSIZ DUP('*'), EOS
EnvValue        DB      BUFSIZ DUP('@'), EOS
OutBuffer       DB      BUFSIZ DUP('$')
rc              DW      0
PrintEnvData    ENDS

PrintEnvCode    SEGMENT PARA
                ASSUME  CS:PrintEnvCode, DS:PrintEnvData, ES:PrintEnvData, SS:Stack

;       putString -- 文字列出力
;       INPUT  : SI -- 出力文字列の先頭アドレス
;       OUTPUT : なし
putString       PROC    NEAR
                MOV     DI, OFFSET OutBuffer
putString1:      
                MOV     AL, BYTE PTR [SI]
                MOV     BYTE PTR [DI], AL
                CMP     AL, BYTE PTR EOS
                JE      putString2
                INC     SI
                INC     DI
                JMP     putString1
putString2:
                MOV     BYTE PTR [DI], '$'
                @DosDispString  OutBuffer
                RET
putString       ENDP

;       toupper -- 大文字変換
;       INPUT  : なし
;       OUTPUT : なし
toupper         PROC    NEAR
toupper2:
                MOV     AL, BYTE PTR DS:[SI]
                CMP     AL, BYTE PTR EOS
                JE      toupper1
                CMP     AL, 'a'
                JL      toupper3
                CMP     AL, 'z'
                JG      toupper3
                SUB     AL, 'a'-'A'
                MOV     BYTE PTR DS:[SI], AL
toupper3:
                INC     SI
                JMP     toupper2
toupper1:
                RET
toupper         ENDP

;       main -- メイン
;       INPUT  : なし
;       OUTPUT : なし
main            PROC
                MOV     AX, SEG rc
                MOV     DS, AX

                MOV     Argc, 0
                MOV     ArgIndex, 1

                @getArgc Argc                   ; 引数の数を取得
main2:
                MOV     AX, ArgIndex
                CMP     AX, Argc
                JG      main1

                @getArgv ArgIndex, EnvName      ; 引数を取得
                MOV     SI, OFFSET EnvName
                CALL    toupper
                @getEnv EnvName, EnvValue       ; 環境変数の値を取得

                MOV     SI, OFFSET Msg0         ; 引数と環境変数の値を
                CALL    putString               ; 括弧を付けて表示

                MOV     SI, OFFSET EnvName
                CALL    putString

                MOV     SI, OFFSET Msg1
                CALL    putString

                MOV     SI, OFFSET EnvValue
                CALL    putString

                MOV     SI, OFFSET Msg2
                CALL    putString

                INC     ArgIndex
                JMP     main2
main1:
                MOV     rc, 0
                @DosExit rc
main            ENDP

PrintEnvCode    ENDS
                END     main
