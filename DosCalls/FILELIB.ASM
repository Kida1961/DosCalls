PAGE    ,132
TITLE   FILELIB.ASM -- FileLib ハイレベルファイル操作
%OUT    FILELIB.ASM

INCLUDE CONSTANT.INC

INCL_FILE       EQU     0   
INCLUDE DOSCALLS.MAC
INCLUDE DOSCALLS.DEF

BUFSIZ          EQU     80
FULLPATH        EQU     128
MAXFILES        EQU     20
IN_USE          EQU     0

@@DosCallsStack SEGMENT PARA STACK 'STACK'
                DB      128 DUP("@")
@@DosCallsStack ENDS

@@FileLibData   SEGMENT PARA

FileStruc       STRUC
                DB      '#'     ; デバッグ用目印         
@@Handle@@      DW      -1      ; ファイル・ハンドル
@@UseFLag@@     DW      -1      ; 使用中フラグ
@@EofFLag@@     DW      -1      ; ファイル終了フラグ
@@Access@@      DW      -1      ; ファイル・アクセス・モード
                                ;       DOSREADACCESS
                                ;       DOSWRITEACCESS
                                ;       DOSREADWRITEACCESS
@@Bpos@@        DW      0       ; 入出力バッファー中の文字の位置
@@Remain@@      DW      0       ; 入出力バッファー中の未使用文字数
@@Chars@@       DW      0       ; 入出力バッファー中の文字数
@@Buffer@@      DB      BUFSIZ DUP('#') ; 入出力バッファー
FileStruc       ENDS

FStrucPtrTbl    MACRO   Cnt
TIndex          =       0
                REPT    Cnt
                FStrucPtr %TIndex
TIndex          =       TIndex + 1
                ENDM
                ENDM

FStrucPtr       MACRO   Num
                DW      FileStruc&Num
                ENDM

FStrucTbl       MACRO   Cnt
FSTIndx         =       0
                REPT    Cnt
                FStruc  %FSTIndx
FSTIndx         =       FSTIndx + 1
                ENDM
                ENDM

FSTruc          MACRO   FSIndex
FileStruc&FSIndex FileStruc <FSindex,,NOT IN_USE,NOT EOF,,0,0,0,>
                ENDM

FileIndex       DW      0       ; FileStruc のインデックス
Files           DW      0       ; 現在開いているファイルの数
FileHandle      DW      -1      ; ファイル・ハンドル
FileMode        DW      -1      ; ファイルのオープン・モード
                                ;       FL_READ
                                ;       FL_WRITE
                                ;       FL_APPEND
                                ;       FL_READWRITE
pName           DW      -1      ; ファイル名へのポインター
                DW      -1      ;
pHandle         DW      -1      ; ファイルハンドルへのポインター
                DW      -1      ;
SaveDS          DW      -1      ; レジスター保管領域
SaveES          DW      -1
SaveBP          DW      -1
SaveBX          DW      -1
SaveCX          DW      -1
SaveDX          DW      -1
SaveSI          DW      -1
SaveDI          DW      -1
InitPos         DW      -1      ; ファイルポインターの初期値
SeekCode        DW      -1      ; シーク動作の仕方
                                ;       0 : 先頭からのオフセット位置に移動
                                ;       1 : 現在一からのオフセット位置に移動
                                ;       2 : 終りからのオフセット位置に移動
SeekOffset      DW      0       ; シークのオフセット
                DW      0       ;
Attrib          DW      0       ; ファイル作成時の属性 (必ず 0)
pNotInUse       DW      -1      ; 未使用 FileStruc へのポインター
pFileStruc      DW      -1      ; FileStruc へのポインター
pSrc            DW      -1      ; 転送元アドレス
                DW      -1
pDist           DW      -1      ; 転送先アドレス
                DW      -1
TailPos         DW      -1      ; ファイル終端位置
                DW      -1      
LastChar        DB      BLANK   ; ファイル終端の文字
LastBytesSize   DW      1
ReadChars       DW      0       ; 読取り文字
nBytes          DW      0       ; 読取り文字数
Char            DB      BLANK   ; 書出し文字
Chars           DW      0       ; 書出し文字数
PutChars        DW      0       ; 書出し文字数
pDI             DW      0       ; DI の一時退避用

                FStrucTbl    MAXFILES
pFILE           LABEL   WORD
                FStrucPtrTbl MAXFILES
@@FileLibData   ENDS

                EXTRN   @@DosOpen: FAR
                EXTRN   @@DosClose: FAR
                EXTRN   @@DosWrite: FAR
                EXTRN   @@DosRead: FAR
                EXTRN   @@DosCreat: FAR

@@FileLibCode   SEGMENT PARA
                ASSUME  CS:@@FileLibCode, DS:@@FileLibData, ES:@@FileLibData, SS:@@DosCallsStack

; flushBuffer -- バッファーのデータをファイルに書き出す
; 書き出し文字数が 0 の場合は何もしない
; 入　力 SI : FileStruc へのポインタ
; 戻り値 AX : @@DosWrite の戻り値
;           : FL_DISKFULL 書出し先のディスフに空がない
;           : FL_NOERROR 正しく書き出した
flushBuffer     PROC    NEAR
                MOV     AX, [SI].@@Bpos@@   ; 文字がなかったら何もしない
                CMP     AX, 0
                JE      flushBuffer2   
                LEA     AX, [SI].@@Handle@@
                PUSH    AX
                PUSH    DS
                LEA     AX, [SI].@@Buffer@@
                PUSH    AX
                PUSH    DS
                MOV     AX, [SI].@@Bpos@@
                MOV     Chars, AX
                LEA     AX, Chars
                PUSH    AX
                PUSH    DS
                CALL    @@DosWrite
                JC      flushBuffer1    ; DOS エラー検出
                CMP     AX, [SI].@@Bpos@@ ; 書き込めた文字数を確認する
                CLC                     ; 邪魔な CY をクリアする
                JE      flushBuffer2    ; 一致したらエラーなしで完了
                MOV     AX, FL_DISKFULL ; 一致しなかったら、DISKFULL     
                JMP     flushBuffer1
