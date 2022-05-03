PAGE    ,132                     
TITLE   TSTFILE3.ASM -- DOS機能呼び出し File (FILE.ASM)テスト パート3
%OUT    TSTFILE3.ASM
        
INCLUDE CONSTANT.INC
INCL_CONSOLE    EQU     0       ; CONSOLE機能マクロ組み込み
INCL_DISK       EQU     0       ; DISK機能マクロ組み込み
INCL_FILE       EQU     0       ; FILE機能マクロ組み込み
INCL_MISC       EQU     0       ; MISC機能マクロ組み込み
INCL_PROCESS    EQU     0       ; PROCESS機能マクロ組み込み 
INCLUDE DosCalls.MAC
INCLUDE DosCalls.DEF

BUFFERSIZE      EQU     128
CODEBUFSIZE     EQU     6
DWORDBUFSIZE    EQU     10
HEXBUFSIZE      EQU     4
HEXMASK         EQU     000FH

Stack           SEGMENT PARA STACK 'STACK'
                DB      128 DUP("S")
Stack           ENDS

TstFile3Data    SEGMENT PARA
@FCB2Date       RECORD  @Year:7, @month:4, @Day:5
@FCB2Time       RECORD  @Hours:5, @Minutes:6, @seconds:5
DateTimeUS      @DosDTTMStringUS   <>
                DB      DALLAR
DateTimeUSLength DW $-DateTimeUS-1
DateTimeEuro    @DosDTTMStringEuro <>
                DB      DALLAR
DateTimeEuroLength DW $-DateTimeEuro-1
DateTimeJpn     @DosDTTMStringJpn  <>
                DB      DALLAR
DateTimeJpnLength DW $-DateTimeJpn-1

drvLtrA         DB      "A", DALLAR
drvLtrB         DB      "B", DALLAR
drvLtrC         DB      "C", DALLAR
TestFileName0   DB      "TestFile.000",0
TestFileName1   DB      "TestFile.001",0
TestFileName2   DB      "TestFile.002",0
TestFileName3   DB      "TestFile.003",0
TestFileName4   DB      "TestFile.004",0
TestFileMatch   DB      "Test*.*",0
TestFileHandle  DW      -1
TestFileAccess  DW      0
TestFileAttrib  DW      0
TestFileName    DB      BUFFERSIZE DUP(DALLAR)
TestFileDate    @FCBDate <0,0,0>
TestFileTime    @FCBTime <0,0,0> 
TestDTA         @DosDTA <>
CInfo           @DosCuntryInfo <>
DateSepa        DB      "-", DALLAR
TimeSepa        DB      ":", DALLAR
TimeInfo        DB      2 DUP(BLANK), DALLAR
DateTimeFmt     DW      @DOSDTTMFMTJPN
TimeFMT         DB      @DOSDTTMFMT24
TempDateTime    DW      0
OldFileName     DB      "OLDFILE.DAT", 0
OldFileAttrib   DW      0
OldFileHandle   DW      -1
NewFileName     DB      "NEWFILE.DAT", 0
NewFileAttrib   DW      0
NewFileAccess   DW      DOSREADACCESS
NewFileHandle   DW      -1
TempDate        @FCBDate <0,0,0>
TempTime        @FCBTime <0,0,0>
CurDate         @FCBDate <0,0,0>
CurTime         @FCBTime <0,0,0>
NewDate         @FCBDate <2020-1980,11,7>
NewTime         @FCBTime <1,23,22>
bJunk           DB      BLANK
wJunk           DW      -1
Code            DW      -1
CodeBuf         DB      CODEBUFSIZE DUP(SHARP), DALLAR
HexBuf          DB      HEXBUFSIZE DUP(SHARP), "H",  DALLAR 
HexChars        DB      "0123456789ABCDEF"
NewLine         DB      CRCHAR, LFCHAR, DALLAR
PauseMsg        DB      "何かキーを押して下さい。", DALLAR
OpenMsg         DB      "FILE.ASM テストプログラム パート 3", CRCHAR, LFCHAR
                DB      "====================================================", CRCHAR, LFCHAR
                DB      "このテストプログラムではDOS機能呼び出し、", CRCHAR, LFCHAR
                DB      "機能番号          機能", CRCHAR, LFCHAR
                DB      "======== ===========================================", CRCHAR, LFCHAR
                DB      "   4E    最初にマッチするファイルを見つける", CRCHAR, LFCHAR 
                DB      "   4F    次にマッチするファイルを見つける", CRCHAR, LFCHAR 
                DB      "   56    ファイル名変更", CRCHAR, LFCHAR 
                DB      "   57    ファイル日時の設定", CRCHAR, LFCHAR 
                DB      "   57    ファイル日時の読取り", CRCHAR, LFCHAR 
                DB      "======== ===========================================", CRCHAR, LFCHAR
                DB      "を　テストします。", CRCHAR, LFCHAR 
                DB      "テスト中にドライブ A をアクセスします。", CRCHAR, LFCHAR
                DB      "フォーマットしたディスケットをドライブ A に入れて下さい。", CRCHAR, LFCHAR
                DB      "テストを開始します。", CRCHAR, LFCHAR, DALLAR

