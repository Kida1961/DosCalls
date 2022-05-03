PAGE    ,132
TITLE   TYPEOUT.ASM -- Type out file
%OUT    TYPEOUT.ASM

INCLUDE CONSTANT.INC
INCL_CONSOLE    EQU     0    
INCL_GETARGS    EQU     0    
INCL_FILE       EQU     0    
INCL_PROCESS    EQU     0    
INCLUDE DosCalls.MAC
INCLUDE DosCalls.DEF
                
MAXROWS         EQU     20
BUFFERSIZE      EQU     512

myStack         SEGMENT PARA STACK
                DB      128 DUP("@")
myStack         ENDS

myData          SEGMENT PARA
Buffer          DB      BUFFERSIZE DUP('%')
Chars           DW      BUFFERSIZE
Handle          DW      0
fileName        DB      64 DUP(EOS), EOS
fileMode        DB      0
fEOF            DB      NOT EOF
Rows            DW      0
Argc            DW      0
ArgIndex        DW      1
NewLine         DB      CRCHAR, LFCHAR, DALLAR
Header1         DB      "===== ", DALLAR
Header2         DB      " =====", CRCHAR, LFCHAR, DALLAR
PauseMsg        DB      "何かキーを押して下さい。", DALLAR
usage           DB      "使い方: typeout ファイル名", CRCHAR, LFCHAR, DALLAR
fileError1      DB      "ファイル ", DALLAR
fileError2      DB      " が見つかりません。", CRCHAR, LFCHAR, DALLAR
Char            DB      BLANK
bJunk           DB      BLANK
rc              DB      0
myData          ENDS

typeOut         SEGMENT PARA
                ASSUME  CS:typeOut, DS:myData, ES:myData, SS:myStack

DispAsciizString PROC   NEAR
DispAsciizString2:
                MOV     AL, BYTE PTR [DI]
                CMP     AL, BYTE PTR EOS
                JE      DispAsciizString1
                MOV     Char, AL
                @DosDispOut Char
                INC     DI
                JMP     DispAsciizString2
DispAsciizString1:
                RET
DispAsciizString ENDP

;       一文字読み取り
getc            PROC    NEAR
                MOV     chars, 1
                @DosRead Handle, Char, chars
                RET
getc1: 
                MOV     AL, BYTE PTR EOS
                MOV     fEOF, EOF
                RET
getc            ENDP

;       一文字書出し
putc            PROC    NEAR
                @DosDispOut Char
                RET
putc            ENDP

;       一時停止
pause           PROC    NEAR
                @DosDispString NewLine
                @DosDispString PauseMsg
                @DosClrKbdBuf
                @DosConInEcho bJunk
                @DosDispString NewLine
                RET
pause           ENDP

DispHeader      PROC    NEAR
                @DosDispString Header1
                LEA     DI, fileName
                CALL    DispAsciizString
                @DosDispString Header2
                RET
DispHeader      ENDP

;       ファイルの内容表示
ListFile        PROC
                CALL    DispHeader
                MOV     rows, 0
ListFile3:    
                CALL    getc
                CMP     fEOF, BYTE PTR EOF
                JE      ListFile1
                MOV     AL, Char
                CMP     AL, BYTE PTR EOFCHAR
                JE      ListFile1
                CALL    putc
                CMP     AL, BYTE PTR LFCHAR
                JNE     ListFile2
                INC     rows
                MOV     AX, rows
                CMP     AX, WORD PTR MAXROWS
                JNE     ListFile2
                CALL    DispHeader
                CALL    pause
                CALL    DispHeader
                MOV     rows, 0
ListFile2:    
                JMP     ListFile3
ListFile1:    
                RET
ListFile        ENDP

main            PROC
                MOV     AX, SEG myData  ; setup DS
                MOV     DS, AX

                ; コマンドラインの引数の数を取得
                MOV     Argc, 0
                @getArgc Argc
                CMP     Argc, 0
                JG      main1        
                @DosDispString usage
                JMP     main2
     
                ; 一番目の引数
                MOV     ArgIndex, 1
main1:
                ; 引数の最後に達したか
                MOV     AX, ArgIndex
                CMP     AX, Argc
                JG      main2           ; 達していれば終了
                
                ; 引数を取得
                @getArgv ArgIndex, fileName

                ; ファイルを開ける。開けられなかったら、次の引数
                @DosOpen fileName fileMode Handle
                JC      main3
                CALL    ListFile
                @DosClose Handle
                JMP  main4
main3:          
                @DosDispString fileError1
                LEA     DI, fileName
                CALL    DispAsciizString
                @DosDispString fileError2
                CALL    pause
main4:          
                INC     argIndex
                JMP     main1
                
main2:
                MOV     rc, 00H
                @DosExit rc
main            ENDP
typeOut         ENDS
                END     main
