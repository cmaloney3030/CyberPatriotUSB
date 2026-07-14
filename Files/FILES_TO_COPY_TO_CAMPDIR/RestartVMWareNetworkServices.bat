@echo off
:: Check for administrative privileges
net session >nul 2>&1
if %errorLevel% == 0 (
    goto :main
) else (
    echo Requesting administrative privileges...
    goto :UACPrompt
)

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:main
cls
echo ===================================================
echo       Restarting VMware Network Services
echo ===================================================
echo.

:: --- Stop Services ---
echo Stopping VMware NAT Service...
net stop "VMware NAT Service"
echo.

echo Stopping VMnetDHCP Service...
net stop "VMnetDHCP"
echo.

echo ---------------------------------------------------
:: Small pause to let services settle down
timeout /t 2 /nobreak >nul

:: --- Start Services ---
echo Starting VMnetDHCP Service...
net start "VMnetDHCP"
echo.

echo Starting VMware NAT Service...
net start "VMware NAT Service"
echo.

echo ===================================================
echo       Services restarted successfully!
echo ===================================================
echo.
pause