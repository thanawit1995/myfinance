@echo off
chcp 65001 > nul
cd /d "%~dp0"
cls
echo ====================================================================
echo   เปิดแอป JP Money บนหน้าจอคอมพิวเตอร์ Windows ทันที
echo ====================================================================
echo.

if exist "build\windows\x64\runner\Release\myfinance.exe" (
    echo กำลังเปิดโปรแกรม JP Money...
    start "" "build\windows\x64\runner\Release\myfinance.exe"
    exit /b 0
)

echo กำลังประกอบโปรแกรมสำหรับ Windows ครั้งแรก กรุณารอสักครู่...
call flutter run -d windows
