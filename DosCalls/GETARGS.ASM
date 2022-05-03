PAGE    ,132
TITLE   GETARGS.ASM -- Get command line arguments
%OUT    GETARGS.ASM

INCLUDE CONSTANT.INC
INCL_MISC       EQU     0
INCLUDE DosCalls.MAC

DONE            EQU     0H
YES             EQU     0H
MAXARGS         EQU     20
BUFSIZ          EQU     128

@@GetArgsData   SEGMENT PARA PUBLIC
; Constant
delimChars      DB      TAB, BLANK, COMMA, SQUORT, DQUORT, EOS
spaceChars      DB      BLANK, TAB, EOS
quortChars      DB      SQUORT, DQUORT, EOS

; Save area
initFlag        DB      NOT DONE ; PSP segment information initialize flag
ptrPSP          DW      NULL    ; NULL    ; Segment of PSP
                DW      0       ; Offset of PSP
argDest         DW      NULL    ; SEGMENT arg destination address
                DW      NULL    ; OFFSET arg destination address
parmCnt         DW      0
parmPtr         DW      MAXARGS DUP(NULL) ; Point to parameter
cmdBuf          DB      BUFSIZ DUP('*'), EOS     
parmBuf         DB      BUFSIZ DUP('%'), EOS
lastComma       DW      NOT YES 
quort           DB      EOS     ; Quort chararacter
saveBX          DW      -1
saveCX          DW      -1
saveDX          DW      -1
saveSI          DW      -1
saveDI          DW      -1
saveDS          DW      -1
saveES          DW      -1
saveBP          DW      -1
@@GetArgsData   ENDS

@@DosCallsStack SEGMENT PARA STACK 'STACK'
                DB      20 DUP('@')
@@DosCallsStack ENDS

@@GetArgsCode   SEGMENT PARA PUBLIC
                ASSUME  CS:@@GetArgsCode, DS:@@GetArgsData, ES:@@GetArgsData, SS:@@DosCallsStack
;      getArgv -- Return pointer to argument
;      ENTRY  @index : Index of arguments
;      RETURN  @arg : Point to argument
                PUBLIC  @@getArgv
@@getArgv       PROC    FAR             ; getArgv @index @arg
                PUSH    DS              ; save Regs
                MOV     AX, SEG saveDS
                MOV     DS, AX
                MOV     saveBX, BX
                MOV     saveCX, CX
                MOV     saveDX, DX
                MOV     saveSI, SI
                MOV     saveDI, DI
                POP     AX
                MOV     saveDS, AX
                MOV     saveES, ES
                MOV     saveBP, BP
                
                MOV     BP, SP
                CALL    initArgs

                MOV     AX, [BP+4]      ; SEGMENT @argv
                MOV     argDest, AX     ; Save Arg buffer pointer
                MOV     AX, [BP+6]      ; OFFSET @argv
                MOV     argDest+2, AX

                MOV     AX, argDest  
                MOV     ES, AX
                MOV     DI, argDest+2
                MOV     BYTE PTR ES:[DI], EOS ; Set null string

                MOV     AX, [BP+8]      ; SEGMENT @index
                MOV     ES, AX
                MOV     DI, [BP+10]     ; OFFSET @index
                MOV     AX, WORD PTR ES:[DI]
                CMP     AX, parmCnt     ; Check out index range
                JG      getArgv1        ; Index too big

                DEC     AX              ; Determein Argv pointer
                ADD     AX, AX
                ADD     AX, OFFSET parmPtr
                MOV     SI, AX
                MOV     SI, [SI]        ; Source OFFSET
                
                MOV     AX, argDest     ; Restore arg destination SEGMENT
                MOV     ES, AX
                MOV     DI, argDest+2   ; Restore arg destination OFFSET
getArgv2:
                MOV     AL, BYTE PTR DS:[SI] ; Copy arg string
                MOV     BYTE PTR ES:[DI], AL
                CMP     AL, BYTE PTR EOS
                JE      getArgv1
                INC     SI
                INC     DI
                JMP     getArgv2