Test00Msg0      DB      "              ファイル属性                      現在の属性", CRCHAR, LFCHAR, DALLAR
Test00Msg1      DB      "              読取り専用ファイル (READONLY)       ", DALLAR
Test00Msg2      DB      "              隠しファイル (HIDDEN)               ", DALLAR
Test00Msg3      DB      "              システム・ファイル (SYSTEM)         ", DALLAR 
Test00Msg4      DB      "              ボリュームラベル (LABEL)            ", DALLAR 
Test00Msg5      DB      "              サブ・ディレクトリー (SUBDIRECTORY) ", DALLAR 
Test00Msg6      DB      "              保存ビット (ARCHIVE)                ", DALLAR 
Test00MsgOn     DB      "ON", DALLAR
Test00MsgOff    DB      "OFF", DALLAR

Test4E          DB      "機能番号4E 最初にマッチするファイルを見つける", CRCHAR, LFCHAR, DALLAR
Test4EMsg1      DB      "        テストファイルを作成します。", CRCHAR, LFCHAR, DALLAR
Test4EMsg2      DB      "        テストファイルを作成出来ませんでした。 エラーコード ", DALLAR
Test4EMsg3      DB      "        テストファイルを作成しました。", CRCHAR, LFCHAR, DALLAR
Test4EMsg4      DB      "              TESTFILE.000", CRCHAR, LFCHAR
                DB      "              TESTFILE.001", CRCHAR, LFCHAR
                DB      "              TESTFILE.002", CRCHAR, LFCHAR
                DB      "              TESTFILE.003", CRCHAR, LFCHAR
                DB      "              TESTFILE.004", CRCHAR, LFCHAR, DALLAR
Test4EMsg5      DB      "        最初にマッチするファイルを見つけます。", CRCHAR, LFCHAR, DALLAR
                DB      "              探すファイル名: TEST*.*", CRCHAR, LFCHAR, DALLAR
Test4EMsg6      DB      "              ファイルは見つかりません。 エラーコード ", DALLAR
Test4EMsg7      DB      "              見つかったファイル名 ", DALLAR
Test4EMsg9      DB      "              ファイル日時 ", DALLAR

Test4F          DB      "機能番号4F 次にマッチするファイルを見つける", CRCHAR, LFCHAR, DALLAR
Test4FMsg1      DB      "        次にマッチするファイルを見つけます。", CRCHAR, LFCHAR, DALLAR
Test4FMsg2      DB      "              ファイルはもうありません。", CRCHAR, LFCHAR, DALLAR

