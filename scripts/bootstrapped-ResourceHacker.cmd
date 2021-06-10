:: **********************************************************
:: Forcefully download rhack Bash to vendor/rhack and run the command 
:: under the newly aquired sh.exe
:: **********************************************************

@echo off
SETLOCAL EnableDelayedExpansion

set "rhackpath=%~dp0..\vendor\ResourceHacker"
set "rhackexename=reshacker_setup.zip"
set "rhacktmp=%~dp0..\vendor\%rhackexename%"
mkdir "%~dp0..\vendor" 2>NUL

if exist "%rhacktmp%" (
    del "%rhacktmp%" 2>nul
)

if exist "%rhacktmp%_tmp" (
    del "%rhacktmp%_tmp" 2>nul
)

:: Can we immediately use sh?
if exist "%rhackpath%\ResourceHacker.exe" (
    call "%rhackpath%\ResourceHacker.exe" %*
    exit /b !errorlevel!
)


echo () Resource hacker not installed, bootstrapping from Internet

:: Download method
set downloadmethod=webclient
call powershell -Command "gcm Invoke-WebRequest" >nul 2>&1
if "%errorlevel%" EQU "0" set downloadmethod=webrequest


:: Try downloading rhack ten times
set "downloadurl=http://www.angusj.com/resourcehacker/resource_hacker.zip"
echo () Download link: %downloadurl%
for /L %%a in (1,1,1,1,1,1,1,1,1,1) do (
    if not exist "%rhacktmp%_tmp" (
        if "%downloadmethod%" equ "webclient" (
            call powershell -Command "(New-Object Net.WebClient).DownloadFile('%downloadurl%', '%rhacktmp%_tmp')"
        ) else (
            call powershell -Command "Invoke-WebRequest '%downloadurl%' -OutFile '%rhacktmp%_tmp'"
        )
    )
    if not exist "%rhacktmp%_tmp" (
        REM wait one seconds
        ping 127.0.0.1 -n 2 > nul
    )
)

ren "%rhacktmp%_tmp" "%rhackexename%" 2>nul

call "%~dp0\windows-extract.cmd" "%rhacktmp%" "%rhackpath%"

if exist "%rhacktmp%_tmp" (
    del "%rhacktmp%_tmp" 2>nul
)

if exist "%rhacktmp%" (
    del "%rhacktmp%" 2>nul
)

call "%rhackpath%\ResourceHacker.exe" %*
exit /b %errorlevel%


