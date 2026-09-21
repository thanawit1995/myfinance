@echo off
chcp 65001 > nul
title MyFinance VAULT
cd /d C:\Projects\myfinance
echo ===================================================
echo   กำลังเปิดระบบการเงินส่วนบุคคล VAULT...
echo   กรุณารอสักครู่ หน้าต่างโปรแกรมจะเปิดขึ้นมาอัตโนมัติ
echo ===================================================
flutter run -d windows
pause