Test56          DB      "機能番号56 ファイル名変更", CRCHAR, LFCHAR, DALLAR
Test56Msg1      DB      "        テストファイル OLDFILE.DAT を作ります。", CRCHAR, LFCHAR, DALLAR
Test56Msg2      DB      "        テストファイルを作れませんでした。 エラーコード ", DALLAR
Test56Msg3      DB      "        作成したファイル名を確認できません。エラーコード ", DALLAR
Test56Msg4      DB      "        作成したファイル名 ", DALLAR
Test56Msg5      DB      "        ファイル名を変更します。", CRCHAR, LFCHAR, DALLAR
Test56Msg6      DB      "        変更後のファイル名 ", DALLAR

Test57          DB      "機能番号57 ファイル日時の設定/ファイル日時の読取り", CRCHAR,  LFCHAR, DALLAR
Test57Msg1      DB      "        テストファイルを NEWFILE.DAT をオープンします。", CRCHAR, LFCHAR,DALLAR
Test57Msg2      DB      "        テストファイルをオープンできません。 エラーコード ", DALLAR
Test57Msg3      DB      "        テストファイルの日時を読取ります。", CRCHAR, LFCHAR, DALLAR
Test57Msg4      DB      "            日時を読取れません。 エラーコード ",  DALLAR
Test57Msg5      DB      "            現在の日時 ", DALLAR
Test57Msg6      DB      "        テストファイル NEWFILE.DAT の日時を変更します。", CRCHAR, LFCHAR
                DB      "            新しい日時 ", DALLAR
Test57Msg7      DB      "            設定できません。 エラーコード ", DALLAR
Test57Msg8      DB      "        テストファイル NEWFILE.DAT の日時を確認します。", CRCHAR, LFCHAR, DALLAR
Test57Msg9      DB      "            日時を読取れません。 エラーコード ",  DALLAR
Test57Msg10     DB      "            設定された日時 ", DALLAR

rc              DW      0         
TstFile3Data    ENDS

TstFile3Code    SEGMENT PARA
                ASSUME  CS:TstFile3Code, DS:TstFile3Data, ES:TstFile3Data, SS:Stack

skipBlanks      PROC    NEAR
skipBlanks2:
                CMP     BYTE PTR [SI], BLANK
                JNE     skipBlanks1
                INC     SI
                JMP     skipBlanks2
skipBlanks1:       
                RET
skipBlanks      ENDP

copyDateTime    PROC    NEAR
                CALL    skipBlanks
copyDateTime2:    
                MOV     AL, BYTE PTR [SI]
                CMP     AL, BYTE PTR DALLAR
                JE      copyDateTime1
                MOV     [DI], AL
                INC     SI
                INC     DI
                JMP     copyDateTime2
copyDateTime1:    
                RET
copyDateTime    ENDP

DTTMFmtUS       PROC    NEAR
                MOV     CX, DateTimeUSLength
                LEA     DI, DateTimeUS
DTTMFmtUS2:     
                JCXZ    DTTMFmtUS1
                MOV     BYTE PTR [DI], BLANK
                INC     DI
                DEC     CX
                JMP     DTTMFmtUS2
