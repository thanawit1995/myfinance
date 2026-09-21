[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

Set-Location $PSScriptRoot
Clear-Host

Write-Host "====================================================================" -ForegroundColor Cyan
Write-Host "   ระบบส่งโปรเจกต์ขึ้น GitHub Pages (1-Click GitHub Deploy)" -ForegroundColor Green
Write-Host "====================================================================" -ForegroundColor Cyan
Write-Host ""

try {
    # 1. Check Git
    $gitCheck = Get-Command git -ErrorAction SilentlyContinue
    if (-not $gitCheck) {
        Write-Host "[!] ไม่พบโปรแกรม Git ในเครื่อง กรุณาติดตั้ง Git ก่อนดำเนินการ" -ForegroundColor Red
        return
    }

    # 2. Check Repository
    if (-not (Test-Path ".git")) {
        Write-Host "[*] กำลังเริ่มต้นสร้าง Git Repository ในเครื่อง..." -ForegroundColor Yellow
        git init
        git branch -M main
    }

    # Ensure git config has name & email so commit won't fail
    $userName = git config user.name
    if (-not $userName) {
        git config user.name "JP Money User"
        git config user.email "user@jpmoney.local"
    }

    # 3. Add and commit files
    Write-Host "[*] กำลังบันทึกไฟล์โปรเจกต์ทั้งหมดเข้า Git..." -ForegroundColor Yellow
    git add .
    git commit -m "Update JP Money with Hybrid Backup and PWA Web App" 2>$null

    # 4. Check remote URL
    $remoteUrl = git remote get-url origin 2>$null
    if (-not $remoteUrl) {
        Write-Host ""
        Write-Host "--------------------------------------------------------------------" -ForegroundColor Gray
        Write-Host "กรุณาวางลิงก์ GitHub Repository ของคุณ (จากหน้าเว็บ GitHub ที่คุณเพิ่งสร้าง)" -ForegroundColor White
        Write-Host "ตัวอย่าง: https://github.com/your-username/myfinance.git" -ForegroundColor DarkGray
        Write-Host "--------------------------------------------------------------------" -ForegroundColor Gray
        $inputUrl = Read-Host "คลิกขวาเพื่อวาง URL ที่นี่ แล้วกด Enter"
        if ([string]::IsNullOrWhiteSpace($inputUrl)) {
            Write-Host "[!] คุณไม่ได้ระบุ URL ยกเลิกการทำงาน" -ForegroundColor Red
            return
        }
        git remote add origin $inputUrl.Trim()
        $remoteUrl = $inputUrl.Trim()
    }

    Write-Host ""
    Write-Host "[*] กำลังส่งไฟล์ขึ้น GitHub ไปยัง: $remoteUrl ..." -ForegroundColor Yellow
    git push -u origin main

    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "====================================================================" -ForegroundColor Green
        Write-Host "   [ สำเร็จสมบูรณ์! ] ข้อมูลถูกส่งขึ้น GitHub เรียบร้อยแล้ว" -ForegroundColor Green
        Write-Host "====================================================================" -ForegroundColor Green
        Write-Host ""
        Write-Host "ขั้นตอนต่อไป (เปิดใช้เว็บแอป - ทำครั้งเดียวบนเว็บ GitHub):" -ForegroundColor Cyan
        Write-Host "1. เปิดหน้า Repository ของคุณบนเว็บ GitHub"
        Write-Host "2. ไปที่แท็บ Settings (รูปฟันเฟืองด้านบน) -> เมนูด้านซ้ายเลือก Pages"
        Write-Host "3. ใต้หัวข้อ 'Build and deployment' -> ตรงช่อง Source ให้เลือกเป็น:"
        Write-Host "   'GitHub Actions'" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "ระบบ GitHub จะทำการประกอบเว็บแอปและให้ลิงก์สาธารณะใช้งานได้ตลอด 24 ชม.!" -ForegroundColor Green
        Write-Host ""
    } else {
        Write-Host ""
        Write-Host "[!] เกิดข้อผิดพลาดในการ push ขึ้น GitHub" -ForegroundColor Red
        Write-Host "สาเหตุที่เป็นไปได้:" -ForegroundColor Yellow
        Write-Host "1. ยังไม่ได้ล็อกอินสิทธิ์ GitHub ในเครื่อง (หากมีหน้าต่างเบราว์เซอร์เด้งขึ้นมา ให้กด Sign In)"
        Write-Host "2. พิมพ์ URL Repository ผิด หรือยังไม่ได้สร้าง Repository ชื่อนี้บน GitHub"
        Write-Host ""
    }
}
catch {
    Write-Host ""
    Write-Host "[!] เกิดข้อผิดพลาด: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
}
finally {
    Write-Host ""
    Read-Host "กดปุ่ม Enter เพื่อปิดหน้าต่างนี้..."
}