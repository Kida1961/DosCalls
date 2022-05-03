PAGE    ,132
TITLE   GETENVS.ASM -- Get environment variable
%OUT    GETENVS.ASM

INCLUDE CONSTANT.INC
INCL_MISC       EQU     0
INCLUDE DosCalls.MAC

DONE            EQU     0H

@@GetEnvsData   SEGMENT PARA PUBLIC
initFlag        DB      NOT DONE ; PSP segment information initialize flag
ptrPSP          DW      NULL    ; NULL    ; Segment of PSP
                DW      0       ; Offset of PSP
ptrENV          DW      NULL    ; NULL    ; Segment of Environment valiables,
                DW      0       ; Offset of Environment valiables,
EnvName         DW      NULL    ; SEGMENT:@Name
                DW      NULL    ; OFFSET :@Name
EnvValue        DW      NULL    ; SEGMENT:@Value
                DW      NULL    ; OFFSET :@Value
saveBX          DW      -1      ; Register save area
saveCX          DW      -1
saveDX          DW      -1
saveSI          DW      -1
saveDI          DW      -1
saveDS          DW      -1
saveES          DW      -1
saveBP          DW      -1
@@GetEnvsData   ENDS

@@DosCallsStack SEGMENT PARA STACK 'STACK'
                DB      20 DUP('@')
@@DosCallsStack ENDS

@@GetEnvsCode   SEGMENT PARA PUBLIC 
                ASSUME  CS:@@GetEnvsCode, DS:@@GetEnvsData, ES:@@GetEnvsData, SS:@@DosCallsStack

;       getEnv -- Get value of environment valiable
;       ENTRY DS:[SI] : Point to environment valiable name
;             ES:[DI] : Point to value of environment valiable
;       RETURN CY = 0 : Environment Valiable exist
;              CY = 1 : Environment Valiable does not xist
;              ES:[DI] : Point to value of environment valiable
                PUBLIC  @@getEnv
@@getEnv        PROC    FAR             ; getEnv @Name @Valiable
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
                
                MOV     AX, [BP+8]      ; SEGMENT of @Name
                MOV     EnvName, AX
                MOV     AX, [BP+10]     ; OFFSET of @Name
                MOV     EnvName+2, AX
               
                MOV     AX, [BP+4]      ; SEGMENT of @Value 
                MOV     EnvValue, AX
                MOV     ES, AX
                MOV     AX, [BP+6]      ; OFFET of @Value
                MOV     EnvValue+2, AX

                CALL    initEnvArgs
                
                CALL    lookupEnvName
                JC      getEnv1
                CALL    copyEnvValue
getEnv1:                
                MOV     BX, saveBX      ; Restore Regs
                MOV     CX, saveCX
                MOV     DX, saveDX
                MOV     SI, saveSI
                MOV     DI, saveDI
                MOV     ES, saveES
                MOV     BP, saveBP
                MOV     DS, saveDS
                
                RET     8
@@getEnv        ENDP

;               initEnvArgs -- Initialize PSP and command line parameter work area
;               ENTRY   ==NONE==
;               RETURN  ==NONE==
initEnvArgs     PROC
                CMP     initFlag, DONE
                JE      initEnvArgs1
                @DosGetPSP ptrPSP
                CALL    saveEnvInfo
                MOV     initFlag, DONE  ; Initialization completed
initEnvArgs1:
                RET
initEnvArgs     ENDP

;        savePSPInfo -- Save PSP addresses
;        ENTRY   ==NONE==
;        RETURN  ==NONE==
saveEnvInfo     PROC
                MOV     DI, OFFSET ptrEnv
                MOV     AX, ptrPSP
                MOV     ES, AX
                MOV     AX, ES:[2CH]
                MOV     DS:[DI], AX     ; Save address of environment valuable area
                RET
saveEnvInfo     ENDP

;       lookupEnvName -- look up Environment name
;       ENTRY   ==NONE==
;       RETURN  CY = 0 Found
;                       ES:DI -- Point to Environment Value 
;               CY = 1 Not Found
lookupEnvName   PROC
                PUSH    DS              ; Save DS

                MOV     AX, EnvValue    ; Make NULL string
                MOV     ES, AX
                MOV     DI, EnvValue+2
                MOV     BYTE PTR ES:[DI], EOS
                
                MOV     AX, ptrEnv
                MOV     ES, AX
                MOV     DI, ptrEnv+2
                
                MOV     AX, EnvName
                MOV     SI, EnvName+2
                MOV     DS, AX

lookupEnvName3:
                CALL    compEnvName
                JNC     lookupEnvName1
                CALL    skiptoNextEnvName
                JC      lookupEnvName2
                JMP     lookupEnvName3
lookupEnvName1:    
                CLC
                POP     DS              ; Restore DS
                RET

lookupEnvName2:    
                STC
                POP     DS              ; Restore DS
                RET
lookupEnvName   ENDP
          
;        compEnvName -- Compare target environment name
;        ENTRY DS:[SI] -- Environment name should be refered
;              ES:[DI] -- Environment name to be compared
;        RETURN CY = 0 : Equivalent
;               CY = 1 : Not equivalent
compEnvName     PROC
compEnvName3:
                MOV     AL, BYTE PTR DS:[SI]
                CMP     AL, BYTE PTR ES:[DI]
                JNE     compEnvName1
                INC     SI
                INC     DI
                JMP     compEnvName3
compEnvName1:
                CMP     AL, BYTE PTR EOS
                JNE     compEnvName5
                MOV     AL, BYTE PTR ES:[DI]
                CMP     AL, BYTE PTR EQUAL
                JNE     compEnvName5
                INC     DI              ; Point to next character
                CLC
                RET
compEnvName5:
                STC
                RET
compEnvName     ENDP

;       copyEnvValue -- Copy environment variable value
;       ENTRY ES:[DI] : Point to environment variable source
;       RETURN == NONE ==
copyEnvValue    PROC
                PUSH    DS
                MOV     AX, EnvValue
                MOV     SI, EnvValue+2
                MOV     DS, AX
copyEnvValue2:
                MOV     AL, BYTE PTR ES:[DI]
                MOV     BYTE PTR DS:[SI], AL
                CMP     AL, BYTE PTR EOS
                JE      copyEnvValue1
                INC     SI
                INC     DI
                JMP     copyEnvValue2
copyEnvValue1:
                POP     DS
                RET
copyEnvValue    ENDP

;       skiptoNextEnvName -- skip to next environment valiable name
;       ENTRY   DS:[SI] -- Environment staring
;       RETURN  DS:[SI] -- Point to next environment valiable name
skiptoNextEnvName PROC
skiptoNextEnvName2:
                MOV     AL, BYTE PTR ES:[DI]
                CMP     AL, BYTE PTR EOS
                JE      skiptoNextEnvName1
                INC     DI
                JMP     skiptoNextEnvName2
skiptoNextEnvName1:
                INC     DI
                MOV     AL, BYTE PTR ES:[DI]
                CMP     AL, BYTE PTR EOS
                JE      skiptoNextEnvName3
                CLC
                RET
skiptoNextEnvName3:
                STC
                RET
skiptoNextEnvName ENDP
@@GetEnvsCode   ENDS
                END
