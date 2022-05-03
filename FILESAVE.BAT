@echo off
copy a:\DosCalls\*.* c:\Doscalls\doscalls\*.* /V
copy a:\TestProg\*.* c:\Doscalls\TestProg\*.* /V
copy a:\Samples\*.*  c:\Doscalls\Samples\*.*  /V
copy a:\Debug\*.*    c:\Doscalls\Debug\*.*    /V
copy a:\*.*          c:\Doscalls\*.*          /V
@echo on
