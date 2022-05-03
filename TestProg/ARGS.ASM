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

;       putArg -- éÊìæÇµÇΩà¯êîÇäáå ïtÇ≈ï\é¶Ç∑ÇÈ
;       INPUT  : Ç»Çµ
;       OUTPUT : Ç»Çµ
putArg          PROC    NEAR
                @DosDispString  ArgMsg1
                @getArgv ArgIndex, Argv
                MOV     SI, OFFSET Argv
putArg1:
                CMP     BYTE PTR [SI], EOS
                JE      putArg2
                INC     SI
                JMP     putArg1
putArg2:
                MOV     BYTE PTR DS:[SI], '$'
                @DosDispString  Argv
                @DosDispString  ArgMsg2
                RET
putArg          ENDP

;       main -- ÉÅÉCÉì
;       INPUT  : Ç»Çµ
;       OUTPUT : Ç»Çµ
main            PROC
                MOV     AX, SEG rc
                MOV     DS, AX

                MOV     Argc, 0
                MOV     ArgIndex, 1
                @getArgc Argc           ; à¯êîÇÃêîÇéÊìæ
main2:
                MOV     AX, ArgIndex
                CMP     AX, Argc
                JG      main1

                MOV     AX, ArgIndex
                MOV     Code, AX
                CALL    uint2dec
                @DosDispString CodeBuf

                CALL    putArg

                INC     ArgIndex
                JMP     main2
main1:
                MOV     rc, 0
                @DosExit rc
main            ENDP
ArgsCode        ENDS
                END     main