flushBuffer2:   
                MOV     AX, FL_NOERROR
flushBuffer1:   
                RET     
flushBuffer     ENDP

; putByte -- 一バイトバッファーに書く
; バッファーに空がなければ、まず、バッファーをディスクに書き出す
; 入　力 pFileStruc : FileStruc へのポインタ
; 戻り値 AX : flushBuffer の戻り値
;           : FL_NOERROR 正しく書き出せた
putByte         PROC    NEAR
                MOV     SI, pFileStruc
                CMP     [SI].@@Remain@@, 0 ; BUFFERに空がない
                JNE     putByte1
                CALL    flushBuffer
                JC      putByte2        ; DOS エラーあり
                CMP     AX, WORD PTR FL_NOERROR
                JNE     putByte2        ; 書込みエラーあり
                MOV     [SI].@@Bpos@@, 0 ; 次の文字のため初期化
                MOV     [SI].@@Remain@@, BUFSIZ
putByte1:                
                MOV     AX, [SI].@@Bpos@@  ; 文字をバッファーに入れる 
                LEA     DI, [SI].@@Buffer@@
                ADD     DI, AX
                MOV     BL, Char
                MOV     BYTE PTR [DI], BL
                INC     [SI].@@Bpos@@   ; 次の文字の準備
                DEC     [SI].@@Remain@@
                MOV     AX, FL_NOERROR 
putByte2:                
                RET                    
putByte         ENDP

; getOneChar -- 読だしバッファーから一文字取り出す
; 入　力
; 戻り値 AX : getByte の戻り値
;           : FL_EOF ファイルの終りに達した
getOneChar      PROC    NEAR
                CALL    getByte
                JC      getOneChar1
                CMP     AX, BYTE PTR FL_EOF
                CLC                     ; 邪魔な CY をリセット
                JE      getOneChar1
                MOV     BL, Char
                CMP     BL, BYTE PTR EOFCHAR
                CLC                     ; 邪魔な CY をリセット
                JNZ     getOneChar1
                MOV     AX, FL_EOF      ; EOF リターンコード設定
getOneChar1:    
                RET                    
getOneChar      ENDP

; getByte -- 一文字 FileStruc バッファーから読みだす
; 読だしバッファーが空の時は、ディスクから読みだす
; 入　力 pFileStruc : FileStruc へのポインター
; 戻り値 AX : fillBuffer の戻り値
;           : FL_NOERROR 正しく読みだせた
getByte         PROC    NEAR
                MOV     SI, pFileStruc
                CMP     WORD PTR [SI].@@Remain@@, 0
                JNE     getByte1
                CALL    fillBuffer
                JC      getByte2        ; DOS エラー検査
                CMP     AX, WORD PTR FL_EOF ; FILELIB エラー検査
                CLC                     ; 無駄な CY をクリアする
                JE      getByte2
getByte1:         
                MOV     DI, [SI].@@Bpos@@
                LEA     BX, [SI].@@Buffer@@
                MOV     BL, BYTE PTR [BX+DI]
                MOV     Char, BL
                INC     [SI].@@Bpos@@
                DEC     [SI].@@Remain@@
                MOV     AX, FL_NOERROR
getByte2:         
                RET     
getByte         ENDP

; copyByte -- 読み取りバッファーから読だし先バッファーに読み取る
; 読み取りバッファーが空の時は、ディスクから読みだす
; 入　力 pDist,pDist+2 : 読だし先バッファーへのポインタ
;        Chars : 読みだす文字数
; 戻り値 AX : getByte の戻り値
;           : FL_NOERROR 正しく読み取れた
copyBytes       PROC    NEAR
                MOV     CX, Chars       ; 読みだすバイト数
                MOV     ReadChars, 0        ; 読みだしたバイト数
copyBytes1:     
                JCXZ    copyBytes2      ; 読みだし残バイト数検査
                CALL    getByte
                JC      copyBytes4      ; DOS エラー検査
                CMP     AX, WORD PTR FL_EOF ; FILELIB リターンコード検査
                CLC                     ; 無駄な CY をリセット
                JE      copyBytes3
                MOV     AX, pDist+2     ; 転送先設定
                MOV     ES, AX
                MOV     DI, pDist     
                MOV     BL, Char        ; 読みだした 1Byte を転送
                MOV     BYTE PTR ES:[DI], BL
                INC     pDist           ; 次の転送先     
                DEC     CX
                INC     ReadChars
                JMP     copyBytes1
copyBytes3:     
                CMP     ReadChars, 0    ; 読み込んだ文字が無い
                JE      copyBytes4
                CLC                     ; すでに読み込んだ分を生かす
copyBytes2:
                MOV     AX, FL_NOERROR
copyBytes4:     
                RET
copyBytes       ENDP

