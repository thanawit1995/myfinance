@echo off
chcp 65001 > nul
echo ====================================================================
echo   เครื่องมือสร้างไฟล์ติดตั้ง Android App (1-Click Android APK Builder)
echo ====================================================================
echo.
echo กำลังเริ่มประกอบร่างไฟล์ติดตั้ง Android (.apk)...
echo (ขั้นตอนนี้อาจใช้เวลาประมาณ 1-2 นาที กรุณารอสักครู่)
echo.

call flutter build apk --release

if %errorlevel% equ 0 (
    echo.
    echo ====================================================================
    echo   [ สำเร็จสมบูรณ์! ] สร้างไฟล์ติดตั้ง Android APK เรียบร้อยแล้ว
    echo ====================================================================
    echo.
    echo ตำแหน่งไฟล์ APK ที่พร้อมใช้งาน:
    echo build\app\outputs\flutter-apk\app-release.apk
    echo.
    echo คุณสามารถคัดลอกไฟล์ app-release.apk นี้ไปส่งทาง LINE, Google Drive
    echo หรือนำไปติดตั้งบนมือถือ Android ของคุณและเพื่อนๆ ได้ทันที!
    echo (พร้อมใช้งานทั้งระบบบันทึกรายรับ-รายจ่าย และ Home Screen Widgets)
    echo.
    explorer.exe "build\app\outputs\flutter-apk"
) else (
    echo.
    echo [!] เกิดข้อผิดพลาดในการสร้างไฟล์ APK
)

pause
