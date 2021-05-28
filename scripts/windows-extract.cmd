@echo off
:: ***************************************
:: Unzip into directory
:: Usage windows-extract <zipfile> <destdir>
:: ***************************************
:: https://stackoverflow.com/questions/21704041/creating-batch-script-to-unzip-a-file-without-additional-zip-tools

if not exist "%~1" (
    echo Error file doesn't exist: "%~1"
    exit /b -1
)

:: Clear the output directory
call :NORMALIZEPATH src "%~1"
call :NORMALIZEPATH dest "%~2"

if exist "%dest%" (
    powershell -Command "Remove-Item -LiteralPath '%dest%' -Force -Recurse" >nul 2>&1
)
mkdir "%dest%" 2>NUL

set "vbs=%temp%\_%random%%random%.vbs"
> "%vbs%"  echo set objShell = CreateObject("Shell.Application")
>>"%vbs%"  echo set FilesInZip=objShell.NameSpace("%src%").items
>>"%vbs%"  echo objShell.NameSpace("%dest%").CopyHere(FilesInZip)

cscript //nologo "%vbs%"
del "%vbs%" /f /q > nul 2>&1


 goto :EOF
:: ========== FUNCTIONS ==========

:NORMALIZEPATH <return> <path>
    SET "%~1=%~f2"
goto :EOF