; FileIndex2FileStruc -- FileIndex から FileStruc ポインタへの変換
; 入　力 FileIndex 
; 戻り値 SI (FIleStrucへのポインタ)
FileIndex2FileStruc PROC NEAR
                MOV     AX, FileIndex
                ADD     AX, AX
                MOV     SI, OFFSET pFILE
                ADD     AX, SI
                MOV     SI, AX
                MOV     AX, DS:[SI]
                RET
FileIndex2FileStruc ENDP

; nextNotInUse -- 次の未使用 FileStruc を探す
; 戻り値 pFileStruc (未使用の FileStruc へのポインタ)
;        AX : FL_TOOMANY (未使用の FileStruc なし)
;           : FL_NOERROR (未使用の FileStruc あり)
nextNotInUse    PROC    NEAR
                MOV     AX, Files
                CMP     AX, MAXFILES
                JE      nextNotInUse3
                MOV     WORD PTR FileIndex, 0
nextNotInUse2:
                CALL    FileIndex2FileStruc
                MOV     SI, AX
                MOV     AX, WORD PTR DS:[SI].@@UseFLag@@
                CMP     AX, NOT IN_USE
                JE      nextNotInUse1
                INC     WORD PTR FileIndex
                JMP     nextNotInUse2
nextNotInUse3:                
                MOV     pFileStruc, -1
                MOV     AX, FL_TOOMANY  ; No more room
                RET                  
nextNotInUse1:
                MOV     pFileStruc, SI
                MOV     AX, FL_NOERROR
                RET                   
nextNotInUse    ENDP

; findFileStruc -- 該当する FileStruc を探す
; 入　力 FileHandle
; 戻り値 pFileStruc (該当の FileStruc へのポインタ)
;        AX : FL_INVALID (該当なし)
;           : FL_NOERROR (該当あり) 
findFileStruc   PROC    NEAR
                MOV     FileIndex, 0
findFileStruc2:
                MOV     AX, FileIndex
                CMP     AX, MAXFILES
                JE      findFileStruc1
                CALL    FileIndex2FileStruc
                MOV     DI, AX
                MOV     AX, DS:[DI].@@Handle@@
                CMP     AX, FileHandle
                JE      findFileStruc3
                INC     WORD PTR FileIndex
                JMP     findFileStruc2
findFileStruc3:
                MOV     WORD PTR pFileStruc, DI
                MOV     AX, FL_NOERROR     
                RET                        
findFileStruc1:
                MOV     AX, FL_INVALID  ; FileLib エラー
                RET     
findFileStruc   ENDP

; openFile -- ファイルをオープンする
; 入　力 pName : ファイル名へのポインタ
;        FileMode : オープンするファイルモード
; 戻り値 Handle : ファイルハンドル
openFile        PROC    NEAR
                MOV     AX, pName       ; @@name offset
                PUSH    AX
                MOV     AX, pName+2     ; @@name segment
                PUSH    AX
                MOV     AX, OFFSET FileMode     ; @@mode offset
                PUSH    AX
                MOV     AX, SEG FileMode        ; @@mode segment
                PUSH    AX
                MOV     AX, OFFSET FileHandle   ; @@Handle@@ offset
                PUSH    AX
                MOV     AX, SEG FileHandle      ; @@Handle@@ segment
                PUSH    AX
                CALL    @@DosOpen       ; @@name, @@mode, @@Handle@@
                RET
openFile        ENDP

; openRegist -- オープンしたファイルの FileStruc に共通の規定値を設定する
; 入　力 pFileStruc : FileStruc へのポインタ
;        FileHandle : ファイルハンドル
openRegist      PROC    NEAR
                MOV     SI, pFileStruc
                MOV     AX, FileHandle
                MOV     WORD PTR [SI].@@Handle@@, AX
                MOV     WORD PTR [SI].@@UseFLag@@, IN_USE
                MOV     WORD PTR [SI].@@EofFLag@@, NOT EOF
                MOV     AX, FileMode
                MOV     WORD PTR [SI].@@Access@@, AX
                RET
openRegist      ENDP

; fillBuffer -- FileStruc のバッファーにファイルの内容を読み取る
; 入　力 SI : FileStruc へのポインタ
; 戻り値 AX : FL_EOF (ファイルの終りに到達した)
;        AX : FL_NOERROR (正しく読み取れた)
fillBuffer      PROC    NEAR
                LEA     AX, [SI].@@Handle@@
                PUSH    AX
                PUSH    DS
                LEA     AX, [SI].@@Buffer@@
                PUSH    AX
                PUSH    DS
                MOV     nBytes, BUFSIZ
                LEA     AX, nBytes
                PUSH    AX
                PUSH    DS
                CALL    @@DosRead
                JC      fillBuffer1     ; DOS エラー検出
                CMP     nBytes, 0       ; 読み取ったデータ数検査
                CLC                     ; 無駄な CY をリセットする
                JE      fillBuffer2     ; 読み取ったデータ数が 0 (EOF)
                MOV     [SI].@@EofFLag@@, NOT EOF
                MOV     [SI].@@Bpos@@, 0
                MOV     BX, nBytes
                MOV     [SI].@@Remain@@, BX
                MOV     [SI].@@Chars@@, BX
                MOV     AX, FL_NOERROR
                JMP     fillBuffer3
fillBuffer2:                            ; EOF の場合
                MOV     AX, FL_EOF
fillBuffer1:                            ; DOS エラーの場合
                MOV     [SI].@@EofFLag@@, EOF
                MOV     [SI].@@Bpos@@, 0
                MOV     [SI].@@Remain@@, 0
                MOV     [SI].@@Chars@@, 0
fillBuffer3:
                RET                   
fillBuffer      ENDP

