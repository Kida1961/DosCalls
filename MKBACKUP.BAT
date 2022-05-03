@echo off
if "%1" == "" goto MESSAGE
mkdir .\DosCalls.%1
xcopy .\DosCalls\*.*     .\DosCalls.%1\DosCalls\*.* /S /V
xcopy .\TestProg\*.*     .\DosCalls.%1\TestProg\*.* /S /V
xcopy .\Samples\*.*      .\DosCalls.%1\Samples\*.* /S /V
xcopy .\DosDebug\*.*     .\DosCalls.%1\Debug\*.* /S /V
xcopy .\*.*              .\DosCalls.%1\*.* /S /V
dir .\DosCalls.%1 /W
pause
dir .\DosCalls.%1\DosCalls /W
pause
dir .\DosCalls.%1\TestProg /W
pause
dir .\DosCalls.%1\Samples /W
pause
dir .\DosCalls.%1\Debug /W
pause
goto END
:MESSAGE
echo 使い方
echo       %0 バックアップバージョン (V00 V01 V02 ......)
:END
@echo on
