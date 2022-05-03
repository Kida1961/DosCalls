PAGE    ,132
TITLE   CREAT.ASM -- Creat sample
%OUT    CREAT.ASM

INCLUDE CONSTANT.INC
INCL_CONSOLE    EQU     0    
INCL_GETARGS    EQU     0    
INCL_FILE       EQU     0    
INCL_PROCESS    EQU     0    
INCLUDE DosCalls.MAC

BUFFERSIZE      EQU     512
FULLPATH        EQU     128

myStack         SEGMENT PARA STACK
                DB      128 DUP("@")
myStack         ENDS

myData          SEGMENT PARA
handle          DW      0
fileName        DB      FULLPATH DUP(DALLAR)
attrib          DW      0  
argc            DW      0
chars           DW      0
index           DW      0
rc              DB      0FFH
errMsg1         DB      "使い方: creat ファイル名...", CRCHAR, LFCHAR, DALLAR
myData          ENDS

creatCode       SEGMENT PARA
                ASSUME  CS:creatCode, DS:myData, ES:myData, SS:myStack
main            PROC
                MOV     AX, SEG myData  ; setup DS
                MOV     DS, AX

                ; コマンドラインの引数の数を取得
                @getArgc argc
                CMP     argc, 0         ; 引数がないと、
                JNE     main1           ; エラーを表示し終了
                @DosDispString errMsg1
                JMP     main2
                MOV     index, 0
main1:          
                MOV     AX, index
                CMP     AX, argc                ; index > args になったら
                JG      main2                   ; ループを抜ける
                @getArgv index, fileName        ; ファイル名を取得
                @DosCreat fileName attrib handle ; ファイルを作成
                @DosClose handle                 ;
                INC     index                   
                JMP     main1
main2:                
                MOV     rc, 00H
                @DosExit rc
main            ENDP
creatCode       ENDS
                END     main