; skipToEOL -- 行末まで読とばす
; 入　力    :
; 戻り値    :
skipToEOL       PROC    NEAR
skipToEOL2:
                CALL    getByte
                JC      skipToEOL1
                CMP     AX, WORD PTR FL_NOERROR
                JNE     skipToEOL1
                CALL    isEND
                CMP     AX, WORD PTR TRUE
                JE      skipToEOL1
                JMP     skipToEOL2
skipToEOL1:
                RET
skipToEOL       ENDP

; isEND -- 行末の判定 (行末文字 :  LFCHAR, EOFCHAR)
; 入　力 Char : 判定する文字
; 戻り値 AX : TRUE (行末文字)
;        AX : NOT TRUE (行末文字でない)
isEND           PROC    NEAR
                MOV     BL, Char
                CMP     BL, WORD PTR LFCHAR
                JE      isEND1
                CMP     BL, WORD PTR EOFCHAR
                JE      isEND1
                MOV     AX, NOT TRUE
                RET
isEND1:
                MOV     AX, TRUE
                RET
isEND           ENDP

; copyLine -- 一行読み取る
; 入　力 Char : 読み取る最大文字数
;        pDist,Pdist+2 : 読み取る文字を入れるバッファーへのポインタ
; 戻り値 AX : FL_NOERROR (正しく読み取れた)
;        AX : getByte の戻り値
copyLine        PROC    NEAR
                MOV     CX, Chars       ; 読み取り文字数の上限
copyLine1:
                JCXZ    copyLine2       ; バッファー空きなしを検出
                CALL    getByte
                JC      copyLine3
                CMP     AX, WORD PTR FL_EOF
                JE      copyLine4
                MOV     BL, Char
                CMP     BL, BYTE PTR CRCHAR
                JE      copyLine2
                CMP     BL, BYTE PTR EOFCHAR
                JE      copyLine5
                MOV     BX, pDist+2     ; バッファー・アドレス
                MOV     ES, BX
                MOV     DI, pDist
                MOV     BL, Char
                MOV     BYTE PTR ES:[DI], BL ; 文字をバッファーに転送 
                INC     pDist
                INC     ReadChars
                DEC     CX
                JMP     copyLine1
copyLine2:
                MOV     BX, pDist+2     ; バッファー・アドレス
                MOV     ES, BX
                MOV     DI, pDist
                MOV     BYTE PTR ES:[DI], EOS
                CALL    skipToEOL       ; 行末まで読み飛ばし
                MOV     AX, FL_NOERROR
                RET
copyLine4:
                MOV     DI, pDist
                MOV     BYTE PTR ES:[DI], EOS
                CMP     ReadCHars, 0
                JE      copyLine6
                MOV     AX, FL_NOERROR
copyLine6:
                RET
copyLine3:
                MOV     DI, pDist
                MOV     BYTE PTR ES:[DI], EOS
                RET
copyLine5:
                MOV     DI, pDist
                MOV     BYTE PTR ES:[DI], EOS
                CMP     ReadChars, 0
                JNE     copyLine7
                MOV     AX, FL_EOF
copyLine7:
                RET
copyLine        ENDP

; openRead -- FL_READ でファイルをオープンする
; 戻り値 AX : FL_NOERROR 正しくオープンできた
;           : openFile の戻り値
openRead        PROC    NEAR
                MOV     WORD PTR FileMode, DOSREADACCESS
                CALL    openFile
                JC      openRead1       ; On DOS error
                CALL    openRegist
                MOV     [SI].@@Bpos@@, BUFSIZ
                MOV     AX, FL_NOERROR  ; Set FileLib return code
openRead1:
                RET                     
openRead        ENDP

openWrite       PROC    NEAR
                MOV     WORD PTR FileMode, DOSWRITEACCESS
                MOV     Attrib, 0
                MOV     AX, pName       ; @@name offset
                PUSH    AX
                MOV     AX, pName+2     ; @@name segment
                PUSH    AX
                LEA     AX, Attrib
                PUSH    AX
                PUSH    DS
                LEA     AX, FileHandle
                PUSH    AX
                PUSH    DS
                CALL    @@DosCreat     
                JC      openWrite1      ; On DOS error
                CALL    openRegist
                MOV     [SI].@@Bpos@@, 0
                MOV     [SI].@@Remain@@, BUFSIZ
                MOV     AX, FL_NOERROR  ; Set error code
openWrite1:
                RET                     ; Normal return
openWrite       ENDP

; getLastChar -- ファイルの最後の文字を取り出す
; 入　力 FileHandle ファイルハンドル
; 戻り値 LastChar : ファイルの最後の文字
;        AX : DosRead の戻り値
getLastChar     PROC    NEAR
                MOV     SeekCode, 2     ; Move to tail
                MOV     SeekOffset, 0  
                MOV     SeekOffset+2, 0
                @DosLSeek FileHandle, SeekOffset, SeekCode
    
                MOV     AX, SeekOffset  ; Save Tail position
                MOV     TailPos, AX 
                MOV     AX, SeekOffset+2
                MOV     TailPos+2, AX
                
                MOV     SeekCode, 0     ; Move to Lastchar position
                SUB     SeekOffset, 1   
                SBB     SeekOffset+2, 0
                @DosLSeek FileHandle, SeekOffset, SeekCode
                LEA     AX, FileHandle
                PUSH    AX
                PUSH    DS
                LEA     AX, LastChar
                PUSH    AX
                PUSH    DS
                LEA     AX, LastBytesSize
                PUSH    AX
                PUSH    DS
                CALL    @@DosRead
                ;; @DosRead FileHandle, LastChar, LastBytesSize
                RET