DTTMFmtUS1:     
                MOV     AX, TempTime
                AND     AX, MASK @Hours
                MOV     CL, @Hours
                SHR     AX, CL
                MOV     Code, AX
                CALL    uint2dec
                LEA     SI, CodeBuf
                LEA     DI, DateTimeUS.@@DTTMHoursUS
                CALL    copyDateTime
                LEA     DI, DateTimeUS.@@DTTMSepa1US
                MOV     AL, BYTE PTR TimeSepa
                MOV     BYTE PTR [DI], AL
                MOV     AX, TempTime
                AND     AX, MASK @Minutes
                MOV     CL, @Minutes
                SHR     AX, CL
                MOV     Code, AX
                CALL    uint2dec
                LEA     SI, CodeBuf    
                LEA     DI, DateTimeUS.@@DTTMMinutesUS 
                CALL    copyDateTime
                LEA     DI, DateTimeUS.@@DTTMSepa2US
                MOV     AL, BYTE PTR TimeSepa
                MOV     BYTE PTR [DI], AL
                MOV     AX, TempTime
                AND     AX, MASK @Seconds
                MOV     CL, 2
                MUL     CL
                MOV     Code, AX
                CALL    uint2dec
                LEA     SI, CodeBuf
                LEA     DI, DateTimeUS.@@DTTMSecondsUS
                CALL    copyDateTime
                MOV     AX, TempDate
                AND     AX, MASK @Month
                MOV     CL, @Month
                SHR     AX, CL
                MOV     Code, AX
                CALL    uint2dec
                LEA     SI, CodeBuf
                LEA     DI, DateTimeUS.@@DTTMMonthUS
                CALL    copyDateTime
                LEA     DI, DateTimeUS.@@DTTMSepa3US
                MOV     AL, BYTE PTR DateSepa
                MOV     BYTE PTR [DI], AL
                MOV     AX, TempDate
                AND     AX, MASK @Day
                MOV     Code, AX
                CALL    uint2dec
                LEA     SI, CodeBuf
                LEA     DI, DateTimeUS.@@DTTMDayUS
                CALL    copyDateTime
                LEA     DI, DateTimeUS.@@DTTMSepa4US
                MOV     AL, BYTE PTR DateSepa
                MOV     BYTE PTR [DI], AL
                MOV     AX, TempDate
                AND     AX, MASK @Year 
                MOV     CL, @Year
                SHR     AX, CL
                ADD     AX, 1980
                CALL    uint2dec
                MOV     Code, AX
                LEA     SI, CodeBuf
                LEA     DI, DateTimeUS.@@DTTMYearUS
                CALL    copyDateTime
                RET
DTTMFmtUS       ENDP

DTTMFmtEuro     PROC    NEAR
                MOV     CX, DateTimeEuroLength
                LEA     DI, DateTimeEuro
DTTMFmtEuro2:    
                JCXZ    DTTMFmtEuro1
                MOV     BYTE PTR [DI], BLANK
                INC     DI
                DEC     CX
                JMP     DTTMFmtEuro2
DTTMFmtEuro1:    
                MOV     AX, TempTime
                AND     AX, MASK @Hours
                MOV     CL, @Hours
                SHR     AX, CL
                MOV     Code, AX
                CALL    uint2dec
                LEA     SI, CodeBuf
                LEA     DI, DateTimeEuro.@@DTTMHoursEuro
                CALL    copyDateTime
                LEA     DI, DateTimeEuro.@@DTTMSepa1Euro
                MOV     AL, BYTE PTR TimeSepa
                MOV     BYTE PTR [DI], AL
                MOV     AX, TempTime
                AND     AX, MASK @Minutes
                MOV     CL, @Minutes
                SHR     AX, CL
                MOV     Code, AX
                CALL    uint2dec
                LEA     SI, CodeBuf
                LEA     DI, DateTimeEuro.@@DTTMMinutesEuro
                CALL    copyDateTime
                LEA     DI, DateTimeEuro.@@DTTMSepa2Euro
                MOV     AL, BYTE PTR TimeSepa
                MOV     BYTE PTR [DI], AL
                MOV     AX, TempTime
                AND     AX, MASK @Seconds
                MOV     CL, 2
                MUL     CL
                MOV     Code, AX
                CALL    uint2dec
                LEA     SI, CodeBuf
                LEA     DI, DateTimeEuro.@@DTTMSecondsEuro
                CALL    copyDateTime
                MOV     AX, TempDate
                AND     AX, MASK @Day
                MOV     Code, AX
                CALL    uint2dec
                LEA     SI, CodeBuf
                LEA     DI, DateTimeEuro.@@DTTMDayEuro
                CALL    copyDateTime
                LEA     DI, DateTimeEuro.@@DTTMSepa3Euro
                MOV     AL, BYTE PTR DateSepa
                MOV     BYTE PTR [DI], AL
                MOV     AX, TempDate
                AND     AX, MASK @Month
                MOV     CL, @Month
                SHR     AX, CL
                MOV     Code, AX
                CALL    uint2dec
                LEA     SI, CodeBuf
                LEA     DI, DateTimeEuro.@@DTTMMonthEuro
                CALL    copyDateTime
                LEA     DI, DateTimeEuro.@@DTTMSepa4Euro
                MOV     AL, BYTE PTR DateSepa
                MOV     BYTE PTR [DI], AL
                MOV     AX, TempDate
                AND     AX, MASK @Year 
                MOV     CL, @Year
                SHR     AX, CL
                ADD     AX, 1980
                MOV     Code, AX
                CALL    uint2dec
                LEA     SI, CodeBuf
                LEA     DI, DateTimeEuro.@@DTTMYearEuro
                CALL    copyDateTime
                RET
