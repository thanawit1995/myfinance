@echo off
chcp 65001 > nul
cd /d "%~dp0"
cls
echo ====================================================================
echo   เครื่องมือสร้างไฟล์ติดตั้ง Android App (1-Click Android APK Builder)
echo ====================================================================
echo.
echo กำลังเริ่มประกอบร่างไฟล์ติดตั้ง Android APK...
echo (ขั้นตอนนี้อาจใช้เวลาประมาณ 1-2 นาที กรุณารอสักครู่)
echo.

call flutter build apk --release
if errorlevel 1 goto :BUILD_FAIL

:BUILD_SUCCESS
copy /y "%~dp0build\app\outputs\flutter-apk\app-release.apk" "%~dp0JP_Money.apk" > nul
echo.
echo ====================================================================
echo   [ สำเร็จสมบูรณ์! ] สร้างไฟล์ติดตั้ง Android APK เรียบร้อยแล้ว
echo ====================================================================
echo.
echo ตำแหน่งไฟล์ APK ที่พร้อมใช้งาน:
echo %~dp0JP_Money.apk
echo.
echo คุณสามารถส่งไฟล์ JP_Money.apk นี้ไปทาง LINE หรือ Google Drive
echo เพื่อนำไปติดตั้งบนมือถือ Android ของคุณได้ทันทีครับ
echo.
explorer.exe /select,"%~dp0JP_Money.apk"
goto :END

:BUILD_FAIL
echo.
echo [!] เกิดข้อผิดพลาดในการสร้างไฟล์ APK
echo.

:END
pause