getLastChar     ENDP

; openAppend -- FL_APPEND でファイルをオープンする
; ファイルポインタはファイルの最後に移動する
; 戻り値 AX : openFile の戻り値
;           : FL_NOERROR 正しくオープンできた
openAppend      PROC    NEAR
                MOV     WORD PTR FileMode, DOSREADWRITEACCESS
                CALL    openFile
                JC      openAppend1     ; On DOS error
                MOV     AX, pHandle+2   ; Save FileHandle
                MOV     ES, AX
                MOV     DI, pHandle
                MOV     AX, FileHandle
                MOV     WORD PTR ES:[DI], AX
                CALL    getLastChar
                CMP     BYTE PTR LastChar, EOFCHAR
                JNE     openAppend5
                SUB     TailPos, 1      ; Go back one character
                SBB     TailPos+2, 0
                @DosLSeek FileHandle, TailPos, SeekCode
openAppend5:                            
                CALL    openRegist
                MOV     [SI].@@Bpos@@, 0
                MOV     [SI].@@Remain@@, BUFSIZ
                MOV     AX, FL_NOERROR  ; Set error code
openAppend1:
                RET                     
openAppend      ENDP

; openReadWrite -- FL_READWRITE でファイルをオープンする
; 入　力
; 戻り値 AX : openRead の戻り値
;           : FL_NOERROR 正しくオープンできた
openReadWrite   PROC    NEAR
                MOV     WORD PTR FileMode, DOSWRITEACCESS
                CALL    openFile
                JC      openReadWrite1  ; On DOS error
                CALL    openRegist
                MOV     [SI].@@Bpos@@, 0
                MOV     [SI].@@Remain@@, BUFSIZ
                MOV     [SI].@@Chars@@, BUFSIZ  
                MOV     AX, FL_NOERROR  ; Set error code
openReadWrite1:
                RET                     
openReadWrite   ENDP

; @@get -- ブロック単位で読みだす
; 入　力 [BP+12][BP+14] : ファイルハンドル
;        [BP+8][BP+10] : 読だしバッファー
;        [BP+4][BP+6] : 読だしバイト数
; 戻り値 AX : findFileStruc の戻り値
;           : copyBytes の戻り値 
;        [BP+4][BP+6] : 読みだしたバイト数
                PUBLIC  @@get
@@get           PROC    FAR     ; handle buffer bytes
                PUSH    DS
                MOV     AX, SEG SaveDS
                MOV     DS, AX
                POP     AX
                MOV     SaveDS, AX
                MOV     SaveES, ES
                MOV     SaveDI, DI
                MOV     SaveBX, BX
                MOV     SaveBP, BP
                
                MOV     BP, SP
                MOV     AX, [BP+12]     ; ファイルハンドル
                MOV     ES, AX
                MOV     DI, [BP+14]    
                MOV     AX, ES:[DI]
                MOV     FileHandle, AX  ; ファイルハンドルを保管
                CALL    findFileStruc   ; 該当する FileStruc を探す
                CMP     AX, WORD PTR FL_NOERROR ; 探索結果確認 
                JNE     @@get1          ; 該当なし
                MOV     AX, [BP+4]      ; 読みだしバイト数
                MOV     ES, AX
                MOV     DI, [BP+6]    
                MOV     AX, ES:[DI]   
                MOV     Chars, AX       ; バイト数保管
                MOV     AX, [BP+8]      ; 読みだしバッファー設定
                MOV     pDist+2, AX
                MOV     DI, [BP+10]   
                MOV     pDist, DI
                CALL    copyBytes       ; 読みだし
                MOV     BX, [BP+4]      ; 読みだしたバイト数を返す
                MOV     ES, BX
                MOV     DI, [BP+6]
                MOV     BX, ReadChars
                MOV     ES:[DI], BX   
@@get1:
                MOV     BX, SEG SaveDS
                MOV     ES, BX
                MOV     BP, ES:SaveBP
                MOV     DI, ES:SaveDI
                MOV     BX, ES:SaveBX
                MOV     DS, ES:SaveDS
                MOV     ES, ES:SaveES
                RET     12              ; Normal return
@@get           ENDP

; @@getchar --  一バイト読みだす
; 入　力 [BP+8][BP+10] : ファイルハンドル
; 戻り値 AX : findFileStruc の戻り値
;           : getOneChar の戻り値
;        [BP+4][BP+6] : 読みだした文字
                PUBLIC  @@getchar
@@getchar       PROC    FAR     ; handle, char  
                PUSH    DS
                MOV     AX, SEG SaveDS
                MOV     DS, AX
                POP     AX
                MOV     SaveDS, AX
                MOV     SaveES, ES
                MOV     SaveDI, DI
                MOV     SaveBX, BX
                MOV     SaveBP, BP

                MOV     BP, SP
                MOV     AX, [BP+8]      ; SEGMENT handle
                MOV     ES, AX
                MOV     DI, [BP+10]     ; OFFSET handle
                MOV     AX, ES:[DI]
                MOV     FileHandle, AX
                CALL    findFileStruc
                CMP     AX, WORD PTR FL_NOERROR
                JNE     @@getchar1
                CALL    getOneChar
                JC      @@getchar1
                CMP     AX, WORD PTR FL_NOERROR
                JNE     @@getchar1
                MOV     BX, [BP+4]      ; SEGMENT char
                MOV     ES, BX    
                MOV     DI, [BP+6]      ; OFFSET char
                MOV     BL, Char
                MOV     BYTE PTR ES:[DI], BL
