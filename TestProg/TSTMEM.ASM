PAGE    ,132
TITLE   TSTMEM.ASM -- DOS機能呼び出し Memory (MEMORY.ASM)テスト
%OUT    TSTMEM.ASM

INCLUDE CONSTANT.INC
INCL_CONSOLE    EQU     0       ; CONSOLE機能マクロ組み込み
INCL_MEMORY     EQU     0       ; MEMORY機能マクロ組み込み
INCL_PROCESS    EQU     0       ; PROCESS機能マクロ組み込み 
INCLUDE DosCalls.MAC
INCLUDE DosCalls.DEF

BUFFERSIZE      EQU     128
CODEBUFSIZE     EQU     6
HEXBUFSIZE      EQU     4
ALLCSIZE1       EQU     10
ALLCSIZE2       EQU     2
ALLCSIZE3       EQU     10
HEXMASK         EQU     000FH

Stack           SEGMENT PARA STACK 'STACK'
                DB      128 DUP("S")
Stack           ENDS

TstMemData      SEGMENT PARA
Blocks          DW      0
MaxBlocks       DW      0
SaveMaxBlocks   DW      0
BlockSeg        DW      -1
BadBlockSeg     DW      -1
ptrMEMSeg       DW      -1
bJunk           DW      -1
wJunk           DW      -1
Code            DW      -1
CodeBuf         DB      CODEBUFSIZE DUP(SHARP), DALLAR 
HexBuf          DB      HEXBUFSIZE DUP(SHARP), "H", DALLAR 
HexChars        DB      "0123456789ABCDEF"
NewLine         DB      CRCHAR, LFCHAR, DALLAR
PauseMsg        DB      "何かキーを押して下さい。", DALLAR
OpenMsg         DB      "MEMORY.ASM テストプログラム", CRCHAR, LFCHAR
                DB      "======== =====================================", CRCHAR, LFCHAR
                DB      "このテストプログラムではDOS機能呼び出し、", CRCHAR, LFCHAR
                DB      "機能番号          機能", CRCHAR, LFCHAR
                DB      "======== =====================================", CRCHAR, LFCHAR
                DB      "   48    メモリーの割り振り (Alloc)", CRCHAR, LFCHAR
                DB      "   49    割り振られたメモリーの解放 (Dealloc)", CRCHAR, LFCHAR
                DB      "   4A    割り振られたブロックの修正 (SetBlock)", CRCHAR, LFCHAR
                DB      "======== =====================================", CRCHAR, LFCHAR
                DB      "を　テストします。", CRCHAR, LFCHAR 
                DB      "テストを開始します。", CRCHAR, LFCHAR, DALLAR
               
Test48          DB      "機能番号48 メモリーの割り振り", CRCHAR, LFCHAR, DALLAR
Test48Msg1      DB      "        割り振り段落数 ", DALLAR  
Test48Msg2      DB      "        割り振れませんでした。 エラーコード ", DALLAR
Test48Msg3      DB      "        割り振り可能段落数 ", DALLAR
Test48Msg4      DB      "        割り振られたブロックのセグメント ", DALLAR

Test49          DB      "機能番号49 割り振られたメモリーの解放", CRCHAR, LFCHAR, DALLAR
Test49Msg1      DB      "        間違ったブロックへのポインターで解放 ", DALLAR
Test49Msg2      DB      "        解放できませんでした。 エラーコード ", DALLAR
Test49Msg3      DB      "        解放しました。", CRCHAR, LFCHAR, DALLAR
Test49Msg4      DB      "        正しいブロックへのポインターで解放 ", DALLAR
Test49Msg5      DB      "        解放できませんでした。 エラーコード ", DALLAR
Test49Msg6      DB      "        解放しました。", CRCHAR, LFCHAR, DALLAR
                
Test4A          DB      "機能番号4A 割り振られたブロックの修正", CRCHAR, LFCHAR
                DB      "        メモリーを割り振り。段落数 ", DALLAR
