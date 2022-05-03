PAGE    ,132
TITLE   DEVICE.ASM -- DEVICE related functions
%OUT    DEVICE.ASM
INCLUDE CONSTANT.INC

@@DeviceData    SEGMENT PARA
SaveBP          DW      -1
SaveDS          DW      -1
@@DeviceData    ENDS 

@@DosCallsStack SEGMENT PARA STACK 'STACK'
                DB      16 DUP('$')
@@DosCallsStack ENDS

@@DeviceCode    SEGMENT PARA
                ASSUME  CS:@@DeviceCode, DS:@@DeviceData, ES:@@DeviceData, SS:@@DosCallsStack
        
@@DeviceCode    ENDS
                END