@@getchar1:                
                MOV     BX, SEG SaveDS
                MOV     ES, BX
                MOV     BP, ES:SaveBP
                MOV     DI, ES:SaveDI
                MOV     BX, ES:SaveBX
                MOV     DS, ES:SaveDS
                MOV     ES, ES:SaveES
                RET     8               ; Normal return   
@@getchar       ENDP

; @@getline -- 一行読みだす
; 読だしバッファーに入りきれない場合は、切り捨てる
; 入　力 [BP+12][BP+14] : ファイルハンドル
;        [BP+8][BP+10] : 読だしバッファー
;        [BP+4][BP+6] : バッファーサイズ
; 戻り値 AX : findFileStruc の戻り値
;           : CopyLine の戻り値
;        [BP+4][BP+6] : 読み取った文字数
                PUBLIC  @@getline
@@getline       PROC    FAR     ; handle, line, maxchars
                PUSH    DS
                MOV     AX, SEG SaveDS
                MOV     DS, AX
                POP     AX
                MOV     SaveDS, AX
                MOV     SaveES, ES
                MOV     SaveDI, DI
                MOV     SaveBX, BX
                MOV     SaveCX, CX
                MOV     SaveDX, DX
                MOV     SaveBP, BP

                MOV     BP, SP
                MOV     AX, [BP+12]   
                MOV     ES, AX
                MOV     DI, [BP+14]
                MOV     AX, ES:[DI]
                MOV     FileHandle, AX
                CALL    findFileStruc
                CMP     AX, WORD PTR FL_NOERROR
                JNE     @@getline1
                MOV     AX, [BP+4]      ; SEGMENT maxchars
                MOV     ES, AX
                MOV     DI, [BP+6]      ; OFFSET maxchars
                MOV     AX, ES:[DI]
                DEC     AX              ; EOS の分を予約
                MOV     Chars, AX       ; バッファーのサイズを設定
                MOV     AX, [BP+8]      ; SEGMENT line           
                MOV     pDist+2, AX     ; 読み取りバッファーのセグメント
                MOV     DI, [BP+10]     ; OFFSET line
                MOV     pDist, DI       ; 読み取りバッファーのオフセット 
                MOV     ReadChars, 0    ; 読み取った文字数をリセット
                CALL    CopyLine
                JC      @@getline1
                CMP     AX, WORD PTR FL_NOERROR
                JNE     @@getline1
                MOV     BX, [BP+4]      ; 読み取った文字数の設定
                MOV     ES, BX
                MOV     DI, [BP+6]
                MOV     BX, ReadChars
                MOV     ES:[DI], BX
@@getline1:               
                MOV     BX, SEG SaveDS
                MOV     ES, BX
                MOV     BP, ES:SaveBP
                MOV     DI, ES:SaveDI
                MOV     BX, ES:SaveBX
                MOV     CX, ES:SaveCX
                MOV     DX, ES:SaveDX
                MOV     DS, ES:SaveDS
                MOV     ES, ES:SaveES
                RET     12              
@@getline       ENDP

; @@put -- ブロック単位で書き出す
; 入　力 : [BP+12][BP+14] : ファイルハンドル
;          [BP+8][BP+10] : 書き出すブロック
;          [BP+4][BP+6] : 書き出すバイト数
; 戻り値 AX : findFIleStruc の戻り値
;           : putByte の戻り値
;        CY : DOS エラーあり
;        [BP+4][BP+6] : 書き出したバイト数
                PUBLIC  @@put
@@put           PROC    FAR     ; handle, buffer, bytes    
                PUSH    DS
                MOV     AX, SEG SaveDS
                MOV     DS, AX
                POP     AX
                MOV     SaveDS, AX
                MOV     SaveES, ES
                MOV     SaveCX, CX
                MOV     SaveDI, DI
                MOV     SaveBP, BP

                MOV     BP, SP
                MOV     AX, [BP+12]     ; Handle
                MOV     ES, AX
                MOV     DI, [BP+14]
                MOV     AX, WORD PTR ES:[DI]
                MOV     FileHandle, AX  ; Save file handle
                CALL    findFIleStruc   ; ファイル構造体を探す
                CMP     AX, WORD PTR FL_NOERROR
                JNE     @@put1
                MOV     AX, [BP+4]      ; bytes
                MOV     ES, AX
                MOV     DI, [BP+6]
                MOV     CX, ES:[DI]
                MOV     AX, [BP+8]      ; Source buffer SEGMENT 
                MOV     ES, AX          ;
                MOV     DI, [BP+10]     ; Source buffer OFFSET
                MOV     pDI, DI         ; DI を一時保管
                MOV     PutChars, 0
@@put3:                
                JCXZ    @@put2
                MOV     DI, pDI         ; DI を戻す
                MOV     AL, BYTE PTR ES:[DI]
                MOV     Char, AL
                CALL    putByte
                JC      @@Put1
                CMP     AX, WORD PTR FL_NOERROR
                JNE     @@Put1
                INC     PutChars
                INC     pDI
                DEC     CX
                JMP     @@put3
@@put2:                
                CLC                     ; 無用の CY をクリアする
                MOV     BX, [BP+4]      ; 書き込んだバイト数を返す
                MOV     ES, BX
                MOV     DI, [BP+6]
                MOV     CX, WORD PTR ES:[DI]
                MOV     WORD PTR ES:[DI], CX
