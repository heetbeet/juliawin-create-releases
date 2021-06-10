:: **********************************************************
:: Forcefully download rcedit Bash to vendor/rcedit and run the command 
:: under the newly aquired sh.exe
:: **********************************************************

@echo off
SETLOCAL EnableDelayedExpansion

set "rceditpath=%~dp0..\vendor\rcedit"
set "rceditexename=rcedit_setup.exe"
set "rcedittmp=%~dp0..\vendor\%rceditexename%"
mkdir "%~dp0..\vendor" 2>NUL

if exist "%rcedittmp%" (
    del "%rcedittmp%" 2>nul
)

if exist "%rcedittmp%_tmp" (
    del "%rcedittmp%_tmp" 2>nul
)

:: Can we immediately use sh?
if exist "%rceditpath%\rcedit.exe" (
    call "%rceditpath%\rcedit.exe" %*
    exit /b !errorlevel!
)


echo () rcedit not installed, bootstrapping from Internet

:: Download method
set downloadmethod=webclient
call powershell -Command "gcm Invoke-WebRequest" >nul 2>&1
if "%errorlevel%" EQU "0" set downloadmethod=webrequest


:: Try downloading rcedit ten times
set "downloadurl=https://github.com/electron/rcedit/releases/download/v1.1.1/rcedit-x64.exe"
echo () Download link: %downloadurl%
for /L %%a in (1,1,1,1,1,1,1,1,1,1) do (
    if not exist "%rcedittmp%_tmp" (
        if "%downloadmethod%" equ "webclient" (
            call powershell -Command "(New-Object Net.WebClient).DownloadFile('%downloadurl%', '%rcedittmp%_tmp')"
        ) else (
            call powershell -Command "Invoke-WebRequest '%downloadurl%' -OutFile '%rcedittmp%_tmp'"
        )
    )
    if not exist "%rcedittmp%_tmp" (
        REM wait one seconds
        ping 127.0.0.1 -n 2 > nul
    )
)

mkdir "%rceditpath%" 2>NUL
move "%rcedittmp%_tmp" "%rceditpath%\rcedit.exe"  2>NUL


if exist "%rcedittmp%_tmp" (
    del "%rcedittmp%_tmp" 2>nul
)

if exist "%rcedittmp%" (
    del "%rcedittmp%" 2>nul
)

call "%rceditpath%\rcedit.exe" %*
exit /b %errorlevel%


