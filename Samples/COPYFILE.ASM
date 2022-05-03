PAGE    ,132
TITLE   COPYFILE.ASM -- DosCalls sample
%OUT    COPYFILE.ASM

INCLUDE CONSTANT.INC
INCL_CONSOLE    EQU     0
INCL_GETARGS    EQU     0
INCL_FILE       EQU     0    
INCL_FILELIB    EQU     0    
INCL_PROCESS    EQU     0    
INCLUDE DosCalls.MAC
INCLUDE DosCalls.DEF

BUFFERSIZE      EQU     80      
FULLPATH        EQU     128

Stack           SEGMENT PARA STACK
                DB      128 DUP("@")
Stack           ENDS

CopyFileData    SEGMENT PARA
Buffer          DB      BUFFERSIZE DUP('$')
Bytes           DB      0
Char            DB      BLANK
inHandle        DW      0
inName          DB      FULLPATH DUP('$'), EOS
inAccess        DW      0
inBytes         DW      0       ; 読み取りバイト数
inAttrib        DB      0
inDTA           @DosDTA <>      ; 読み取りもとファイル DTA 
outHandle       DW      0
outName         DB      FULLPATH DUP('$'), EOS
outAccess       DW      0
outBytes        DW      0       ; 書込みバイト数
outDTA          @DosDTA <>      ; 書込み先ファイル DTA 
outAttrib       DB      0
Argc            DW      0       ; コマンドラインの引数の数
FileDate        @DosDate <0,0,0>
FileTime        @DosTime <0,0,0>

rc              DB      0
errMsg1         DB      "使い方: copyfile コピー元ファイル名 コピー先ファイル名", CRCHAR, LFCHAR, DALLAR
errMsg2a        DB      "コピー元ファイル ", DALLAR
errMsg2b        DB      " がありません。", CRCHAR, LFCHAR, DALLAR
errMsg3a        DB      "コピー先ファイル ", DALLAR
errMsg3b        DB      " があります。コピーを打ち切ります。", CRCHAR, LFCHAR, DALLAR
errMsg4a        DB      "コピー元ファイル ", DALLAR
errMsg4b        DB      " をオープンできません。コピー作業を中止します。", CRCHAR, LFCHAR, DALLAR
errMsg5a        DB      "コピー元ファイル ", DALLAR
errMsg5b        DB      " を読み込めませんでした。コピー作業を中止します。", CRCHAR, LFCHAR, DALLAR
errMsg6a        DB      "コピー先ファイル ", DALLAR
errMsg6b        DB      " に書き込めませんでした。コピー作業を中止します。", CRCHAR, LFCHAR, DALLAR
CopyFileData    ENDS

CopyFileCode    SEGMENT PARA
                ASSUME  CS:CopyFileCode, DS:CopyFileData, ES:CopyFileData, SS:Stack

DumpBuffer      PROC    NEAR
DumpBuffer2:
                JCXZ    DumpBuffer1
                MOV     AL, BYTE PTR [DI]
                MOV     Char, AL
                @DosDispOut Char
                INC     DI
                DEC     CX
                JMP     DumpBuffer2
DumpBuffer1:
                RET
DumpBuffer      ENDP

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

main            PROC
                MOV     AX, SEG rc      ; setup DS
                MOV     DS, AX
                
                ; コマンドライン引数の数を取得
                @getArgc argc
                CMP     argc, 2
                JE      main2
                @DosDispString errMsg1
                JMP     main99
main2:          
                ; 一番目のコマンドライン引数を取得
                MOV     argc, 1
                @getArgv argc inName
                
                ; 二番目のコマンドライン引数を取得
                MOV     argc, 2
                @getArgv argc outName

                ; コピー元のファイルを探す
                @DosSetDTA inDTA
                MOV     inAttrib, 0
                @DosFindFirst inName, inAttrib
                JC      main3
                JMP     main4
main3:
                ; コピー元ファイルなし
                @DosDispString errMsg2a
                LEA     DI, inName
                CALL    DispAsciizString
                @DosDispString errMsg2b
                JMP     main99
main4:
                ; コピー先ファイルを探す。"見つからない"が正しい。
                @DosSetDTA outDTA
                MOV     outAttrib, 0
                @DosFindFirst outName, outAttrib
                JNC     main5
                JMP     main6
main5:
                ; コピー先が見つかった。作業を中止。
                @DosDispString errMsg3a
                LEA     DI, outName
                CALL    DispAsciizString
                @DosDispString errMsg3b
                JMP     main99
main6:
                ; コピー元を FL_READ で開く
                MOV     inAccess, FL_READ
                @open   inHandle, inName, inAccess
                JC      main7
                CMP     AX, WORD PTR FL_NOERROR
                JNE     main7
                JMP     main8
main7:
                ; コピー元を開けられない。
                @DosDispString errMsg4a
                LEA     DI, inName
                CALL    DispAsciizString
                @DosDispString errMsg4b 
                JMP     main99
main8:
                ; コピー先を FL_WRITE で開く
                MOV     outAccess, FL_WRITE
                @open   outHandle, outName, outAccess
                JC      main9
                CMP     AX, WORD PTR FL_NOERROR
                JNE     main9
                JMP     main10
main9:                
                ; コピー先を開けられない。
                @DosDispString errMsg4a
                LEA     DI, inName
                CALL    DispAsciizString
                @DosDispString errMsg4b 
                JMP     main98
main10:                
                MOV     AX, BUFFERSIZE
                MOV     inBytes, AX
                @get    inHandle, Buffer, inBytes
                JC      main11
                CMP     AX, WORD PTR FL_EOF     ; EOF を検出するまで繰り返し
                CLC                             ; 邪魔な CY をクリア
                JE      main12                  ;
                MOV     AX, inBytes
                MOV     outBytes, AX
                @put    outHandle, Buffer, outBytes
                JC      main13
                CMP     AX, WORD PTR FL_NOERROR
                JNE     main13
                JMP     main10
main11:
                ; 読み取れなかった
                @DosDispString errMsg5a
                LEA     DI, inName
                CALL    DispAsciizString
                @DosDispString errMsg5b
                JMP     main12
main13:
                ; 書き込めなかった
                @DosDispString errMsg6a
                LEA     DI, outName
                CALL    DispAsciizString
                @DosDispString errMsg6b
main12:
                ; EOF に到達した
                @close outHandle
main98:                
                @close inHandle
main99:                
                @DosExit rc
main            ENDP
CopyFileCode    ENDS
                END     main
