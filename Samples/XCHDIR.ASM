PAGE    ,132
TITLE   XCHDIR.ASM -- Change drive and directory
%OUT    XCHDIR.ASM

INCLUDE CONSTANT.INC
INCL_DIR        EQU     0
INCL_DISK       EQU     0
INCL_GETARGS    EQU     0
INCL_CONSOLE    EQU     0
INCL_PROCESS    EQU     0    
INCLUDE DosCalls.MAC
               
myStack         SEGMENT PARA STACK
                DB      128 DUP("@")
myStack         ENDS

MAXDIR          EQU     128

myData          SEGMENT PARA
argc            DW      0
directory       DB      MAXDIR DUP('%'), EOS
drvltr          DB      'C'
drives          DW      0
rc              DB      0FFH
errMsg1         DB      '使い方: xchdir ディレクトリー', CRCHAR, LFCHAR, DALLAR
errMsg2         DB      'ドライブレターが不正です。', CRCHAR, LFCHAR, DALLAR
errMsg3         DB      'ディレクトリーが不正です。', CRCHAR, LFCHAR, DALLAR
myData          ENDS

xchdirCode      SEGMENT PARA
                ASSUME  CS:xchdirCode, DS:myData, ES:myData, SS:myStack

main            PROC
                MOV     AX, SEG myData  ; setup DS
                MOV     DS, AX

                @getArgc argc
                CMP     argc, 1
                JE      main1
                @DosDispString errMsg1
                JMP     main0
main1:          
                @getArgv argc directory
                MOV     SI, OFFSET directory
                CMP     BYTE PTR [SI+1], ':'    ; ドライブレターの確認
                JNE     main2
                MOV     AL, BYTE PTR [SI]       ; ドライブレターを取り出す
                MOV     drvltr,AL
                @DosSelDisk drvltr, drives      ; カレントドライブをかえる
                JNC     main2
                @DosDispString errMsg2
                JMP     main0
main2:          
                @DosChdir directory             ; ディレクトリーをかえる
                JNC     main0
                @DosDispString errMsg3
                
main0:          
                MOV     rc, 00H
                @DosExit rc
main            ENDP
xchdirCode      ENDS
                END     main