DTTMFmtEuro     ENDP

DTTMFmtJpn      PROC    NEAR
                MOV     CX, DateTimeJpnLength
                LEA     DI, DateTimeJpn
DTTMFmtJpn2:
                JCXZ    DTTMFmtJpn1
                MOV     BYTE PTR [DI], BLANK
                INC     DI
                DEC     CX
                JMP     DTTMFmtJpn2
DTTMFmtJpn1:    
                MOV     AX, TempDate
                AND     AX, MASK @Year 
                MOV     CL, @Year
                SHR     AX, CL
                ADD     AX, 1980
                MOV     Code, AX
                CALL    uint2dec
                LEA     SI, CodeBuf
                LEA     DI, DateTimeJpn.@@DTTMYearJpn
                CALL    copyDateTime
                LEA     DI, DateTimeJpn.@@DTTMSepa1Jpn
                MOV     AL, BYTE PTR DateSepa
                MOV     BYTE PTR [DI], AL
                MOV     AX, TempDate
                AND     AX, MASK @Month
                MOV     CL, @Month
                SHR     AX, CL
                MOV     Code, AX
                CALL    uint2dec
                LEA     SI, CodeBuf
                LEA     DI, DateTimeJpn.@@DTTMMonthJpn
                CALL    copyDateTime
                LEA     DI, DateTimeJpn.@@DTTMSepa2Jpn
                MOV     AL, BYTE PTR DateSepa
                MOV     BYTE PTR [DI], AL
                MOV     AX, TempDate
                AND     AX, MASK @Day
                MOV     Code, AX
                CALL    uint2dec
                LEA     SI, CodeBuf
                LEA     DI, DateTimeJpn.@@DTTMDayJpn
                CALL    copyDateTime
                MOV     AX, TempTime
                AND     AX, MASK @Hours
                MOV     CL, @Hours
                SHR     AX, CL
                MOV     Code, AX
                CALL    uint2dec
                LEA     SI, CodeBuf
                LEA     DI, DateTimeJpn.@@DTTMHoursJpn
                CALL    copyDateTime
                LEA     DI, DateTimeJpn.@@DTTMSepa3Jpn
                MOV     AL, BYTE PTR TimeSepa
                MOV     BYTE PTR [DI], AL
                MOV     AX, TempTime
                AND     AX, MASK @Minutes
                MOV     CL, @Minutes
                SHR     AX, CL
                MOV     Code, AX
                CALL    uint2dec
                LEA     SI, CodeBuf
                LEA     DI, DateTimeJpn.@@DTTMMinutesJpn
                CALL    copyDateTime
                LEA     DI, DateTimeJpn.@@DTTMSepa4Jpn
                MOV     AL, BYTE PTR TimeSepa
                MOV     BYTE PTR [DI], AL
                MOV     AX, TempTime
                AND     AX, MASK @Seconds
                MOV     CL, 2
                MUL     CL
                MOV     Code, AX
                CALL    uint2dec
                LEA     SI, CodeBuf
                LEA     DI, DateTimeJpn.@@DTTMSecondsJpn
                CALL    copyDateTime
                RET
