# คู่มือการสร้างไฟล์ติดตั้งแอปพลิเคชัน (Build Guide) — ฉบับผู้เริ่มต้น

คู่มือนี้จัดทำขึ้นเป็นภาษาไทยอย่างละเอียด สำหรับผู้ที่ไม่เคยเขียนโค้ดและไม่เคยใช้ Terminal มาก่อน คุณสามารถทำตามทีละขั้นตอนได้ง่ายๆ ด้วยการ Copy & Paste คำสั่งที่ระบุไว้ครับ

---

## ทำความเข้าใจคำศัพท์เบื้องต้น (สั้นๆ 1 ประโยค)
- **Build (บิลด์):** คือกระบวนการรวมโค้ดและรูปภาพทั้งหมดให้กลายเป็นไฟล์โปรแกรมสำเร็จรูปที่นำไปติดตั้งใช้งานได้จริง (เช่นไฟล์ .apk บนมือถือ หรือ .exe บนคอมพิวเตอร์)
- **APK (.apk):** คือไฟล์ติดตั้งแอปสำหรับสมาร์ตโฟนและแท็บเล็ตระบบ Android
- **Windows Executable (.exe):** คือไฟล์ติดตั้งและเปิดใช้งานโปรแกรมสำหรับคอมพิวเตอร์ Windows 11
- **PowerShell:** คือหน้าต่างรับคำสั่งแบบพิมพ์ของ Windows (เปิดได้โดยกดปุ่ม Start แล้วพิมพ์ว่า PowerShell)

---

## ส่วนที่ 1: วิธีสร้างไฟล์ติดตั้งสำหรับมือถือ Android (.apk)

### ขั้นตอนที่ 1: เปิด PowerShell
1. กดปุ่ม **Windows (Start)** บนคีย์บอร์ด
2. พิมพ์คำว่า `PowerShell`
3. คลิกเปิด **Windows PowerShell**

### ขั้นตอนที่ 2: ไปยังโฟลเดอร์ของโปรเจกต์
คัดลอกคำสั่งด้านล่างนี้ แล้วคลิกขวาเพื่อวางใน PowerShell จากนั้นกดปุ่ม Enter:

```powershell
cd C:\Projects\myfinance
```

### ขั้นตอนที่ 3: สั่งสร้างไฟล์ APK
วางคำสั่งนี้แล้วกดปุ่ม Enter:

```powershell
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User"); flutter build apk --release
```

> **คำอธิบาย:** ระบบจะเริ่มรวมไฟล์ ใช้เวลาประมาณ 1-3 นาที เมื่อเสร็จสิ้นจะขึ้นข้อความ `Built build\app\outputs\flutter-apk\app-release.apk`

### ขั้นตอนที่ 4: ตำแหน่งไฟล์ที่ได้และวิธีนำไปลงมือถือ
ไฟล์ APK ที่สร้างเสร็จแล้วจะอยู่ที่:
`C:\Projects\myfinance\build\app\outputs\flutter-apk\app-release.apk`

**วิธีนำไปติดตั้งในมือถือ Android:**
1. ส่งไฟล์ `app-release.apk` เข้ามือถือ (ผ่านสาย USB, Google Drive, หรือแชทส่วนตัว)
2. กดเปิดไฟล์ `.apk` บนมือถือ
3. หากระบบถาม ให้เลือก **"อนุญาตการติดตั้งแอปจากแหล่งที่ไม่รู้จัก" (Allow from this source)**
4. กด **ติดตั้ง (Install)** ใช้งานได้ทันที!

---

## ส่วนที่ 2: วิธีสร้างโปรแกรมสำหรับ Windows 11 Desktop (.exe)

### ขั้นตอนที่ 1: สั่งสร้างโปรแกรม Windows
เปิด PowerShell แล้ววางคำสั่งนี้:

```powershell
cd C:\Projects\myfinance
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User"); flutter build windows --release
```

> **คำอธิบาย:** คำสั่งนี้จะสร้างไฟล์สำหรับรันบนคอมพิวเตอร์ Windows 11 โดยตรง มีความเร็วสูงและไม่ต้องใช้โปรแกรมจำลอง

### ขั้นตอนที่ 2: ตำแหน่งโปรแกรมที่ได้
โฟลเดอร์โปรแกรมที่พร้อมใช้งานจะอยู่ที่:
`C:\Projects\myfinance\build\windows\x64\runner\Release`

**วิธีเปิดใช้งานบนคอมพิวเตอร์:**
1. เข้าไปที่โฟลเดอร์ด้านบน
2. ดับเบิลคลิกไฟล์ `myfinance.exe` เพื่อเปิดใช้งานแอปได้ทันที
3. คุณสามารถคลิกขวาที่ `myfinance.exe` แล้วเลือก **Show more options > Create shortcut** เพื่อส่งทางลัดมาไว้ที่หน้าจอ Desktop ได้เลยครับ

---

## ส่วนที่ 3: วิธีอัปเดตหรือตรวจสอบโค้ดก่อน Build (สำหรับทดสอบ)

หากต้องการทดสอบความถูกต้องของระบบทั้งหมดก่อนทำการ Build ให้รันคำสั่งเหล่านี้ทีละบรรทัด:

1. **ตรวจสอบความเรียบร้อยของโค้ด (ต้องได้ 0 issues):**
```powershell
cd C:\Projects\myfinance
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User"); flutter analyze
```

2. **ทดสอบระบบคำนวณและฐานข้อมูลอัตโนมัติ (Automated Tests):**
```powershell
cd C:\Projects\myfinance
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User"); flutter test
```