Test4AMsg1      DB      "        割り振れませんでした。 エラーコード ", DALLAR
Test4AMsg2      DB      "        割り振りました。", CRCHAR, LFCHAR, DALLAR
Test4AMsg3      DB      "        ブロックを修正。段落数 ", DALLAR
Test4AMsg4      DB      "        ブロックを修正出来ません。 エラーコード ", DALLAR
Test4AMsg5      DB      "        ブロック修正後段落数 ", DALLAR
Test4AMsg6      DB      "        ブロックを修正。段落数", DALLAR
Test4AMsg7      DB      "        ブロックを修正出来ません。 エラーコード ", DALLAR
Test4AMsg8      DB      "        ブロックを修正後段落数 ", DALLAR
Test4AMsg9      DB      "        ブロックを解放します。", CRCHAR, LFCHAR, DALLAR
Test4AMsg10     DB      "        ブロックを解放できません。 エラーコード ", DALLAR
Test4AMsg11     DB      "        解放しました。", CRCHAR, LFCHAR, DALLAR

rc              DW      0         
TstMemData      ENDS

TstMemCode      SEGMENT PARA
                ASSUME  CS:TstMemCode, DS:TstMemData, ES:TstMemData, SS:Stack

uint2hex        PROC    NEAR
                MOV     AX, Code
                LEA     BX, HexBuf
                MOV     DI, HEXBUFSIZE-1
                MOV     CL, 4
uint2hex2:        
                CMP     DI, 0
                JL      uint2hex1
                AND     AX, HEXMASK
                LEA     SI, HexChars
                ADD     SI, AX
                MOV     AL, [SI]
                MOV     BYTE PTR [BX+DI], AL
                MOV     AX, Code
                SHR     AX, CL
                MOV     Code, AX
                DEC     DI
                JMP     uint2hex2
uint2hex1:        
                RET
uint2hex        ENDP

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

                @DosDispString OpenMsg
                @DosClrKbdBuf
                @DosDirectInWOEcho bJunk

                @DosDispString Test48
                @DosDispString Test48Msg1
                MOV     Blocks, ALLCSIZE1
                MOV     AX, Blocks
                MOV     Code, AX
                CALL    uint2Hex
                @DosDispString HexBuf    
                @DosDispString NewLine
                
                @DosAlloc Blocks, BlockSeg, MaxBlocks
                JNC     main1
                MOV     Code, AX
                @DosDispString Test48Msg2
                CALL    uint2hex
                @DosDispString HexBuf
                @DosDispString NewLine
                @DosDispString Test48Msg3
                MOV     AX, MaxBlocks
                MOV     SaveMaxBlocks, AX
                MOV     Code, AX
                CALL    uint2dec
                @DosDispString CodeBuf
                @DosDispString NewLine
                JMP     main2
main1:          
                @DosDispString Test48Msg4
                MOV     AX, BlockSeg
                MOV     Code, AX
                CALL    uint2hex
                @DosDispString HexBuf
                @DosDispString NewLine
main2:          
                @DosDispString Test48Msg1
                MOV     AX, MaxBlocks
                SUB     AX, 2
                MOV     Blocks, AX
                MOV     Code, AX
                CALL    uint2dec
                @DosDispString CodeBuf    
                @DosDispString NewLine
                
                MOV     BlockSeg, 0
                MOV     MaxBlocks, 0
                @DosAlloc Blocks, BlockSeg, MaxBlocks
                JNC     main3
                MOV     Code, AX
                @DosDispString Test48Msg2
                CALL    uint2hex
                @DosDispString HexBuf
                @DosDispString NewLine
                @DosDispString Test48Msg3
                MOV     AX, MaxBlocks
                MOV     Code, AX
                CALL    uint2dec
                @DosDispString CodeBuf
                @DosDispString NewLine
                JMP     main4
main3:          
                @DosDispString Test48Msg4
                MOV     AX, BlockSeg
                MOV     Code, AX
                CALL    uint2hex
                @DosDispString HexBuf
                @DosDispString NewLine