@@put1:                
                MOV     BX, SEG SaveDS
                MOV     ES, BX
                MOV     BP, ES:SaveBP
                MOV     CX, ES:SaveCX
                MOV     DI, ES:SaveDI
                MOV     DS, ES:SaveDS
                MOV     ES, ES:SaveES
                RET     12              ; Error return
@@put           ENDP

; @@putchar -- 一文字書き出す
; 入　力 [BP+8][BP+10] : ファイルハンドル
;        [BP+4][BP+6] : 書き出す文字
; 戻り値 AX : FindFileStruc の戻り値
;           : putByte の戻り値
;        CY : DOS エラーあり
                PUBLIC  @@putChar
@@putchar       PROC    FAR     ; Handle, CHar
                PUSH    DS
                MOV     AX, SEG SaveDS
                MOV     DS, AX
                POP     AX
                MOV     SaveDS, AX
                MOV     SaveES, ES
                MOV     SaveDI, DI
                MOV     SaveBX, BX
                MOV     SaveBP, BP

                MOV     BP, SP
                MOV     AX, [BP+8]      ; Handle
                MOV     ES, AX
                MOV     DI, [BP+10]
                MOV     AX, ES:[DI]
                MOV     FileHandle, AX
                CALL    FindFileStruc   ; ファイル構造体を探す
                CMP     AX, WORD PTR FL_NOERROR
                JNE     @@putchar1
                
                MOV     AX, [BP+4]
                MOV     ES, AX
                MOV     DI, [BP+6]
                MOV     AL, BYTE PTR ES:[DI]
                MOV     Char, AL
                CALL    putByte         ; バッファーに書き出す
@@putchar1:                             ; エラー検出後の処理
                MOV     BX, SEG SaveDS
                MOV     ES, BX
                MOV     BP, ES:SaveBP
                MOV     BX, ES:SaveBX
                MOV     DI, ES:SaveDI
                MOV     DS, ES:SaveDS
                MOV     ES, ES:SaveES
                RET     8   
@@putchar       ENDP

; @@putline -- 一行書き出す
; 書き出す文字列は EOS で終端してあること
; 入　力 [BP+8][BP+10] : ファイルハンドル
;        [BP+4][BP+6] : 書き出し文字列
; 戻り値 AX : FindFileStruc の戻り値
;           : putByte の戻り値 
;        CY : DOS エラーあり
                PUBLIC  @@putline
@@putline       PROC    FAR     ; Handle, Buffer
                PUSH    DS
                MOV     AX, SEG SaveDS
                MOV     DS, AX
                POP     AX
                MOV     SaveDS, AX
                MOV     SaveES, ES
                MOV     SaveSI, SI
                MOV     SaveDI, DI
                MOV     SaveBX, BX
                MOV     SaveCX, CX
                MOV     SaveDX, DX
                MOV     SaveBP, BP

                MOV     AX, FL_NOERROR  ; FILELIB エラーをクリア
                MOV     BP, SP
                MOV     BX, [BP+8]      ; ファイルハンドル
                MOV     ES, BX
                MOV     DI, [BP+10]
                MOV     BX, WORD PTR ES:[DI]
                MOV     FileHandle, BX  ; ファイルハンドルを保管
                CALL    FindFileStruc
                CMP     AX, WORD PTR FL_NOERROR
                JNE     @@putline1
                MOV     BX, [BP+4]      ; SEGMENT Buffer
                MOV     ES, BX
                MOV     DI, [BP+6]      ; OFFSET Buffer
                MOV     pDI, DI         ; DI を一時保管
@@putline2:
                MOV     DI, pDI         ; DI を元に戻す
                MOV     BL, BYTE PTR ES:[DI]
                CMP     BL, BYTE PTR EOS
                JE      @@putline3
                MOV     Char, BL 
                CALL    putByte
                JC      @@putline1
                CMP     AX, WORD PTR FL_NOERROR
                JNE     @@putline1
                INC     pDI             ; pDIを次の位置に
                JMP     @@putline2
@@putline3:
                MOV     Char, BYTE PTR CRCHAR
                CALL    putByte
                JC      @@putline1
                CMP     AX, WORD PTR FL_NOERROR
                JNE     @@putline1
                MOV     Char, BYTE PTR LFCHAR
                CALL    putByte
@@putline1:
                MOV     BX, SEG SaveDS
                MOV     DS, BX
                MOV     BP, SaveBP
                MOV     ES, SaveES
                MOV     SI, SaveSI
                MOV     DI, SaveDI
                MOV     BX, SaveBX
                MOV     CX, SaveCX
                MOV     DX, SaveDX
                MOV     DS, SaveDS
                MOV     ES, SaveES
                RET     8
@@putline       ENDP

; ファイルをオープンする
; ファイル名は EOS で終端していること
; Modeの設定値
;       FL_READ (読だし)
;       FL_WRITE (書込み)
;       FL_APPEND (追記)
;       FL_READWRITE (読み書き)
; 正しくオープンできたら、ファイルハンドルを返す
; 入　力 [BP+8][BP+10] : ファイル名
;        [BP+4][BP+6] : アクセスモード
; 戻り値 AX : nextNotInUse の戻り値
;           : openRead の戻り値
;           : openWrite の戻り値
;           : openAppend の戻り値
;           : openReadWrite の戻り値
;           : FL_INVALID アクセスモードが間違っている
;           : FL_NOERROR 正しくオープンできた
;        [BP+12][BP+14] : ファイルハンドル
                PUBLIC  @@open  ; Handle, Name, Mode