getArgv1:
                MOV     BX, saveBX      ; Restore Regs
                MOV     CX, saveCX
                MOV     DX, saveDX
                MOV     SI, saveSI
                MOV     DI, saveDI
                MOV     ES, saveES
                MOV     BP, saveBP
                MOV     DS, saveDS
                RET     8
@@getArgv       ENDP

;      getArgc -- Return number of arguments
;      ENTRY  ==NONE==
;      RETURN  ==NONE==
                PUBLIC  @@getArgc
@@getArgc       PROC    FAR             ; @argc
                PUSH    DS              ; save Regs
                MOV     AX, SEG saveDS
                MOV     DS, AX
                MOV     saveBX, BX
                MOV     saveCX, CX
                MOV     saveDX, DX
                MOV     saveSI, SI
                MOV     saveDI, DI
                POP     AX
                MOV     saveDS, AX
                MOV     saveES, ES
                MOV     saveBP, BP

                MOV     BP, SP
                CALL    initArgs
                MOV     AX, [BP+4]      ; SEGMENT @argc
                MOV     ES, AX
                MOV     DI, [BP+6]      ; OFFSET @argc
                MOV     AX, WORD PTR parmCnt
                MOV     WORD PTR ES:[DI], AX
                
                MOV     BX, saveBX      ; Restore Regs
                MOV     CX, saveCX
                MOV     DX, saveDX
                MOV     SI, saveSI
                MOV     DI, saveDI
                MOV     ES, saveES
                MOV     BP, saveBP
                MOV     DS, saveDS
                RET     4
@@getArgc       ENDP

;               initArgs -- Initialize PSP and command line parameter work area
;               ENTRY   ==NONE==
;               RETURN  ==NONE==
initArgs        PROC
                CMP     initFlag, DONE
                JE      initArgs1
                @DosGetPSP ptrPSP
                CALL    saveArgs
                MOV     initFlag, DONE  ; Initialization completed
initArgs1:
                RET
initArgs        ENDP

;       skipBlanks
;       ENTRY  DS:[SI] : Point to environmrnt string
;       RETURN DS:[SI] : Point to next NON-BLANK character
;              AL : Last character
skipBlanks      PROC
skipBlanks2:
                MOV     AL, BYTE PTR [SI]
                CMP     AL, BYTE PTR EOS
                JE      skipBlanks1
                CALL    isSpace
                JC      skipBlanks1
                INC     SI
                JMP     skipBlanks2
skipBlanks1:
                RET
skipBlanks      ENDP

;       saveQWord -- save Quorted word
;       ENTRY   ==NONE==
;       RETURN  ==NONE==
saveQWord       PROC
                MOV     AL, BYTE PTR [SI]
                MOV     quort, AL
                INC     SI
                MOV     DX, DI
saveQWord1:
                MOV     AL, BYTE PTR [SI]
                CMP     AL, BYTE PTR EOS
                JE      saveQWord2
                CMP     AL, quort
                JE      saveQWord3
                MOV     BYTE PTR [DI], AL
                INC     SI
                INC     DI
                JMP     saveQWord1
saveQWord3:
                INC     SI
saveQWord2:       
                MOV     BYTE PTR [DI], EOS
                INC     DI
                CALL    SaveArgPtr
                RET
saveQWord       ENDP

;       saveOWord -- save Other Word 
;       ENTRY   ==NONE==
;       RETURN  ==NONE==
saveOWord       PROC
                MOV     DX, DI
saveOWord1:
                MOV     AL, BYTE PTR [SI]
                CMP     AL, BYTE PTR EOS
                JE      saveOWord2
                CALL    isDelim
                JNC     saveOWord2
                MOV     BYTE PTR [DI], AL
                INC     SI
                INC     DI
                JMP     saveOWord1
saveOWord2:
                MOV     BYTE PTR [DI], EOS
                CALL    SaveArgPtr
                INC     DI
                RET
saveOWord       ENDP

;       saveArgs -- parse and save command line parameters
;       ENTRY   ==NONE==
;       RETURN  ==NONE==
saveArgs        PROC
                CALL    copyCmdBuffer
                MOV     SI, OFFSET cmdBuf
                MOV     DI, OFFSET parmBuf
                CALL    skipBlanks