DTTMFmtJpn      ENDP

dispDateTime    PROC    NEAR
                MOV     AX, DateTimeFmt
                CMP     AX, WORD PTR @DOSDTTMFMTUS
                JNZ     dispDateTime1
                CALL    DTTMFmtUS
                @DosDispString DateTimeUS
                JMP     dispDateTime2
dispDateTime1:
                CMP     AX, WORD PTR @DOSDTTMFMTEURO
                JNE     dispDateTime3
                CALL    DTTMFmtEuro
                @DosDispString DateTimeEuro
                JMP     dispDateTime2
dispDateTime3:
                CMP     AX, WORD PTR @DOSDTTMFMTJPN 
                JNE     dispDateTime4
                CALL    DTTMFmtJpn
                @DosDispString DateTimeJpn
                JMP     dispDateTime2
dispDateTime4:
                CALL    DTTMFmtJpn
                @DosDispString DateTimeJpn
dispDateTime2:
                @DosDispString NewLine
                RET
dispDateTime    ENDP

dispAttrib      PROC    NEAR
                MOV     TestFileAttrib, AX
                @DosDispString Test00Msg0
                @DosDispString Test00Msg1
                MOV     AX, TestFileAttrib
                AND     AX, WORD PTR DOSREADONLY
                JZ      dispAttrib1
                @DosDispString Test00MsgOn
                JMP     dispAttrib2
dispAttrib1:                
                @DosDispString Test00MsgOff
dispAttrib2:                
                @DosDispString NewLine
                @DosDispString Test00Msg2
                MOV     AX, TestFileAttrib 
                AND     AX, WORD PTR DOSHIDDEN
                JZ      dispAttrib3
                @DosDispString Test00MsgOn
                JMP     dispAttrib4
dispAttrib3:                
                @DosDispString Test00MsgOff
dispAttrib4:                
                @DosDispString NewLine
                @DosDispString Test00Msg3
                MOV     AX, TestFileAttrib 
                AND     AX, WORD PTR DOSSYSTEM
                JZ      dispAttrib5
                @DosDispString Test00MsgOn
                JMP     dispAttrib6
dispAttrib5:                
                @DosDispString Test00MsgOff 
dispAttrib6:                
                @DosDispString NewLine
                @DosDispString Test00Msg4
                MOV     AX, TestFileAttrib 
                AND     AX, WORD PTR DOSLABEL
                JZ      dispAttrib7
                @DosDispString Test00MsgOn
                JMP     dispAttrib8
dispAttrib7:                
                @DosDispString Test00MsgOff 
dispAttrib8:                
                @DosDispString NewLine
                @DosDispString Test00Msg5
                MOV     AX, TestFileAttrib 
                AND     AX, WORD PTR DOSSUBDIR
                JZ      dispAttrib9
                @DosDispString Test00MsgOn
                JMP     dispAttrib10
dispAttrib9:                
                @DosDispString Test00MsgOff
dispAttrib10:                
                @DosDispString NewLine
                @DosDispString Test00Msg6
                MOV     AX, TestFileAttrib 
                AND     AX, WORD PTR DOSARCHIVE
                JZ      dispAttrib11
                @DosDispString Test00MsgOn
                JMP     dispAttrib12
dispAttrib11:                
                @DosDispString Test00MsgOff
dispAttrib12:                
                RET
dispAttrib      ENDP

getFileName     PROC    NEAR
getFileName2:
                MOV     AL, BYTE PTR [SI]
                CMP     AL, BYTE PTR EOS
                MOV     BYTE PTR [DI], AL
                JE      getFileName1 
                INC     SI
                INC     DI
                JMP     getFileName2
