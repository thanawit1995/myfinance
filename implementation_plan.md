# แผนการพัฒนาแอป MyFinance (Implementation Plan) — Phase 0 (v2)

แผนงานนี้จัดทำขึ้นโดยยึดตามข้อกำหนดใน [AGENTS.md](file:///c:/Projects/myfinance/AGENTS.md.md) และเป้าหมายของแอป **MyFinance** เพื่อสร้างระบบการเงินส่วนตัวแบบ Local-First บน Windows Desktop และ Android

> **v2**: อัปเดตจากฉบับแรกหลังยืนยันคำถามเปิด 5 ข้อ, ทบทวนความเสี่ยง 7 ข้อ, และเพิ่มฟีเจอร์ backup/encryption ตามที่คุยกัน รายละเอียดการเปลี่ยนแปลงทั้งหมดอยู่ใน **หัวข้อ 6 (Decision Log)**

---

## 1. ภาพรวมสถาปัตยกรรมและเทคโนโลยี (Tech Stack)

| ส่วนประกอบ | เทคโนโลยีที่เลือกใช้ | เหตุผลและความจำเป็น |
| :--- | :--- | :--- |
| **Framework** | Flutter 3.x / Dart 3.x | รองรับทั้ง Windows Desktop และ Android (Phone/Tablet) จากโค้ดชุดเดียว |
| **Database** | SQLite + `drift` | ฐานข้อมูลแบบ SQL เก็บข้อมูลในเครื่อง ปลอดภัย ทำงานออฟไลน์ได้ รวดเร็ว และรองรับ Migration อย่างแม่นยำ |
| **State Management** | `flutter_riverpod` | จัดการสถานะและข้อมูลของแอปให้ลื่นไหล แยก Logic ออกจาก UI ทดสอบง่าย |
| **Routing** | `go_router` | ระบบสลับหน้าจอที่รองรับการตรวจจับ PIN/Fingerprint Lock ก่อนเข้าหน้ารายงาน/ข้อมูล |
| **Data Types (เงิน)** | Custom `Money` (int สตางค์) | ป้องกันปัญหาเศษทศนิยมคลาดเคลื่อนตามกฎเรื่องเงินอย่างเด็ดขาด |
| **Data Types (สินทรัพย์/FX)** | `decimal` | คำนวณจำนวนหน่วยลงทุน (8 ตำแหน่ง) และเรต FX (6 ตำแหน่ง) ได้อย่างแม่นยำสูง |
| **Local Security** | `flutter_secure_storage` | เก็บ Master PIN, Fingerprint preference, Encryption key แบบเข้ารหัสในระบบ OS Keystore |
| **Biometric** | `local_auth` | รองรับสแกนลายนิ้วมือบน Android ควบคู่กับ PIN |
| **Backup** | `google_sign_in` + `googleapis` (Drive API v3, scope `drive.file`) | สำรอง/กู้คืนไฟล์ฐานข้อมูลขึ้น Google Drive ของผู้ใช้เอง แบบสั่งเองเท่านั้น (manual trigger) |
| **Encryption** | `cryptography` (AES-256) | เข้ารหัสไฟล์ backup ก่อนอัปโหลดขึ้น Google Drive |
| **Export & Share** | `excel`, `pdf`, `printing`, `share_plus` | ส่งออกรายงานเป็น Excel/PDF และเปิด share sheet ให้เลือกปลายทางเอง |
| **Language & Fonts** | `flutter_localizations` + Noto Sans Thai | รองรับไทย/อังกฤษแบบมาตรฐานสากล แสดงผลภาษาไทยสวยงามทั้ง 2 แพลตฟอร์ม |

**หมายเหตุเรื่อง Offline**: แอปทำงานแบบ **Offline-first** — ใช้งานหลักทั้งหมด (บันทึกรายการ, ดูรายงาน, คำนวณภาษี ฯลฯ) ไม่ต้องต่ออินเทอร์เน็ต ต้องต่อเน็ตเฉพาะตอนผู้ใช้ **สั่งสำรอง/กู้คืนข้อมูลขึ้น-ลง Google Drive เองเท่านั้น** (ไม่มี background sync อัตโนมัติ)

---

## 2. โครงสร้างฐานข้อมูล (Database Schema) สำหรับทุก Phase

ทุกตารางถูกออกแบบให้รองรับกฎเหล็ก:
- Primary Key ใช้ **UUID v4 (String)**
- มีคอลัมน์มาตรฐาน: `created_at`, `updated_at`, `deleted_at` (Soft Delete)
- **ไม่มีการแยกตารางตามเดือน/ปีเด็ดขาด** (สรุปข้อมูลผ่าน SQL Query / View)
- ตารางธุรกรรมเป็นแบบ **Append-only ledger** ร่วมกับระบบบันทึกประวัติ `audit_logs`
- **Index บังคับ** (ดูหัวข้อ 2.1) เพื่อรองรับ query รายงาน/กราฟเมื่อข้อมูลโตขึ้น

> **เปลี่ยนจาก v1**: ตัดคอลัมน์ `sync_version` ออกจากทุกตาราง เพราะกลไก backup ที่ยืนยันไว้คือ "สำรอง/กู้คืนทั้งไฟล์ฐานข้อมูล" ไม่ใช่ sync ระดับแถวข้ามอุปกรณ์ จึงไม่มี logic ใดใช้คอลัมน์นี้จริง (ถ้าอนาคตต้องการ sync แบบ real-time ข้ามเครื่องพร้อมกัน ค่อยเพิ่มกลับเข้ามา)

### รายการตารางทั้งหมด (17 ตาราง)

#### (1) กลุ่มระบบบัญชีและการเงินพื้นฐาน

1. **`currencies`** (ข้อมูลสกุลเงิน)
   - `code` (TEXT, PK): รหัสสกุลเงิน เช่น `THB`, `USD`
   - `name` (TEXT): ชื่อสกุลเงิน
   - `symbol` (TEXT): สัญลักษณ์ เช่น `฿`, `$`
   - `is_base` (BOOLEAN): เป็นสกุลเงินหลักของระบบหรือไม่ (THB = true)
   - คอลัมน์มาตรฐาน: `created_at`, `updated_at`, `deleted_at`

2. **`fx_rates`** (บันทึกอัตราแลกเปลี่ยนที่ผู้ใช้กรอก)
   - `id` (TEXT, PK): UUID
   - `base_currency` (TEXT): สกุลเงินต้นทาง เช่น `USD`
   - `target_currency` (TEXT): สกุลเงินปลายทาง เช่น `THB`
   - `rate` (TEXT): อัตราแลกเปลี่ยนในรูปแบบ Decimal String ความละเอียด 6 ตำแหน่ง
   - `effective_date` (TEXT ISO8601): วันที่มีผลของอัตราแลกเปลี่ยน
   - `note` (TEXT, Nullable): บันทึกช่วยจำ
   - คอลัมน์มาตรฐาน: `created_at`, `updated_at`, `deleted_at`

3. **`accounts`** (บัญชีการเงินทั้ง 6 บัญชีและบัญชีในอนาคต)
   - `id` (TEXT, PK): UUID
   - `name` (TEXT): ชื่อบัญชี (เช่น `SCB`, `Krungthai`, `Dime! Save`, `Dime! FCD`, `Dime! USD`, `บัตรเครดิต`)
   - `account_type` (TEXT): ประเภท (`bank`, `fcd`, `offshore`, `credit_card`, `cash`)
   - `currency_code` (TEXT): สกุลเงินของบัญชี (`THB` หรือ `USD`)
   - `is_domestic` (BOOLEAN): ในประเทศ (true) หรือต่างประเทศ (false)
   - `closing_day` (INTEGER, Nullable): วันสรุปยอดรอบบิล (สำหรับบัตรเครดิต = 23 เสมอ ไม่เลื่อนตามวันหยุด)
   - `due_day` (INTEGER, Nullable): วันครบกำหนดชำระ (ตั้งค่าเองได้)
   - `credit_limit_satang` (INTEGER, Nullable): วงเงินบัตรเครดิต (หน่วยสตางค์)
   - `is_active` (BOOLEAN): เปิดใช้งานอยู่หรือไม่ — **บัญชีที่ปิดใช้งาน (false) จะไม่ปรากฏในตัวเลือกตอนสร้างธุรกรรมใหม่ แต่ธุรกรรมเดิมและรายงานเดิมยังคงแสดงผลตามปกติ** (ดู FK-delete policy หัวข้อ 2.2)
   - คอลัมน์มาตรฐาน: `created_at`, `updated_at`, `deleted_at`

4. **`categories`** (หมวดหมู่รายรับ-รายจ่าย)
   - `id` (TEXT, PK): UUID
   - `name_th` (TEXT): ชื่อหมวดหมู่ภาษาไทย
   - `name_en` (TEXT): ชื่อหมวดหมู่ภาษาอังกฤษ
   - `category_type` (TEXT): ประเภท (`income`, `expense`, `transfer`)
   - `parent_id` (TEXT, Nullable): UUID หมวดหมู่หลัก (รองรับหมวดหมู่ย่อย)
   - `tax_income_type` (TEXT, Nullable): มาตราเงินได้สำหรับยื่นภาษี (`40_1`, `40_2`, `40_4`, `40_8`, null)
   - `icon` (TEXT, Nullable): รหัสไอคอน
   - `color` (TEXT, Nullable): รหัสสี
   - `is_system` (BOOLEAN): หมวดมาตรฐานระบบ (ลบไม่ได้)
   - `is_active` (BOOLEAN): เปิดใช้งานอยู่หรือไม่ (เช่นเดียวกับ `accounts.is_active`)
   - คอลัมน์มาตรฐาน: `created_at`, `updated_at`, `deleted_at`

5. **`transactions`** (สมุดบัญชีแยกประเภท Append-only)
   - `id` (TEXT, PK): UUID
   - `transaction_type` (TEXT): ประเภท (`income`, `expense`, `transfer`, **`invest_buy`, `invest_sell`**)
   - `source_account_id` (TEXT, FK): บัญชีต้นทาง (หรือบัญชีที่จ่าย)
   - `destination_account_id` (TEXT, FK, Nullable): บัญชีปลายทาง (กรณีโอนเงิน/ขายสินทรัพย์คืนเข้าบัญชี — เป็น null เมื่อ `transaction_type = invest_buy` เพราะเงินไม่เข้าบัญชีใด แต่กลายเป็นสินทรัพย์แทน)
   - `category_id` (TEXT, FK, Nullable): หมวดหมู่รายรับ/รายจ่าย
   - **`asset_id` (TEXT, FK, Nullable): สินทรัพย์ที่เกี่ยวข้อง — ใช้เฉพาะเมื่อ `transaction_type` เป็น `invest_buy` หรือ `invest_sell` เท่านั้น เป็น null สำหรับธุรกรรมประเภทอื่น**
   - `amount_original_satang` (INTEGER): ยอดเงินตามสกุลเงินที่ทำรายการ (หน่วยสตางค์ หรือ cent)
   - `currency_code` (TEXT): สกุลเงินของรายการ (`THB`, `USD`)
   - `fx_rate` (TEXT): อัตราแลกเปลี่ยน Decimal String (ถ้าเป็น THB = 1.0)
   - `amount_thb_satang` (INTEGER): ยอดเงินแปลงเป็น THB สตางค์ (ล็อกไว้ ณ วันทำรายการ)
   - `transaction_date` (TEXT ISO8601): วันและเวลาที่ทำรายการ
   - `note` (TEXT, Nullable): รายละเอียดเพิ่มเติม
   - `is_cleared` (BOOLEAN): เคลียร์ยอดแล้วหรือไม่ (สำหรับกระทบยอดบัตรเครดิต)
   - คอลัมน์มาตรฐาน: `created_at`, `updated_at`, `deleted_at`

   > **Flow การซื้อหุ้นด้วยเงินบาท (ยืนยันแล้ว)**: บังคับแปลงผ่าน Dime! USD ก่อนเสมอ เพื่อความไม่ยุ่งยาก แบ่งเป็น **2 transactions ต่อเนื่องกัน**:
   > 1. `transfer`: source = Dime! Save (THB) → destination = Dime! USD, พร้อม fx_rate
   > 2. `invest_buy`: source = Dime! USD, destination = null, asset_id = หุ้นที่ซื้อ, เชื่อมกับ `investment_lots.buy_transaction_id`
   >
   > ตอนขายหุ้น เงินกลับเข้า Dime! USD เสมอ → `invest_sell`: source = null (ไม่มีบัญชีต้นทาง เพราะขายสินทรัพย์ ไม่ใช่โอนเงิน), destination = Dime! USD, asset_id = หุ้นที่ขาย, เชื่อมกับ `investment_sales.sell_transaction_id`

6. **`audit_logs`** (ประวัติการแก้ไขและลบธุรกรรม)
   - `id` (TEXT, PK): UUID
   - `entity_table` (TEXT): ชื่อตารางที่มีการเปลี่ยนแปลง (เช่น `transactions`)
   - `entity_id` (TEXT): UUID ของแถวที่มีการเปลี่ยนแปลง
   - `action` (TEXT): การกระทำ (`CREATE`, `UPDATE`, `DELETE`)
   - `before_data_json` (TEXT, Nullable): ข้อมูลก่อนแก้ในรูป JSON
   - `after_data_json` (TEXT, Nullable): ข้อมูลหลังแก้ในรูป JSON
   - `change_timestamp` (TEXT ISO8601): เวลาที่เกิดการแก้ไข
   - คอลัมน์มาตรฐาน: `created_at`, `updated_at`, `deleted_at`

7. **`credit_card_installments`** (โครงสร้างเผื่อผ่อนชำระ)
   - `id` (TEXT, PK): UUID
   - `transaction_id` (TEXT, FK): รายการธุรกรรมตั้งต้น
   - `account_id` (TEXT, FK): บัญชีบัตรเครดิต
   - `total_amount_satang` (INTEGER): ยอดเต็ม
   - `monthly_amount_satang` (INTEGER): ยอดผ่อนต่อเดือน
   - `total_tenor_months` (INTEGER): จำนวนงวดทั้งหมด
   - `remaining_tenor_months` (INTEGER): จำนวนงวดที่เหลือ
   - `start_date` (TEXT ISO8601): วันเริ่มผ่อน
   - คอลัมน์มาตรฐาน: `created_at`, `updated_at`, `deleted_at`
   - *(ไม่มีฟิลด์ดอกเบี้ย/ค่าธรรมเนียมผ่อน — ยืนยันแล้วว่าไม่ใช้บัตรแบบมีดอกเบี้ยผ่อน ถ้าในอนาคตมี ค่อยเพิ่มคอลัมน์ nullable ทีหลังได้โดยไม่กระทบข้อมูลเดิม)*

---

#### (2) กลุ่มการลงทุนและพอร์ตโฟลิโอ (Investment & Lots FIFO)

8. **`assets`** (สินทรัพย์ลงทุน)
   - `id` (TEXT, PK): UUID
   - `symbol` (TEXT): ชื่อย่อสินทรัพย์ (เช่น `PTT`, `VOO`, `BTC`)
   - `name` (TEXT): ชื่อเต็มสินทรัพย์
   - `asset_type` (TEXT): ประเภท (`thai_stock`, `foreign_stock`, `etf`, `mutual_fund`, `crypto`, `gold`, `bond`)
   - `currency_code` (TEXT): สกุลเงินที่ซื้อขาย
   - `default_account_id` (TEXT, FK): บัญชีที่ถือครองสินทรัพย์นี้ (เช่น `Dime! USD`)
   - คอลัมน์มาตรฐาน: `created_at`, `updated_at`, `deleted_at`

9. **`investment_lots`** (การบันทึกต้นทุนแบบ Lot เพื่อตัด FIFO ตรวจสอบย้อนหลังได้)
   - `id` (TEXT, PK): UUID
   - `asset_id` (TEXT, FK): รหัสสินทรัพย์
   - `buy_transaction_id` (TEXT, FK): อ้างอิงธุรกรรมการซื้อ (`invest_buy`)
   - `buy_date` (TEXT ISO8601): วันที่ซื้อ
   - `quantity` (TEXT): จำนวนหน่วยที่ซื้อ Decimal String 8 ตำแหน่ง
   - `remaining_quantity` (TEXT): จำนวนหน่วยที่ยังเหลืออยู่ Decimal String 8 ตำแหน่ง
   - `cost_per_unit_original_satang` (INTEGER): ราคาต่อหน่วยเดิม (cent หรือ สตางค์)
   - `fx_rate` (TEXT): เรต FX วันที่ซื้อ (Decimal 6 ตำแหน่ง)
   - `cost_per_unit_thb_satang` (INTEGER): ราคาต้นทุนต่อหน่วยเป็น THB สตางค์
   - `fee_thb_satang` (INTEGER): ค่าธรรมเนียมซื้อเป็น THB สตางค์
   - `status` (TEXT): สถานะ Lot (`open`, `partially_closed`, `closed`)
   - คอลัมน์มาตรฐาน: `created_at`, `updated_at`, `deleted_at`

10. **`investment_sales`** (บันทึกประวัติการขายที่จับคู่ตัดออกจาก Lot)
    - `id` (TEXT, PK): UUID
    - `sell_transaction_id` (TEXT, FK): อ้างอิงธุรกรรมการขาย (`invest_sell`)
    - `lot_id` (TEXT, FK): Lot ที่ถูกตัดขายออกไป (ตาม FIFO)
    - `sell_date` (TEXT ISO8601): วันที่ขาย
    - `quantity_sold` (TEXT): จำนวนหน่วยที่ขายจาก Lot นี้ (Decimal 8 ตำแหน่ง)
    - `sell_price_thb_satang` (INTEGER): ราคาขายต่อหน่วยเป็น THB สตางค์
    - `cost_thb_satang` (INTEGER): ต้นทุนรวมของส่วนที่ตัดขาย
    - `realized_gain_loss_thb_satang` (INTEGER): กำไร/ขาดทุนที่เกิดขึ้นจริง (หน่วยสตางค์)
    - `fee_thb_satang` (INTEGER): ค่าธรรมเนียมการขาย
    - คอลัมน์มาตรฐาน: `created_at`, `updated_at`, `deleted_at`

11. **`asset_prices`** (ราคาตลาดที่ผู้ใช้บันทึกมือเดือนละครั้ง Mark-to-Market)
    - `id` (TEXT, PK): UUID
    - `asset_id` (TEXT, FK): รหัสสินทรัพย์
    - `price_date` (TEXT ISO8601): วันที่บันทึกราคา
    - `market_price_original_satang` (INTEGER): ราคาตลาดต่อหน่วยสกุลเดิม
    - `fx_rate` (TEXT): อัตราแลกเปลี่ยน ณ วันนั้น
    - `market_price_thb_satang` (INTEGER): ราคาตลาดต่อหน่วยเป็น THB สตางค์
    - คอลัมน์มาตรฐาน: `created_at`, `updated_at`, `deleted_at`

---

#### (3) กลุ่มงบประมาณ, การพยากรณ์ และรายการอัตโนมัติ

12. **`budgets`** (เพดานงบประมาณรายจ่าย)
    - `id` (TEXT, PK): UUID
    - `category_id` (TEXT, FK): หมวดหมู่ค่าใช้จ่าย
    - `limit_satang` (INTEGER): ยอดเงินสูงสุดต่อเดือน (หน่วยสตางค์)
    - `is_active` (BOOLEAN): เปิดใช้งานหรือไม่ (ไม่ Rollover ขึ้นเดือนใหม่นับใหม่)
    - คอลัมน์มาตรฐาน: `created_at`, `updated_at`, `deleted_at`

13. **`recurring_rules`** (กฎบันทึกรายการอัตโนมัติ)
    - `id` (TEXT, PK): UUID
    - `title` (TEXT): ชื่อรายการ เช่น "เงินเดือน", "Netflix"
    - `transaction_type` (TEXT): ประเภทรายการ
    - `source_account_id` (TEXT, FK): บัญชีต้นทาง
    - `destination_account_id` (TEXT, FK, Nullable): บัญชีปลายทาง
    - `category_id` (TEXT, FK, Nullable): หมวดหมู่
    - `amount_satang` (INTEGER): จำนวนเงิน (สตางค์)
    - `currency_code` (TEXT): สกุลเงิน
    - `frequency` (TEXT): ความถี่ (`daily`, `weekly`, `monthly`, `yearly`)
    - `day_of_month` (INTEGER, Nullable): วันที่ทำรายการ (1-31)
    - `next_run_date` (TEXT ISO8601): กำหนดการรันรอบถัดไป
    - **`end_date` (TEXT ISO8601, Nullable): วันที่หยุดสร้างรายการอัตโนมัติ — NULL = ทำซ้ำตลอดไป, มีค่า = หยุดหลังวันที่นี้**
    - `is_active` (BOOLEAN): เปิดใช้งานอยู่หรือไม่
    - คอลัมน์มาตรฐาน: `created_at`, `updated_at`, `deleted_at`
    - *ตอนสร้างรายการใน UI: ให้เลือก "ตลอดไป" (บันทึก `end_date = null`) หรือ "จนถึงวันที่" (เปิด date picker)*

---

#### (4) กลุ่มภาษีและการนำเข้าเงินได้ต่างประเทศ

14. **`tax_deductions`** (รายการลดหย่อนภาษีส่วนบุคคล)
    - `id` (TEXT, PK): UUID
    - `tax_year` (INTEGER): ปีภาษี ค.ศ. (เช่น 2026)
    - `deduction_group` (TEXT): กลุ่มลดหย่อน (`personal`, `insurance`, `fund`, `property`, `donation`)
    - `deduction_type` (TEXT): ประเภท (`self`, `provident_fund`, `rmf`, `ssf`, `thaiesg`, `life_insurance`, `health_insurance`, `home_loan_interest`, `donation_general`, `donation_education`)
    - `amount_satang` (INTEGER): จำนวนเงินลดหย่อน (สตางค์)
    - `transaction_id` (TEXT, FK, Nullable): เชื่อมโยงกับธุรกรรมที่จ่ายจริง
    - `note` (TEXT, Nullable): รายละเอียดหลักฐาน
    - คอลัมน์มาตรฐาน: `created_at`, `updated_at`, `deleted_at`

15. **`foreign_remittances`** (ติดตามเงินได้ต่างประเทศที่นำเข้าไทย)
    - `id` (TEXT, PK): UUID
    - `remittance_transaction_id` (TEXT, FK): อ้างอิงธุรกรรมโอนเงินเข้าไทย
    - `source_account_id` (TEXT, FK): บัญชีต่างประเทศต้นทาง
    - `tax_year_earned` (INTEGER, Nullable): ปีภาษีที่เกิดเงินได้ในต่างประเทศ (ค.ศ.) — **เก็บไว้เป็น metadata อ้างอิงส่วนตัวเท่านั้น ไม่ถูกใช้ในการคำนวณภาษีใด ๆ** (ภาษีอ้างอิงจาก `remittance_date` เพียงอย่างเดียว เพราะเข้าเกณฑ์ต้องเสียภาษีก็ต่อเมื่อนำเงินกลับเข้าบัญชีในไทยเท่านั้น)
    - `remittance_date` (TEXT ISO8601): วันที่นำเงินเข้ามาในไทย — **ใช้ฟิลด์นี้ในการกำหนดปีภาษีที่ต้องยื่น**
    - `amount_original_satang` (INTEGER): จำนวนเงินสกุลต่างประเทศ
    - `currency_code` (TEXT): สกุลเงินต่างประเทศ
    - `fx_rate` (TEXT): เรต FX ณ วันนำเข้า
    - `amount_thb_satang` (INTEGER): ยอดเงินบาทที่ได้รับ
    - `is_taxable` (BOOLEAN): เข้าข่ายต้องยื่นภาษีเงินได้บุคคลธรรมดาหรือไม่
    - `note` (TEXT, Nullable): รายละเอียด
    - คอลัมน์มาตรฐาน: `created_at`, `updated_at`, `deleted_at`

---

#### (5) กลุ่มสุขภาพการเงินและการตั้งค่าระบบ

16. **`financial_health_settings`** (การตั้งค่าเกณฑ์ตัวชี้วัดสุขภาพการเงิน 8 ตัว)
    - `id` (TEXT, PK): UUID
    - `metric_code` (TEXT, UNIQUE): รหัสตัวชี้วัด (`liquidity`, `emergency_fund`, `debt_burden`, `debt_service`, `solvency`, `health_coverage`, `savings_rate`, `investment_ratio`)
    - `target_operator` (TEXT): ตัวดำเนินการเปรียบเทียบ (`>`, `>=`, `<`, `<=`)
    - `target_value` (TEXT): ค่าเกณฑ์เป้าหมาย (Decimal String)
    - `user_param_1_satang` (INTEGER, Nullable): สำหรับใส่ "ทุนประกัน" (หน่วยสตางค์)
    - `user_param_2_satang` (INTEGER, Nullable): สำหรับใส่ "ค่ารักษาที่ประเมิน" (หน่วยสตางค์)
    - คอลัมน์มาตรฐาน: `created_at`, `updated_at`, `deleted_at`

17. **`balance_snapshots`** *(ตารางใหม่ — เพิ่มเพื่อรองรับกราฟแนวโน้ม net worth ย้อนหลังโดยไม่ต้อง replay ledger ทั้งหมดทุกครั้ง)*
    - `id` (TEXT, PK): UUID
    - `account_id` (TEXT, FK): บัญชีที่ snapshot
    - `snapshot_date` (TEXT ISO8601): วันที่ snapshot (เช่น สิ้นเดือน)
    - `closing_balance_satang` (INTEGER): ยอดคงเหลือ ณ วันนั้น (หน่วยสตางค์)
    - `currency_code` (TEXT): สกุลเงินของบัญชี
    - คอลัมน์มาตรฐาน: `created_at`, `updated_at`
    - *หมายเหตุ: เป็นข้อมูลแคชที่คำนวณได้จากการ replay ledger เท่านั้น ไม่ใช่ข้อมูลที่ผู้ใช้กรอกเอง จึงไม่มี `deleted_at` — ถ้าคำนวณผิดพลาด ระบบสร้างใหม่ทับได้เสมอ*

---

### 2.1 Index ที่ต้องมี (บังคับตั้งแต่ Phase 0)

| ตาราง | คอลัมน์ที่ทำ Index |
| :--- | :--- |
| `transactions` | `transaction_date`, `source_account_id`, `category_id`, `asset_id`, `deleted_at` |
| `investment_lots` | `asset_id` |
| `investment_sales` | `lot_id` |
| `balance_snapshots` | `account_id`, `snapshot_date` |

### 2.2 FK On-Delete Policy (บังคับ — ต้องเขียนใน business logic layer ไม่ใช่ DB constraint)

- การ "ลบ" บัญชี (`accounts`) หรือหมวดหมู่ (`categories`) จาก UI **คือการตั้ง `is_active = false`** ไม่ใช่การลบจริง
- บัญชี/หมวดหมู่ที่ `is_active = false` จะไม่ปรากฏในตัวเลือกตอนสร้างธุรกรรมใหม่ แต่ธุรกรรมเก่าและรายงานเดิมยังคงอ้างอิงและแสดงผลได้ตามปกติ
- `deleted_at` (soft-delete แบบเต็ม) **สงวนไว้เฉพาะรายการที่ไม่เคยมีธุรกรรมใดอ้างอิงเลย** (เช่น สร้างผิดแล้วลบทิ้งทันที) — ต้อง block การใช้ `deleted_at` ถ้ายังมีธุรกรรมอ้างอิงอยู่

---

## 3. ผังความสัมพันธ์ของข้อมูล (ER Diagram — Text)

```text
[currencies] 1 --- ∞ [accounts]
[currencies] 1 --- ∞ [fx_rates]
[currencies] 1 --- ∞ [assets]

[accounts] 1 (source) --- ∞ [transactions]
[accounts] 1 (dest)   --- ∞ [transactions]
[accounts] 1          --- ∞ [balance_snapshots]
[categories] 1 (parent) --- ∞ [categories] (child)
[categories] 1        --- ∞ [transactions]
[categories] 1        --- ∞ [budgets]

[transactions] 1 --- 1 [credit_card_installments]
[transactions] 1 --- 1 [foreign_remittances]
[transactions] 1 --- ∞ [audit_logs]
[transactions] 1 (invest_buy)  --- 1 [investment_lots]
[transactions] 1 (invest_sell) --- ∞ [investment_sales]

[assets] 1 --- ∞ [transactions] (via asset_id)
[assets] 1 --- ∞ [investment_lots]
[assets] 1 --- ∞ [asset_prices]
[investment_lots] 1 --- ∞ [investment_sales] (FIFO Allocation)

[tax_deductions] ∞ --- 0..1 [transactions]
[recurring_rules] (Generates, จนถึง end_date หรือตลอดไป) ---> [transactions]
```

---

## 4. โครงสร้างโฟลเดอร์แบบ Feature-First

```text
myfinance/
├── android/                             # การตั้งค่าสำหรับระบบ Android
├── windows/                             # การตั้งค่าสำหรับระบบ Windows Desktop
├── assets/
│   ├── fonts/
│   │   └── NotoSansThai-Regular.ttf     # ฟอนต์อ่านภาษาไทยคมชัด
│   └── icons/
├── lib/
│   ├── core/                            # โครงสร้างพื้นฐานส่วนกลาง
│   │   ├── database/                    # ระบบฐานข้อมูล SQLite (Drift)
│   │   │   ├── app_database.dart        # ตัวจัดการตารางและการเชื่อมต่อ
│   │   │   ├── tables/                  # นิยามโครงสร้าง 17 ตารางข้างต้น
│   │   │   └── daos/                    # คำสั่งค้นหาและจัดการข้อมูล SQL
│   │   ├── money/                       # ระบบคำนวณเงินและอัตราแลกเปลี่ยน
│   │   │   ├── money.dart               # คลาสเก็บเงินหน่วยสตางค์ (int)
│   │   │   └── fx_rate.dart             # คลาสคำนวณ FX (Decimal 6 ตำแหน่ง)
│   │   ├── security/                    # ระบบ PIN, Fingerprint และการเข้ารหัส
│   │   │   ├── auth_service.dart        # ตรวจ PIN / Fingerprint (fallback เป็น PIN เสมอ)
│   │   │   └── encryption_service.dart  # สร้าง/เก็บ encryption key แยกต่างหากใน secure storage
│   │   ├── backup/                      # ระบบสำรอง/กู้คืนข้อมูล
│   │   │   ├── backup_service.dart      # zip + encrypt + upload ขึ้น Google Drive (manual trigger)
│   │   │   └── restore_service.dart     # download + decrypt + unzip
│   │   ├── theme/                       # ธีม สี และการจัดระยะหน้าจอ
│   │   └── router/                      # ระบบสลับหน้าจอ (GoRouter)
│   ├── features/                        # แยกแต่ละฟีเจอร์เป็นเอกเทศ
│   │   ├── accounts/                    # จัดการ 6 บัญชี และบัตรเครดิต
│   │   ├── transactions/                # บันทึกรายรับ-รายจ่าย รายการโอน รายการลงทุน
│   │   ├── budget/                      # ตั้งงบประมาณและพยากรณ์ Run-rate
│   │   ├── investments/                 # พอร์ตลงทุน, Lots FIFO, ราคาตลาด
│   │   ├── tax/                         # คำนวณภาษี 40(1)-(8) และ Remittance
│   │   ├── financial_health/            # คำนวณและประเมินเกณฑ์ 8 ตัวชี้วัด
│   │   ├── reports/                     # รายงานรายเดือน/รายปี, Export Excel/PDF, Share
│   │   └── settings/                    # ตั้งค่าภาษา, PIN, Fingerprint, สำรอง/กู้คืนข้อมูล
│   ├── l10n/                            # ไฟล์ภาษา (ไทย/อังกฤษ)
│   │   ├── app_th.arb
│   │   └── app_en.arb
│   └── main.dart                        # จุดเริ่มต้นของแอปพลิเคชัน
└── test/                                # ชุดทดสอบอัตโนมัติ (Unit Test)
    ├── core/
    │   ├── money_test.dart              # ทดสอบความถูกต้องของคลาส Money
    │   └── fx_rate_test.dart            # ทดสอบการแปลงค่าเงิน FX
    └── features/                        # ทดสอบ Business Logic แต่ละระบบ
```

---

## 5. รายการ Packages และเหตุผลความจำเป็น

1. **`drift` & `drift_dev` & `sqlite3_flutter_libs`**
   - *เหตุผล*: ระบบจัดการฐานข้อมูล SQLite สำหรับ Flutter ที่มีความเสถียรสูง มีระบบตรวจสอบ Type ของข้อมูล และมีระบบ Migration พร้อม Rollback อย่างเป็นระเบียบ
2. **`flutter_riverpod` & `riverpod_annotation`**
   - *เหตุผล*: State management ที่ปลอดภัย ทดสอบง่าย ไม่ผูกติดกับ UI
3. **`go_router`**
   - *เหตุผล*: Router มาตรฐานอย่างเป็นทางการของ Flutter สามารถดักจับหน้าจอเพื่อบังคับให้ใส่ PIN/Fingerprint ได้
4. **`decimal`**
   - *เหตุผล*: ใช้สำหรับคำนวณจำนวนหุ้น/คริปโต (8 ตำแหน่ง) และอัตราแลกเปลี่ยน (6 ตำแหน่ง) โดยไม่มีการปัดเศษผิดพลาด
5. **`uuid`**
   - *เหตุผล*: สร้างรหัส Primary Key แบบ UUID v4 ตามกฎข้อบังคับ
6. **`flutter_secure_storage`**
   - *เหตุผล*: บันทึก PIN, ค่า preference เปิด/ปิด Fingerprint (จริง ๆ ค่านี้อยู่ใน SharedPreferences ธรรมดา ไม่ใช่ secure storage — ดูข้อ 12), และ encryption key สำหรับ backup ลงในระบบจัดเก็บข้อมูลปลอดภัยของเครื่อง
7. **`flutter_localizations` & `intl`**
   - *เหตุผล*: จัดการสลับภาษา ไทย-อังกฤษ และจัดรูปแบบวันที่ ค.ศ./พ.ศ. และตัวเลข
8. **`fl_chart`**
   - *เหตุผล*: วาดกราฟสุขภาพการเงิน สัดส่วนค่าใช้จ่าย และแนวโน้มพอร์ตลงทุน/net worth (จาก `balance_snapshots`)
9. **`excel` & `pdf` & `printing`**
   - *เหตุผล*: ส่งออกรายงานภาษีและสรุปรายเดือนเป็นไฟล์ Excel และ PDF ตามข้อกำหนด
10. **`home_widget`**
    - *เหตุผล*: ส่งข้อมูลยอดเงินคงเหลือที่ใช้ได้ไปแสดงบนหน้าจอโฮมของ Android
11. **`local_auth`**
    - *เหตุผล*: รองรับสแกนลายนิ้วมือ Android ควบคู่กับ PIN — ถ้าสแกนไม่ผ่านหรือไม่ได้ enroll ไว้ fallback เป็น PIN เสมอ
12. **`shared_preferences`**
    - *เหตุผล*: เก็บค่า preference ทั่วไปที่ไม่ใช่ข้อมูลลับ เช่น "เปิดใช้ Fingerprint หรือไม่" (ไม่จำเป็นต้องเข้ารหัสระดับ secure storage)
13. **`google_sign_in` & `googleapis`**
    - *เหตุผล*: Login เข้า Google Account และเรียก Drive API v3 (scope `drive.file` เท่านั้น — แอปเข้าถึงได้แค่ไฟล์ที่ตัวเองสร้าง ไม่แตะไฟล์อื่นใน Drive ผู้ใช้) สำหรับอัปโหลด/ดาวน์โหลดไฟล์ backup
14. **`cryptography`**
    - *เหตุผล*: เข้ารหัส AES-256 ไฟล์ backup ก่อนอัปโหลดขึ้น Google Drive ด้วย encryption key ที่สุ่มแยกต่างหาก (ไม่ผูกกับ PIN)
15. **`share_plus`**
    - *เหตุผล*: เปิด share sheet ของระบบให้ผู้ใช้เลือกปลายทางเองตอน export รายงาน Excel/PDF
16. **`archive`**
    - *เหตุผล*: บีบอัดไฟล์ฐานข้อมูล SQLite เป็น .zip ก่อนเข้ารหัสและอัปโหลด backup

---

## 6. Decision Log (คำถามที่ยืนยันแล้ว — เดิมคือหัวข้อ "คำถามที่ต้องยืนยัน")

1. **โอนเงินข้ามสกุลเงินเพื่อลงทุน**: บังคับแปลง THB → USD ผ่าน Dime! USD ก่อนเสมอ (ไม่อนุญาตให้ซื้อหุ้นตรงจากบัญชี THB) → บันทึกเป็น 2 transactions ต่อเนื่อง (`transfer` แล้วตามด้วย `invest_buy`) ขายหุ้นแล้วเงินกลับเข้า Dime! USD เสมอ (`invest_sell`)
2. **รอบบิลบัตรเครดิต**: ยึดวันที่ 23 เสมอ ไม่เลื่อนตามวันหยุดเสาร์-อาทิตย์
3. **ปีภาษีเงินได้ต่างประเทศ**: คิดภาษีจาก **ปีที่นำเงินกลับเข้าไทย** (`remittance_date`) เท่านั้น ไม่เกี่ยวกับปีที่เกิดเงินได้ในต่างประเทศ — `tax_year_earned` เก็บไว้เป็น metadata อ้างอิงส่วนตัวเฉย ๆ
4. **เกณฑ์สุขภาพการเงิน ข้อ 5-6**: ค่า "ทุนประกัน" และ "ค่ารักษาที่ประเมิน" ให้กรอกเป็นค่าคงที่ในหน้าตั้งค่า
5. **ความปลอดภัย**: ใช้ PIN 6 หลัก + รองรับสแกนลายนิ้วมือ Android — ถ้าสแกนไม่ผ่าน/ไม่ได้ enroll fallback เป็น PIN เสมอ ค่า preference เปิด/ปิด fingerprint เก็บด้วย SharedPreferences ธรรมดา
6. **ช่องกรอกสินทรัพย์ตอนลงทุน**: เพิ่ม `asset_id` (nullable FK) ลงในตาราง `transactions` โดยตรง (ไม่พึ่ง join กับ `investment_lots` อย่างเดียว) เพื่อให้หน้าประวัติธุรกรรมแสดงชื่อสินทรัพย์ได้เร็วโดยไม่ต้อง join
7. **Index**: เพิ่ม index ตามหัวข้อ 2.1 ตั้งแต่ Phase 0
8. **FK on-delete**: ลบบัญชี/หมวดหมู่ = ตั้ง `is_active = false` (บันทึกเพิ่มไม่ได้ แต่ข้อมูลเดิมยังอยู่) ตามหัวข้อ 2.2
9. **Balance snapshot**: เพิ่มตารางที่ 17 `balance_snapshots` สำหรับกราฟแนวโน้ม net worth
10. **ดอกเบี้ยผ่อนบัตรเครดิต**: ไม่ต้องมีฟิลด์ เพราะไม่เคยผ่อนแบบมีดอกเบี้ย
11. **Recurring rules — วันสิ้นสุด**: เพิ่ม `end_date` (nullable) เลือกได้ว่า "ตลอดไป" หรือ "จนถึงวันที่"
12. **Sync**: ตัดคอลัมน์ `sync_version` ออกจากทุกตาราง เพราะกลไกที่ต้องการคือ backup/restore ทั้งไฟล์ขึ้น Google Drive แบบสั่งเอง ไม่ใช่ sync ระดับแถวแบบ real-time
13. **Backup & Export**: สำรองไฟล์ฐานข้อมูล SQLite (บีบอัด .zip → เข้ารหัส AES-256 → อัปโหลด Google Drive) แบบสั่งเองเท่านั้น ใช้ **encryption key แยกต่างหากที่สุ่มขึ้นเอง** เก็บใน `flutter_secure_storage` (ไม่ผูกกับ PIN) — ตอน setup ครั้งแรกต้องแสดง **recovery key เป็นข้อความ/QR code ให้ผู้ใช้จดหรือถ่ายรูปเก็บไว้เอง** (คล้าย seed phrase) เพื่อกันกรณีเปลี่ยนเครื่องแล้ว secure storage หาย ส่วนการ export รายงานเลือกได้ทั้ง Excel และ PDF พร้อมเปิด share sheet ให้เลือกปลายทางเอง
