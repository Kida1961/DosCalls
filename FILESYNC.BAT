@ECHO OFF                                                      
REPLACE C:\DOSCALLS\*.*                   A:\                  /A
REPLACE C:\DOSCALLS\DOSCALLS\*.*          A:\DOSCALLS          /A
REPLACE C:\DOSCALLS\TESTPROG\*.*          A:\TESTPROG          /A
REPLACE C:\DOSCALLS\SAMPLES\*.*           A:\SAMPLES           /A
REM
REPLACE C:\DOSCALLS\*.*                   A:\                  /U
REPLACE C:\DOSCALLS\DOSCALLS\*.*          A:\DOSCALLS          /U
REPLACE C:\DOSCALLS\TESTPROG\*.*          A:\TESTPROG          /U
REPLACE C:\DOSCALLS\SAMPLES\*.*           A:\SAMPLES           /U
@ECHO ON