getFileName1:  
                MOV     BYTE PTR [DI], DALLAR
                RET
getFileName     ENDP

dispDTAInfo     PROC    NEAR
                @DosDispString Test4EMsg7
                LEA     SI, TestDTA.@@DTAName
                LEA     DI, TestFileName
                CALL    getFileName
                @DosDispString TestFileName
                @DosDispString NewLine
                MOV     AX, 0
                MOV     AL, TestDTA.@@DTAAttrib
                CALL    dispAttrib
                @DosDispString NewLine
                @DosDispString Test4EMsg9
                MOV     AX, TestDTA.@@Date 
                MOV     TempDate, AX
                MOV     AX, TestDTA.@@Time 
                MOV     TempTime, AX
                MOV     AL, CInfo.@@TimeFmt
                MOV     TimeFMT, AL
                CALL    dispDateTime
                @DosDispString NewLine
                RET
dispDTAInfo     ENDP

pause           PROC    NEAR
                @DosDispString PauseMsg
                @DosClrKbdBuf
                @DosDirectInWOEcho bJunk
                @DosDispString NewLine
                @DosDispString NewLine
                RET
pause           ENDP

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

main            PROC
                MOV     AX, SEG rc      ; setup DS
                MOV     DS, AX

                @DosDispString OpenMsg
                CALL    pause
                @DosSelDisk drvLtrA, wJunk

                @DosDispString Test4E
                @DosDispString Test4EMsg1
                @DosCreat TestFileName0, TestFileAttrib, TestFileHandle
                JNC     main1 
                MOV     Code, AX
                @DosDispString Test4Emsg2
                CALL    uint2hex
                @DosDispString HexBuf
                @DosDispString NewLine
                JMP     main99
main1:
                @DosClose TestFileHandle
                @DosCreat TestFileName1, TestFileAttrib, TestFileHandle
                JNC     main2
                MOV     Code, AX
                @DosDispString Test4Emsg2
                CALL    uint2hex
                @DosDispString HexBuf
                @DosDispString NewLine
                JMP     main99
main2:
                @DosClose TestFileHandle
                @DosCreat TestFileName2, TestFileAttrib, TestFileHandle
                JNC     main3
                MOV     Code, AX
                @DosDispString Test4Emsg2
                CALL    uint2hex
                @DosDispString HexBuf
                @DosDispString NewLine
                JMP     main99
main3:
                @DosClose TestFileHandle
                @DosCreat TestFileName3, TestFileAttrib, TestFileHandle
                JNC     main4
                MOV     Code, AX
                @DosDispString Test4Emsg2
                CALL    uint2hex
                @DosDispString HexBuf
                @DosDispString NewLine
                JMP     main99
main4:
                @DosClose TestFileHandle
                @DosCreat TestFileName4, TestFileAttrib, TestFileHandle
                JNC     main5
                MOV     Code, AX
                @DosDispString Test4Emsg2
                CALL    uint2hex
                @DosDispString HexBuf
                @DosDispString NewLine
                JMP     main99
main5:
                @DosClose TestFileHandle
                @DosDispString Test4EMsg5
                @DosSetDTA TestDTA
                @DosFindFirst TestFileMatch, TestFileAttrib
                JNC     main6
                MOV     Code, AX
                @DosDispString Test4Emsg6
                CALL    uint2hex
                @DosDispString HexBuf
                @DosDispString NewLine
                JMP     main99
main6:
                CALL    dispDTAInfo
                CALL    pause
                
                @DosDispString Test4F
main8:
                @DosDispString Test4FMsg1
                @DosFindNext
                CMP     AX, 18
                JE      main7
                CALL    dispDTAInfo
                CALL    pause
                JMP     main8