main4:          
                CALL    pause
                
                @DosDispString Test49
                @DosDispString Test49Msg1
                MOV     AX, BlockSeg
                SUB     AX, 10
                MOV     BadBlockSeg, AX
                MOV     Code, AX
                CALL    uint2hex
                @DosDispString HexBuf
                @DosDispString NewLine
                @DosDealloc BadBlockSeg
                JNC     main5
                MOV     Code, AX
                @DosDispString Test49Msg2
                CALL    uint2hex
                @DosDispString HexBuf
                @DosDispString NewLine
                JMP     main6
main5:                
                @DosDispString Test49Msg3
main6:                
                CALL    pause
                
                @DosDispString Test49Msg4
                MOV     AX, BlockSeg
                MOV     Code, AX
                CALL    uint2hex
                @DosDispString HexBuf
                @DosDispString NewLine
                @DosDealloc BlockSeg
                JNC     main7
                MOV     Code, AX
                @DosDispString Test49Msg5
                CALL    uint2hex
                @DosDispString HexBuf
                @DosDispString NewLine
                JMP     main8
main7:                
                @DosDispString Test49Msg6
main8:
                CALL    pause
                @DosDispString Test4A
                MOV     AX, SaveMaxBlocKs
                MOV     Blocks, AX
                MOV     Code, AX
                CALL    uint2dec
                @DosDispString CodeBuf
                @DosDispString NewLine

                MOV     BlockSeg, 0
                MOV     MaxBlocks, 0
                @DosAlloc Blocks, BlockSeg, MaxBlocks
                JNC     main9
                MOV     Code, AX
                @DosDispString Test4AMsg1
                CALL    uint2hex
                @DosDispString HexBuf
                @DosDispString NewLine
                JMP     main10
main9:
                @DosDispString Test4AMsg2
                @DosDispString Test4AMsg3
                MOV     AX, 1
                MOV     Code, AX
                MOV     Blocks, AX
                CALL    uint2dec
                @DosDispString CodeBuf
                @DosDispString NewLine
                MOV     MaxBlocks, 0
                @DosSetblock BlockSeg, Blocks, MaxBlocks
                JNC     main11
                MOV     Code, AX
                @DosDispString Test4AMsg4
                CALL    uint2hex
                @DosDispString HexBuf
                @DosDispString NewLine
                JMP     main12
main11:
                @DosDispString Test4AMsg5
                MOV     AX, MaxBlocks
                MOV     Code, AX
                CALL    uint2dec
                @DosDispString CodeBuf
                @DosDispString NewLine
main12:
                CALL    pause

                @DosDispString Test4AMsg6
                MOV     AX, SaveMaxBlocks
                ADD     AX, 1
                MOV     Code, AX
                MOV     Blocks, AX
                CALL    uint2dec
                @DosDispString CodeBuf
                @DosDispString NewLine
                MOV     MaxBlocks, 0
                @DosSetblock BlockSeg, Blocks, MaxBlocks
                JNC     main13
                MOV     Code, AX
                @DosDispString Test4AMsg7
                CALL    uint2hex
                @DosDispString HexBuf
                @DosDispString NewLine
                JMP     main14
main13:
                @DosDispString Test4AMsg8
                MOV     AX, MaxBlocks
                MOV     Code, AX
                CALL    uint2dec
                @DosDispString CodeBuf
                @DosDispString NewLine
main14:
                @DosDispString Test4AMsg9
                @DosDealloc BlockSeg
                JNC     main15
                MOV     Code, AX
                @DosDispString Test4AMsg10
                CALL    uint2Hex
                @DosDispString HexBuf
                @DosDispString NewLine
                JMP     main16
main15:
                @DosDispString Test4AMsg11
main16:
main10:
                MOV     rc, 00H
                @DosExit rc
main            ENDP
TstMemCode      ENDS
                END     main
