@echo off
chcp 65001 > nul
echo ========================================================
echo   กำลังเปิดเซิร์ฟเวอร์สำหรับใช้งาน Lumi Web App (PWA)
echo ========================================================
echo.
echo กรุณารอสักครู่ กำลังเปิดเบราว์เซอร์ที่ http://localhost:8080 ...
echo (หากต้องการปิดเซิร์ฟเวอร์ ให้กดปิดหน้าต่างดำนี้ได้เลย)
echo.

start http://localhost:8080
"%LOCALAPPDATA%\Pub\Cache\bin\dhttpd.bat" --path build\web --port 8080
pause