main7:
                @DosDispString Test4FMsg2
                CALL    pause

                @DosDispString Test56
                @DosDelete NewFileName
                @DosCreat OldFileName, OldFileAttrib, OldFileHandle
                JNC     main9
                MOV     Code, AX
                @DosDispString Test56Msg2
                CALL    uint2hex
                @DosDispString HexBuf
                @DosDispString NewLine
                JMP     main10
main9:          
                @DosClose OldFileHandle
                @DosFindFirst OldFileName, OldFileAttrib
                JNC     main11
                MOV     Code, AX
                @DosDispString Test56Msg3
                CALL    uint2hex
                @DosDispString HexBuf
                @DosDispString NewLine
                JMP     main10
main11:         
                @DosDispString Test56Msg4
                LEA     SI, TestDTA.@@DTAName
                LEA     DI, TestFileName
                CALL    getFileName
                @DosDispString TestFileName
                @DosDispString NewLine

                @DosDispString Test56Msg5
                @DosRename OldFileName, NewFileName
                @DosFindFirst NewFileName, NewFileAttrib
                @DosDispString Test56Msg6
                LEA     SI, TestDTA.@@DTAName
                LEA     DI, TestFileName
                CALL    getFileName
                @DosDispString TestFileName
                @DosDispString NewLine

                CALL    pause
                
                @DosGetCountryInfo CInfo
                MOV     AX, CInfo.@@DTTMFmt
                MOV     DateTimeFMT, AX
                MOV     AL, CInfo.@@SepDate
                MOV     DateSepa, AL
                MOV     AL, CInfo.@@SepTime
                MOV     TimeSepa, AL
                MOV     AL, CInfo.@@TimeFmt
                MOV     TimeFMT, AL
                
                @DosDispString Test57
                @DosDispString Test57Msg1
                @DosOpen NewFileName, NewFileAccess, NewFileHandle
                JNC     main12
                MOV     Code, AX
                @DosDispString Test57Msg2
                CALL    uint2hex
                @DosDispString HexBuf
                @DosDispString NewLine
                JMP     main13
main12:
                @DosDispString Test57Msg3
                MOV     CurDate, 0
                MOV     CurTime, 0
                @DosGetTimeStamp NewFileHandle, CurDate, CurTime
                JNC     main14
                MOV     Code, AX
                @DosDispString Test57Msg4
                CALL    uint2hex
                @DosDispString HexBuf
                @DosDispString NewLine
                JMP     main13
main14:                
                @DosDispString Test57Msg5
                MOV     AX, CurDate
                MOV     TempDate, AX
                MOV     AX, CurTime
                MOV     TempTime, AX
                CALL    dispDateTime
                
                @DosDispString Test57Msg6
                MOV     AX, NewDate
                MOV     TempDate, AX
                MOV     AX, NewTime
                MOV     TempTime, AX
                CALL    dispDateTime
                
                @DosSetTimeStamp NewFileHandle, NewDate, NewTime
                JNC     main15
                MOV     Code, AX
                @DosDispString Test57Msg7
                CALL    uint2hex
                @DosDispString HexBuf
                @DosDispString NewLine
                JMP     main13
main15:                
                @DosDispString Test57Msg8 
                MOV     CurDate, 0
                MOV     CurTime, 0
                @DosGetTimeStamp NewFileHandle, CurDate, CurTime
                JNC     main16
                MOV     Code, AX
                @DosDispString Test57Msg9
                CALL    uint2hex
                @DosDispString HexBuf
                JMP     main13
main16:
                @DosDispString Test57Msg10
                MOV     AX, CurDate
                MOV     TempDate, AX
                MOV     AX, CurTime
                MOV     TempTime, AX
                CALL    dispDateTime
main13:
                @DosClose NewFileHandle
main10:
main99:
                @DosSelDisk drvLtrC, wJunk
      
                MOV     rc, 00H
                @DosExit rc
main            ENDP
TstFile3Code    ENDS
                END     main
