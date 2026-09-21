@echo off
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0upload_github.ps1"
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [Error] Script execution failed.
    pause
)
