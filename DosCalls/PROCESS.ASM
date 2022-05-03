PAGE    ,132
TITLE   PROCESS.ASM -- Process controle
%OUT    PROCESS.ASM

@@ProcessData   SEGMENT PARA
SaveDS          DW      -1
SaveBP          DW      -1
@@ProcessData   ENDS

@@DosCallsStack SEGMENT PARA STACK 'STACK'
                DB      6 DUP('#')
@@DosCallsStack ENDS

@@ProcessCode   SEGMENT PARA PUBLIC '@@DosCallsCode'
                ASSUME  CS:@@ProcessCode, DS:@@ProcessData, ES:@@ProcessData, SS:@@DosCallsStack

                PUBLIC  @@DosExit
@@DosExit       PROC    FAR     ; @exitcode
                PUSH    DS
                MOV     AX, SEG SaveDS
                MOV     DS, AX
                POP     AX
                MOV     SaveDS, AX
                MOV     SaveBP, BP
                
                MOV     BP, SP
                MOV     AX, [BP+4]      ; SEGMENT @exitcode
                MOV     ES, AX
                MOV     AX, [BP+6]      ; OFFSET @exitcode
                MOV     SI, AX
                MOV     AX, ES:[SI]
                MOV     AH, 4CH
                INT     21H
@@DosExit       ENDP
@@ProcessCode   ENDS
                END