saveArgs1:        
                MOV     AL, BYTE PTR [SI]
                CMP     AL, BYTE PTR EOS
                JE      saveArgs2
                MOV     lastComma, NOT YES
                CALL    isQuort
                JC      saveArgs3
                CALL    saveQWord
                JMP     saveArgs4
saveArgs3:
                CALL    saveOWord
saveArgs4:
                CALL    skipBlanks
                CMP     BYTE PTR [SI], COMMA
                JNE     saveArgs6
                MOV     lastComma, YES
                INC     SI
                CALL    skipBlanks
saveArgs6:                       
                JMP     saveArgs1
saveArgs2:                       
                CMP     lastComma, YES
                JNE     saveArgs5
                CALL    saveOWord
saveArgs5:                       
                RET
saveArgs        ENDP

;      saveArgPtr -- Save pointer to command line parameter
;                    and increment argment counter
;      ENTRY  ==NONE==
;      RETURN  ==NONE==
saveArgPtr      PROC
                PUSH    SI              ; Save SI
                MOV     AX, parmCnt
                CMP     AX, MAXARGS     
                JGE     saveArgPtr1
                ADD     AX, AX
                MOV     SI, AX
                MOV     BX, OFFSET parmPtr
                MOV     DS:[BX+SI], DX
                INC     parmCnt         ; Count up parmCnt
saveArgPtr1:
                POP     SI              ; Resotre SI
                RET
saveArgPtr      ENDP

;     isDelim -- Check delimiter character
;     ENTRY AL : Character to be tested
;     RETURN CY = 0 : Match delimiter chatcter
;            CY = 1 : Not match delimiter chatcter
isDelim         PROC
                PUSH    ES
                PUSH    DI
                MOV     BX, SEG delimChars
                MOV     ES, BX
                MOV     DI, OFFSET delimChars
                CALL    isChars
                POP     DI
                POP     ES
                RET
isDelim         ENDP
               
;     isQuort -- Check quort character
;     ENTRY AL : Character to be tested
;     RETURN CY = 0 : Match quort chatctar
;            CY = 1 : Not match quort chatctar
isQuort         PROC
                PUSH    ES
                PUSH    DI
                MOV     BX, SEG quortChars
                MOV     ES, BX
                MOV     BX, OFFSET quortChars
                MOV     DI, BX
                CALL    isChars
                POP     DI
                POP     ES
                RET
isQuort         ENDP
               
;     isSpace -- Check space character
;     ENTRY AL : Character to be tested
;     RETURN CY = 0 : Match space chatcter
;            CY = 1 : Not match space chatcter
isSpace         PROC
                PUSH    ES
                PUSH    DI
                MOV     BX, SEG spaceChars
                MOV     ES, BX
                MOV     DI, OFFSET spaceChars
                CALL    isChars
                POP     DI
                POP     ES
                RET
isSpace         ENDP
               
;     isChars -- Finc character in character list
;     ENTRY AL : Character to be tested
;     RETUNR CY = 0 : Match chatacter in a list
;            CY = 1 : Do not match chatacter in a list
isChars         PROC
isChars2:
                CMP     BYTE PTR ES:[DI], EOS
                JE      isChars1
                CMP     AL, BYTE PTR ES:[DI]
                JE      isChars3
                INC     DI
                JMP     isChars2
isChars3:
                CLC
                JMP     isChars4
isChars1:
                STC
isChars4:
                RET
isChars         ENDP

;               copyCmdBuffer -- Copy one comand line parameter
;               ENTRY  === NONE ===
;               RETURN === NONE === 
copyCmdBuffer   PROC
                PUSH    DS              ; Save DS
                MOV     AX, ptrPSP
                MOV     DS, AX
                MOV     CX, 0
                MOV     CL, BYTE PTR DS:[80H]
                MOV     AX, SEG cmdBuf
                MOV     ES, AX
                MOV     SI, 81H         ; Source SEGMENT:OFFSET
                MOV     DI, OFFSET cmdBuf
                CLD
                REP MOVS BYTE PTR ES:[DI], DS:[SI]
                MOV     BYTE PTR ES:[DI], EOS
                POP     DS              ; Restore DS
                RET
copyCmdBuffer   ENDP
@@GetArgsCode   ENDS
                END