@@open          PROC    FAR
                PUSH    DS
                MOV     AX, SEG SaveDS
                MOV     DS, AX
                POP     AX
                MOV     SaveDS, AX
                MOV     SaveES, ES
                MOV     SaveDI, DI
                MOV     SaveBP, BP

                MOV     BP, SP
                MOV     AX, [BP+8]      ; SEGMENT Name
                MOV     pName+2, AX
                MOV     AX, [BP+10]     ; OFFSET Name
                MOV     pName, AX
                MOV     AX, [BP+12]     ; SEGMENT Handle
                MOV     pHandle+2, AX
                MOV     AX, [BP+14]     ; OFFSET Handle
                MOV     pHandle, AX

                MOV     pFileStruc, -1
                CALL    nextNotInUse
                CMP     AX, WORD PTR FL_NOERROR
                JNE     @@open7         ; FileLib error

                MOV     AX, [BP+4]      ; SEGMENT Mode
                MOV     ES, AX
                MOV     DI, [BP+6]      ; OFFSET Mode
                MOV     AX, WORD PTR ES:[DI]
                
                CMP     AX, WORD PTR FL_READ
                JNE     @@open2
                CALL    openRead        ; Open as read
                JC      @@open7         ; Error on open
                JMP     @@open6         ; No error on open
@@open2:          
                CMP     AX, WORD PTR FL_WRITE
                JNE     @@open3
                CALL    openWrite
                JC      @@open7         ; Error on DOS
                CMP     AX, WORD PTR FL_NOERROR
                JNE     @@open7         ; Error on FileLib
                JMP     @@open6         ; No error
@@open3:                
                CMP     AX, WORD PTR FL_APPEND
                JNE     @@open4
                CALL    openAppend
                JC      @@open7         ; Error on open
                CMP     AX, WORD PTR FL_NOERROR
                JNE     @@open7         ; Error on FileLib
                JMP     @@open6         ; No error
@@open4:                
                CMP     AX, WORD PTR FL_READWRITE
                JNE     @@open5
                CALL    openReadWrite
                JC      @@open7         ; Error on open
                CMP     AX, WORD PTR FL_NOERROR
                JNE     @@open7         ; Error on FileLib
                JMP     @@open6         ; No error
@@open5:                
                MOV     AX, FL_INVALID  ; Set error code
                JMP     @@open7
@@open6:
                MOV     AX, pHandle+2   ; Save Handle
                MOV     ES, AX
                MOV     DI, pHandle
                MOV     AX, FileHandle
                MOV     WORD PTR ES:[DI], AX
                INC     WORD PTR Files
                MOV     AX, FL_NOERROR
@@open7:
                MOV     BX, SEG SaveDS  ; Restore Regs 
                MOV     ES, BX
                MOV     BP, ES:SaveBP
                MOV     DI, ES:SaveDI
                MOV     DS, ES:SaveDS
                MOV     ES, ES:SaveES
                RET     12              ; Error return
@@open          ENDP

; ファイルをクローズする
; 入　力 [BP+4][BP+6] ファイルハンドル
; 戻り値 AX : findFileStruc の戻り値
;           : @@DosClose の戻り値
                PUBLIC  @@close ; handle
@@close         PROC    FAR  
                PUSH    DS
                MOV     AX, SEG SaveDS
                MOV     DS, AX
                POP     AX
                MOV     SaveDS, AX
                MOV     SaveES, ES
                MOV     SaveDI, DI
                MOV     SaveBX, BX
                MOV     SaveBP, BP

                MOV     BP, SP
                MOV     AX, [BP+4]   
                MOV     ES, AX
                MOV     DI, [BP+6]
                MOV     AX, ES:[DI]
                MOV     FileHandle, AX
                CALL    findFileStruc
                CMP     AX, BYTE PTR FL_NOERROR
                JNE     @@close6
@@close1:          
                MOV     SI, pFileStruc
                CMP     DS:[SI].@@Access@@, WORD PTR DOSREADACCESS
                JE      @@close2
                CALL    flushBuffer
@@close2:                
                LEA     AX, DS:[SI].@@Handle@@
                PUSH    AX
                PUSH    DS
                CALL    @@DosClose
                JC      @@close6        ; DOS error
                
@@close3:       
                ;; Reset FileStruc
                MOV     WORD PTR [SI].@@Handle@@, -1
                MOV     WORD PTR [SI].@@UseFLag@@, NOT IN_USE
                MOV     WORD PTR [SI].@@EofFLag@@, NOT EOF
                MOV     WORD PTR [SI].@@Access@@, 0
                MOV     WORD PTR [SI].@@Bpos@@, 0 
                MOV     WORD PTR [SI].@@Remain@@, 0 
                MOV     WORD PTR [SI].@@Chars@@, 0
                LEA     DI, [SI].@@Buffer@@         
                MOV     CX, BUFSIZ
@@close5:                               ; Clear read/write buffer
                JCXZ    @@close4
                MOV     BYTE PTR [DI], SHARP
                INC     DI
                DEC     CX
                JMP     @@close5
@@close4:       
                DEC     WORD PTR Files
                MOV     AX, FL_NOERROR  ; Set error code
@@close6:       
                MOV     BX, SEG SaveDS
                MOV     ES, BX
                MOV     BP, ES:SaveBP
                MOV     DI, ES:SaveDI
                MOV     BX, ES:SaveBX
                MOV     DS, ES:SaveDS
                MOV     ES, ES:SaveES
                RET     4               ; Normal return
@@close         ENDP
@@FileLibCode   ENDS
                END
