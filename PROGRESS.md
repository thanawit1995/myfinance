# บันทึกความคืบหน้าโครงการ MyFinance (PROGRESS.md)

อัปเดตล่าสุด: 9 ตุลาคม 2026 (ปรับปรุงความคมชัดของ Budget Bar ในโหมดกลางคืน: เพิ่มเส้นขอบรางหลอด, ปรับสีรางหลอด, เพิ่มความสูงหลอดเป็น 11px, เพิ่มเงาเรืองแสงสีชมพู Luminous Glow, และปรับสีตัวหนังสือให้อ่านง่าย)

- [x] **Lumi Budget Bar Night Mode Contrast & Glow Enhancement (9 ต.ค. 2026)**:
  - **1. ปรับปรุงความคมชัดของรางหลอดงบประมาณ (Track Contrast & Border)**:
    - ในโหมดกลางคืน (`isDark`):
      - เพิ่มเส้นขอบรางหลอดสีขาวละมุน `Border.all(color: Colors.white.withValues(alpha: 0.28), width: 1.0)` รอบหลอดงบประมาณ เพื่อให้เห็นขอบเขตทั้งหมดของหลอด 0% - 100% ได้อย่างชัดเจน
      - ปรับสีพื้นหลังรางหลอด (Unfilled track) เป็นสีม่วงเข้มโทนสว่าง `Color(0xFF382536)` เพื่อให้ตัดกับพื้นหลังการ์ดสีมืดอย่างพอดี
    - ในโหมดกลางวัน: คงสีขาวสะอาด `Colors.white.withValues(alpha: 0.9)` ตามเดิม
  - **2. ปรับขนาดหลอดและการเรืองแสง (Height & Luminous Glow)**:
    - เพิ่มความสูงของหลอดงบประมาณในโหมดกลางคืนเป็น `11` พิกเซล (จากเดิม 9) ให้อ่านง่ายและโดดเด่นสมส่วน
    - ปรับการไล่เฉดสีในโหมดกลางคืนให้สว่างขึ้น (`Color(0xFFFFC27A)` -> `Color(0xFFFF64A2)`)
    - เพิ่มเงาเรืองแสงละมุน (`BoxShadow`) สีชมพู Lumi `Color(0xFFFF5B9A).withValues(alpha: 0.45)` ให้แถบงบประมาณที่ใช้ไป
  - **3. ปรับสีตัวอักษรกำกับตามหลัก Contrast Ratio**:
    - ข้อความ "ความคืบหน้าการใช้เงิน": ในโหมดกลางคืนปรับเป็น `Color(0xFFD8C7D2)` ให้สว่าง คมชัด ไม่กลืนไปกับพื้นหลัง
    - ตัวเลขเปอร์เซ็นต์ `$percentUsed%`: ในโหมดกลางคืนปรับเป็น `Color(0xFFFF7DB0)` ให้สดใส อ่านง่าย
  - **4. ปรับปรุงใน `vault_home_screen.dart`**:
    - ปรับ `LinearProgressIndicator` ในหน้า Dashboard โหมดกลางคืนให้มีสีพื้นหลังรางและตัวเลขเปอร์เซ็นต์ที่คมชัดเช่นเดียวกัน
  - **5. การทดสอบและการรับรองคุณภาพ**:
    - `flutter analyze`: **0 errors, 0 warnings** (No issues found)
    - `flutter test`: ผ่านทั้งหมด **213/213 tests passed** (100%)

- [x] **Lumi Home Hero Mascot Dark Mode Support (9 ต.ค. 2026)**:
  - **1. นำเข้าไฟล์ภาพมาสคอต Lumi โหมดกลางคืน (Transparent PNG 500x500 พิกเซล)**:
    - คัดลอกจากโฟลเดอร์ `lumi_image/` เข้าสู่ `assets/images/`:
      - `lumi_mascot_smile_dark.png`: มาสคอตยิ้มสดใส กอดน้องแมว สำหรับโหมดกลางคืน (Twilight Bloom)
      - `lumi_mascot_warning_dark.png`: มาสคอตกังวล สงสัย ถือโทรศัพท์พร้อมเครื่องหมายเตือน สำหรับโหมดกลางคืน
      - `lumi_mascot_shock_dark.png`: มาสคอตตกใจสุดขีด ถือโทรศัพท์พร้อมเครื่องหมายตกใจ สำหรับโหมดกลางคืน
  - **2. แสดงผลรูปมาสคอตตัวใหญ่สลับตามโหมดกลางวัน/กลางคืนอัตโนมัติ (`budget_hero_card.dart`, `vault_home_screen.dart`, `settings_screen.dart`)**:
    - **`BudgetHeroCard`**: ตรวจจับ `isDark` (`Theme.of(context).brightness == Brightness.dark`) และสลับ asset path อัตโนมัติ:
      - เกินงบ: `lumi_mascot_shock_dark.png` (กลางคืน) / `lumi_mascot_shock.png` (กลางวัน)
      - เตือน (<=20%): `lumi_mascot_warning_dark.png` (กลางคืน) / `lumi_mascot_warning.png` (กลางวัน)
      - ปกติ (>20%): `lumi_mascot_smile_dark.png` (กลางคืน) / `lumi_mascot_smile.png` (กลางวัน)
    - **`vault_home_screen.dart`**: ฟังก์ชัน `_buildMasterBudgetCard` สลับ asset path ตาม `isDark` เช่นกัน
    - **`settings_screen.dart`**: ปรับรูปตัวอย่างมาสคอตใหญ่ (Default mascot preview thumbnail) และกรอบพื้นหลังให้รองรับโหมดกลางคืนอย่างสวยงาม
  - **3. การทดสอบและการรับรองคุณภาพ**:
    - เพิ่ม Widget Tests ใน `lumi_home_dashboard_test.dart` ครอบคลุมการแสดงผลรูปภาพ Dark Mode ทั้ง 3 สถานะ (Smile, Warning, Shock)
    - `flutter analyze`: **0 errors, 0 warnings** (No issues found)
    - `flutter test`: ผ่านทั้งหมด **213/213 tests passed** (100%)

- [x] **Database Migration Idempotency & Duplicate Column Prevention (8 ต.ค. 2026)**:
  - **1. ป้องกันข้อผิดพลาด `duplicate column name: is_default` ใน SQLite (`app_database.dart`)**:
    - ปรับปรุงขั้นตอน `onUpgrade` (from < 13 และทุกเวอร์ชัน) ให้เรียกผ่าน `_safeAddColumn` และ `_safeCreateTable`
    - หากคอลัมน์หรือตารางมีอยู่แล้วในฐานข้อมูล (เช่น จากการ Sync คลาวด์, กู้คืนไฟล์สำรอง, หรือ snapshot ก่อนหน้า) จะไม่เกิดข้อผิดพลาด `SqliteException(1): duplicate column name` และระบบจะดำเนินการอัปเกรด Schema ต่อจนสำเร็จสมบูรณ์
  - **2. เพิ่ม Unit Test ตรวจสอบความปลอดภัยของการอัปเกรดฐานข้อมูล (`test/core/database_test.dart`)**:
    - เพิ่มการทดสอบกรณี `onUpgrade` จากเวอร์ชัน 12 ไป 13 ขณะที่มีคอลัมน์ `is_default` อยู่แล้วในตาราง `accounts` ยืนยันว่าทำงานสำเร็จและไม่โยน Exception
    - `flutter analyze`: **0 errors, 0 warnings**
    - `flutter test`: ผ่านทั้งหมด **210/210 tests passed** (100%)

- [x] **Lumi Home Hero Mascot Dynamic Emotion, Upsize & Behind-Bar Layering (8 ต.ค. 2026)**:
  - **1. นำเข้าไฟล์ภาพมาสคอต Lumi & น้องแมวแบบโปร่งใส (Transparent PNG)**:
    - คัดลอกจากโฟลเดอร์ `lumi_image/` เข้าสู่ `assets/images/`:
      - `lumi_mascot_smile.png`: มาสคอตยิ้มสดใส กอดน้องแมว
      - `lumi_mascot_warning.png`: มาสคอตกังวล สงสัย ถือโทรศัพท์พร้อมเครื่องหมายเตือน
      - `lumi_mascot_shock.png`: มาสคอตตกใจสุดขีด ถือโทรศัพท์พร้อมเครื่องหมายตกใจ
  - **2. แสดงผลอารมณ์มาสคอตตามสถานะงบประมาณคงเหลือเดือน (`BudgetHeroCard`, `vault_home_screen.dart`)**:
    - **Smile (`lumi_mascot_smile.png`)**: งบประมาณเดือนนั้นคงเหลือ > 20% (หรือยังไม่ได้ตั้งงบประมาณ)
    - **Warning (`lumi_mascot_warning.png`)**: งบประมาณเดือนนั้นคงเหลือ <= 20% และยังไม่เกินงบ
    - **Shock (`lumi_mascot_shock.png`)**: รายจ่ายเกินงบประมาณเดือนนั้น (ยอดคงเหลือติดลบ หรือค่าใช้จ่าย > งบที่ตั้งไว้)
    - รองรับ Custom Mascot จากเมนูตั้งค่า (Settings): หากผู้ใช้อัปโหลดรูปเอง จะแสดงรูปที่กำหนดเองก่อน
  - **3. จัดวางมาสคอตเลเยอร์หลัง Budget Progress Bar และตัดรายละเอียดที่ไม่จำเป็นออก**:
    - วางโครงสร้างเป็น `Stack`:
      - Layer หลัง: วางมาสคอตตัวใหญ่ขนาด 175×185 พิกเซล ชิดขวาล่าง ซ้อนอยู่หลังหลอด Budget Progress Bar
      - Layer หน้า: แสดงเฉพาะข้อมูลสำคัญ ได้แก่ ป้าย "✨ เงินที่ใช้ได้ในเดือนนี้", ยอดยกคงเหลือตัวใหญ่, ยอดจากงบรวม, หลอดความคืบหน้าการใช้เงินพร้อมตัวเลขเปอร์เซ็นต์แบบ Inline (เช่น 18%)
      - ตัดยอด "ใช้ไปแล้ว" ที่ซ้ำซ้อนออก และตัดปุ่มชิปเปอร์เซ็นต์เดิมออกเพื่อเปิดพื้นที่ให้มาสคอตตัวใหญ่โดดเด่นสมส่วน
  - **4. การทดสอบและการรับรองคุณภาพ**:
    - อัปเดตและเพิ่ม Widget Tests ใน `lumi_home_dashboard_test.dart` ครอบคลุมการแสดงผลรูปภาพทั้ง 3 สถานะ (Smile, Warning, Shock)
    - `flutter analyze`: **0 errors, 0 warnings** (No issues found)
    - `flutter test`: ผ่านทั้งหมด **209/209 tests passed** (100%)

- [x] **Financial Summary & Dashboard Investment Separation (8 ต.ค. 2026)**:
  - **1. แยกกิจกรรมและผลผลิตพอร์ตการลงทุนออกจากรายรับค่าครองชีพ (`monthly_summary_screen.dart`, `vault_home_screen.dart`)**:
    - **รายรับค่าครองชีพ (Living Income)**: กรองยอดเงินสดจากการขายสินทรัพย์ (`investment_sell:`) และเงินปันผล/ดอกเบี้ยรับ (`cat-inc-...0003` หรือ tag `dividend:`) ออกจากการ์ดรายรับหลัก ทำให้รายรับแสดงเฉพาะรายได้จากการทำงาน/ธุรกิจอย่างแท้จริง
    - **อัตราการออม (% Savings Rate)**: คำนวณจาก `(Living Income - Living Expense) / Living Income` สะท้อนวินัยการออมที่แท้จริง ไม่ถูกยอดขายสินทรัพย์หลักแสนหรือหลักล้านบิดเบือน
    - **การ์ดใหม่ "กิจกรรมและผลผลิตจากการลงทุน" (Investment Activities & Asset Yields Card)**:
      - **ผลผลิตจากสินทรัพย์**: แสดงยอดรวมเงินปันผลและดอกเบี้ยรับ (`assetYieldSatang`), แยกปันผลและดอกเบี้ยชัดเจน พร้อมแสดง **กำไร/ขาดทุนจากการขายที่รับรู้จริง (Realized Capital Gain/Loss)** ตามหลัก FIFO
      - **การเคลื่อนย้ายเงินทุนในพอร์ต (Capital Flow)**: แสดงเงินลงทุนเพิ่ม (ซื้อสินทรัพย์), เงินสดที่ได้คืน (ขายสินทรัพย์), และกระแสเงินสดสุทธิ (Net Capital Flow)
  - **2. เพิ่มฟังก์ชัน Query Realized Gain/Loss ตามช่วงเวลา (`investments_dao.dart`)**:
    - เพิ่ม `getRealizedGainLossForPeriod(start, end)` ดึงยอด Realized Gain/Loss, ยอดขายรวม, และต้นทุนรวมจากตาราง `investmentSales` ในช่วงเวลาใดๆ ได้อย่างแม่นยำ
  - **3. ปรับปรุงหน้า Home Dashboard (`vault_home_screen.dart`)**:
    - คำนวณ `totalLivingIncomeMonthSatang` แยกจากการขายสินทรัพย์และปันผล ส่งต่อให้การ์ด Cash Flow และกราฟ Lumi Desktop Layout อย่างถูกต้อง
  - **4. การทดสอบและการรับรองคุณภาพ**:
    - เพิ่ม Unit Tests ใน `monthly_summary_investment_split_test.dart` ครอบคลุมการแยกรายรับ, การคำนวณ % การออม, และการ Query Realized Gain/Loss
    - `flutter analyze`: **0 errors, 0 warnings** (No issues found)
    - `flutter test`: ผ่านทั้งหมด **206/206 tests passed** (100%)

- [x] **4-Decimal Investment Price, Non-Investment Master Budget & Default Account System (8 ต.ค. 2026)**:
  - **1. ซื้อขายสินทรัพย์สามารถตั้งราคาได้ถึงทศนิยม 4 หลัก (`buy_sell_trade_dialog.dart`, `investments_dao.dart`, `portfolio_screen.dart`)**:
    - ฟอร์มซื้อขายสินทรัพย์รองรับการกรอกราคาทศนิยมสูงสุด 4 ตำแหน่ง (เช่น 35.1234 บาท/หน่วย หรือ $0.0055) พร้อมข้อความแนะนำ `helperText`
    - เพิ่มคอลัมน์และฟิลด์ `pricePerUnitOriginal` ในโครงสร้าง Lot และ `InvestmentTradeRecord` เพื่อรักษาความละเอียด 4-8 ตำแหน่งไว้ ไม่ถูกตัดทศนิยม
    - หน้า Trade History แสดงราคาต่อหน่วยตามทศนิยม 4 ตำแหน่งที่แท้จริง
  - **2. Master Budget & Expense Trend คิดเฉพาะรายจ่ายที่ไม่ใช่การลงทุน (`vault_home_screen.dart`, `lumi_desktop_layout.dart`)**:
    - แยกยอด `totalLivingExpense` (รายจ่ายเพื่อการดำรงชีพ) ออกจากยอดรวมรายจ่าย โดยกรองรายการที่มี tag `investment_buy:` หรือหมวดหมู่การลงทุน (`cat-exp-0000-4000-8000-000000000099`) ออก
    - งบประมาณคงเหลือ (`remainingBudget`) คำนวณจาก `totalBudget - totalLivingExpense` ป้องกันไม่ให้การลงทุนส่งผลให้งบประมาณติดลบหรือเตือนงบหมด
    - กราฟแนวโน้มรายจ่าย (`dailyExpenses` และ `ExpenseTrendProjectionCard`) แสดงเฉพาะรายจ่ายจริง ไม่นำเงินลงทุนมารวมในกราฟแท่งและแนวโน้ม
  - **3. ระบบตั้งบัญชีหลัก (Default Account) และแสดงเป็นชื่อแรก (`accounts_table.dart`, `accounts_dao.dart`, `accounts_screen.dart`, `quick_add_screen.dart`)**:
    - ปรับ Schema SQLite v13: เพิ่มคอลัมน์ `is_default` (boolean) ในตาราง `accounts` พร้อม Migration v12 -> v13 ปลอดภัย 100%
    - เพิ่มฟังก์ชัน `setDefaultAccount(accountId)` ใน `AccountsDao` รีเซ็ตบัญชีอื่นและตั้งบัญชีเป้าหมายเป็นบัญชีหลัก
    - ปรับ `getActiveAccounts()` และ `watchActiveAccounts()` ให้ ORDER BY `is_default DESC, created_at ASC` ทำให้บัญชีหลักปรากฏเป็นลำดับแรกเสมอใน Quick Add Account Picker
    - เพิ่มปุ่ม "ตั้งเป็นบัญชีหลัก" ใน Dialog แก้ไขบัญชี และป้าย Badge "บัญชีหลัก ⭐" ในหน้ารายการบัญชีและ Bottom Sheet
  - **4. การทดสอบและการรับรองคุณภาพ**:
    - เพิ่ม Unit Tests ครอบคลุมทั้ง 3 ฟีเจอร์: `accounts_dao_test.dart`, `investments_dao_test.dart`, `master_budget_living_expense_test.dart`
    - `flutter analyze`: **0 errors, 0 warnings** (No issues found)
    - `flutter test`: ผ่านทั้งหมด **202/202 tests passed** (100%)

- [x] **Recurring Notification & Attention Insight Overhaul (5 ต.ค. 2026)**:
  - **1. แก้ไขปัญหารายการแจ้งเตือนเก่าไม่หายไปหลังกดติ๊กถูก / รับทราบทั้งหมด (`vault_home_screen.dart`)**:
    - ใน `_loadNotificationsData`: นำ `dismissed_recurring_notification_ids` จาก `SharedPreferences` มากรองรายการที่เคยกดรับทราบออกจากส่วน "รายการประจำที่บันทึกแล้วล่าสุด"
    - เมื่อผู้ใช้กดติ๊กถูกที่รายการเดี่ยว หรือกด "รับทราบทั้งหมด" รายการเหล่านั้นจะหายไปทันที ไม่ค้างแสดงผลอีกต่อไป
  - **2. นำปุ่ม "รับทราบแล้ว" (Mark read) มุมขวาบนออก (`vault_home_screen.dart`)**:
    - ตัดปุ่ม "รับทราบแล้ว" ที่ซ้ำซ้อนกับปุ่ม "รับทราบทั้งหมด" ออก และเปลี่ยนเป็นปุ่มปิดกากบาท (`Icons.close_rounded`) สะอาดตา
  - **3. แก้ไขแจ้งเตือนรายการที่ถึงกำหนดวันนี้ (Coway) ให้แสดงผลเตือนชัดเจน (`vault_home_screen.dart`)**:
    - ในตัวนับ badge กระดิ่งแจ้งเตือน (`unreadRecurringCount`): นำรายการ Recurring Rule ที่ถึงกำหนดวันนี้หรือเลยกำหนด (Due today / Overdue เช่น Coway) มารวมกับจำนวนรายการที่ยังไม่ได้รับทราบ ทำให้กระดิ่งแสดงตัวเลขสีแดงแจ้งเตือนอย่างถูกต้อง
    - ในกล่อง Attention Card หน้าหลัก Dashboard: เพิ่มการตรวจสอบรายการประจำที่ถึงกำหนดวันนี้ หากมีรายการที่ต้องยืนยันหรือถึงกำหนดชำระ ระบบจะแสดงข้อความแจ้งเตือนสีส้มเด่นชัด เช่น `มีรายการประจำถึงกำหนดวันนี้: Coway (฿...)` เพื่อเตือนให้ผู้ใช้ทราบและกดจัดการได้ทันที
  - **4. การทดสอบและการรับรองคุณภาพ**:
    - `flutter analyze`: **0 errors, 0 warnings** (No issues found)
    - `flutter test`: ผ่านทั้งหมด **191/191 tests passed** (100%)

- [x] **Accounts Screen Interface & Typography Overhaul (4 ต.ค. 2026)**:
  - **1. นำคำว่า "เปิดใช้งาน" และปุ่มดินสอออก (`accounts_screen.dart`)**:
    - บัญชีที่เปิดใช้งานปกติจะไม่แสดงคำว่า "เปิดใช้งาน" ช่วยลดความแออัด และนำปุ่มดินสอออกเพื่อให้มีพื้นที่แนวนอนเต็มที่ โดยยังคงกดค้าง (Long Press) เพื่อแก้ไขชื่อและไอคอนบัญชีได้เช่นเดิม
  - **2. แก้ไขปัญหาชื่อบัญชีและข้อความตัดบรรทัด / โดนบีบย่อ (Text Clipping & Layout Fix)**:
    - **การ์ดบัญชีเงินฝากและ FCD**: จัดวางชื่อบัญชีไว้ตรงกลางแนวตั้งขนานกับยอดเงินตามแบบเดิมที่คุ้นเคย ลบ `(เรต ...)` ออกเพื่อความกระชับสะอาดตา เหลือเฉพาะยอดเทียบเงินบาท เช่น `≈ ฿131,432.22` และชื่อบัญชีไม่ถูกบีบตัดคำ
    - **การ์ดพอร์ตการลงทุน**: ปรับชื่อหัวข้อเป็น **"การลงทุน"** พร้อมข้อความย่อย `พอร์ตหุ้น, กองทุน, คริปโต, ทองคำ` สวยงาม ไม่ล้นขอบ
    - **การ์ดบัตรเครดิต**: วางชื่อบัตรเต็มบรรทัดคู่กับยอดหนี้ และกระชับข้อความรอบบิลเป็น `ตัดรอบ 23 • ครบชำระ 10` ทำให้อ่านได้ครบทุกตัวอักษรโดยไม่โดนตัดทอนเป็น `...`
  - **3. ยกระดับ UX & ความเข้ากันได้กับธีม Quiet Luxury (Vault)**:
    - รองรับ Dark Mode และ Light Mode อย่างสมบูรณ์แบบ ทั้งบน OPPO Find X9, PC (Windows) และ Web
  - **4. การทดสอบและการรับรองคุณภาพ**:
    - `flutter analyze`: **0 errors, 0 warnings**
    - `flutter test`: ผ่านทั้งหมด **191/191 tests passed** (100%)

- [x] **Master Cloud Sync Account & Asset Icon Preservation (4 ต.ค. 2026)**:
  - **1. ป้องกัน Delta Sync เขียนทับไอคอนในเครื่องด้วย null (`sync_service.dart`)**:
    - ปรับปรุง `_syncAccounts`, `_syncAssets`, และ `_syncCategories` ในระหว่างการดึงข้อมูลจาก Cloud (Pull)
    - หากแถวข้อมูลจาก Cloud Supabase ส่งค่า `icon` มาเป็น null (เช่น กรณีตารางบน Supabase ยังไม่มีคอลัมน์ หรือถูกตัดออก) ระบบจะรักษาไอคอนในเครื่อง (`localIconMap`) ไว้ ไม่ถูกเขียนทับด้วย null เด็ดขาด
  - **2. แก้ไขการรีเฟรชหน้าจอเมื่อดึง Master Snapshot สำเร็จ (`backup_restore_screen.dart`)**:
    - เพิ่ม `transactionsVersionProvider.notifier.state++` ทันทีหลัง `pullMasterSnapshotFromCloud` ทำงานสำเร็จ เพื่อส่งสัญญาณให้หน้าจอบัญชี (`AccountsScreen`), บัตรเครดิต และหน้าหลัก รีโหลดข้อมูลใหม่จากฐานข้อมูล SQLite ทันทีโดยไม่ต้องสลับหน้าจอหรือรีสตาร์ตแอป
  - **3. ผลการทดสอบและการรับรองคุณภาพ**:
    - `flutter analyze`: **0 errors, 0 warnings**
    - `flutter test`: ผ่านทั้งหมด **191/191 tests passed** (100%)

- [x] **Image Cropper Overhaul, Cloud Route Fix, Auto Refresh & Portfolio Pie Chart Sync (4 ต.ค. 2026)**:
  - **1. ปรับปรุงระบบ Image Cropper ใหม่ทั้งหมด (`image_cropper_dialog.dart`)**:
    - เพิ่ม **ปุ่มหมุนรูปภาพทีละ 90° ตามเข็มนาฬิกา (Rotate 90°)** แก้ปัญหารูปถ่ายแนวนอน/แนวตั้งกลับด้าน
    - เพิ่ม **Slider ซูมภาพ พร้อมปุ่ม Zoom in (+) และ Zoom out (-)** ช่วยให้ปรับขนาดภาพได้ละเอียดและแม่นยำทั้งบนมือถือและการใช้เมาส์บน Desktop/Web
    - เพิ่ม **ปุ่มรีเซ็ต (Reset)** ดึงภาพกลับมากึ่งกลางขนาดพอดีกรอบ
    - ออกแบบหน้าต่างแสดงผลเป็น **Dimmed Cutout Overlay + Rule of Thirds Grid**: เห็นภาพส่วนเกินรอบนอกแบบสลัว ไม่ถูกตัดทึบหายไป ทำให้กะตำแหน่งจัดวางได้ง่ายและตรงจุด
    - ปรับการ Export ภาพลง Canvas ให้แม่นยำ 1:1 กับสิ่งที่ตาเห็นบนหน้าจอ (WYSIWYG)
  - **2. แก้ไขปุ่ม Cloud Backup หน้า Home (`main.dart`, `sync_status_widget.dart`)**:
    - ลงทะเบียน route `'/backup_restore'` ใน `MaterialApp`
    - เชื่อมโยงปุ่มในป๊อปอัปสถานะซิงค์ให้เปิดหน้า `BackupRestoreScreen` ได้อย่างปลอดภัยและทำงานได้จริงทุกจุด
  - **3. ปรับปรุง UI หน้าพอร์ตการลงทุน (`portfolio_screen.dart`, `lot_inspection_screen.dart`)**:
    - นำปุ่มข้อความ "ดูตามพอร์ต" ที่มุมบนขวาของการ์ดสัดส่วนสินทรัพย์ออก
    - ซิงค์แผนภูมิวงกลมและหัวข้อกราฟ (สัดส่วนตามประเภทสินทรัพย์ / สัดส่วนตามพอร์ตการลงทุน) ให้เปลี่ยนตามการสลับปุ่มโหมด (ประเภทสินทรัพย์ / พอร์ต) ด้านล่างโดยอัตโนมัติ
    - เปลี่ยนป้าย Chip สุดท้ายในโหมดพอร์ตจาก `+ จัดการพอร์ต` เป็น `จัดการพอร์ต` (และภาษาอังกฤษจาก `+ Manage` เป็น `Manage`) ป้องกันเครื่องหมายบวกซ้ำซ้อนกับไอคอน
    - เพิ่มระบบ **Auto-refresh** ในหน้าพอร์ตการลงทุน เมื่อมีการแก้ไขข้อมูล Lot ซื้อหรือรายการธุรกรรม หน้าพอร์ตหลักจะอัปเดตตัวเลขใหม่ทันทีโดยไม่ต้องสลับหน้าหรือลากรีเฟรชเอง
  - **4. การทดสอบและการรับรองคุณภาพ**:
    - `flutter analyze`: **0 errors, 0 warnings**
    - `flutter test`: ผ่านทั้งหมด **191/191 tests passed** (100%)

- [x] **UI Compactness, Master Cloud Sync Integrity, Icon Customization, Home Speed, Notification Dismiss, Modern Dropdown & Mascot Upload (4 ต.ค. 2026)**:
  - **1. ปรับอินเทอร์เฟซปุ่มซิงค์ให้กระชับและรองรับภาษาตามที่เลือก (`backup_restore_screen.dart`, `sync_status_widget.dart`)**:
    - ปรับปุ่ม Force Upload / Download ให้กระชับขึ้น: `เขียนทับข้อมูลคลาวด์ (Master Push)` และ `ดาวน์โหลดข้อมูล Master`
    - หน้า Home ป๊อปอัปสถานะซิงค์ปรับเหลือเฉพาะสถานะการซิงค์ล่าสุด + ปุ่ม **"ซิงค์ด่วน (Quick Sync)"** ส่วนการ Force Upload / Download Master ย้ายเข้าไปอยู่ในหน้า Settings (การสำรองและกู้คืนข้อมูล) เพื่อป้องกันการกดพลาด
    - เพิ่มการตั้งค่า **เปิด-ปิด Quick Startup Sync อัตโนมัติเมื่อเปิดแอป** ให้ผู้ใช้เลือกเปิดหรือปิดได้ตามต้องการ
  - **2. ตรวจสอบและแก้ไขระบบ Master Push / Download Master ให้ครอบคลุมทุกตาราง (`backup_restore_service.dart`, `app_database.dart`)**:
    - ยกระดับ Schema Version เป็น 11 และปรับกระบวนการ Import ข้อมูลของ Master Snapshot ให้ตรวจสอบคอลัมน์ของตารางจริงด้วย `PRAGMA table_info` อัตโนมัติ ป้องกันปัญหาการนำเข้าล้มเหลวหากมีคอลัมน์ใหม่เพิ่มขึ้นมา
    - รองรับการ Export / Import ข้อมูลครบทั้ง 25 ตารางอย่างสมบูรณ์แบบ
  - **3. ระบบปรับแต่งไอคอนสำหรับบัญชี บัตรเครดิต และสินทรัพย์ลงทุน (`app_icon_selector.dart`, `add_account_dialog.dart`, `edit_credit_card_dialog.dart`, `asset_form_dialog.dart`)**:
    - เพิ่มคอลัมน์ `icon` ในตาราง `accounts` และ `assets` พร้อม Migration ใน AppDatabase
    - สร้าง `AppIconSelector` bottom sheet สำหรับเลือกไอคอนสวยงาม แยกตามหมวดหมู่ (ธนาคาร, การเงิน, บัตร, สินทรัพย์/หุ้น, ไลฟ์สไตล์)
    - รองรับการเลือกและแสดงผลไอคอนที่ปรับแต่งเองในหน้า Accounts, บัตรเครดิต และพอร์ตการลงทุน (Portfolio / Holdings)
  - **4. ปรับปรุงความเร็วในการโหลดหน้า Home (`vault_home_screen.dart`, `transactions_dao.dart`)**:
    - รวมการคำนวณสรุปกระแสเงินสดรายได้-รายจ่ายเป็น Single SQL Query ด้วยฟังก์ชัน `getMonthlyCashFlowSummary` ใน TransactionsDao แทนการดึงข้อมูลทั้งเดือนมาคำนวณซ้ำใน Dart
    - รันคำค้นหาทั้ง 9 ฟังก์ชันใน `_loadHomeData` แบบขนาน (Parallel execution ผ่าน `Future.wait`) ทำให้หน้า Home โหลดเสร็จเร็วกว่าเดิมเกือบ 3 เท่า
  - **5. จัดการ Notification รายการที่บันทึกแล้วให้กดรับทราบเพื่อเอาออกจาก Noti ได้ (`vault_home_screen.dart`)**:
    - เพิ่มปุ่มไอคอนติ๊กถูก (รับทราบ) ในแต่ละรายการ Recurring ที่บันทึกแล้ว และปุ่ม **"รับทราบทั้งหมด"** ด้านบน
    - บันทึกประวัติรายการที่รับทราบแล้วลงใน SharedPreferences และตัดยอดออกจากตัวเลขนับการแจ้งเตือนที่ยังไม่ได้อ่าน
  - **6. ออกแบบ Dropdown บัญชีใหม่ให้สวยงามและขยายกรอบเลือกบัญชีใน Quick Add (`quick_add_screen.dart`, `edit_transaction_dialog.dart`)**:
    - แยกช่องบันทึกช่วยจำ (Note) และช่องเลือกบัญชีให้เต็มความกว้างแถว (Full width)
    - เปลี่ยน Dropdown แบบเดิมเป็น Modal Bottom Sheet ที่แสดงรายการบัญชีพร้อมไอคอน ยอดเงินคงเหลือ สกุลเงิน และประเภทบัญชีอย่างชัดเจน สวยงาม สัมผัสง่าย
  - **7. เพิ่ม Animation ตอนบันทึกรายการรายรับ-รายจ่ายตามธีม (`transaction_success_overlay.dart`, `quick_add_screen.dart`)**:
    - ออกแบบแอนิเมชันเฉลิมฉลองเมื่อบันทึกรายการสำเร็จ:
      - **ธีม Lumi**: เอฟเฟกต์ Confetti สีพาสเทลสดใสพร้อมไอคอนเฉลิมฉลอง
      - **ธีม VAULT**: เอฟเฟกต์ประกายสีทองแชมเปญ Quiet Luxury เรียบหรู
  - **8. อัปโหลดรูปภาพ Avatar สำหรับมาสคอต Lumi (`lumi_mascot_avatar.dart`, `lumi_tip_card.dart`, `vault_home_screen.dart`)**:
    - ผู้ใช้สามารถกดที่รูปน้องแมว Lumi เพื่ออัปโหลดรูปภาพของตัวเองได้ (รองรับทั้งไฟล์ภาพบนเครื่องและ Web Base64) พร้อมปุ่มรีเซ็ตกลับเป็นรูปมาสคอตตั้งต้น
  - **9. การทดสอบและการรับรองคุณภาพ**:
    - `flutter test`: ผ่านทั้งหมด **191/191 tests passed** (100%)
    - `flutter analyze --no-fatal-infos`: **0 errors, 0 warnings**


- [x] **Credit Card Closing Day & Payment Due Date Editing Feature (4 ต.ค. 2026)**:
  - **1. เพิ่มฟังก์ชันอัปเดตใน AccountsDao (`accounts_dao.dart`)**:
    - เพิ่มเมธอด `updateCreditCardDetails({id, name, closingDay, dueDay, creditLimitSatang})`
  - **2. สร้าง EditCreditCardDialog (`edit_credit_card_dialog.dart`)**:
    - รองรับการแก้ไขชื่อบัตร, วันตัดรอบบิล (1-31), วันครบกำหนดชำระ (1-31), และวงเงินบัตรเครดิต
    - มีระบบ Validate ป้องกันการกรอกตัวเลขผิดพลาด
    - กล่องพรีวิวสรุปรอบบิลแบบ Realtime แสดงคำอธิบายรอบบิลและวันชำระเงินของเดือนถัดไปอย่างชัดเจน
    - รองรับดีไซน์ทั้งธีม VAULT และ Lumi
  - **3. เชื่อมต่อใน CreditCardSummaryScreen & AccountsScreen**:
    - `CreditCardSummaryScreen`: เพิ่มปุ่มแก้ไขใน AppBar และปุ่มแก้ไขในแบนเนอร์รอบบิลปัจจุบัน แตะแล้วคำนวณรอบบิลและวันนับถอยหลังใหม่ทันที
    - `AccountsScreen`: อัปเดตซับไตเติลให้แสดงทั้งวันตัดรอบและวันครบกำหนดชำระ พร้อมเปิด Dialog แก้ไขบัตรเครดิตเต็มรูปแบบเมื่อกดแก้ไข
  - **4. การทดสอบและการรับรองคุณภาพ**:
    - เพิ่ม Unit Test ใน `credit_card_engine_test.dart` ทดสอบการแก้ไขรอบบิลแล้วคำนวณใหม่ถูกต้อง 100%
    - `flutter analyze --no-fatal-infos`: **0 errors, 0 warnings**
    - `flutter test`: ผ่านทั้งหมด **191/191 tests passed** (100%)
    - `flutter build web`: คอมไพล์และอัปเดตไฟล์ใน `docs/` เรียบร้อย

- [x] **Safari iOS Bottom Navigation Coordinate Mapping & Full-Height Hitbox Fix (3 ต.ค. 2026)**:
  - **1. แก้ปัญหาพิกัดแตะเพี้ยน (Touch Offset) บน iOS Safari (`index.html`)**:
    - **สาเหตุรากฐาน**: บน Safari iOS เมื่อใช้ `viewport-fit=cover` และหน้าเว็บเกิดการเลื่อนหลุด (Rubber-band bounce หรือ Scroll) แม้เพียงเล็กน้อย `window.scrollY` หรือ `visualViewport.offsetTop` จะไม่เป็น 0 ทำให้พิกัดการแตะของ WebKit เลื่อนลงด้านล่าง ผู้ใช้จึงต้องกด "เหนือปุ่ม" จึงจะโดนปุ่ม
    - **การแก้ไข**:
      1. กำหนด `position: fixed; top: 0; left: 0; right: 0; bottom: 0; overscroll-behavior: none; -webkit-overflow-scrolling: auto;` ใน CSS เพื่อล็อกให้ Root Window ไม่เลื่อนหลุดเด็ดขาด
      2. เพิ่ม `interactive-widget=resizes-content` ใน Meta Viewport
      3. เพิ่ม JavaScript Listener ตรวจจับ `scroll` และ `visualViewport.scroll` ให้ดึง `window.scrollTo(0, 0)` ทันที พิกัดแตะจึงตรงกับตำแหน่งที่แสดงบนจอ 100%
  - **2. ขยาย Hitbox ครอบคลุมทั้งความสูงของแถบเมนู (`main_shell.dart`)**:
    - ปรับ `_buildNavItem` และปุ่มกลาง (+) ให้ `GestureDetector(behavior: HitTestBehavior.opaque)` ครอบคลุมพื้นที่เต็มความสูง (`height: 64 + safeBottom`, รวมพื้นที่ด้านล่าง ~86-98pt) และเต็มความกว้างของแต่ละคอลัมน์ (Expanded)
    - ใส่ `color: Colors.transparent` เพื่อสร้าง Render Target ที่สมบูรณ์ ไม่ว่าผู้ใช้จะแตะโดนตัวไอคอน, ตัวอักษร, หรือบริเวณด้านบน/ล่างของแถบเมนู ก็จะทำงานทันที 100% ไม่มี Dead Zone
  - **3. การทดสอบและการรับรองคุณภาพ**:
    - `flutter analyze --no-fatal-infos`: **0 errors, 0 warnings**
    - `flutter test`: ผ่านทั้งหมด **190/190 tests passed** (100%)
    - `flutter build web`: คอมไพล์และอัปเดตไฟล์ใน `docs/` เรียบร้อย

- [x] **Partner Gifting Edition (Pealpeal) & iPhone 14 Pro Onboarding Experience (3 ต.ค. 2026)**:
  - **1. ระบบ Smart Gift Link ตรวจจับพารามิเตอร์อัตโนมัติ (`main.dart`)**:
    - รองรับ URL พารามิเตอร์ เช่น `?to=Pealpeal&preset=lumi_en` หรือ `?to=Pealpeal`
    - เมื่อภรรยาแตะเปิดลิงก์ ระบบจะตั้งค่าเฉพาะเครื่อง iPhone ของเธออัตโนมัติทันที:
      - ภาษา: **English (EN)**
      - สไตล์ดีไซน์: **Lumi (Sunny Bloom Pastel)**
      - ธีมสี: **Follow System (สว่าง/มืดตามการตั้งค่าของ iOS)**
      - บันทึกชื่อ *"Pealpeal"* ลงใน SharedPreferences ประจำเครื่องของเธอ โดยไม่ส่งผลกระทบใดๆ ต่อเครื่อง PC หรือ Android ของคุณ 100%
  - **2. Interactive Welcome & Mini Tutorial Dialog (`partner_welcome_tutorial_dialog.dart`)**:
    - สร้างหน้าต่างต้อนรับสุดประทับใจสไตล์พาสเทล Lumi พร้อมลูกเล่น Carousel 4 สไลด์:
      - **Slide 1 — Welcome, Pealpeal 💕**: ข้อความต้อนรับสุดอบอุ่น สร้างขึ้นด้วยความรัก พร้อมการันตีความปลอดภัยของสมุดบัญชีส่วนตัว 100%
      - **Slide 2 — Gentle & Uplifting Design 🌸**: แนะนำดีไซน์ Sunny Bloom เน้นความสบายตา สดใส เรียบง่าย และสบายใจในทุกๆ วัน
      - **Slide 3 — Effortless Daily Moments ☕**: แนะนำปุ่ม (+) บันทึกค่ากาแฟ ช้อปปิ้ง หรือช่วงเวลาดีๆ ใน 3 วินาที
      - **Slide 4 — Add to Your Home Screen 📱**: แนะนำขั้นตอนกดปุ่ม Share (📤) และ "Add to Home Screen" (➕) ใน Safari เพื่อให้ใช้งานได้เสมือน Native iOS App เต็มหน้าจอ ไร้ URL Bar
    - รองรับการกด Skip เพื่อเข้าใช้งานทันที และปุ่มเปิดดูซ้ำได้จากหน้า Settings ("App Tour & Guide 🌸")
  - **3. ปกป้องความสมบูรณ์แบบบน iPhone 14 Pro & Dynamic Island**:
    - ตรวจสอบ Safe Area ด้านบน (54 pt) ไม่ให้ Dynamic Island บดบังเนื้อหาหรือปุ่ม
    - ตรวจสอบ Safe Area ด้านล่าง (34 pt) และเผื่อระยะห่าง 80 pt ในหน้าจอหลัก ป้องกันไม่ให้แถบ Home Indicator หรือปุ่มลอยทับซ้อนรายการ
    - ป้องกันปัญหาข้อความล้น (RenderFlex Overflow) ด้วย `Wrap` และ `Flexible` ในทุกองค์ประกอบ
  - **4. การทดสอบและการรับรองคุณภาพ**:
    - เพิ่ม Unit & Widget Test: `test/features/partner_welcome_tutorial_test.dart`
    - `flutter test`: ผ่านทั้งหมด **190/190 tests passed** (100%)
    - `flutter analyze --no-fatal-infos`: **0 errors, 0 warnings**
    - `flutter build web`: คอมไพล์ผ่านสมบูรณ์ และคัดลอกไฟล์ขึ้น `docs/` สำหรับ GitHub Pages เรียบร้อย

- [x] **Master Cloud Sync Reliability & Accrued Income Date Preservation (3 ต.ค. 2026)**:
  - **1. แก้ไขปัญหาวันที่ของรายการ Accrued Income เลื่อนเพี้ยนเอง (`app_database.dart`)**:
    - **สาเหตุรากฐาน**: ฟังก์ชัน legacy `alignIncomeDatesWithWorkPeriod()` ใน `beforeOpen` ของฐานข้อมูล บังคับเขียนทับ `transactionDate` ให้ตรงกับเดือนของ `workPeriod` ทุกครั้งที่เปิดแอป ทำให้รายการที่สร้างวันที่ 3/10/2026 โดยระบุรอบผลงาน 2026-09 ถูกย้ายไปเป็น 3/9/2026 โดยอัตโนมัติ
    - **การแก้ไข**: ถอด `alignIncomeDatesWithWorkPeriod()` และ `cleanDistortedNotionNotes()` ออกจาก `beforeOpen` อย่างถาวร ส่งผลให้ `transactionDate` คงที่ตามที่ผู้ใช้บันทึกจริง 100% ไม่ถูกดัดแปลงอีกต่อไป
  - **2. แก้ไขระบบ Master Cloud Sync ซิงค์การจัดเรียง Category, Budget, สินทรัพย์ลงทุน และ Recurring Rules ไม่ติด (`sync_service.dart`)**:
    - **สาเหตุรากฐานของ Master Snapshot**: ใน `_pushMasterSnapshot()` มีการบันทึกสำรอง Master Snapshot (บีบอัด GZip 25 ตาราง) ลงในตาราง fallback `projects` โดยส่งคอลัมน์ `target_budget_satang`, `icon`, `color`, `is_active` ซึ่งไม่มีอยู่จริงใน Supabase ทำให้ Supabase ปฏิเสธด้วย error 400 ส่งผลให้ Master Snapshot ไม่เคยถูกบันทึกขึ้น Cloud สำเร็จ
    - **สาเหตุรากฐานของ Relational Fallback**: เมื่อไม่มี Master Snapshot มือถือจะสลับไปดึงข้อมูลรายตาราง แต่ก่อนดึงข้อมูล ฟังก์ชันซิงค์กลับทำการ Push ค่า Default จากมือถือขึ้นไปทับบน Supabase ก่อน และฟังก์ชัน `_syncBudgets`, `_syncAssets`, `_syncRecurring` ส่งคอลัมน์ที่ไม่ตรงกับสกีมาบน Supabase จนเกิด error 400
    - **การแก้ไข**:
      1. ปรับ `_pushMasterSnapshot()` ให้ส่งเฉพาะคอลัมน์ที่มีอยู่จริงบนตาราง `projects` ใน Supabase (`id`, `user_id`, `name`, `description`, `start_date`, `end_date`, `created_at`, `updated_at`) ทำให้ Master Snapshot ขนาด ~150-250 KB ถูกจัดเก็บและเรียกคืนทั้ง 25 ตารางได้อย่างสมบูรณ์แบบ 100%
      2. ปรับปรุง `getMasterSnapshotInfo()` ให้อ่านข้อมูลสรุป (ชื่อเครื่อง, เวลา, ขนาด, จำนวนรายการ) จากคอลัมน์จริงอย่างถูกต้อง
      3. เพิ่มกลไก `pullOnly: true` ให้กับ `pullMasterSnapshotFromCloud()` และฟังก์ชันย่อยทั้ง 10 ตาราง เพื่อรับประกันว่าการกดดาวน์โหลดข้อมูลจากคลาวด์จะไม่ส่งข้อมูลจากเครื่องปลายทางขึ้นไปทับคลาวด์เด็ดขาด
      4. ปรับ Payload ของ `_syncBudgets`, `_syncAssets`, `_syncRecurring`, `_syncProjects` ให้ตรงกับคอลัมน์จริงบน Supabase เพื่อให้ทั้ง Master Snapshot และ Relational Delta Sync ทำงานผ่านได้ราบรื่น 100%
  - **3. การทดสอบและการรับรองคุณภาพ**:
    - `flutter test`: ผ่านทั้งหมด **188/188 tests passed** (100%)
    - `flutter analyze --no-fatal-infos`: **0 errors, 0 warnings**
    - `flutter build web`: คอมไพล์ผ่านสมบูรณ์ และคัดลอกไฟล์ขึ้น `docs/` สำหรับ GitHub Pages เรียบร้อย

- [x] **Full Cloud Sync Engine, Debt Registry Auto-Pay & Reactive Refresh, Investment Trade Inspection, Cross-Currency Transfer & Accrued WorkPeriod Edit (3 ต.ค. 2026)**:
  - **1. แก้ไขและยกระดับระบบ Cloud Sync ให้แม่นยำ 100% (`sync_service.dart`)**:
    - **Timezone Delta Query Fix**: แก้ไข Query ดึงข้อมูล 10 ตารางใน Supabase ให้ส่งค่า `lastSync.toUtc().toIso8601String()` แทน Local Time ป้องกันการเปรียบเทียบผิดเพี้ยนจาก Timezone Offset +07:00 ที่ทำให้ Quick Sync มองข้ามรายการใหม่
    - **Master Pull Lock Guard Fix**: ปรับ `pullMasterSnapshotFromCloud` ให้สั่งรัน `_executeFullSync(userId, forceFullSync: true)` โดยตรง ไม่ถูกบล็อกค้างจากสถานะ `SyncStatus.syncing` ทำให้การดาวน์โหลด Master Snapshot ลงมือถือทำงานได้ทันที 100%
  - **2. คลีนหน้าจอสุขภาพการเงิน (`financial_health_screen.dart`)**:
    - นำปุ่มไอคอนรูปโล่ (ทะเบียนหนี้สินและประกัน) ที่มุมขวาบน และการ์ดเมนูด้านล่างสุดออกตามคำขอ
  - **3. ทะเบียนหนี้สิน: อัปเดตทันที, ปุ่มชำระค่างวด, และผูกตัดบัญชีอัตโนมัติ (`liabilities_insurance_screen.dart`, `liability_form_dialog.dart`)**:
    - แปลง `_LiabilitiesTab` ให้รองรับ Reactive Reload ทันทีเมื่อสร้าง/แก้ไข/ลบ โดยไม่ต้องออกจากหน้าจอแล้วเข้าใหม่
    - เพิ่มปุ่ม `[ 💳 บันทึกชำระค่างวด ]` ในการ์ดหนี้สินแต่ละรายการ พร้อม Dialog เลือกบัญชีที่ตัดเงิน, วันที่, และตัดยอดหนี้คงเหลืออัตโนมัติ
    - เพิ่มตัวเลือก "วันที่ครบกำหนดชำระรายเดือน (1-31)" และสวิตช์ "ตัดจ่ายอัตโนมัติรายเดือน (Auto-pay)" เชื่อมกับ Recurring Engine อัตโนมัติ
  - **4. รายการซื้อขายสินทรัพย์ลงทุนในหน้าการเงิน (`transaction_list_screen.dart`)**:
    - เปลี่ยนการกดที่รายการซื้อขายสินทรัพย์ในหน้ารายการการเงิน เป็นหน้าต่างตรวจสอบข้อมูล (Read-Only Trade Inspection Dialog) ป้องกันการแก้ตัวเลขต้นทุน/จำนวนหน่วย/ค่าธรรมเนียมจนกระทบ FIFO
    - เพิ่มปุ่มนำทางไปยัง "พอร์ตการลงทุน" และปุ่ม "ลบรายการ" ที่เชื่อมต่อกับ `handleInvestmentTransactionDeleted()` และคำนวณ FIFO ใหม่แบบสมบูรณ์
  - **5. การส่งออกรายงาน PDF รองรับทุกแพลตฟอร์ม (`export_pdf_service.dart`, `reports_screen.dart`)**:
    - เขียนฟังก์ชันสร้าง PDF Bytes และใช้ `Printing.layoutPdf` / `Printing.sharePdf` ทำงานได้ลื่นไหลทั้งบน Web, Windows Desktop และ Android โดยไม่มีปัญหา `dart:io File` crash
  - **6. แก้ไขข้อความหัวข้อในธีม VAULT (`vault_home_screen.dart`)**:
    - ปรับ Subtitle ให้กระชับเหลือเฉพาะ `เดือน ปี` (เช่น "ตุลาคม 2026") ป้องกันข้อความยาวจนโดนตัดทอนบนหน้าจอมือถือ
  - **7. ซ่อน System Tags และปกป้องไม่ให้ถูกลบ (`transaction_list_screen.dart`, `edit_transaction_dialog.dart`)**:
    - ซ่อน System Tags (เช่น `investment_buy:`, `investment_sell:`, `investment_income:`, `project:`, `policy:`, `debt_payment:`) จากป้าย Tag Badges และช่องกรอก Tag ในหน้าแก้ไข เพื่อให้ UI สะอาดตา และคงค่าเดิมไว้เสมอเมื่อบันทึก
  - **8. แก้ไขรายการ Accrued Income ในหน้า Transaction (`edit_transaction_dialog.dart`)**:
    - เพิ่มแถบเลือกรอบเดือนของผลงาน (Accrued Work Period) พร้อมป้ายชื่อเดือนภาษาไทย (เช่น `รายได้ ก.ย. 2026`) ที่อัปเดต Tag อัตโนมัติ
    - เพิ่มป้ายและปุ่ม `[ 💰 รับแล้ว ]` สำหรับรายการที่ยังค้างรับ เพื่อบันทึกว่าได้รับเงินเข้าบัญชีจริงแล้ว
  - **9. แก้ไขการโอนเงินข้ามสกุลเงิน (Dual-Amount Cross-Currency Transfer) (`edit_transaction_dialog.dart`)**:
    - รองรับการกรอกทั้งยอดเงินต้นทางและยอดเงินปลายทาง พร้อมแสดงอัตราแลกเปลี่ยนคำนวณสด (`1 USD ≈ xx.xxxx THB`) บันทึก `amountOriginalSatang`, `amountThbSatang` และ `fxRate` แม่นยำตามกฎการเงิน
  - **10. การทดสอบและการรับรองคุณภาพ**:
    - `flutter test`: ผ่านทั้งหมด **188/188 tests passed** (100%)
    - `flutter analyze`: **0 errors, 0 warnings**
    - `flutter build web`: คอมไพล์ผ่านสมบูรณ์ และคัดลอกไฟล์ไปยัง `docs/` สำหรับ GitHub Pages เรียบร้อย


- [x] **Budget Title Cleanup, Financial Position Clean Layout, Monthly Summary via Expense Trend & Accrued Income Month Tagging (3 ต.ค. 2026)**:
  - **1. ลบคำว่า "ไม่ Rollover" ในหน้า Budget (`budget_screen.dart`, `app_th.arb`, `app_en.arb`)**:
    - ปรับข้อความหัวข้อจาก `สรุปงบประมาณรวมเดือนนี้ 🌸 (ไม่ Rollover)` เป็น **`สรุปงบประมาณรวมเดือนนี้ 🌸`** ให้สะอาดตา ไม่รบกวนการอ่าน
  - **2. คลีนการ์ด Financial Position ในโหมด Lumi (`financial_overview_card.dart`)**:
    - ลบกรอบ Mini Metrics ย่อย 3 ช่องด้านล่าง (รายรับเดือนนี้, รายจ่ายเดือนนี้, กระแสเงินสด) ออกตามคำขอ ทำให้การ์ดกะทัดรัด โฟกัสเฉพาะความมั่งคั่งสุทธิและหมวดหมู่สินทรัพย์ 4 ด้าน
  - **3. ย้ายปุ่มดูรายงานสรุปรายเดือนไปยังหัวข้อกราฟรายจ่าย (`ExpenseTrendProjectionCard`)**:
    - ลบปุ่ม "ดูรายงานรายเดือน" และ "ดูทั้งหมด ›" ออกจาก Financial Position ทั้งธีม VAULT และ Lumi
    - ปรับหัวข้อกราฟให้กระชับขึ้นจาก "แนวโน้มและคาดการณ์รายจ่าย" เป็น **`แนวโน้มรายจ่าย`** แก้ปัญหาข้อความยาวจนโดนตัดคำบนมือถือ
    - หัวข้อการ์ดกราฟสามารถแตะ (Tappable) เพื่อเปิดหน้ารายงานสรุปรายเดือน (`MonthlySummaryScreen`) ได้ทันที
  - **4. ติด Tag รอบเดือนให้กับรายการรายรับ Accrued Income ย้อนหลังและอัตโนมัติ**:
    - เพิ่มฟังก์ชัน `formatPeriodToTag()` แปลงรอบเดือน เช่น `2026-09` เป็น Tag ที่อ่านเข้าใจง่าย เช่น **`รายได้ ก.ย. 2026`**
    - เมื่อบันทึกรับเงิน (`markIncomeAsReceived`) หรือสร้างรายการค้างรับใหม่ ระบบจะติด Tag รอบเดือนในคอลัมน์ `tag` ให้อัตโนมัติ
    - เพิ่มระบบ Backfill `autoTagExistingAccruedIncomes()` เติม Tag ให้กับรายการค้างรับเดิมทั้งหมดในฐานข้อมูล
    - ในหน้ารายการธุรกรรม (`TransactionListScreen`) แสดงป้ายกำกับสีม่วง **`รายได้รอบ ก.ย. 2026`** สำหรับรายการที่ได้รับเงินแล้ว และค้นหาด้วยรอบเดือนหรือ Tag ได้ทันที
  - **5. การทดสอบและการรับรองคุณภาพ**:
    - `flutter test`: ผ่านทั้งหมด **186/186 tests passed** (100%)
    - `flutter analyze`: **0 errors, 0 warnings** (ในโค้ดแอป)
    - `flutter build web`: คอมไพล์ผ่านสมบูรณ์

- [x] **Cloud Restore Dual-Engine, Compact Sync Icon, Recurring 2-Row Layout, Lumi Accrued Breakdown & Expense Trend Projection (3 ต.ค. 2026)**:
  - **1. แก้ปัญหาดึงข้อมูลคลาวด์ไม่พบข้อมูล (Cloud Pull / Dual-Engine Restore)**:
    - ปรับปรุง `pullMasterSnapshotFromCloud()` ใน `SyncService` ให้เป็น Dual-Engine Restore: หากไม่มี blob table `cloud_vault_backup` ให้สลับไปดึงข้อมูลรายตาราง (`transactions`, `accounts`, `categories`, `budgets`, `assets`, `recurring_rules`) ผ่าน Full Sync อัตโนมัติ ป้องกันปัญหา "ไม่มีข้อมูลบนคลาวด์"
    - ปรับปรุง `getMasterSnapshotInfo()` ให้ดึงสถานะจาก `sync_device_state` เมื่อไม่มี snapshot metadata เพื่อแสดงจำนวนรายการบนคลาวด์ได้แม่นยำ
  - **2. ปรับปุ่ม Sync ให้กะทัดรัด & แก้เลข 2 บนกระดิ่งแจ้งเตือนไม่หาย**:
    - ปรับปุ่มซิงค์บน AppBar ให้เหลือเฉพาะไอคอนรูปก้อนเมฆขนาด 36x36 พร้อมจุดสถานะสี (เขียว/น้ำเงินหมุน/ส้ม/แดง) ไม่เกะกะสายตา พร้อม Tooltip แสดงรายละเอียดเมื่อแตะค้าง
    - แก้ไขปุ่ม "รับทราบแล้ว" (Mark read) ในหน้าต่างแจ้งเตือน ให้บันทึกเวลา acknowledgment ล่วงหน้า ทำให้ตัวเลขแบดจ์ 2 หายไปเป็น 0 ทันที
  - **3. แก้ปัญหาตัวเลขและข้อความถูกตัดทอน (No Text Overflow)**:
    - **หน้า Home (Financial Position)**: ปรับการแสดงผล 4 หมวด (เงินสด/เงินฝาก, พอร์ตลงทุน, เงินค้างรับ, สะสมประกัน) เป็น Grid 2x2 พร้อมตัวเลขแบบ Tabular และ `FittedBox` เห็นตัวเลขเต็มจำนวน ไม่ถูกตัด `...`
    - **หน้า Recurring Rules**: ปรับ Card กฎรายการประจำจาก 1 แถวยาว เป็น **2 แถวชัดเจน**:
      - แถวบน: ไอคอนประเภท + ชื่อรายการเต็ม (รองรับสูงสุด 2 บรรทัด) + ยอดเงินตัวใหญ่
      - แถวล่าง: ป้ายสถานะ Auto/รอยืนยัน + ความถี่และรอบถัดไป + ปุ่มทำรายการ + สวิตช์เปิด/ปิด + เมนู 3 จุด
  - **4. เพิ่มรายละเอียดเงินค้างรับและลิงก์นำทางในโหมด Lumi (`FinancialOverviewCard`)**:
    - เพิ่มแผ่นการ์ดสัดส่วน 4 ด้าน (เงินสด/เงินฝาก, พอร์ตลงทุน, เงินค้างรับ พร้อมจำนวนรายการ, สะสมประกัน) ในโทนสีพาสเทล
    - รองรับการกดแตะเพื่อกระโดดไปยังหน้าจัดการของแต่ละส่วนได้ทันที (คลิกเงินค้างรับ $\rightarrow$ ไปหน้ารายรับค้างตกเบิก, คลิกสะสมประกัน $\rightarrow$ ไปหน้ากรมธรรม์ประกัน)
  - **5. กราฟแนวโน้มรายจ่ายและเส้นคาดการณ์สิ้นเดือนใต้ Master Budget (`ExpenseTrendProjectionCard`)**:
    - แสดงกราฟเส้น (Line Chart) แสดงยอดค่าใช้จ่ายสะสมจริงตั้งแต่วันที่ 1 จนถึงวันปัจจุบัน
    - คำนวณอัตราเผาผลาญเฉลี่ยต่อวัน (Burn Rate / Daily Average) แล้ววาดเส้นประคาดการณ์ (Projected Line) ต่อไปจนถึงสิ้นเดือน
    - แสดงเส้นเพดานงบประมาณ (Budget Limit Ceiling) พร้อมป้ายสถานะเตือนสีแดงหากมีแนวโน้มใช้จ่ายเกินงบ หรือสีเขียวหากอยู่ในเกณฑ์ปลอดภัย
  - **6. การทดสอบและการรับรองคุณภาพ**:
    - `flutter test`: ผ่านทั้งหมด **186/186 tests passed** (100%)
    - `flutter analyze`: **0 errors, 0 warnings** (ในโค้ดแอป)
    - คอมไพล์ Web Release อัปเดตโฟลเดอร์ `docs/` สำหรับ GitHub Pages เรียบร้อย

- [x] **Notification Order, Backup Date Clarification, Timezone Consistency & Quick Add Date Selector (3 ต.ค. 2026)**:
  - **1. สลับลำดับหน้าต่างแจ้งเตือน (Notification Sheet Reorder)**:
    - ปรับให้ **"รายการประจำที่บันทึกแล้วล่าสุด"** ขึ้นมาแสดงเป็นส่วนแรก เพื่อให้ผู้ใช้ตรวจเช็กรายการที่ระบบเพิ่งลงให้ได้ทันที
    - นำ **"รายการที่จะมาถึงใน 7 วันข้างหน้า"** มาแสดงเป็นส่วนที่สอง พร้อมปุ่มแก้ไขและลงบัญชีล่วงหน้า (Early Post)
  - **2. ปรับข้อความและแสดงเวลาของไฟล์สำรองในหน้าพรีวิว (`BackupRestoreScreen`)**:
    - สกัดวันเวลาที่สร้างไฟล์จริงจากชื่อไฟล์ (เช่น `myfinance_backup_20261003_1456.db` $\rightarrow$ 3 ต.ค. 2026, 14:56 น.) และแสดงเป็น **"เวลาที่สร้างไฟล์สำรอง"**
    - เปลี่ยนป้าย "บันทึกล่าสุด" เป็น **"รายการธุรกรรมล่าสุดในไฟล์"** พร้อมคำอธิบายย่อยชัดเจน ไม่ทำให้สับสนระหว่างเวลาไฟล์กับเวลาธุรกรรม
  - **3. แก้ปัญหา Timezone และการปัดเศษวันที่เลื่อน (Timezone Consistency & Grouping)**:
    - แก้ไข `sqlite_reader_web.dart` และ `sqlite_reader_native.dart` ให้แปลงเวลาจาก UTC epoch เป็น Local Time อย่างถูกต้อง
    - แก้ไข `sync_service.dart` ให้ส่งออกเวลาในรูปแบบ UTC ชัดเจน และแปลงกลับเป็น Local Time เมื่อดึงข้อมูลลงเครื่อง ป้องกันปัญหาเวลาเลื่อนไปข้างหน้า +7 ชม.
    - แก้ไข `TransactionListScreen` และ `AccountDetailScreen` ให้แปลงเป็น Local Time ก่อนจัดกลุ่มวัน ทำให้รายการไม่กระโดดข้ามวัน
  - **4. เพิ่มแถบเลือกวันที่ทำรายการในหน้า Quick Add (`QuickAddScreen`)**:
    - เพิ่มแถบชิปเลือกวันที่: `[ วันนี้ | เมื่อวาน | ระบุวันที่... ]` ใต้แถบเลือกประเภทรายการ
    - ผู้ใช้สามารถเห็นวันที่ที่จะบันทึกได้อย่างชัดเจน และเลือกย้อนหลังได้ทันที ไม่ต้องกลัวรายการถูกบันทึกผิดวัน
  - **5. การทดสอบและการรับรองคุณภาพ**:
    - `flutter test`: ผ่านทั้งหมด **186/186 tests passed** (100%)
    - `flutter analyze`: **0 errors, 0 warnings** (ในโค้ดแอป)
    - คอมไพล์ Web Release อัปเดตโฟลเดอร์ `docs/` เรียบร้อย

- [x] **UI/UX Refinements: Recurring Dark Mode Contrast, Bell Notifications & 7-Day Early Post, Cascade Category Filter, Credit Badge & Account Month Navigator (3 ต.ค. 2026)**:
  - **1. ปรับปรุงสีสถานะ "รอยืนยัน" ในหน้า Recurring Rules (`RecurringRulesScreen`)**:
    - แก้ไขปัญหาตัวอักษรสีน้ำตาลเข้มกลืนกับพื้นหลังในโหมดมืด (Dark Mode)
    - ปรับเป็นสีเหลืองอำพันสว่าง (`Colors.amber.shade300`) พร้อมพื้นหลังโปร่งแสงที่อ่านง่ายและชัดเจนในโหมดมืด และคงสีที่สบายตาในโหมดสว่าง
    - ปรับป้าย "Auto" ให้ใช้ `Colors.greenAccent` ในโหมดมืด และ `Colors.green.shade800` ในโหมดสว่าง
  - **2. ระบบเคลียร์ตัวเลข Notification บนกระดิ่งเมื่อกดรับทราบ (`VaultHomeScreen`)**:
    - ปรับปรุงการบันทึกเวลาที่กดรับทราบ (`last_read_recurring_notification_time`) โดยใช้เวลามาตรฐานสากล UTC ที่แม่นยำ
    - เมื่อผู้ใช้กด "รับทราบแล้ว" (Mark read) ระบบจะลบตัวเลขแจ้งเตือนสีแดงบนกระดิ่งออกทันทีแบบเรียลไทม์
  - **3. แสดงรายการ Recurring ใน 7 วันข้างหน้า + ฟังก์ชันแก้ไขและบันทึกล่วงหน้า**:
    - หน้าต่างแจ้งเตือน 🔔 แบ่งเป็น 2 ส่วนชัดเจน:
      1. 🕒 **"รายการที่จะมาถึงใน 7 วันข้างหน้า"**: แสดงรายการประจำที่จะถึงกำหนดตัดใน 7 วัน พร้อมบอกจำนวนวันนับถอยหลัง, บัญชี, และยอดเงิน
      2. ✅ **"รายการประจำที่บันทึกแล้วล่าสุด"**: แสดงประวัติรายการประจำที่ระบบบันทึกแล้ว
    - **Early Post & Customization**: ผู้ใช้สามารถแตะที่รายการใน 7 วันข้างหน้า เพื่อเปิดหน้าต่างแก้ไข (ปรับยอดเงินจริง, วันที่ทำรายการ, บันทึกย่อ) และกด **"บันทึกลงบัญชีทันที"**
    - ระบบจะบันทึก Transaction ลงบัญชีทันที และคำนวณเลื่อนรอบถัดไป (`nextRunDate`) ของกฎนั้นข้ามไปรอบหน้า ทำให้เมื่อถึงวันตามกำหนดเดิมในเดือนนั้น ระบบจะไม่บันทึกซ้ำ
  - **4. ตัวกรองหน้า Transaction คัดกรองประเภทก่อนเลือกหมวดหมู่ (`TransactionListScreen`)**:
    - ในหน้าต่างตัวกรอง (Filter) เพิ่มแถบเลือกประเภทรายการก่อน: `[ ทั้งหมด | รายจ่าย | รายรับ | โอนเงิน ]`
    - ช่องเลือกหมวดหมู่จะแสดงเฉพาะหมวดหมู่ที่ตรงกับประเภทที่เลือก (เช่น เลือก "รายจ่าย" จะมีเฉพาะหมวดหมู่รายจ่าย)
    - หากเลือก "โอนเงิน" ระบบจะแจ้งว่าการโอนเงินไม่มีหมวดหมู่ ป้องกันความสับสน
  - **5. ป้ายกำกับ 💳 Credit สำหรับรายการที่จ่ายด้วยบัตรเครดิต (`TransactionListScreen`)**:
    - ในรายการธุรกรรม หากรายการนั้นจ่ายผ่านบัญชีประเภทบัตรเครดิต (`credit_card`) จะมีป้ายสีฟ้าอ่อน `[💳 <ชื่อบัตร/บัตรเครดิต>]` ปรากฏอยู่ใต้ชื่อรายการอย่างชัดเจน
  - **6. หน้ารายละเอียดบัญชีแสดงเฉพาะเดือนปัจจุบัน + Month Navigator (`AccountDetailScreen`)**:
    - ตั้งค่าเริ่มต้นให้แสดงเฉพาะรายการธุรกรรมของ **เดือนปัจจุบัน**
    - เพิ่มแถบควบคุมช่วงเวลา (Month Navigator): ปุ่มเลื่อนเดือนก่อนหน้า ◀, ชื่อเดือน/ปี, ปุ่มเดือนถัดไป ▶, ปุ่มปฏิทินสำหรับเลือกช่วงวันที่เอง (Custom Date Range) และปุ่มย้อนกลับมาเดือนปัจจุบัน
    - แสดงสรุปยอดเงินเข้า (+฿) และเงินออก (-฿) ของบัญชีนั้นตามช่วงเวลาที่เลือก
  - **7. การทดสอบและการรับรองคุณภาพ**:
    - เพิ่ม Unit Test ใน `test/features/recurring_engine_test.dart` เพื่อทดสอบว่า Early Posting เลื่อนรอบถัดไปและป้องกันการลงซ้ำในวันกำหนดการจริง
    - `flutter test`: ผ่านทั้งหมด **185/185 tests passed** (100%)
    - `flutter analyze`: **0 errors, 0 warnings** (ในโค้ดแอป)
    - คอมไพล์ Web Release อัปเดตโฟลเดอร์ `docs/` สำหรับ GitHub Pages เรียบร้อย

- [x] **Cloud Sync UI Streamlining, Settings Cleanup, Recurring Compact Redesign, Home Financial Position & Category/Budget Navigation (3 ต.ค. 2026)**:
  - **1. จัดระเบียบปุ่มคลาวด์และตำแหน่งสถานะ Sync**:
    - ลบปุ่ม "Sync All Data" ออกจากระบบอย่างสมบูรณ์
    - ปรับปุ่มจัดการคลาวด์ใน `BackupRestoreScreen` และ Bottom Sheet ของ `SyncStatusWidget` เหลือ 3 ปุ่มหลักที่ใช้งานง่าย:
      1. 🚀 Master push (upload) — อัปโหลด Master ขึ้นคลาวด์แทนที่ 100%
      2. 📥 Download master data — ดาวน์โหลด Master จากคลาวด์แทนที่เครื่องนี้ 100%
      3. 🚪 Log out — ออกจากระบบคลาวด์
    - ย้ายปุ่มสถานะ Sync ออกจากปุ่มลอยใน `MainShell` และแถบเมนูพอร์ตลงทุน มาวางเฉพาะในแถบส่วนหัวของหน้า Home (`VaultHomeScreen`) คู่กับกระดิ่งแจ้งเตือนแบบเป็นระเบียบ ไม่บังหรือซ้อนทับกระดิ่ง
  - **2. คลีนหน้า Settings & ประวัติ Import CSV**:
    - หน้า Settings: ลบปุ่ม "ตรวจสอบและฟื้นฟูพอร์ตลงทุน (Dime! USD)" และปุ่ม "ประวัติการนำเข้าและย้อนกลับ (Rollback)" ออกเพื่อความสะอาดตา (เข้าถึงได้จากเมนู Notion Import ตามปกติ)
    - หน้า ประวัติ Import CSV: ลบปุ่มไอคอนไม้กวาด "ล้างรายการลงทุนเดิมที่ตกค้าง" ออกจากแถบเมนูด้านบน
  - **3. ปรับปรุงหน้า Recurring Transactions (`RecurringRulesScreen`)**:
    - เพิ่มแถบ Filter Chips แยกประเภท [ ทั้งหมด | รายจ่าย | รายรับ | โอนเงิน ] พร้อมแสดงจำนวนรายการ
    - ปรับการ์ดรายการให้เล็กลง (Compact Card) ลดความสูงลงกว่า 60% สวยงาม กระชับ มีไอคอนระบุประเภท วันที่รอบถัดไป บัญชี ยอดเงิน สวิตช์เปิด/ปิด และเมนูแก้ไข/ลบ
  - **4. ปรับปรุงหน้า Home (Financial Position & Recent Activity)**:
    - Financial Position Dashboard: ออกแบบใหม่ให้มีไอคอนสวยงามนำหน้าทุกรายการ (เงินสด/เงินฝาก 💵, พอร์ตลงทุน 📈, เงินค้างรับ ⏳, เงินสะสมประกัน 🛡️), นำปุ่มข้อความลิงก์เดิมที่รกออก และฝังลิงก์การแตะลงบนหัวข้อรายการโดยตรง
    - Recent Activity: เพิ่มการแตะ (onTap) ที่รายการธุรกรรมล่าสุดเพื่อเปิดหน้าต่างแก้ไข (Edit Transaction) ได้ทันที ทั้งใน Vault Theme และ Lumi Layout
  - **5. ปรับปรุงหน้า Category & Budget Screen**:
    - หน้า Budget: เมื่อแตะที่ตัวการ์ดหมวดหมู่ จะเปิดหน้าต่างรายการธุรกรรม (`TransactionListScreen`) พร้อมตัวกรองหมวดหมู่และช่วงเวลาของเดือนนั้นทันที, ลบปุ่ม "ลบงบประมาณ" ที่มุมการ์ดออก, และสามารถแตะที่ไอคอนดินสอเพื่อแก้ไขหรือลบงบประมาณได้
    - หน้า หมวดหมู่ (Categories): ลบปุ่มดินสอด้านขวาออก เพื่อไม่ให้ซ้อนทับกับแถบสองขีด (Drag handle) ของ ReorderableListView บน Desktop โดยสามารถกดที่ตัวการ์ดเพื่อแก้ไขได้โดยตรง
  - **6. การทดสอบและการรับรองคุณภาพ**:
    - `flutter test`: ผ่านทั้งหมด **184/184 tests passed** (100%)
    - `flutter analyze`: **0 errors, 0 warnings**
    - คอมไพล์ Web Release อัปเดตโฟลเดอร์ `docs/` สำหรับ GitHub Pages เรียบร้อย

- [x] **Live Drift SQLite Dump Engine for Web & Multi-Device Sync (3 ต.ค. 2026)**:
  - **1. ตรวจสอบต้นตอของไฟล์สำรองค้าง (Stale Backup Root Cause Analysis)**:
    - ตรวจสอบไฟล์ `myfinance_backup_20261003_1024.db` ที่ส่งออกจาก Webapp พบว่าในไฟล์ยังมี GPF, หนี้บัตรเครดิตยังไม่ชำระ, วันที่ล่าสุดหยุดอยู่ที่ 2 ต.ค., `budgets` มี 0 แถว และหมวดหมู่มี `sort_order: 0` ทั้งหมด
    - **สาเหตุจริง**: กลไกเดิมของ Webapp ไปอ่านไฟล์ดิบจาก OPFS (`/drift_db/myfinance_vault/database`) ซึ่งเป็นไฟล์เก่าที่ค้างอยู่ในเบราว์เซอร์ตั้งแต่รอบก่อน ในขณะที่การแก้ไขจริงของผู้ใช้ (ลบ GPF, ชำระหนี้บัตร, เรียงหมวดหมู่, ตั้งงบประมาณ) เกิดขึ้นบนฐานข้อมูล Drift ที่ทำงานอยู่บน Web Worker / IndexedDB แบบเรียลไทม์ ทำให้ไฟล์ที่ดาวน์โหลดออกมาเป็นข้อมูลค้างเก่า
  - **2. พัฒนาระบบ Live Drift Dump to SQLite (`dumpDriftDatabaseToSqliteBytes`)**:
    - สร้างเอนจินสกัดและแปลงฐานข้อมูลสดจากอินสแตนซ์ Drift ที่กำลังทำงานอยู่โดยตรง Query ดึง Schema และข้อมูลทุกแถวจากทุกตาราง (25 ตาราง) รวมถึง Indexes และ Views ทั้งหมด
    - นำเข้าสู่ฐานข้อมูล SQLite Binary ใหม่ในหน่วยความจำ (In-Memory SQLite Wasm) แล้วแปลงเป็นไฟล์ `.db` ที่สมบูรณ์ 100% ภายในเวลาเพียง ~160 ms
    - อัปเดตทั้ง `exportAndShareBackup` และ `downloadBackupDirectly` ใน `BackupRestoreService` ให้ใช้ `dumpDriftDatabaseToSqliteBytes(db)` เป็นหลัก ทำให้ข้อมูลที่ส่งออกจาก Webapp ตรงกับหน้าจอและข้อมูลสดในเครื่องของผู้ใช้ 100% เสมอ
  - **3. การทดสอบและการรับรองคุณภาพ**:
    - `flutter test`: ผ่านทั้งหมด **182/182 tests passed** (100%)
    - `dart analyze lib test`: **0 errors, 0 warnings**
    - คอมไพล์ Web Release อัปเดตโฟลเดอร์ `docs/` เรียบร้อย

- [x] **Credit Transactions Architectural Realignment: Budget Deduction, Liquid Cash & Net Worth Protection (3 ต.ค. 2026)**:
  - **1. ปรับการคำนวณกระแสเงินสด (Liquid Cash) และสินทรัพย์สุทธิ (Net Worth)**:
    - ปรับปรุง `getTotalCashSatang()` ใน `AccountsDao` ให้รวมเฉพาะบัญชีเงินสด/เงินฝากจริงในมือและธนาคาร (SCB, Krungthai, Dime! Save, FCD, USD) โดยคัดกรองบัญชี `credit_card` ออก
    - ส่งผลให้ยอดหนี้บัตรเครดิตที่รอชำระจะไม่ไปลดทอนกระแสเงินสด (Liquid Cash) หรือสินทรัพย์สุทธิ (Net Worth) ของผู้ใช้ จนกว่าจะมีการกดบันทึกชำระหนี้จริง
    - การ์ด "กระแสเงินสด" ในหน้าบัญชีและหน้าแรกแสดงยอดเงินฝากจริงทั้งหมดเต็มจำนวน (**฿364,220.89**) ไม่ถูกหักลบด้วยหนี้บัตรเครดิตค้างจ่ายอีกต่อไป
  - **2. รักษาวินัยการเงินและการตัดงบประมาณ (Budgets)**:
    - รายการรูดบัตรเครดิตทุกรายการยังคงถูกนับเป็นรายจ่ายตามหมวดหมู่เพื่อไปตัดงบประมาณรายเดือน (Budget) และ Master Budget ตามปกติ ทำให้ผู้ใช้ควบคุมการใช้จ่ายได้ครบถ้วน
  - **3. รองรับการชำระหนี้ด้วยตนเองตามรอบบิล**:
    - หนี้บัตรเครดิตยังคงถูกจัดหมวดหมู่แยกตามรอบบิลใน `CreditCardSummaryScreen` ให้ผู้ใช้ตรวจสอบยอดและกด "บันทึกชำระหนี้บัตรเครดิต" ตัดเงินจากบัญชีจริงด้วยตนเองเมื่อพร้อม
  - **4. การทดสอบและการรับรองคุณภาพ**:
    - เพิ่ม Unit Test ใน `test/features/credit_card_engine_test.dart` ทดสอบว่ารายการรูดบัตรตัดงบประมาณจริง, ไม่ลดทอนเงินใน SCB, ไม่ลดทอน Liquid Cash และ Net Worth, และเมื่อกดชำระเงินจริง เงินใน SCB และหนี้บัตรเครดิตถึงจะลดลง
    - `flutter test`: ผ่านทั้งหมด **182/182 tests passed** (100%)
    - `dart analyze lib test`: **0 errors, 0 warnings**
    - คอมไพล์ Web Release อัปเดตโฟลเดอร์ `docs/` สำหรับ GitHub Pages

- [x] **Complete SQLite .db 25-Table Integrity, Historical CC Debt Removal, Quick Startup Sync, UI Redesign & Recurring Notification Center (3 ต.ค. 2026)**:
  - **1. ปรับปรุงระบบสำรอง/กู้คืนไฟล์ SQLite .db ให้สมบูรณ์ 25 ตาราง**:
    - แก้ปัญหา WAL checkpoint บน Web SQLite Wasm ด้วยคำสั่ง `PRAGMA wal_checkpoint(TRUNCATE);` ก่อนส่งออกไฟล์ .db ทำให้ข้อมูลล่าสุดที่ค้างใน memory/WAL ถูกเขียนลงไฟล์ .db จริง 100%
    - ปรับปรุงตัวอ่านและฉีดข้อมูล Drift Table Injection (`sqlite_reader_native`, `sqlite_reader_web`, `backup_restore_service`) ให้อ่านและกู้คืนข้อมูลครบทั้ง 25 ตาราง รวมถึง `budgets`, `categories` (พร้อมลำดับ `sort_order` ทั้งหมด), `recurring_rules`, `projects`, `liabilities`, `credit_card_installments`, `investment_lots`, `investment_sales`, `investment_incomes`, `tax_deductions`
    - กรองตารางระบบ SQLite (`sqlite_sequence`, `sqlite_stat*`) ออก ไม่ให้เกิดข้อผิดพลาดในการกู้คืน
    - อัปเดตหน้าพรีวิวไฟล์สำรอง (`BackupInspectionResult`) ให้แสดงจำนวนกฎรายการประจำ (Recurring Rules) และโครงการพิเศษ (Projects)
  - **2. ลบระบบชำระหนี้ประวัติศาสตร์ของบัตรเครดิตออกอย่างถาวร (Eliminate Historical CC Settle)**:
    - ตัดฟังก์ชัน `settleHistoricalDebt`, `getHistoricalDebtSatang`, `cleanupDuplicateHistoricalSettlements` ออกจาก `CreditCardDao`
    - ตัดแบนเนอร์และปุ่มตัดยอดประวัติศาสตร์ออกจาก `CreditCardSummaryScreen`
    - ตัดการเรียก auto-settle ออกจากตัวนำเข้า Notion (`import_executor.dart`)
    - สร้าง `purgeHistoricalSettlements()` กวาดล้างธุรกรรมประดิษฐ์ `tag = 'historical_settle'` และบันทึกลงในรอบการซิงค์ เพื่อแก้ปัญหาข้อมูลชนกันระหว่าง PC กับมือถือได้อย่างหมดจด
  - **3. เร่งความเร็วการซิงค์ตอนเปิดแอป (Quick Startup Sync) & แก้การ์ด Master Device ล้นจอ**:
    - สร้าง `quickStartupSync()` ซิงค์เฉพาะ delta data ที่อัปเดตล่าสุดตอนเปิดแอปหรือกลับมาต่อเน็ต โดยไม่รันลูป deduplication หนัก ทำให้เปิดแอปได้เร็วทันใจ
    - สงวน `syncAll()` แบบ Full Sync พร้อมกวาดล้างข้อมูลซ้ำไว้สำหรับการกดด้วยตนเองของผู้ใช้
    - ซิงค์ตาราง `projects` และ `credit_card_installments` ขึ้น Supabase พร้อมอัปเดต `supabase_schema.sql` และ RLS policies
    - ซิงค์ `sort_order` ของหมวดหมู่ทั้งหมดทั้งหมวดหมู่ระบบและหมวดหมู่ที่ผู้ใช้สร้างเอง ทำให้ลำดับหมวดหมู่ตรงกันทุกอุปกรณ์
    - แก้ไข UI การ์ด Master Device สีส้มในหน้าสำรองข้อมูล (`backup_restore_screen.dart`) ด้วย `Expanded` และ `FittedBox` ไม่ให้ข้อความหลุดล้นกรอบ
  - **4. ปรับปรุง UI กรมธรรม์ประกัน & การ์ดสถานะทางการเงินหน้าแรก**:
    - ปรับปรุงการ์ดภาพรวมประกัน (`insurance_policies_screen.dart`): ออกแบบด้วย `LayoutBuilder` รองรับหน้าจอมือถือ (แยก 2 แถว จัดเบี้ยประกันและเงินสะสมอยู่แถวบน ทุนประกันรวมอยู่แถวล่างเต็มความกว้าง) พร้อม `FittedBox` ป้องกันปัญหาตัวเลขตัดบรรทัด `00.00`
    - ปรับปรุงการ์ดความมั่งคั่งสุทธิหน้าแรก (`vault_home_screen.dart`): เพิ่ม `Expanded` + `FittedBox(fit: BoxFit.scaleDown)` ป้องกันตัวเลขเงินสดและพอร์ตการลงทุนล้นกรอบการ์ด
    - เพิ่มแถบเข้าถึงด่วนใน 1 คลิก สำหรับ **"เงินค้างรับ / ตกเบิก"** พาไปยังหน้า `AccruedIncomeScreen` ได้ทันที
  - **5. ระบบแจ้งเตือนรายการธุรกรรมประจำอัตโนมัติ (Recurring Notification Center)**:
    - เพิ่มไอคอนกระดิ่งแจ้งเตือนพร้อมจุด Badge สีแดงที่ Header หน้า Home (`vault_home_screen.dart`)
    - กดกระดิ่งเพื่อเปิด Bottom Sheet ดูประวัติรายการธุรกรรมประจำที่ระบบบันทึกให้อัตโนมัติ พร้อมปุ่ม "รับทราบแล้ว"
    - แสดงข้อความ SnackBar แจ้งเตือนทันทีเมื่อเปิดแอปแล้วพบว่าระบบได้บันทึกรายการประจำใหม่
  - **6. การทดสอบและการรับรองคุณภาพ**:
    - สร้าง Unit Test ครอบคลุม: `test/core/backup_restore_integrity_test.dart`
    - `flutter test`: ผ่านทั้งหมด **181/181 tests passed** (100%)
    - `dart analyze lib test`: **0 errors, 0 warnings**

- [x] **Credit Card Auto-Settle Idempotency & Dime! USD Investment Reconciliation (2 ต.ค. 2026)**:
  - **1. แก้ไขปัญหาระบบตัดยอดบัตรเครดิตรอบก่อน 24/8/69 ทำงานซ้ำๆ**:
    - ปรับปรุง `settleHistoricalDebt` ใน `CreditCardDao` ให้เป็นระบบ Idempotent ตรวจจับรายการตัดยอดประวัติศาสตร์เดิม หากเคยตัดยอดแล้วจะไม่ออกรายการใหม่ซ้ำอีก และทำการ Update ยอดหนี้ให้ตรงตามจริงแทนการ Insert เพิ่ม
    - พัฒนาฟังก์ชัน `cleanupDuplicateHistoricalSettlements` กวาดล้างรายการตัดยอด Auto-settle ที่เคยถูกสร้างซ้ำซ้อนในฐานข้อมูลเดิมให้เหลือเพียงรายการเดียวที่ถูกต้อง
    - ปรับปรุงการแจ้งเตือนใน `CreditCardSummaryScreen` ให้แสดงผลถูกต้องและซ่อนแบนเนอร์ทันที
  - **2. แก้ไขและป้องกันรายการซื้อหุ้นใน Dime! USD หายไป**:
    - ปรับปรุง `deduplicateTransactions` ใน `TransactionsDao` ให้คุ้มครองรายการธุรกรรมที่ผูกอยู่กับ `InvestmentLots` ห้ามลบเด็ดขาด พร้อมปรับปรุง signature ของรายการลงทุนให้แยกตามสินทรัพย์, สกุลเงิน และจำนวนเงินต้น
    - ปรับปรุง `NotionInvestImportExecutor` ให้บันทึก Note แยกตามจำนวนหุ้นและราคาอย่างชัดเจน ป้องกันการชนกันของ Signature
    - พัฒนาฟังก์ชัน `auditAndReconcileInvestments()` ใน `InvestmentsDao` ค้นหา Orphan Lots ที่รายการธุรกรรมหายไป และฟื้นฟูกลับเข้าบัญชีแยกประเภทของ Dime! USD อัตโนมัติ
    - เพิ่มเมนู "ตรวจสอบและฟื้นฟูพอร์ตลงทุน (Dime! USD)" ในหน้าการตั้งค่า (`SettingsScreen`) เพื่อให้ผู้ใช้กดตรวจสอบและกู้คืนรายการได้ใน 1 คลิก
  - **3. การทดสอบและการรับรองคุณภาพ**:
    - เพิ่ม Unit Test ใน `credit_card_engine_test.dart` ทดสอบการล้างรายการตัดยอดซ้ำและการป้องกันการสร้างซ้ำ
    - เพิ่ม Unit Test ใน `investments_dao_test.dart` ทดสอบการตรวจจับ Orphan Lots, การฟื้นฟูรายการธุรกรรม และการป้องกัน Deduplication ลบรายการซื้อหุ้น

- [x] **Investment UI Overhaul, Dividend Tax Automation, Medical Income Tax Mapping & Foreign Dividend Excel Importer (1 ต.ค. 2026)**:
  - **1. ปรับปรุง UI หน้าการลงทุน (Portfolio Screen) & ซ่อนปุ่ม Sync ไม่ให้บังปุ่มควบคุม**:
    - ย้าย `SyncStatusWidget` ขึ้นไปวางบนแถบ AppBar Action ร่วมกับเมนูตัวเลือกอย่างเป็นระเบียบ ทำให้ไม่ซ้อนทับหรือบังปุ่ม "อัปเดตราคา" และ "เพิ่มเติม"
    - เพิ่มแถบ Quick Actions สำหรับการลงทุนโดยเฉพาะ วางคู่กันชัดเจน: **`[อัปเดตราคาตลาด]`** และ **`[บันทึกเงินปันผล]`**
    - ย้ายปุ่ม **`[+ เพิ่มสินทรัพย์ใหม่]`** ลงไปวางท้ายรายการสินทรัพย์ทั้งในหมวดสินทรัพย์ที่มีการถือครองและสินทรัพย์ที่ยังไม่ได้ลงทุน
  - **2. พัฒนาหน้าต่างบันทึกเงินปันผล (Dividend Income Dialog) & คำนวณภาษีหัก ณ ที่จ่ายอัตโนมัติ**:
    - หุ้นไทย: คำนวณหักภาษี ณ ที่จ่าย 10% อัตโนมัติทันทีที่กรอกยอดปันผล
    - หุ้นต่างประเทศ: คำนวณหักภาษี ณ ที่จ่าย 15% อัตโนมัติทันทีที่กรอกยอดปันผล
    - ดึงอัตราแลกเปลี่ยน (FX) ล่าสุดจากระบบมาเติมให้ทันทีสำหรับสินทรัพย์ต่างประเทศ
    - จับคู่บัญชีเริ่มต้นอัตโนมัติตามสกุลเงิน (USD $\rightarrow$ Dime! USD) และบันทึกลงบัญชีที่ผู้ใช้เลือกจริง
    - บันทึกลงหมวดหมู่เดิม **"ดอกเบี้ยและเงินปันผล"** (`cat-inc-0000-4000-8000-000000000003`) พร้อมประเภทภาษี `40_4_dividend_th` / `40_4_dividend_foreign`
    - เพิ่มการ์ดคำแนะนำภาษีเงินได้ต่างประเทศ (ป.161/2566) อธิบายชัดเจนว่าเงินปันผลที่พักอยู่ในพอร์ตต่างประเทศยังไม่เสียภาษีไทย จะคำนวณภาษีเมื่อโอนเงินกลับเข้าไทยเท่านั้น
  - **3. ปรับระบบเลือกหมวดหมู่รายรับ ให้ผูกประเภทภาษีอัตโนมัติ (Tax Categorization Mapping)**:
    - หมวด `รับจ้าง / ค่าอยู่เวร` $\rightarrow$ ผูกกับ **40(1) เงินเดือน**
    - หมวด `รายรับอื่นๆ` $\rightarrow$ ผูกกับ **ยกเว้นภาษี (non_taxable)**
    - หมวด `ดอกเบี้ยและเงินปันผล` $\rightarrow$ ผูกกับ **40(4) ดอกเบี้ยและเงินปันผล**
    - อัปเดตทั้งใน Seed Data, ฟังก์ชันแพตช์ฐานข้อมูลเดิมอัตโนมัติ, Quick Add Screen และ Edit Transaction Dialog
  - **4. พัฒนาระบบนำเข้าเงินปันผลหุ้นต่างประเทศจากไฟล์ Excel (`ปันผล.xlsx`)**:
    - พัฒนา `DividendExcelParser` รองรับการอ่านวันที่ทั้งแบบข้อความ (`15/7/2024`) และ Excel Date Cells แก้ปัญหา Excel สลับวันกับเดือนอัตโนมัติ (เช่น 12/6/2026 คือ 12 มิ.ย. ไม่ใช่ 6 ธ.ค., 10/9/2026 คือ 10 ก.ย. ไม่ใช่ 9 ต.ค.) ทำให้เรียงลำดับเวลาถูกต้องตามจริง 100%
    - พัฒนา `DividendExcelImportExecutor` บันทึกเข้าบัญชี **Dime! USD**, หมวดหมู่ **ดอกเบี้ยและเงินปันผล**, ประเภทภาษี **40(4) ต่างประเทศ**, บันทึกลงบัญชีแยกประเภท `investment_incomes` และอัปเดตอัตราแลกเปลี่ยนย้อนหลังเข้า `fx_rates` อัตโนมัติ
    - แก้ปัญหาช่องบัญชีว่างในหน้าต่างแก้ไขรายการ: ปรับให้บันทึกบัญชีลงทั้ง `sourceAccountId` และ `destinationAccountId`, ปรับ fallback และ Key ของ Dropdown ใน `EditTransactionDialog` ให้เลือกบัญชี `Dime! USD` อัตโนมัติ พร้อมสคริปต์แพตช์ฐานข้อมูลเดิมให้อัตโนมัติ
    - สร้างหน้าต่างพรีวิวเต็มจอ `DividendExcelPreviewDialog` แสดง Gross USD, Tax USD, Net USD, Net THB พร้อมระบบเลือกทั้งหมด และระบบ Rollback ยกเลิกการนำเข้าได้ใน 1 คลิก
    - ผูกระบบตรวจจับไฟล์อัตโนมัติใน `ImportWizardScreen` เมื่อเลือกไฟล์ชื่อ `ปันผล.xlsx` หรือมีคำว่า `dividend`
  - **5. การทดสอบและการรับรองคุณภาพ (Quality Assurance)**:
    - สร้าง Unit Test ครอบคลุม: `test/features/dividend_excel_import_test.dart` ทดสอบการแปลงไฟล์ `ปันผล.xlsx`, การบันทึกธุรกรรม, การจัดหมวดหมู่ภาษี, และระบบ Rollback 100%

  - **1. ปรับระบบส่งออกไฟล์สำรองเป็น SQLite ไบนารีมาตรฐาน (Portable SQLite)**:
    - เมื่อผู้ใช้เว้นว่างรหัสผ่าน ระบบจะส่งออกเป็นไฟล์ SQLite มาตรฐาน ไม่มีการแอบเข้ารหัสลับด้วยรหัสสุ่มเฉพาะเครื่อง ทำให้สามารถคัดลอกไฟล์ผ่านสาย USB, Google Drive, LINE หรืออีเมล ไปกู้คืนบนมือถือ Android หรือคอมเครื่องอื่นได้ทันที 100%
    - หากผู้ใช้กรอกรหัสผ่านเอง ระบบจึงจะทำการเข้ารหัส AES-256 (`MYFINANCE_ENC_V1`)
  - **2. ระบบ Live Drift Table Injection (กู้คืนข้อมูลสดทันทีไม่ต้องพึ่งรีโหลดเว็บ)**:
    - เพิ่ม `_applyBackupDataToDrift` ทำการปิด Foreign Keys ชั่วคราว ล้างตาราง และฉีดแถวข้อมูลทุกตาราง (Accounts, Categories, Assets, 3,881 Transactions, ฯลฯ) เข้า Drift Database ที่กำลังรันอยู่โดยตรง
    - เรียก `transactionsDao.onLedgerModified?.call()` เพื่อกระตุ้น Riverpod Streams อัปเดตหน้าจอทันที
  - **3. ปรับปรุงข้อความแจ้งเตือนและระบบตรวจไฟล์ (Friendly Prompts)**:
    - หน้าต่างส่งออกแนะนำชัดเจนว่าเว้นว่าง = ไฟล์มาตรฐานที่เปิดข้ามเครื่องได้
    - หน้าต่างกรอกรหัสผ่านแจ้งเตือนชัดเจนหากไฟล์ถูกล็อกรหัส และแสดง SnackBar แนะนำเมื่อยกเลิกแทนการปิดเงียบ
  - **4. แก้ไขปัญหาพรีวิวไฟล์สำรองแสดง 0 รายการ (Web SQLite Reader)**:
    - พัฒนา `sqlite_reader` ด้วย `WasmSqlite3` และ in-memory VFS สำหรับ WebAssembly ทำให้อ่านจำนวนบัญชี, ตัวอย่างชื่อบัญชี, จำนวนรายการจริง (3,881 รายการ) และวันที่ล่าสุดขึ้นหน้าต่าง Preview ได้ทันที
  - **5. ตัดปุ่มล้างข้อมูลซ้ำตามคำขอ & รวมเข้าไพป์ไลน์ Sync อัตโนมัติ**:
    - ระบบ Deduplication ทำงานอัตโนมัติ 100% ทั้งก่อน push ขึ้นคลาวด์และหลัง pull ลงเครื่อง โดยผู้ใช้ไม่ต้องกดเอง
  - **6. แก้ไขการนับงวดประกันจ่ายแล้ว (Insurance Paid Periods)**:
    - คำนวณงวดประกันที่จ่ายแล้วจากปีที่ชำระจริง (Distinct Years) และจำกัดไม่เกินจำนวนงวดทั้งหมด (`totalPeriods`) แก้บั๊กแสดงผล 21/15 งวด
  - **7. การทดสอบและการรับรองคุณภาพ (Quality Assurance)**:
    - แก้ไข UI Overflow และการดักจับ Supabase Uninitialized ใน Widget Test และ SyncStatusWidget / SettingsScreen
    - `flutter test`: ผ่านทั้งหมด **174/174 tests passed** (100% ครบทุกโมดูล)
    - บิลด์ Web Release พร้อมอัปเดตโฟลเดอร์ `docs/` เตรียม Deploy สู่ GitHub Pages ทันที

- [x] **Full Cross-Module Sync, Device-as-Source-of-Truth & Transaction Deduplication Tool**:
  - **1. โครงสร้างซิงค์ข้อมูลครอบคลุมทุกโมดูล (Complete Cross-Module Sync)**:
    - เชื่อมข้อมูลครบทุกหมวด: บัญชีและสกุลเงิน (Accounts), หมวดหมู่พร้อมลำดับการจัดเรียงและหมวดย่อย (Categories with sort_order and parent_id), พอร์ตลงทุน (Assets), ประกัน (Insurance), หนี้สิน (Liabilities), งบประมาณ (Budgets), รายการประจำ (Recurring Rules), และรายการธุรกรรม (Transactions)
    - บันทึกสถานะอุปกรณ์ล่าสุดที่ใช้งาน (`sync_device_state`) บน Supabase เพื่อใช้อุปกรณ์ล่าสุดเป็น Source of Truth
  - **2. ระบบ Deduplication อัตโนมัติ**:
    - เพิ่มฟังก์ชัน `deduplicateTransactions()` ใน `TransactionsDao` ตรวจหา signature ซ้ำ (วันเวลา, จำนวนเงิน, บัญชี, หมวดหมู่, ชนิดรายการ)
    - รวมเข้ากับ `syncAll()` อัตโนมัติ
  - **3. อัปเดตและเผยแพร่ (Build & Deploy)**:
    - คอมไพล์ Flutter Web Release และอัปเดตโฟลเดอร์ `docs/` สำหรับ GitHub Pages (`https://thanawit1995.github.io/myfinance/`)

- [x] **Money BIG PLAN (Excel 2020-2023) Importer, Endowment Insurance Asset, Cash Flow Card & Net Worth Breakdown**:
  - **1. หน้าต่างพรีวิวแบบเต็มจอ (Full-Screen Import Previews)**:
    - ปรับหน้าต่างพรีวิวการนำเข้าของ `NotionInvestPreviewDialog`, `NotionFundsPreviewDialog`, และ `NotionGoldPreviewDialog` เป็นแบบ Full-Screen (`Dialog.fullscreen`) กว้างเต็มจอ เห็นคอลัมน์ครบทุกแถว (เรต USD/THB, ต้นทุนบาท, บัญชีต้นทาง) พร้อม Scrollbar ทั้งแนวตั้งและแนวนอน และช่องเลือกทั้งหมด (Select All)
  - **2. รองรับไฟล์ประวัติเรตแลกเปลี่ยน Invest-Stocks (`Invest-Stocks_USDTHB_Historical_Rates.csv`)**:
    - ตรวจจับคอลัมน์ `USDTHB Rate` และ `Invested (USD)` โดยอัตโนมัติ
    - คำนวณจำนวนหุ้น (`Shares`) จากตารางอ้างอิงประวัติศาสตร์ให้อัตโนมัติ ผู้ใช้ไม่ต้องแก้คอลัมน์ใน CSV เอง
  - **3. ระบบ Rollback และปุ่มล้างข้อมูลที่ไม่มี Batch**:
    - รองรับการ Rollback ธุรกรรมหุ้น/กองทุน/ทองคำที่นำเข้าใหม่อย่างปลอดภัย
    - เพิ่มปุ่มคลิกเดียวในหน้าประวัติการนำเข้า (`ImportHistoryScreen`) เพื่อรีเซ็ต/ล้างข้อมูลการลงทุนที่เคยนำเข้ามาก่อนหน้านี้และไม่มี Batch ID ให้สะอาดเรียบร้อย
  - **4. ปรับหน้าบัญชี: บัตร "กระแสเงินสด" (Cash Flow / Liquid Cash)**:
    - เปลี่ยนชื่อการ์ดบนสุดของหน้าบัญชี (`AccountsScreen`) เป็น **"กระแสเงินสด"**
    - คำนวณเฉพาะผลรวมของเงินฝากธนาคาร/เงินสด (อนุญาตให้ติดลบได้) โดยไม่นำมูลค่าพอร์ตการลงทุนมารวม
  - **5. หน้าแรก (Home Screen): แยกแจกแจงสินทรัพย์สุทธิอย่างชัดเจน**:
    - ในส่วนความมั่งคั่งสุทธิ (Financial Position) แยกแถวด้านล่างให้เห็นชัดเจน: **`เงินสด/เงินฝาก`** และ **`พอร์ตลงทุน`** พร้อมแสดงยอดรวมสินทรัพย์สุทธิที่ถูกต้อง
  - **6. ผู้นำเข้าประวัติย้อนหลัง Money BIG PLAN (Excel 2020 - ส.ค. 2023)**:
    - พัฒนา `MoneyBigPlanParser` รองรับการอ่านไฟล์ `.xlsx` (แผ่นงาน 2020, 2021, 2022, 2023 โดยสิ้นสุดที่เดือนสิงหาคม 2023 ก่อนเริ่มใช้ Notion)
    - คำนวณผลบวกลบคูณหารในช่องข้อความอัตโนมัติ (เช่น `17442+3077` หรือ `24000+1312.5+6000`)
    - ลงบัญชี **SCB** ทุกรายการทั้งรายรับและรายจ่าย
    - ข้ามรายการลงทุนทั้งหมด (`กองทุน/หุ้น`, `Cryptocurrency`, `SSF`, `RMF`) เนื่องจากบันทึกใน Notion แล้ว
    - **การจัดการประกันชีวิตแบบออมทรัพย์ (Endowment Insurance)**: เบี้ยประกัน 45,000 บาท/ปี จะถูกบันทึกเป็นการโอน (Transfer) เข้าบัญชีสินทรัพย์ **`ประกันออมทรัพย์ (เมืองไทยประกันชีวิต)`** พร้อมติดแท็ก `deduction:life_insurance` ทำให้สินทรัพย์สุทธิไม่ลดลง และระบบรายงานภาษีคำนวณลดหย่อนภาษีได้ครบถ้วน
    - สร้างหน้าต่างพรีวิวเต็มจอ `MoneyBigPlanPreviewDialog` พร้อมแถบสรุปยอดและตัวกรองประเภท
  - **7. การทดสอบและการรับรองคุณภาพ**:
    - `flutter test`: ผ่านทั้งหมด **168/168 tests passed** (100%)
    - `flutter analyze`: **0 errors, 0 warnings**

  - **1. หน้าพอร์ตการลงทุน (Portfolio Screen)**:
    - ออกแบบแถบควบคุมเหลือเพียง 2 ปุ่มชัดเจน: **ปุ่มตัวกรอง (Filter)** และ **ปุ่มเรียงลำดับ (Sorting)**
    - ไม่มีการ์ดสรุปหลายหมวดมากองให้รกหน้าจอ การ์ดสรุปหลักคำนวณเงินต้น, มูลค่าตลาดรวม, และกำไร/ขาดทุนสุทธิ **แบบไดนามิก** ตามประเภทสินทรัพย์ที่ผู้ใช้เลือกกรองทันที
    - จัดเรียงตามมูลค่าสินทรัพย์จากมากไปน้อย (Market Value Descending) เป็นค่าเริ่มต้น
  - **2. หน้าภาพรวมทางการเงิน (Financial Summary Screen) & การเจาะลึกธุรกรรม (Transaction Drill-down)**:
    - แตะที่การ์ด **รายรับ (Income)** หรือ **รายจ่าย (Expense)** เพื่อเปิดหน้า `TransactionListScreen` ที่กรองเฉพาะช่วงเวลาและประเภทรายการนั้นทันที
    - แตะที่รายการหมวดหมู่รายรับ/รายจ่ายแต่ละอัน เพื่อเจาะลึกดูธุรกรรมย่อยในหมวดหมู่นั้นตามช่วงเวลา
    - เพิ่มแอนิเมชันเปลี่ยนเดือน/ช่วงเวลาด้วย `SlideTransition` + `AnimatedSwitcher` นุ่มนวล ไม่รีเฟรชหน้าจอทั้งหมด
  - **3. สินทรัพย์สุทธิ (Net Worth Single Source of Truth)**:
    - ปรับปรุง `AccountsDao.getTotalNetWorthSatang()` ให้ดึงมูลค่าพอร์ตการลงทุนปัจจุบันจาก `InvestmentsDao` รวมเข้ากับเงินฝากในบัญชีธนาคารทุกสกุลเงิน (THB + USD + FCD) โดยอัตโนมัติ
    - แสดงหมวดหมู่ "พอร์ตการลงทุน" พร้อมมูลค่ารวมและปุ่มแตะเพื่อไปหน้าพอร์ตในหน้าบัญชี (`AccountsScreen`)
  - **4. ประวัติการนำเข้าไฟล์ CSV & ระบบยกเลิกการนำเข้า (Rollback)**:
    - ปรับปรุง `NotionInvestImportExecutor`, `NotionFundsImportExecutor`, และ `NotionGoldImportExecutor` ให้บันทึก Batch ID ลงตาราง `import_batches` ทุกครั้งที่นำเข้า
    - ปรับปรุง `ImportBatchesDao.rollbackBatch()` ให้ลบ `InvestmentLots` ที่เชื่อมโยงกับธุรกรรมในชุดนั้นอย่างปลอดภัยก่อนลบธุรกรรม พร้อมคำนวณ FIFO ใหม่ให้อัตโนมัติ ป้องกัน Foreign Key Error
    - เพิ่มปุ่ม "ดูประวัติการนำเข้า (Rollback)" ในกล่องข้อความแจ้งเตือนสำเร็จของการนำเข้าหุ้น, กองทุน และทองคำ
    - เพิ่มเมนู "ประวัติการนำเข้าและย้อนกลับ (Import History & Rollback)" ในหน้าการตั้งค่า (`SettingsScreen`)
  - **5. ปรับปรุงอัตราแลกเปลี่ยนการนำเข้าหุ้น Notion (Notion Invest Stock FX Rate)**:
    - ถอดเรตคงที่ 33.65 ออก และรองรับการอ่านเรตจริงจากคอลัมน์ `USDTHB Rate` ในไฟล์ CSV
    - ใส่ตารางอ้างอิงอัตราแลกเปลี่ยนประวัติศาสตร์ครบทั้ง 21 รายการตามไฟล์ `Invest-Stocks_USDTHB_Historical_Rates.csv`
    - เพิ่มระบบคำนวณจำนวนหุ้น (Shares) อัตโนมัติหากนำเข้าไฟล์สรุปเรตแลกเปลี่ยนที่ไม่มีคอลัมน์ Shares
  - **6. การทดสอบและการรับรองคุณภาพ**:
    - `flutter test`: ผ่านทั้งหมด **166/166 tests passed** (100%)
    - `flutter analyze`: **0 errors, 0 warnings**

- [x] **Notion Import Enhancements (Notion_expense & Notion_invest with Fixed 33.65 FX Rate)**:
  - **1. ปรับปรุงการนำเข้า Notion_expense (รายจ่าย)**:
    - เพิ่มการแม็ปบัญชี: `'money'`, `'online banking'`, `'online_banking'`, `'onlinebanking'` $\rightarrow$ บัญชี **`SCB`** อัตโนมัติ (หากไม่มีให้สร้างบัญชี SCB)
    - เพิ่มการคลีนคอลัมน์บัญชี (Account/Wallet) ด้วย `cleanNotionRelation` ตัดลิงก์ URL และ Emoji ออกให้เป็นชื่อที่ถูกต้อง
    - เพิ่มการแม็ปหมวดหมู่: `'ทั่วไป'`, `'general'`, และแถวที่ไม่มีหมวดหมู่ $\rightarrow$ หมวดหมู่ **`ค่าใช้จ่ายอื่นๆ`** (`Other Expense`)
  - **2. ปรับปรุงการนำเข้า Notion_invest (การลงทุน)**:
    - **กำหนดอัตราแลกเปลี่ยนคงที่ (Fixed Rate)**: ใช้อัตราแลกเปลี่ยน **`33.650000`** บาท/USD สำหรับรายการลงทุนต่างประเทศ (หุ้น และ ทองคำ) ตามความต้องการของผู้ใช้
    - **กองทุนรวม (Mutual Funds)**: เงิน THB ตัดจากบัญชี **`SCB`**
    - **ทองคำ (Gold)**: เงิน USD อัตราแลกเปลี่ยน 33.65 ตัดจากบัญชี **`Dime! FCD`**
    - **หุ้นต่างประเทศ (Stocks)**: คัดแยกบัญชีตัดเงินตามช่อง Text ใน Notion:
      - `THB` $\rightarrow$ ตัดจากบัญชี **`Dime! Save`** (คำนวณหักเป็นเงินบาท THB ตามเรต 33.65)
      - `FCD` $\rightarrow$ ตัดจากบัญชี **`Dime! FCD`** (USD)
      - `USD` หรือ `ปันผล` $\rightarrow$ ตัดจากบัญชี **`Dime! USD`** (USD)
  - **3. การตรวจสอบ & ผลลัพธ์**:
    - เพิ่มและปรับปรุง Unit Tests: `test/import/notion_category_mapper_test.dart`, `test/import/notion_invest_parser_test.dart`, `test/features/notion_invest_funds_gold_test.dart`, `test/features/csv_import_executor_test.dart`
    - `flutter analyze`: **0 errors, 0 warnings**
    - `flutter test`: ผ่านทั้งหมด **165/165 tests passed** (100%)
    - บิลด์เวอร์ชัน Web Release สำเร็จสมบูรณ์ (`flutter build web --release`)

- [x] **Auto Credit Card Settle (Historical Debt < 24 ส.ค. 69) & Encrypted Backup Inspection Fix**:
  - **1. ตัดยอดหนี้ประวัติศาสตร์ของบัตรเครดิตอัตโนมัติ (Credit Card Historical Debt Settlement)**:
    - เพิ่มฟังก์ชัน `settleHistoricalDebt` และ `getHistoricalDebtSatang` ใน `CreditCardDao` สำหรับคำนวณยอดค้างชำระก่อน 24 ส.ค. 2569 (วันตัดรอบ 23 ส.ค. 2569 เวลา 23:59:59) และบันทึกรายการหักล้างยอดประวัติศาสตร์เป็นธุรกรรมโอนเงิน (Transfer) เข้าบัตรเครดิตโดยตรง (`sourceAccountId: null`)
    - รักษารายการธุรกรรมย้อนหลัง 595 รายการ (ตั้งแต่ปี 2023) และสถิติรายจ่าย/หมวดหมู่เดิมไว้ครบถ้วน 100%
    - เพิ่มแบนเนอร์แจ้งเตือนและปุ่มคลิกเดียว *"ตัดยอดประวัติศาสตร์ (ก่อน 24 ส.ค. 69)"* ในหน้าสรุปบัตรเครดิต (`CreditCardSummaryScreen`) สำหรับฐานข้อมูลที่มีอยู่แล้ว
    - เพิ่มระบบตัดยอดอัตโนมัติทันทีหลังนำเข้า Notion (`ImportExecutor`) พร้อม map บัญชี `'credit card'`, `'credit_card'`, `'บัตรเครดิต'` เข้าสู่บัญชีบัตรเครดิตที่ถูกต้อง
    - ผลลัพธ์: บัตรเครดิตแสดงเฉพาะ 2 รอบบิลล่าสุดตามที่ต้องการ คือรอบก่อนหน้า (24/8/69 - 23/9/69) และรอบปัจจุบัน (24/9/69 เป็นต้นไป)
  - **2. แก้ไขการตรวจสอบไฟล์สำรองข้อมูล (Backup Restore Inspection Web Fix)**:
    - แก้ไขปัญหาข้อผิดพลาด `ไฟล์ไม่ถูกต้อง: ไฟล์ที่เลือกไม่ใช่ฐานข้อมูล SQLite ของ MyFinance` บนเว็บ
    - ปรับปรุง `backup_inspector_stub.dart` ให้ตรวจจับ Header การเข้ารหัส AES-256 (`MYFINANCE_ENC_V1`) และถอดรหัสตรวจสอบข้อมูลก่อนยืนยันความถูกต้องของไฟล์ ทำให้การกู้คืนไฟล์สำรองข้อมูลบนเว็บเบราว์เซอร์ทำงานได้อย่างราบรื่น
  - **3. การตรวจสอบ & ทดสอบ**:
    - เพิ่ม Unit Tests ใน `test/features/credit_card_engine_test.dart` และ `test/core/backup_inspect_stub_test.dart`
    - `flutter analyze`: **0 errors, 0 warnings**
    - `flutter test`: ผ่านทั้งหมด **163/163 tests passed** (100%)
    - บิลด์เวอร์ชันเว็บสำเร็จสมบูรณ์ (`flutter build web --release`)

- [x] **Auto Investment Category for Buy Trades, Action Button Cleanup & Release Build**:
  - **1. หมวดหมู่ "การลงทุน" สำหรับการซื้อสินทรัพย์ (Auto Investment Expense Category)**:
    - เพิ่มฟังก์ชัน `getOrCreateInvestmentExpenseCategory()` ใน `CategoriesDao` เพื่อสร้าง/เรียกใช้หมวดหมู่รายจ่าย "การลงทุน" (Investment)
    - ปรับปรุง `InvestmentsDao.recordBuyTrade()` ให้กำหนด `categoryId` เป็นหมวดหมู่ "การลงทุน" ลงใน ledger transaction โดยอัตโนมัติ
    - เพิ่ม Unit Test ครอบคลุมการบันทึกหมวดหมู่นี้ใน `test/features/investments_dao_test.dart`
  - **2. ตัดปุ่มส่วนเกินออกตามรูปภาพที่ผู้ใช้แจ้ง (UI Cleanup)**:
    - หน้าพอร์ตการลงทุน (`portfolio_screen.dart`): ตัดปุ่มด่วน 3 ปุ่มในหน้าถือครองออก (`+ เพิ่มสินทรัพย์`, `อัปเดตราคาตลาด`, `บันทึกเงินปันผล`) เพื่อให้หน้าจอสะอาดตา ไม่ซ้ำซ้อนกับเมนูด้านบน
    - หน้าแรก (`vault_home_screen.dart`): ตัดปุ่มค้นหาและปุ่มตั้งค่าที่มุมขวาบนของ Header ออกตามภาพ
  - **3. การตรวจสอบ & ผลิตภัณฑ์**:
    - `flutter analyze`: **0 errors, 0 warnings**
    - `flutter test`: ผ่านทั้งหมด **158/158 tests passed** (100%)
    - อัปเดตขึ้น GitHub (`origin main`)
    - สร้างไฟล์ Android APK (`flutter build apk --release`)

- [x] **UI Overhaul: Portfolio/Investments, Category Management & Budget/Project Dialogs**:
  - **1. เมนูการลงทุน (Investments & Portfolio)**:
    - **ลบปุ่มลอย (FAB) "ซื้อ / ขาย"** ออกจากทุกหน้าและทุกแท็บของเมนูการลงทุน เพื่อไม่ให้บดบังข้อมูล
    - **ปรับหน้าต่าง "เพิ่มสินทรัพย์ใหม่" (`AssetFormDialog`)**: เปลี่ยนเป็นหน้าจอเต็ม (Full Screen `Scaffold`) กว้างขวาง มี AppBar และปุ่มบันทึกด้านล่าง
    - **ปรับหน้าต่าง "บันทึกเงินปันผล/ดอกเบี้ย" (`DividendIncomeDialog`)**: เปลี่ยนเป็นหน้าจอเต็ม (Full Screen `Scaffold`) ใช้งานสะดวกสบาย
    - **แก้ปัญหาข้อความตกขอบ/ล้นกรอบ**:
      - TabBar ด้านบน: เปิดใช้งาน `isScrollable: true` และ `tabAlignment: TabAlignment.center` ทำให้ชื่อแท็บไม่ถูกบีบหรือตัดขาด
      - Quick Action Buttons: ใช้ `Wrap` จัดวางปุ่ม "เพิ่มสินทรัพย์", "อัปเดตราคาตลาด", "บันทึกเงินปันผล" ทำให้ปุ่มไม่ตกขอบขวาของจอ
      - ลบข้อความ Subtitle `"แตะเพื่อจัดการ Lot หรือซื้อขาย"` ใต้หัวข้อ "รายการสินทรัพย์ที่ถืออยู่"
      - Badge กำไรที่รับรู้แล้ว (+฿150.00) ในแท็บ Realized P&L: ปรับให้ใช้ `Wrap` ให้อยู่ภายในการ์ด ไม่เลยกรอบขวา
      - ปุ่ม "เปลี่ยนเดือน" ในหน้า "อัปเดตราคาตลาดประจำเดือน" (`MonthlyValuationScreen`): ปรับใช้ `Wrap` ไม่หลุดล้นขอบการ์ด
  - **2. หน้าจัดการหมวดหมู่ (Categories Management)**:
    - ลบแถบคำแนะนำด้านบน ("กดค้างแล้วลากเพื่อจัดลำดับ...") ออก
    - ซ่อนไอคอนดวงตา, ถังขยะ และจุดลาก 6 จุดออกจากการ์ดหมวดหมู่ เหลือเฉพาะ **ปุ่มดินสอ** ปุ่มเดียว
    - รองรับการแตะค้างที่การ์ดเพื่อลากสลับตำแหน่งได้ตามปกติ
    - เมื่อแตะการ์ดหรือกดปุ่มดินสอ จะเปิดหน้าแก้ไขหมวดหมู่ (`CategoryFormDialog` แบบเต็มจอ) ซึ่งมีปุ่ม **"ซ่อนหมวดหมู่นี้"** และหากเป็นหมวดหมู่ที่ผู้ใช้สร้างเองจะมีปุ่ม **"ลบหมวดหมู่"** (รองรับทั้งรายรับและรายจ่าย)
  - **3. หน้าต่างสร้างโครงการและงบประมาณ (Budgets & Projects Dialogs)**:
    - ปรับขยายขนาดกรอบ Dialog ให้กว้างขึ้น (`insetPadding` สบายตา และความกว้าง 440px)
    - กล่องเลือกระยะเวลาโครงการ: ปรับเป็น 2 การ์ดคู่ซ้าย-ขวา แสดงป้าย "วันเริ่มต้น" / "วันสิ้นสุด" พร้อมวันที่เต็มชัดเจน (เช่น `26/09/2026`) ไม่ถูกตัดทอนหรือเป็นจุดไข่ปลา `...`
  - **การทดสอบความถูกต้อง**:
    - `flutter analyze`: **No issues found! (0 error, 0 warning)**
    - `flutter test`: ผ่านทั้งหมด **158/158 tests passed** (100%)

- [x] **Bug Fixes & Financial Reporting Enhancements (Web & Mobile)**:
  - **1. ป๊อปอัปแจ้งเตือนปิดอัตโนมัติใน 5 วินาที (Auto-dismiss SnackBar)**:
    - เพิ่มตัวจับเวลา `Future.delayed(Duration(seconds: 5))` เพื่อสั่งปิด `hideCurrentSnackBar()` โดยตรง ป้องกันปัญหา SnackBar ค้างบนเบราว์เซอร์
  - **2. แก้ไขหน้าต่างซื้อ-ขายสินทรัพย์ลงทุนไม่โหลด (Invest Trade Screen Fix)**:
    - แก้ไขสาเหตุ Error จากการจัดรูปแบบวันที่ด้วยภาษาไทยที่ยังไม่ได้โหลดข้อมูล Locale บน Flutter Web โดยเพิ่ม `initializeDateFormatting()` ใน `main.dart` และ fallback รายชื่อเดือนภาษาไทย
    - เพิ่ม Unit / Widget Test ครอบคลุมการแสดงผลฟอร์มซื้อขายสินทรัพย์ลงทุน (`test/features/buy_sell_trade_test.dart`)
  - **3. แก้ไขยอดบัตรเครดิตให้อัปเดตทันทีแบบเรียลไทม์ (Credit Card Realtime Balance)**:
    - เชื่อมต่อ `transactionsVersionProvider` เข้ากับ `VaultHomeScreen`, `AccountsScreen`, และ `CreditCardSummaryScreen` เพื่อให้หน้าจอรับรู้ทุกการบันทึกรายการใหม่ทันที
    - ปรับปรุงการคำนวณยอดหนี้บัตรเครดิตบนหน้าหลักให้รวมยอดค้างชำระทั้งหมด (`totalDebtSatang`) ไม่ตกหล่นแม้รายการจะอยู่ต่างรอบบิล
    - ปรับปรุงการตรวจจับธุรกรรมของบัตรเครดิตให้ครอบคลุมทั้งค่าใช้จ่าย, การโอน, และเงินคืน
  - **4. คำนวณสินทรัพย์สุทธิ (Net Worth) รวมมูลค่าพอร์ตการลงทุน (Unrealized Profit/Loss)**:
    - ปรับปรุง `getTotalNetWorthSatang` ใน `AccountsDao` ให้รองรับมูลค่าพอร์ตการลงทุน (`portfolioValueSatang`)
    - คำนวณความมั่งคั่งสุทธิ = เงินในบัญชีทั้งหมด + มูลค่าตลาดของพอร์ตลงทุน (ราคาปัจจุบัน x จำนวนหน่วยที่ถือครอง) ทำให้เมื่อซื้อหุ้น/กองทุน ยอดสินทรัพย์สุทธิจะไม่ลดลง แต่สะท้อนกำไรขาดทุนที่ยังไม่เกิดขึ้นจริง (Unrealized P/L)
    - แสดงข้อความรายละเอียดระบุมูลค่าพอร์ตลงทุนในการ์ดสินทรัพย์สุทธิของหน้ารวมบัญชีอย่างชัดเจน
  - **5. ยกเครื่องหน้ารายงานสรุปรายเดือน (Monthly Summary Screen Overhaul)**:
    - ลบข้อความและไอคอนคำแนะนำการปัดซ้ายขวา (`ปัดจอซ้าย-ขวา เพื่อเปลี่ยนช่วงเวลา`) ออก
    - รวมยอดสรุป รายรับ, รายจ่าย, เงินลงทุน, เงินออมสุทธิ และ อัตราการออม เข้าไว้ด้วยกันในการ์ดสรุปการเงินเดียว (`_buildUnifiedSummaryCard`)
    - แทนที่กราฟแท่งแนวตั้งเดิมด้วย กราฟแผนภูมิแท่งแนวนอน (Horizontal Bar Chart) ที่ประหยัดพื้นที่แนวตั้ง และแสดงสัดส่วนกระแสเงินสดชัดเจน
  - **6. นำกล่องคำแนะนำ Chrome ในหน้า Backup & Restore ออก**:
    - ลบกล่องคำแนะนำ `ทำไม Chrome ในมือถือถึงเปลี่ยนโฟลเดอร์ไม่ได้?...` ออกตามคำขอ ทำให้หน้าสำรองข้อมูลกระชับ สะอาดตา
  - **การทดสอบความถูกต้อง**:
    - `flutter analyze`: **No issues found! (0 error, 0 warning)**
    - `flutter test`: ผ่านทั้งหมด **157/157 tests passed** (100%)
    - `flutter build web --release --base-href /myfinance/`: ผ่านสมบูรณ์ 100%

- [x] **Comprehensive UI/UX Enhancements, Credit Card Statement Cycles, Account Renaming & Advanced Financial Reports**:
  - **1. ปิดหน้าบันทึกด่วนอัตโนมัติ (Quick Add Auto-Close) & ปรับเวลาแจ้งเตือน 5 วินาที**:
    - ปรับปรุง `QuickAddScreen` ให้ปิดหน้าจอลงทันทีหลังกดบันทึกสำเร็จ (Auto-dismiss / Pop) กลับไปยังหน้าที่ผู้ใช้เปิดค้างไว้
    - ตั้งเวลาการแสดงผลแถบแจ้งเตือน (SnackBar) ยืนยันการบันทึกสำเร็จให้คงอยู่พอดีที่ 5 วินาที (`Duration(seconds: 5)`)
  - **2. แก้ไขชื่อบัญชีได้ (Editable Account Name)**:
    - เพิ่มฟังก์ชัน `updateAccountName` ใน `AccountsDao` พร้อม unit test
    - เพิ่มปุ่มไอคอนดินสอแก้ไขชื่อบัญชีในหน้าต่างรายละเอียดบัญชี (`AccountDetailScreen`)
    - รองรับการกดค้าง (Long Press) ที่การ์ดบัญชีในหน้ารวมบัญชี (`AccountsScreen`) เพื่อเปลี่ยนชื่อบัญชีได้ทันทีอย่างสะดวกรวดเร็ว
  - **3. ปรับปรุงหน้าจอบัตรเครดิต & เพิ่มระบบรอบบิลย้อนหลัง & ปุ่มชำระหนี้ (Credit Card Overhaul)**:
    - แก้ไขสีพื้นหลังและการแสดงผลในธีมมืด (VAULT theme) ให้ตัวอักษรคมชัด ไม่จมหรือกลืนกับสีกรอบ
    - เพิ่มระบบคำนวณและแสดงผลรอบบิลย้อนหลังสูงสุด 6 รอบบิล พร้อมแถบเลือกดูรอบบิล (Cycle Chips: รอบปัจจุบัน, รอบก่อนหน้า, และรอบบิลย้อนหลังตามเดือน)
    - แก้ไขให้รายการรูดบัตรเครดิตล่าสุดแสดงผลในหน้ารวมรายการของรอบบิลอย่างถูกต้อง ครบถ้วน
    - เพิ่มปุ่ม "ชำระหนี้" (Pay Credit Card) พร้อมหน้าต่างบันทึกการชำระหนี้จากบัญชีเงินฝากไปยังบัตรเครดิต และอัปเดตยอดคงค้างทันที
  - **4. ปรับแต่ง Dialog งบประมาณรายเดือน & โครงการพิเศษ (Budget Dialog Polish)**:
    - แก้ไข Dropdown เลือกหมวดหมู่ในหน้าเพิ่มงบประมาณ ไม่ให้ข้อความหมวดหมู่ยื่นล้นออกนอกกรอบ Dialog (`isExpanded: true` และ `TextOverflow.ellipsis`)
    - แก้ไขหน้าต่างสร้างโครงการพิเศษ: ปรับกล่องเลือกช่วงเวลา (วันเริ่มต้น - วันสิ้นสุด) ให้สวยงาม ไม่มีการตัดคำตกบรรทัด
  - **5. ปรับปรุงระบบซื้อ-ขายสินทรัพย์ลงทุน (Invest Buy/Sell Dialog Fix)**:
    - โหลดรายการสินทรัพย์และบัญชีล่วงหน้าใน `initState` ป้องกันปัญหาหน้าต่างรีเซ็ตข้อมูลขณะพิมพ์ตัวเลข
    - แก้ไขการปิด context ของ modal sheet และเพิ่มปุ่มทางเลือกในการเพิ่มสินทรัพย์ใหม่ทันทีหากยังไม่มีสินทรัพย์ในพอร์ต
  - **6. ยกเครื่องหน้ารายงานการเงิน & สรุปรายเดือน (Financial Reports & Gestures Overhaul)**:
    - **การปัดหน้าจอแนวนอน (Horizontal Swipe Navigation)**: รองรับการปัดซ้าย-ขวาเพื่อเลื่อนดูข้อมูลเดือน/ช่วงเวลาถัดไปหรือก่อนหน้าได้อย่างเป็นธรรมชาติ
    - **ตัวเลือกมุมมองช่วงเวลา (Granularity Selector)**: เลือกระยะเวลาการสรุปได้ 7 รูปแบบ — รายวัน, สัปดาห์, เดือน, ไตรมาส, ปี, ทั้งหมด, และกำหนดช่วงวันที่เอง (Custom Date Range)
    - **กราฟเปรียบเทียบ รายรับ vs รายจ่าย (Income vs Expense Bar Chart)**: แสดงกราฟแท่งเปรียบเทียบยอดรวมรายรับและรายจ่ายในแต่ละช่วงเวลาด้วย `fl_chart`
    - **สัดส่วนรายรับ/รายจ่ายแยกตามหมวดหมู่ (Category Breakdown)**: แสดงรายการหมวดหมู่พร้อมเปอร์เซ็นต์ส่วนแบ่งและหลอด Progress bar สีสันสวยงาม สามารถสลับดูระหว่าง "รายจ่าย" หรือ "รายรับ" ได้
  - **การทดสอบความถูกต้อง**:
    - `flutter analyze` ผ่านฉลุย **No issues found! (0 error, 0 warning)**
    - `flutter test` ผ่านทั้งหมดครบถ้วน **156/156 tests passed** (100%)
    - `flutter build web --release --base-href /myfinance/` คอมไพล์ผ่านฉลุย 100%

- [x] **Major UI Overhaul, Navigation Bar Restructure, Direct Quick Add, Full-Page Invest & Category Drag-to-Reorder**:
  - **1. ปรับไอคอนแอปและภาพโลโก้ใหม่ทั้งหมด (New Visual Brand & App Icons)**:
    - ติดตั้งภาพการ์ตูนกราฟิกคู่รักกับน้องแมวและกราฟการเติบโตทางการเงินลงในไอคอนแอปของ Android ทุกขนาด (`mipmap-mdpi` ถึง `mipmap-xxxhdpi`), Favicon และ Web PWA Icons (`Icon-192`, `Icon-512`, maskable)
    - เพิ่มไอคอนโลโก้ในรูปแบบ Badge Avatar บริเวณมุมบนซ้ายของหน้าจอหลัก (`VaultHomeScreen`) ทั้งในธีม VAULT และธีม LUMI รวมถึงแถบเมนูหลักของเวอร์ชัน Desktop
  - **2. รื้อถอนปุ่มลอย (FAB) ออกจากทุกหน้า**:
    - ลบปุ่มลอยบันทึกรายการออกจากหน้า Home และหน้า Money
    - ลบปุ่มลอย "เพิ่มบัญชี" ออกจากหน้าบัญชี (`AccountsScreen`) โดยยังคงปุ่ม `+` ใน AppBar ให้ใช้งานได้อย่างสะดวก
    - ลบปุ่มลอย "ตั้งงบหมวดหมู่ / สร้างโครงการใหม่" ออกจากหน้าจอ Budget (`BudgetScreen`)
  - **3. ปรับโครงสร้างเมนูหลัก (Bottom Navigation Bar) & ปุ่ม Quick Add ตรงกลาง**:
    - ตัดเมนู `Plan` ออกจากแถบเมนูหลักด้านล่าง (เนื่องจากมีให้เข้าถึงได้ครบถ้วนในเมนู "เพิ่มเติม" / Settings อยู่แล้ว)
    - เพิ่มปุ่มกดด่วนทรงกลมเครื่องหมาย `+` เด่นชัดอยู่ตรงกึ่งกลางของแถบเมนูหลัก (หน้าแรก, การเงิน, [+], การลงทุน, เพิ่มเติม)
    - เมื่อแตะปุ่ม `+` ระบบจะเด้งเปิดหน้าบันทึกรายจ่าย (`QuickAddScreen` ในโหมด Expense) ทันทีอย่างรวดเร็ว
  - **4. ปรับหน้าจอ Budget ให้กะทัดรัดและประหยัดพื้นที่**:
    - ตัด AppBar ด้านบนใน `BudgetScreen` ที่ซ้อนกับแท็บของ Money ออกจนหมด
    - ปรับแถบสลับระหว่าง "งบประมาณรายเดือน" กับ "โครงการพิเศษ" ให้เป็นแถบสลับทรงแคปซูลขนาดเล็กกะทัดรัด (สูงเพียง 36px) ประหยัดพื้นที่หน้าจออย่างมาก
    - ย้ายปุ่มจัดการหมวดหมู่และปุ่ม `+` เพิ่มงบประมาณ/สร้างโครงการมาจัดวางเคียงข้างแถบสลับอย่างสวยงาม
  - **5. ปรับหน้าจอซื้อ-ขายสินทรัพย์ลงทุน (Add Invest) เป็นแบบเต็มหน้าจอ (Full Page)**:
    - ยกเลิกการแสดงผลแบบ AlertDialog กรอบลอยเดิมที่คับแคบและตกขอบ
    - พัฒนาเป็นหน้าจอใหม่เต็มหน้า (`BuySellTradeScreen`) ตามดีไซน์เดียวกับหน้า Quick Add
    - รองรับการคำนวณและสรุปยอดเงินสุทธิ การกรอกราคา/หน่วย ค่าธรรมเนียม เรต FX พร้อมปุ่มยืนยันขนาดใหญ่ด้านล่าง
  - **6. จัดลำดับหมวดหมู่แบบลากวาง (Drag-and-Drop Category Reordering) พร้อมอัปเดต Schema v10**:
    - เพิ่มคอลัมน์ `sort_order` ในตาราง `categories` พร้อม Database Migration สู่ Version 10
    - ในหน้า "จัดการหมวดหมู่" ผู้ใช้สามารถกดค้างแล้วลาก (Long-press & drag) เพื่อจัดลำดับหมวดหมู่ได้ตามใจชอบ โดยระบบจะบันทึกลง SQLite ทันที
    - หน้าบันทึกด่วน (`QuickAddScreen`) และหน้าต่างเลือกหมวดหมู่ (`CategoryPickerSheet`) จะเรียงลำดับหมวดหมู่ตามที่ผู้ใช้จัดไว้ 100%
  - **การทดสอบความถูกต้อง**:
    - `flutter analyze` ผ่านฉลุย **No issues found! (0 error, 0 warning)**
    - `flutter test` ผ่านทั้งหมดครบถ้วน **154/154 tests passed** (100%)
    - `flutter build web --release --base-href /myfinance/` คอมไพล์ผ่านฉลุย 100%


  - **1. แก้ไขระบบสแกนลายนิ้วมือบน Chrome บน Android (WebAuthn / Passkeys)**:
    - แก้ไข Dart JS Interop annotation จาก `@JS('window.MyFinanceWebAuthn')` เป็น `@JS('MyFinanceWebAuthn')` เพื่อให้ Dart เชื่อมต่อไปยัง global object บนเบราว์เซอร์ได้อย่างถูกต้อง
    - ปรับปรุงการแปลง ArrayBuffer ของ Credential ID ด้วย `bufferToBase64Url` และ `base64UrlToUint8Array` ป้องกันปัญหา Padding error ใน `atob()`
    - ปรับ `userVerification` เป็น `preferred` เพื่อรองรับระบบล็อกหน้าจอและสแกนนิ้วบนอุปกรณ์ Android ทุกยี่ห้อ พร้อมแจ้งเตือนเป็นภาษาไทยกรณีเข้าเว็บผ่าน HTTP (ต้องเป็น HTTPS หรือ localhost ตามมาตรฐานความปลอดภัยสากล)
  - **2. เพิ่มพื้นที่แสดง Transactions ในหน้า Money**:
    - ลบปุ่มรายงาน (Report) และปุ่มเงินตกเบิกที่ซ้ำซ้อนออกจาก AppBar ด้านบน
    - ย่อกล่องค้นหาข้อความเดิมที่กินพื้นที่แนวตั้ง ให้กลายเป็นปุ่มไอคอนรูปแว่นขยาย (`Icons.search`) วางอยู่ข้างปุ่มตัวกรอง (`Icons.filter_list`)
    - ซ่อน/แสดงแถบค้นหาด้วยแอนิเมชันเปิด-ปิด (`AnimatedSize`) ลื่นไหล ไม่กินพื้นที่หน้าจอเมื่อไม่ได้ใช้งาน ทำให้พื้นที่แสดงรายการธุรกรรมเพิ่มขึ้นเกือบ 50%
  - **3. ปรับปรุงการเลือกหมวดหมู่ (Category Selection UX)**:
    - สร้าง `CategoryPickerSheet` แบบ Modal BottomSheet รองรับการค้นหาชื่อหมวดหมู่แบบเรียลไทม์ พร้อมไอคอนสวยงามและปุ่มสร้างหมวดหมู่ใหม่
    - นำมาแทนที่ `DropdownButtonFormField` เดิมในหน้าบันทึกด่วน (`QuickAddScreen`) และหน้าแก้ไขรายการ (`EditTransactionDialog`)
  - **4. ป้องกันการเผลอปิดแอปด้วยการปัด/กดย้อนกลับ (Double Back / Swipe Exit Confirmation)**:
    - ติดตั้ง `PopScope` ใน `MainShell`: เมื่อผู้ใช้ปัดขอบจอหรือกดย้อนกลับที่หน้าหลัก ระบบจะแจ้งเตือนแถบข้อความ "ปัดหรือกดย้อนกลับอีกครั้งเพื่อออกจากแอป" หากทำซ้ำภายใน 2 วินาทีถึงจะปิดแอป
  - **5. แอนิเมชันและ Micro-interactions ที่รวดเร็ว**:
    - เพิ่มแอนิเมชันเปลี่ยนแท็บเมนูหลักด้วย `AnimatedSwitcher` (Fade Transition 200ms) นุ่มนวลและตอบสนองทันใจ
    - เพิ่มระบบ Haptic Feedback ในปุ่มบันทึกธุรกรรม
  - **6. ปรับแต่งส่วนหัวและหน้าจอการตั้งค่า (Settings & Related Screens UI)**:
    - หัวข้อหน้าจอการตั้งค่า: เปลี่ยนเป็น `การตั้งค่า` (TH) / `Setting` (EN)
    - หน้ารายการประจำ (Recurring): ปรับสีกรอบ "กระแสเงินสด 30 วัน" ให้ใช้ `VaultTheme.surface` และตัวอักษรสีชัดเจน ไม่กลืนกับพื้นหลังมืด พร้อมย่นความยาวข้อความให้กระชับ
    - หน้าวางแผนภาษี (Tax Planning): ย่นชื่อหัวข้อ AppBar ให้สั้นกระชับเป็น "วางแผนภาษี"
    - หน้าติดตามเงินได้ต่างประเทศ (Foreign Remittance): ย่นชื่อหัวข้อ AppBar และย้ายเมนูเลือก "ปีที่นำเข้า" กับปุ่ม "ระบุจำนวนวันในไทย" ลงมาจัดวางในการ์ดควบคุมด้านบนของเนื้อหา body อย่างลงตัว ไม่เบียดกับหัวข้อ
  - **การทดสอบความถูกต้อง**:
    - `flutter analyze` ผ่านฉลุย **No issues found! (0 error, 0 warning)**
    - `flutter test` ผ่านทั้งหมดครบถ้วน **154/154 tests passed** (100%)
    - `flutter build web --release --base-href /myfinance/` คอมไพล์ผ่านฉลุย 100%

- [x] **Notion Income Work Period Alignment (P4P / Medical Shifts) & Webapp Biometrics (WebAuthn / Passkeys)**:
  - **1. จัดงวดรายรับ Notion ตามคอลัมน์ Monthly Overview (P4P & Shift Arrears)**:
    - ปรับปรุง `CsvImportParser` ให้ตรวจจับคอลัมน์ `Monthly Overview` ของ Notion: หากรายการรายรับ (เช่น P4P, ค่าเวร) ได้รับเงินในเดือนหนึ่ง (เช่น 25 กันยายน 2026) แต่งวดผลงานคือเดือนก่อนหน้า (เช่น `August 26`) วันที่ของรายการจะถูกจัดให้อยู่ในเดือนของงวดงาน (`2026-08-25`) ทันที
    - มีการต่อท้ายหมายเหตุ `(รับเงินจริง: 25/09/2026)` ใน Note อัตโนมัติ เพื่อให้คงประวัติวันที่เงินโอนเข้าบัญชีจริง
    - ทำให้หน้า **Monthly Overview** ของเดือนสิงหาคมและกันยายนแสดงยอดรายรับตรงตามงวดผลงานจริง 100%
  - **2. ปรับปรุงข้อมูลรายรับเดิมในฐานข้อมูลอัตโนมัติ (Database Auto-Alignment on Startup)**:
    - เพิ่มฟังก์ชัน `alignIncomeDatesWithWorkPeriod()` ใน `TransactionsDao`
    - ผูกเข้ากับ `AppDatabase.beforeOpen`: เมื่อเปิดแอป ระบบจะตรวจสอบรายการรายได้เดิมที่เคยนำเข้าและมีงวดเดือนระบุไว้ หากวันที่ยังไม่ตรงงวด ระบบจะย้ายวันที่ให้ตรงงวดเดือนนั้นให้อัตโนมัติทันที
  - **3. รองรับการสแกนลายนิ้วมือ/ใบหน้าบน Webapp (WebAuthn / Passkeys)**:
    - สร้าง `WebBiometricService` รองรับมาตรฐานความปลอดภัยสากล WebAuthn (Passkeys) ผ่านเบราว์เซอร์
    - เมื่อเปิด Webapp บนมือถือ Android (ผ่าน Chrome), คอมพิวเตอร์ Windows (ผ่าน Windows Hello) หรือ iPhone/Mac (ผ่าน Safari/Touch ID/Face ID) ระบบจะสามารถเรียกตัวสแกนนิ้วของเครื่องเพื่อปลดล็อกเข้าเว็บได้ทันที
    - มีระบบแยกแพลตฟอร์มแบบ Conditional Export ไม่กระทบ Native และ Unit Tests
  - **การทดสอบความถูกต้อง**:
    - เพิ่ม Unit Tests ใน `test/features/notion_income_import_test.dart` และ `test/core/web_biometric_test.dart`
    - `flutter analyze` ผ่านฉลุย **No issues found! (0 error, 0 warning)**
    - `flutter test` ผ่านทั้งหมดครบถ้วน **154/154 tests passed** (100%)
    - `flutter build web --release --base-href /myfinance/` คอมไพล์ผ่านฉลุย 100%

- [x] **Code & Package Cleanup, AES-256 Encrypted Backups, Biometrics/PIN Security, Year-End Run-Rate Fix & Real Cash Income**:
  - **1. ปรับปรุงสูตรพยากรณ์รายจ่ายสิ้นปี (Year-End Run-Rate Projection Formula)**:
    - ปรับปรุงการคำนวณใน `RunRateCalculator` ให้คิดยอดประมาณการช่วงที่เหลือของเดือนปัจจุบัน (`remainingCurrentMonthProjection`) ร่วมกับยอดสะสมจริง (`accumulatedMonthExpenseSatang`) ทำให้ตัวเลขพยากรณ์สิ้นปีแม่นยำและสมจริงตลอดทั้งเดือน
    - มี Unit Tests รองรับครบถ้วนใน `test/features/run_rate_test.dart`
  - **2. แสดงเฉพาะรายรับจริงใน Monthly Overview (Real Cash Income & Accrued Income Exclusion)**:
    - ปรับการคำนวณใน `MonthlySummaryScreen`, `FinancialHealthDao` และ `FinancialReportsService` ให้คำนวณเฉพาะรายรับที่ได้รับเงินเข้าบัญชีจริงแล้ว (`isCleared == true`)
    - ยอดตกเบิกหรือเงินค้างรับ (`isCleared == false`) จะถูกแยกแสดงเป็นป้ายสถานะ "ตกเบิกค้างรับ" อย่างโปร่งใส ไม่นำมาปะปนกับรายรับจริง
    - มี Unit Tests รองรับใน `test/features/quick_add_accrued_income_test.dart`
  - **3. ยกระดับความปลอดภัย PIN, สแกนลายนิ้วมือ และ Android (PIN & Biometric Security)**:
    - เพิ่ม `android:allowBackup="false"` ใน `AndroidManifest.xml` ป้องกันการดูดฐานข้อมูลผ่านคำสั่ง ADB หรือ Google Cloud Backup อัตโนมัติ
    - ย้ายการเก็บสถานะสวิตช์เปิด/ปิด PIN และสแกนลายนิ้วมือจาก SharedPreferences ไปยัง `FlutterSecureStorage` (เข้ารหัส Keystore บนฮาร์ดแวร์) พร้อม Migration อัตโนมัติ
    - เพิ่มระบบ Rate Limiting ป้องกันการสุ่มรหัส PIN (Brute-Force Lockout): หากใส่ผิดติดต่อกัน 5 ครั้ง ระบบจะระงับการลอง 30 วินาที
    - เพิ่มระบบปลดล็อกด้วย **สแกนลายนิ้วมือ (Biometrics)** อัตโนมัติทันทีที่เปิดแอป (Cold Start) และเมื่อสลับกลับมาจากเบื้องหลัง (Resume After Timeout) หากไม่ผ่านสามารถกดสลับไปใส่ PIN สำรองได้
  - **4. ระบบเข้ารหัสไฟล์สำรองข้อมูล AES-256 (Encrypted Backups with Backward Compatibility)**:
    - สร้าง `BackupCryptoHelper` รองรับการเข้ารหัสไบนารี SQLite ด้วย AES-256-CBC, PKCS7 Padding, Random Salt 16 ไบต์, Random IV 16 ไบต์ และ Magic Header `MYFINANCE_ENC_V1`
    - ไฟล์สำรองอัตโนมัติในเครื่อง (Rolling Backups) จะถูกเข้ารหัสด้วย Master Key ประจำเครื่องเสมอ ป้องกันการนำไฟล์ไปเปิดดูด้วย DB Browser หรือโปรแกรมภายนอก
    - การส่งออกไฟล์สำรอง (Export) มีกล่องให้ผู้ใช้เลือกตั้งรหัสผ่านเพิ่มเติมสำหรับนำไปเปิดที่เครื่องอื่นได้ หรือเว้นว่างเพื่อใช้คีย์ของเครื่องเดิม
    - หน้ากู้คืนข้อมูล (Restore) จะตรวจจับไฟล์เข้ารหัสอัตโนมัติและแสดงกล่องถามรหัสผ่าน (Password Prompt) พร้อมรองรับไฟล์แบ็กอัป SQLite รุ่นเก่าที่ไม่เข้ารหัสได้แบบ 100% ย้อนหลัง (Backward Compatible)
  - **5. ทำความสะอาดโค้ด/แพ็กเกจที่ไม่ใช้งาน เพื่อให้แอปเบาลง (Clean up unused code, packages, and assets)**:
    - ลบไฟล์ระบบ Google Drive Sync เก่า และ Hybrid Backup ที่ไม่ได้ใช้งาน 10 ไฟล์
    - ถอดแพ็กเกจที่ไม่จำเป็นออกจาก `pubspec.yaml` (อาทิ `go_router`, `googleapis`, `google_sign_in`, `connectivity_plus`, `archive` รวม 15 แพ็กเกจที่เกี่ยวข้อง)
    - ลบไฟล์ภาพ PNG ที่ไม่ได้ใช้งานออกจาก `assets/images/`
  - **การทดสอบความถูกต้อง**:
    - `flutter analyze` ผ่านฉลุย **No issues found! (0 error, 0 warning, 0 info)**
    - `flutter test` ผ่านทั้งหมดครบถ้วน **151/151 tests passed** (100%)

- [x] **Notion Invest Import (Funds, Gold, Stocks) & 4-Decimal Trade Precision & Medical Tax 40(1) Update**:
  - **1. จัดหมวดหมู่ภาษีรายได้การแพทย์เป็น 40(1) ทั้งหมด**:
    - ปรับปรุงการจัดหมวดหมู่ภาษีในตัวนำเข้า CSV Notion: ค่าเวรโรงพยาบาลที่สังกัด (เวรเหมา/รายชั่วโมง), ค่า DF ที่ตรวจในโรงพยาบาลสังกัด, เงินส่งเสริมพิเศษ (เบี้ยกันดาร), ค่าตรวจสุขภาพ, และเงินหมื่นไม่ทำเวชฯ ให้นับเป็น **มาตรา 40(1)** ตามประมวลรัษฎากรว่าด้วยสัญญาจ้างแรงงานของสถานพยาบาลต้นสังกัด
    - คงเหลือเฉพาะคลินิก/โรงพยาบาลภายนอก (TTCM) ที่ยังคงเป็น **มาตรา 40(2)** และรายการ Top-up ที่ไม่คิดภาษี
  - **2. ปรับปรุง UI หน้ารายการธุรกรรม & แก้ไขชื่อเพี้ยนจาก Notion Relation**:
    - ซ่อนเวลา (เช่น `00:00`) ใน ListTile ของหน้ารายการธุรกรรมเพื่อความกระชับสะอาดตา โดยยังคงแสดงวันที่และเวลาครบถ้วนเมื่อกดเข้าไปดู/แก้ไขรายละเอียด
    - ปรับปรุง `ImportExecutor` ให้ตัดข้อความ Notion relation link (เช่น `(https://app.notion.com/...)`) และชื่อซ้ำในวงเล็บออกอัตโนมัติ
    - เพิ่มฟังก์ชัน `cleanDistortedNotionNotes()` ใน `TransactionsDao` ที่รันตอนเปิดแอปอัตโนมัติ (`beforeOpen`) เพื่อชำระข้อมูลเดิมที่เคย import เข้าไปแล้วให้สะอาดสวยงามทันที
  - **3. รองรับราคาซื้อขายและ NAV ทศนิยมละเอียด 4 หลัก (Decimal 4-Precision)**:
    - เพิ่มคอลัมน์ `price_per_unit_original` และ `price_per_unit_thb` ในตาราง `InvestmentLots`
    - เพิ่มคอลัมน์ `market_price_original` และ `market_price_thb` ในตาราง `AssetPrices`
    - เพิ่ม Database Migration Version 9 รองรับการอัปเกรดฐานข้อมูลอย่างปลอดภัย
    - ปรับปรุง `InvestmentsDao`, `FifoEngine`, ไดอะล็อกซื้อขาย (`buy_sell_trade_dialog.dart`) และหน้าประเมินมูลค่า (`monthly_valuation_screen.dart`) ให้คำนวณและแสดงราคาต่อหน่วยด้วยทศนิยมละเอียด 4 ตำแหน่ง (เช่น NAV `31.9043`) โดยยอดเงินรวมยังคงเก็บเป็น integer สตางค์ตามกฎ Rule 4 อย่างเคร่งครัด
  - **4. ระบบนำเข้าพอร์ตการลงทุนจาก Notion (Notion_invest Import Wizard)**:
    - สร้าง `NotionFundsParser` และ `NotionFundsImportExecutor` รองรับการนำเข้ากองทุนรวม (Mutual Funds: K-SET50, SCBFP-SSF, กบข. ฯลฯ) พร้อมบันทึก NAV ปัจจุบันและคำนวณต้นทุนต่อหน่วยแบบ Decimal
    - สร้าง `NotionGoldParser` และ `NotionGoldImportExecutor` รองรับการนำเข้าทองคำดิจิทัล (MST-GOLD 99.99%) คำนวณ USD, FX Rate และ THB Satang พร้อมบันทึกราคาตลาด
    - เพิ่มหน้าต่างพรีวิว `NotionFundsPreviewDialog` และ `NotionGoldPreviewDialog` ให้ผู้ใช้ตรวจสอบ/เลือกรายการก่อนกดยืนยัน
    - ปรับปรุง `ImportWizardScreen` ให้มีตัวเลือกแทมเพลต "Notion กองทุนรวม" และ "Notion ทองคำ" พร้อมระบบ Auto-detect คอลัมน์อัตโนมัติเมื่อเลือกไฟล์ CSV
  - **การทดสอบความถูกต้อง**:
    - เพิ่ม Unit Test ใหม่ใน `test/features/notion_invest_funds_gold_test.dart` และ `test/features/investments_dao_test.dart`
    - อัปเดตและรัน `flutter test` ผ่านทั้งหมด **158/158 tests passed** (100%)
    - `flutter analyze` ผ่านฉลุย **0 error, 0 warning**


- [x] **Project Files Cleanup & Android APK Build**:
  - **1. คอมไพล์ไฟล์ติดตั้ง Android APK (Release)**:
    - รันคำสั่ง `flutter build apk --release` พร้อมตั้งค่า Android SDK 36, minSdk 26
    - สร้างไฟล์ติดตั้ง [MyFinance.apk](file:///c:/Projects/myfinance/MyFinance.apk) (40.6 MB) วางไว้ที่รากของโปรเจกต์สำหรับนำไปติดตั้งบนโทรศัพท์และแท็บเล็ต Android
  - **2. ทำความสะอาดไฟล์และโฟลเดอร์ที่ไม่ใช้งาน (Clean Up Project Files)**:
    - ลบโฟลเดอร์ `windows/` ออกตามความประสงค์ของผู้ใช้ที่เน้นใช้งานเฉพาะ Webapp และ Android App
    - ลบโฟลเดอร์ CSV ของ Notion ที่ซ้ำซ้อน (`Notion_expense/`, `Notion_income/`, `Notion_invest/`) โดยยังคงรักษาโฟลเดอร์ต้นฉบับ `Notion data/` ไว้ตามที่ผู้ใช้เลือก
    - ลบไฟล์ APK เวอร์ชั่นเก่า (`OURS.apk`)
    - ล้างโฟลเดอร์แคช `build/` ได้พื้นที่หน่วยความจำในเครื่องคืนมากว่า **2.12 GB**
    - ลบไฟล์สคริปต์เก่า (`implementation_plan.md`, `upload_github.ps1`)
  - **การทดสอบความถูกต้อง**:
    - `flutter analyze` ผ่านฉลุย `No issues found!` (0 error, 0 warning)
    - `flutter test` ผ่านทั้งหมด `151/151 tests passed` (100%)

- [x] **Designated Backup Folder Auto-Sync & 3-Version Rolling Backup**:
  - **1. ระบบกำหนดและจดจำโฟลเดอร์สำหรับสำรองข้อมูล (Designated Backup Folder)**:
    - เมื่อเข้าหน้าสำรองข้อมูล ระบบจะให้ผู้ใช้เลือกโฟลเดอร์ปลายทางที่ต้องการ (เช่น Google Drive for Desktop, OneDrive หรือ Documents)
    - ระบบจะสร้างโฟลเดอร์ `MyFinance_Backup` ให้อัตโนมัติและจดจำตำแหน่งไว้ใน SharedPreferences
    - แสดงที่อยู่โฟลเดอร์บนหน้าจอ พร้อมปุ่ม "เปลี่ยนโฟลเดอร์" และปุ่ม "สำรองเวอร์ชั่นใหม่ตอนนี้"
  - **2. สำรองข้อมูลอัตโนมัติทุกครั้งที่มีการบันทึก/แก้ไข/ลบ (Continuous Rolling Backup)**:
    - เชื่อมต่อตัวตรวจจับการเปลี่ยนแปลงธุรกรรมผ่าน `TransactionsDao.onLedgerModified` และ Drift stream listener
    - ทำงานอัตโนมัติเมื่อมีการ เพิ่ม (`insert`), แก้ไข (`update`), ลบ (`softDelete`) หรือเคลียร์รายการธุรกรรม
    - มีระบบ Debounce 1.5 วินาที เพื่อประสิทธิภาพ ไม่เขียนไฟล์ซ้ำซ้อน
    - บันทึกไฟล์ในรูปแบบ `myfinance_backup_YYYYMMDD_HHmmss.db` พร้อมตัดทิ้งอัตโนมัติให้คงเหลือ **3 เวอร์ชั่นล่าสุด** เสมอ
  - **3. กู้คืนข้อมูลแบบค้นหาจากโฟลเดอร์หลักเป็นหลัก (Smart Restore from 3 Rolling Versions)**:
    - แสดงการ์ด 3 เวอร์ชั่นล่าสุดในโฟลเดอร์ พร้อมเวลา ขนาดไฟล์ และป้ายกำกับ `[ล่าสุด]`, `[ก่อนหน้า]`, `[เก่ากว่า]`
    - เมื่อผู้ใช้กด "กู้คืน" ในเวอร์ชั่นใด ระบบจะเปิดกล่องพรีวิวสรุปข้อมูล (จำนวนบัญชี, ธุรกรรม, วันที่ล่าสุด) ให้ตรวจสอบความถูกต้องก่อนกดยืนยันเสมอ
    - มีปุ่มทางเลือก "เลือกไฟล์สำรองอื่นจากเครื่อง..." และ "ส่งออกแชร์ไฟล์สำรอง (.db)"
  - **การทดสอบความถูกต้อง**:
    - เพิ่ม Unit Tests ใน `backup_restore_service_test.dart` ครอบคลุมการตั้งค่าโฟลเดอร์, การจำกัด 3 เวอร์ชั่นล่าสุด (ลบไฟล์เก่าทิ้ง), และ callback การแจ้งเตือนธุรกรรม
    - ผ่านการทดสอบทั้งหมด `151/151 tests passed` (100%)
    - `flutter analyze` ผ่านฉลุย `No issues found!` (0 error, 0 warning)


- [x] **Fix GitHub Actions Web Deployment & Conditional SQLite FFI**:
  - **1. แก้ไขข้อผิดพลาด Flutter Web Build บน GitHub Actions (Runs #42 and #43)**:
    - สาเหตุ: ไฟล์ `backup_restore_service.dart` มีการ import `package:sqlite3/sqlite3.dart` โดยตรง ซึ่งดึง `dart:ffi` เข้ามา ทำให้ Flutter Web คอมไพล์ไม่ผ่าน (`Error: Only JS interop members may be 'external'`)
    - แก้ไข: แยกการทำงานของ SQLite Inspector ออกมาเป็นระบบ Conditional Export ในโฟลเดอร์ `lib/core/services/backup_inspect/`
      - `backup_inspector_native.dart`: สำหรับ Windows / Android (ทำงานผ่าน SQLite FFI ตรวจดูตารางและสรุปข้อมูลในไฟล์ `.db`)
      - `backup_inspector_stub.dart`: สำหรับ Web (Web-safe stub ปลอดภัยจาก FFI)
      - `backup_inspector.dart`: ทำการเลือก export ไฟล์ตามแพลตฟอร์มอัตโนมัติ (`if (dart.library.io)`)
  - **การทดสอบความถูกต้อง**:
    - ทดสอบคอมไพล์ `flutter build web --release --base-href /myfinance/` สำเร็จเรียบร้อย 100%
    - ทดสอบ `flutter analyze` ผ่านฉลุย `No issues found!` (0 error, 0 warning)
    - ทดสอบ `flutter test` ผ่านทั้งหมด `148/148 tests passed`
    - Push ขึ้น GitHub repository สำเร็จเรียบร้อย


- [x] **Local File Backup & Restore System with Pre-Restore Inspection**:
  - **1. ยกเครื่องระบบสำรองข้อมูลเป็นแบบไฟล์ในเครื่อง (Local File Backup / Share)**:
    - ตัดการพึ่งพา Google Drive API และ OAuth ที่ซับซ้อนออก เพื่อให้คุณและแฟนใช้งานแยกข้อมูลกันได้อย่างอิสระ 100% ปราศจากปัญหาล็อกอินหลุดหรือ People API error
    - สร้าง `BackupRestoreService` รองรับการสำรองและกู้คืนฐานข้อมูล SQLite โดยตรง
  - **2. ฟังก์ชันส่งออกและแชร์ไฟล์สำรอง (Export & Share)**:
    - มีปุ่ม "ส่งออกและแชร์ไฟล์สำรอง (.db)" ที่ทำการ flush checkpoint ของฐานข้อมูล แล้วเปิดหน้าต่างแชร์ของมือถือ (Share Sheet) ให้ผู้ใช้เลือกบันทึกลง Google Drive ของตัวเอง, ส่งเข้า LINE หรือเซฟลงโฟลเดอร์ในเครื่อง
    - บน Windows Desktop เปิดหน้าต่างเลือกตำแหน่งบันทึกไฟล์ลงคอมพิวเตอร์
  - **3. กล่องพรีวิวสรุปข้อมูลก่อนกดยืนยันกู้คืน (Pre-Restore Preview Summary)**:
    - เมื่อผู้ใช้เลือกไฟล์ `.db` ระบบจะเข้าไปอ่านข้อมูลภายในไฟล์แบบ Read-Only ทันที
    - แสดงกล่องพรีวิวสรุป: ชื่อและขนาดไฟล์, จำนวนบัญชีและรายชื่อบัญชีตัวอย่าง, จำนวนรายการธุรกรรม และวันที่บันทึกธุรกรรมล่าสุด เพื่อให้ผู้ใช้ตรวจสอบความถูกต้องก่อนกดยืนยัน
  - **4. ระบบสำรองข้อมูลฉุกเฉิน (Safety Backups)**:
    - สร้างสำเนาฉุกเฉินของฐานข้อมูลเดิมในเครื่องอัตโนมัติก่อนเขียนทับข้อมูลเสมอ พร้อมระบบประวัติให้กดย้อนกลับ (Rollback) ได้ทุกเมื่อ
  - **5. ปรับหน้า Settings (การตั้งค่า)**:
    - เปลี่ยนเมนูจาก "Google Drive Sync" เป็น "สำรองและกู้คืนข้อมูล (Backup & Restore)"
  - **การทดสอบความถูกต้อง**:
    - เพิ่ม Unit Tests ใน `backup_restore_service_test.dart` ครอบคลุมการ inspect ไฟล์ฐานข้อมูลและการอ่านประวัติ Safety Backup
    - ผ่านการทดสอบทั้งหมด `148/148 tests passed` (100%)
    - `flutter analyze` ผ่านฉลุย `0 error, 0 warning`

- [x] **Google Drive Sync Streamlining & Auto-Connect Prevention**:
  - **1. ป้องกันการแอบเชื่อมต่อ Google อัตโนมัติเมื่อเปิดหน้าตั้งค่า (Prevent Auto Silent Sign-In)**:
    - เพิ่มฟังก์ชัน `getCachedUser()` ใน `GoogleAuthService` เพื่ออ่านข้อมูลผู้ใช้จาก secure storage ในเครื่องโดยตรง โดยไม่กระตุ้นการล็อกอินเงียบ (Silent Sign-In) ไปยัง Google
    - แก้ไข `SettingsScreen` และ `CloudSyncScreen` ให้เรียกใช้ `getCachedUser()` ในช่วงโหลดหน้าจอ ทำให้เวลาผู้ใช้กดเข้าหน้า More / Settings แอปจะไม่แอบเชื่อมต่อ Google เองโดยไม่ได้รับอนุญาต
  - **2. รวบปุ่มล็อกอิน ขอสิทธิ์ และซิงค์เหลือขั้นตอนเดียว (One-Click Google Sign-In & Sync)**:
    - ตัดปุ่ม "Authorize" และขั้นตอนขอสิทธิ์หลายชั้นออกไป
    - เมื่อผู้ใช้กดปุ่ม **"เข้าสู่ระบบ (Sign In)"** ระบบจะทำขั้นตอนล็อกอิน ขอสิทธิ์ Google Drive และตรวจซิงค์ข้อมูลให้เสร็จสิ้นในคลิกเดียว
  - **3. หน้าจอซิงค์เรียบง่าย ปรับเป็นปุ่มเดียว "ซิงค์ข้อมูลตอนนี้ (Sync Now)"**:
    - ตัดปุ่ม "ส่งขึ้น Drive" และ "ดึงจาก Drive" ที่ซ้ำซ้อนออก
    - รวมเป็นปุ่มเดียว **"ซิงค์ข้อมูลตอนนี้ (Sync Now)"** ซึ่งทำงานแบบสองทิศทางอัจฉริยะ (ถ้า Drive มีข้อมูลใหม่กว่าจะดึงมา / ถ้าเครื่องมีข้อมูลใหม่กว่าจะส่งขึ้น)
    - ปรับหน้าจอให้เหลือเฉพาะส่วนจำเป็น: การ์ดบัญชี Google (มีปุ่มออกจากระบบ), สถานะการเชื่อมต่อ และปุ่ม Sync Now
  - **การทดสอบความถูกต้อง**:
    - ผ่านการทดสอบทั้งหมด `145/145 tests passed` (100%)
    - `flutter analyze` ผ่านฉลุย `0 error, 0 warning`

- [x] **UI & Theme Refinement (เอาช่องค่าธรรมเนียมออก, ปรับแต่งหน้าต่างเงินปันผล, ปรับโทน Lumi Dark Mode)**:
  - **1. เอาช่องค่าธรรมเนียมออกจากบันทึกรายรับและรายจ่าย (Fee Removal)**:
    - ตัดช่อง "ค่าธรรมเนียม" ออกจากหน้าต่างบันทึก/แก้ไขธุรกรรมประเภทรายรับ (`income`) และรายจ่าย (`expense`) เพื่อความกระชับและตรงกับการใช้งานจริง
    - คงช่อง "ค่าธรรมเนียม" ไว้เฉพาะรายการโอนเงินระหว่างบัญชี (`transfer`) เท่านั้น
    - ป้องกันการบันทึกค่าธรรมเนียมตกค้างในรายรับ-รายจ่าย โดยระบบจะรีเซ็ตค่าธรรมเนียมเป็น 0 สตางค์อัตโนมัติหากไม่ใช่รายการโอนเงิน
  - **2. ปรับปรุงหน้าต่างบันทึกเงินปันผล (Dividend Dialog Contrast & Renaming)**:
    - แก้ไขชื่อหัวข้อ Dialog และปุ่มกดให้เป็น **"บันทึกเงินปันผล" (Record Dividend)** ให้ตรงกับปุ่มเปิด
    - แก้ไขคอนทราสต์การมองเห็นของกล่องเครดิตภาษีเงินปันผล (Thai Dividend Tax Credit) และกล่องสรุปเงินปันผลสุทธิ (Net Preview) โดยเปลี่ยนจากการใช้สีพื้นหลังคงที่ (`shade50`) มาใช้สีที่ปรับเปลี่ยนตามธีม (`isDark ? surfaceContainerHighest : Colors.blue/green.shade50`) ทำให้ตัวอักษรและตัวเลขอ่านได้ชัดเจน 100% ไม่กลืนกับพื้นหลังในโหมดมืด
  - **3. ปรับโหมดมืดของธีม Lumi ให้สบายตาและไม่สว่างจ้า (Lumi Dark Mode Enhancement)**:
    - ปรับโทนสีพื้นหลังหลักของ Lumi Theme Dark Mode ใน `lumi_theme.dart` ให้อยู่ในโทน Midnight Plum เข้มลึก (`0xFF120E18` และ surface `0xFF1B1522`)
    - ปรับสีแท็บเมนูข้างซ้าย (Desktop NavigationRail) ไม่ให้กลืนและสบายตา
    - ปรับปรุงการ์ดหน้าแรกของธีม Lumi ทั้ง 6 การ์ดให้รองรับโหมดมืดอย่างสมบูรณ์:
      - `BudgetHeroCard`: ไล่เฉดสีพื้นหลังเข้มสบายตา ปรับสีกรอบ แถบหลอดงบประมาณ และป้ายหัวข้อ
      - `FinancialOverviewCard`: ปรับพื้นหลังการ์ด และปรับเฉดสีป้ายกล่องรายรับ-รายจ่าย-กระแสเงินสดให้มีคอนทราสต์นุ่มนวล
      - `CreditCardCard`: ปรับเฉดสีฟ้าเข้ม Midnight Blue สำหรับโหมดมืด
      - `PortfolioCard`: ปรับเฉดสีเขียวเข้ม Deep Forest Green สำหรับโหมดมืด
      - `RecentActivityCard`: ปรับสีพื้นหลัง เส้นคั่นรายการ ป้ายไอคอน และข้อความ
      - `LumiTipCard`: ปรับกล่องคำแนะนำและกล่องแจ้งเตือน ให้มีสีพื้นหลังเข้มสบายตา ตัวการ์ตูนน้องแมว Momo มีกรอบคอนทราสต์ชัดเจน
  - **การทดสอบความถูกต้อง**:
    - ผ่านการทดสอบทั้งหมด `145/145 tests passed` (100%)
    - `flutter analyze` ผ่านฉลุย `0 error, 0 warning`


  - **1. ปรับปรุงหัวข้อ AppBar ด้านบนไม่ให้ตัดคำ (No Truncation / 2-Line Wrap)**:
    - ปรับ AppBar ในหน้าที่มีขนาดยาว (`Financial Health & Forecast`, `Liabilities & Insurance Registry`, `Accrued Income & Arrears Tracker`, `Foreign Remittance Tracking`, `Credit Card Summary`, `Monthly Valuation`, `Recurring Rules`) ให้รองรับ 2 บรรทัด (`maxLines: 2, softWrap: true`), ขนาดฟอนต์ 15-16px อ่านสบายตา ไม่ถูกตัดคำเป็น `...` บนมือถือ
  - **2. & 3. ปรับปรุงหน้าต่างแก้ไขรายการธุรกรรม (Edit Transaction Dialog)**:
    - **ล็อกประเภทธุรกรรม (Lock Transaction Type)**: นำปุ่มเปลี่ยนประเภท (SegmentedButton) ออก ป้องกันความผิดพลาดของบัญชี โดยแสดงเป็น Type Badge สีระบุสถานะชัดเจน (`[รายจ่าย]`, `[รายรับ]`, `[โอนเงิน]`)
    - **จัดเรียงลำดับใหม่สำหรับ รายจ่าย และ โอนเงิน**: 1. ชื่อ transaction / บันทึก -> 2. จำนวนเงิน -> 3. หมวดหมู่ (หรือบัญชีปลายทาง) -> 4. บัญชี -> 5. วันที่และเวลา -> 6. ป้ายกำกับ (Tag) และค่าธรรมเนียม
    - **จัดเรียงลำดับใหม่สำหรับ รายรับ**: 1. ชื่อ transaction / บันทึก -> 2. จำนวนเงิน -> 3. หมวดหมู่ -> 4. บัญชี -> 5. วันที่และเวลา -> 6. ประเภทภาษีเงินได้บุคคลธรรมดา -> 7. ภาษีหัก ณ ที่จ่าย และ ค่าธรรมเนียม -> 8. ป้ายกำกับ (Tag)
  - **4. กระชับหน้าต่างแก้ไขรายการ (Compact One-Screen Layout)**:
    - ปรับระยะห่างเป็น 8px, กำหนด `isDense: true` และ `contentPadding` ทุกช่องกรอก
    - วางช่อง "ภาษีหัก ณ ที่จ่าย" และ "ค่าธรรมเนียม" คู่กันในแถวเดียวแบบ 2 คอลัมน์
    - ปรับตัวเลือกวันที่เป็น InputDecorator กะทัดรัด ทำให้ฟิลด์ทั้งหมดแสดงได้ครบในหน้าจอเดียวไม่ต้องเลื่อนเยอะ
  - **5. แก้ไขรายจ่ายไม่ให้มีสถานะตกเบิก/ค้างรับ (Clear Arrears for Expenses)**:
    - อัปเดต `CsvImportParser` ให้บิลและรายการที่ไม่ใช่รายรับมี `isCleared = true` เสมอ ไม่ติดสถานะตกเบิก
    - อัปเดต `transaction_list_screen.dart` และ `import_preview_dialog.dart` ให้แสดงป้าย `[ค้างรับ/ตกเบิก]` เฉพาะเมื่อเป็นรายรับ (`income`) เท่านั้น
    - เพิ่มคำสั่งอัตโนมัติ `cleanupUnclearedExpenses` ใน `beforeOpen` ของฐานข้อมูล เพื่อเคลียร์รายการรายจ่ายเดิมที่เคยติดป้ายตกเบิกออกทั้งหมดอัตโนมัติเมื่อเปิดแอป
  - **6. แก้ไขปุ่มซื้อสินทรัพย์ทับกับ THB บนมือถือ (Portfolio Uninvested Assets)**:
    - ปรับปรุงการ์ดสินทรัพย์ที่ยังไม่ได้ลงทุนใหม่ ให้ชื่อหุ้น ป้ายสกุลเงิน `THB` และป้ายตลาด จัดวางแบบ `Wrap` ภายใน `Expanded`
    - รวมปุ่มแก้ไขและปุ่มลบไว้ในเมนู 3 จุด (`PopupMenuButton`) เพื่อประหยัดพื้นที่
    - ปุ่ม **"ซื้อ"** วางอยู่ฝั่งขวาสุดอย่างเป็นระเบียบ ไม่มีทางทับซ้อนกับป้าย `THB`
  - **การทดสอบความถูกต้อง**:
    - เพิ่ม Unit Tests ใน `notion_bill_import_test.dart` ครอบคลุมการ parse บิลที่มี `Property: No` ให้เป็น `isCleared = true` และการรัน `cleanupUnclearedExpenses`
    - ผ่านการทดสอบทั้งหมด `145/145 tests passed` (100%) และ `flutter analyze 0 error, 0 warning`


- [x] **Webapp Google Drive Sync & Database File Restore/Export Fix**:
  - **ปลดล็อก Deadlock การเชื่อมต่อ Google Drive บน Webapp**:
    - แก้ไขปัญหาปุ่ม "ส่งขึ้น Drive" และ "ดึงจาก Drive" เป็นสีเทากดไม่ได้เมื่อเข้าสู่ระบบด้วย Gmail
    - เพิ่มแบนเนอร์แจ้งเตือนสถานะรอสิทธิ์ Drive พร้อมปุ่ม **"เชื่อมต่อสิทธิ์ (Authorize)"** ให้ผู้ใช้กดขอสิทธิ์ Drive ได้ใน 1 คลิก
    - เมื่อผู้ใช้กดปุ่ม "ดึงจาก Drive" หรือ "ส่งขึ้น Drive" ระบบจะขอสิทธิ์ OAuth และเปิดหน้าต่างยืนยันอัตโนมัติ
  - **ปรับปรุงการค้นหาไฟล์ฐานข้อมูลข้ามโฟลเดอร์ใน Google Drive Cloud (`GoogleDriveApiClient`)**:
    - รองรับการค้นหาไฟล์ฐานข้อมูล `myfinance_vault.db` และ metadata จากทั้งโฟลเดอร์ `MyFinance_Backup`, โฟลเดอร์ `VAULT` (ที่ Google Drive for Desktop ซิงค์มาจาก Windows) รวมถึงค้นหาทั่วทั้ง Drive
  - **ขยายขอบเขตสิทธิ์ Google Drive OAuth**:
    - รองรับทั้ง `https://www.googleapis.com/auth/drive` และ `https://www.googleapis.com/auth/drive.file` เพื่อให้อ่านไฟล์ที่ซิงค์จากคอมพิวเตอร์ได้
  - **เพิ่มตัวเลือกนำเข้าไฟล์ฐานข้อมูลตรง (Direct Database File Options)**:
    - เพิ่มตัวเลือก **"กู้คืนจากไฟล์ฐานข้อมูลในเครื่อง (.db / .sqlite)"** ในหน้า Sync ให้ผู้ใช้นำเข้าไฟล์ฐานข้อมูลเข้าเบราว์เซอร์หรือเครื่องได้ทันที
    - เพิ่มปุ่ม **"ดาวน์โหลดไฟล์สำรอง (.db) ลงเครื่อง"** บน Webapp ให้ดาวน์โหลดสำเนา SQLite ออกมาเป็นไฟล์ได้โดยตรง
  - **การทดสอบความถูกต้อง**:
    - เพิ่มชุดทดสอบ Unit Tests สำหรับ `restoreFromDatabaseBytes` และ `restoreFromDatabasePath`
    - ผ่านการทดสอบทั้งหมด `143/143 tests passed` (100%) และ `flutter analyze 0 error, 0 warning`

- [x] **Notion Bill CSV Import & Automatic Tax Deduction Engine (กบข. และประกันออมทรัพย์)**:
  - **นำเข้า Notion Bills ลง Expense โดยตรง**:
    - รองรับการ Export ไฟล์ Bill Tracker จาก Notion เข้าสู่ระบบรายจ่าย (Expense) ของแอปโดยตรง
    - ระบบจำแนกหมวดหมู่อัตโนมัติจากชื่อบิล (เช่น คอนโด/หอพัก -> ที่อยู่อาศัย, ค่าน้ำ/ค่าไฟ/Coway/Wifi/มือถือ -> สาธารณูปโภค, Netflix/Spotify/Xbox -> บันเทิง, ค่าพ่อแม่ -> ของขวัญ, ตรอ./พรบ. -> การเดินทาง)
    - **ไม่สร้าง Recurring Rules อัตโนมัติ** (ตามคำสั่ง เพื่อให้ผู้ใช้จัดการตั้งค่าใหม่ด้วยตัวเอง)
  - **แยกหมวดหมู่เงินสะสม กบข. ชัดเจน**:
    - บันทึกชื่อหมวดหมู่ `"เงินสะสม กบข."` พร้อมไอคอนสถาบันการเงินและสีเขียวเฉพาะตัว
    - ติดแท็กพิเศษ `deduction:gpf` ในรายการธุรกรรมอัตโนมัติ
  - **แท็กลดหย่อนภาษีประกันออมทรัพย์**:
    - บันทึกรายการ "ประกันออมทรัพย์" เข้าหมวดประกัน/สุขภาพ (`Healthcare`) พร้อมติดแท็ก `deduction:life_insurance`
  - **เชื่อมโยงเครื่องมือคำนวณภาษี (Tax Calculation Engine & Financial Reports Service)**:
    - เชื่อมข้อมูลรายจ่ายที่ติดแท็ก `deduction:gpf` และ `deduction:life_insurance` เข้าสู่การคำนวณลดหย่อนภาษี ภ.ง.ด. ประจำปีโดยอัตโนมัติ
    - เงินสะสม กบข. คำนวณเพดานตามกฎหมายสรรพากร (สูงสุดไม่เกิน 30% ของเงินได้พึงประเมิน และไม่เกิน 500,000 บาทในกลุ่มเกษียณ RMF/SSF/PVD/กบข.)
    - เบี้ยประกันชีวิต/ประกันออมทรัพย์ คำนวณหักลดหย่อนได้ตามจ่ายจริง สูงสุด 100,000 บาท
    - รายงานภาษี (PDF/Excel และหน้า Tax Audit Trail) แสดงยอดลดหย่อนและสูตรการคำนวณที่ถูกต้องครบถ้วน
  - **การทดสอบความถูกต้อง**:
    - เพิ่ม Unit Test ครอบคลุม 100% ทั้งการนำเข้า CSV, การแยกหมวดหมู่, การแท็ก, และการคำนวณภาษี
    - ผ่านการทดสอบทั้งหมด `141/141 tests passed` และ `flutter analyze 0 error, 0 warning`

---

## 1. สิ่งที่ทำไปแล้วใน Phase 0 & Phase 1 (Done)

### Phase 0: รากฐานระบบ (Foundation)
- [x] **โครงสร้างโปรเจกต์ Flutter**: สถาปัตยกรรมแบบ Feature-First พร้อม Riverpod + Drift SQLite
- [x] **โครงสร้างฐานข้อมูล SQLite/Drift 17 ตาราง**: Currencies, FX Rates, Accounts, Categories, Transactions, Audit Logs, Credit Card Installments, Assets, Investment Lots, Investment Sales, Asset Prices, Budgets, Recurring Rules, Tax Deductions, Foreign Remittances, Financial Health Settings, Balance Snapshots
- [x] **ระบบคำนวณเงินและ FX (Unit Tested 100%)**:
  - `Money`: เก็บเงินหน่วยสตางค์ (`int`) ปลอดภัยจากปัญหาเศษทศนิยมคลาดเคลื่อน
  - `FxRate`: คำนวณอัตราแลกเปลี่ยนด้วย `Decimal` 6 ตำแหน่ง
- [x] **ระบบภาษาและการแสดงผล**:
  - `flutter_localizations` พร้อมไฟล์ `app_th.arb` และ `app_en.arb`
  - Noto Sans Thai Font Family

### Phase 1: บัญชีและรายรับรายจ่าย (Accounts, Transactions & Core MVP)
- [x] **Schema Migration v1 -> v2**:
  - เพิ่ม `fee_thb_satang` และ `tag` ในตาราง `transactions`
  - รองรับการอัปเกรดฐานข้อมูลแบบไร้รอยต่อพร้อม Rollback strategy
- [x] **Accounts Engine & Real-time Balance**:
  - คำนวณยอดเงินคงเหลือแบบ Real-time จาก Ledger (หักลบรายจ่าย, โอนออก, และค่าธรรมเนียม)
  - รองรับการปิดการใช้งานบัญชี (`is_active = false`) โดยคงยอดในประวัติบัญชี แต่ไม่นับรวมใน Net Worth ของ Dashboard รวม
- [x] **Credit Card Engine**:
  - ตัดรอบบิลทุกวันที่ 23 ของเดือน (ยึดตามวันจริงไม่เลื่อนวันหยุด)
  - แบ่งยอดใช้จ่ายเป็น "รอบปัจจุบัน (รอตัดรอบ)" และ "ยอดเรียกเก็บแล้ว (รอบที่แล้ว)"
  - คำนวณจำนวนวันที่เหลือก่อนถึงวันตัดรอบ
  - การจ่ายชำระหนี้บัตรเครดิตทำผ่านการโอนเงิน (Transfer) ไม่เกิดรายจ่ายซ้ำซ้อน
- [x] **3-Tap Quick Entry & Transactions Engine**:
  - บันทึกรายการด่วน รายรับ / รายจ่าย / โอนเงิน (THB -> USD พร้อมคำนวณและล็อกเรต FX)
  - ปุ่มลอกรายการล่าสุด (Duplicate Last) กดครั้งเดียวดึงข้อมูลล่าสุดมาให้
  - แป้นตัวเลข Numeric Keypad สวยงาม ใช้ง่ายบนมือถือ
  - Append-only Audit Log บันทึกทุกครั้งที่มีการแก้ไขหรือลบรายการ (Soft Delete)
- [x] **Budgeting Engine (งบประมาณรายเดือน)**:
  - เพดานงบประมาณรายหมวดหมู่แบบ Strict Non-Rollover (ไม่ยกยอดไปเดือนถัดไป)
  - แจ้งเตือนสถานะเมื่อใช้เกิน 80% (สีส้ม) และเกิน 100% (สีแดง)
- [x] **Dashboard ภาพรวมการเงิน**:
  - การ์ดด้านบนแสดง "เงินที่ใช้ได้เหลือเดือนนี้" ตัวใหญ่ชัดเจน
  - สรุปรายรับ, รายจ่าย, เงินออม
  - กราฟวงกลม (Donut Chart) แสดงสัดส่วนรายจ่ายตามหมวดหมู่
  - กราฟแท่ง (Bar Chart) แสดงแนวโน้มรายรับ-รายจ่ายย้อนหลัง 6 เดือน
- [x] **Android Home Widgets (2x2 และ 4x2)**:
  - วิดเจ็ตขนาด 2x2 แสดงเงินคงเหลือและยอดใช้ไป พร้อมปุ่มกด "+ บันทึกไว"
  - วิดเจ็ตขนาด 4x2 แสดงแถบความคืบหน้างบประมาณรายเดือนและยอดรวม
  - อัปเดตข้อมูลในวิดเจ็ตทันทีเมื่อบันทึกรายการ
- [x] **ระบบความปลอดภัย PIN 6 หลัก และ สแกนลายนิ้วมือ**:
  - แฮชรหัสผ่านด้วย SHA-256 พร้อม Salt ผ่าน `flutter_secure_storage`
  - ปลดล็อกด้วยลายนิ้วมือ (`local_auth`)
  - หน้าเปิดแอปและหน้าบันทึกด่วน (Quick Add) เข้าได้ทันทีโดยไม่ต้องใส่ PIN
  - ป้องกันหน้าบัญชี, ประวัติรายการ, งบประมาณ, และตั้งค่า ด้วย PIN/ลายนิ้วมือ
  - จำสถานะการล็อกอินได้ 15 นาทีหลังจากยืนยันตัวตนสำเร็จ
- [x] **Settings & Local-First Database Backup**:
  - สลับภาษาไทย / อังกฤษ
  - สลับโหมดสว่าง / โหมดมืด (Light / Dark Theme)
  - ส่งออกสำเนาไฟล์ฐานข้อมูล SQLite (.db) ผ่านระบบแชร์ของเครื่อง พร้อมแจ้งเตือนความปลอดภัย
- [x] **การจัดการบัญชี และ ถังขยะกู้คืนข้อมูล 30 วัน (Account Trash Bin & Cascade Soft Delete)**:
  - เพิ่มปุ่มลบบัญชีในหน้าหน้ารายละเอียดบัญชี โดยเมื่อลบ บัญชีจะหายไปจากหน้ารวมบัญชีทันที พร้อมซ่อนรายการธุรกรรมทั้งหมดของบัญชีนั้น
  - ข้อมูลที่ถูกลบจะย้ายไปอยู่ใน "ถังขยะ (Trash Bin)" ในเมนูตั้งค่า แสดงเวลานับถอยหลัง 30 วัน
  - สามารถกด "กู้คืน" (Restore) กลับคืนมาได้ทั้งบัญชีและรายการธุรกรรม หรือกด "ลบถาวร"
  - ระบบล้างข้อมูลบัญชีที่อยู่ในถังขยะเกิน 30 วันให้อัตโนมัติ (`cleanupExpiredDeletedAccounts`)
  - เพิ่มฟังก์ชันสร้างบัญชีใหม่ (Create Custom Account) พร้อมกำหนดยอดเริ่มต้นและประเภทบัญชี
- [x] **การแก้ไขรายการธุรกรรม (Transaction Edit & Audit Log)**:
  - แต่ละรายการในประวัติธุรกรรม (ทั้งหน้ารวมและหน้ารายละเอียดบัญชี) สามารถแตะเพื่อเปิดหน้าต่างแก้ไข (Edit Dialog)
  - รองรับการแก้ไขประเภท, จำนวนเงิน, หมวดหมู่, บัญชีต้นทาง/ปลายทาง, วันและเวลา, ค่าธรรมเนียม, หมายเหตุ และแท็ก
  - ทุกการแก้ไขหรือลบรายการจะถูกบันทึกประวัติการเปลี่ยนแปลงลงตาราง `audit_logs` อย่างเคร่งครัดตามกฎ Append-only Ledger
  - อัปเดตข้อมูลบน Android Home Widget อัตโนมัติทันทีที่มีการแก้ไข
- [x] **คู่มือการติดตั้ง (Build Guide)**:
  - เอกสาร `docs/BUILD_GUIDE_TH.md` ภาษาไทยอย่างละเอียดสำหรับผู้ใช้งานทั่วไปที่ไม่เคยเขียนโค้ด

---

### Phase 2: ระบบพอร์ตการลงทุนและการคำนวณต้นทุน FIFO (Investments & Portfolio Engine)
- [x] **Schema Migration v2 -> v3**:
  - เพิ่มคอลัมน์ `market`, `note`, `extra_details_json` ในตาราง `assets`
  - เพิ่มคอลัมน์ `total_cost_thb_satang`, `remaining_cost_thb_satang` ในตาราง `investment_lots`
  - เพิ่มคอลัมน์ `price_gain_loss_thb_satang`, `fx_gain_loss_thb_satang`, `sell_fx_rate`, `buy_fx_rate` ในตาราง `investment_sales`
  - เพิ่มตารางใหม่ `investment_incomes` เพื่อจัดเก็บประวัติเงินปันผล/ดอกเบี้ย พร้อมการหักภาษี ณ ที่จ่าย และเครดิตภาษีเงินปันผล
- [x] **Pure FIFO Domain Engine**:
  - ตัดต้นทุนแบบ FIFO แบบ Deterministic (`buyDate ASC, createdAt ASC, id ASC`)
  - ปันส่วนค่าธรรมเนียมการขายตามสัดส่วนหน่วยสินทรัพย์ โดย Lot สุดท้ายจะดูดซับเศษสตางค์ทำให้ผลรวมตรง 100% เสมอ
  - นโยบาย Residual Balance on Lot Close คุ้มครองไม่ให้มีเศษสตางค์ตกค้างเมื่อปิด Lot
  - แยกกำไร/ขาดทุนจากราคา (Price P&L) และจากอัตราแลกเปลี่ยน (FX P&L) ชัดเจนทุก Lot
  - ทดสอบ Unit Test 100% ครอบคลุมทั้งกรณีซื้อหลายรอบขายข้าม Lot, คริปโตทศนิยม 8 ตำแหน่ง, การซื้อขายสกุล USD, และข้อผิดพลาดเมื่อขายเกินจำนวนที่มี
- [x] **Investments DAO (Database Access Object)**:
  - ระบบบันทึกการซื้อ (`recordBuyTrade`): สร้าง Lot และบันทึกรายจ่ายลงใน Ledger พร้อมล็อกเรต FX
  - ระบบบันทึกการขาย (`recordSellTrade`): ตัดขายแบบ FIFO, บันทึกลงตาราง `investment_sales`, และบันทึกรายรับสุทธิลง Ledger
  - ระบบคำนวณ FIFO ย้อนหลังอัตโนมัติ (`recalculateFifoForAsset`): เมื่อมีการแก้ไขหรือลบรายการซื้อขายในอดีต ระบบจะล้างประวัติการตัดขายและ replay FIFO ใหม่ให้อย่างถูกต้อง
  - ระบบบันทึกรายได้จากการลงทุน (`recordInvestmentIncome`): จัดเก็บเงินปันผล/ดอกเบี้ย คำนวณภาษีหัก ณ ที่จ่าย 10% และเครดิตภาษีปันผลไทย 20/80
  - สรุปภาพรวมพอร์ต (`getPortfolioSummary`) และสรุป Realized P&L แยกตามปีภาษี (`getRealizedGainLossByYear`)
- [x] **ส่วนติดต่อผู้ใช้ (UI Screens & Dialogs)**:
  - เมนู "พอร์ตลงทุน" ในแถบนำทางหลัก (MainShell Navigation Rail / Navigation Bar) พร้อมระบบ PIN Lock ป้องกันข้อมูล
  - หน้าจอพอร์ตการลงทุน (`PortfolioScreen`): แสดงมูลค่าพอร์ตปัจจุบัน, ต้นทุนรวม, กำไร/ขาดทุนรวม, กราฟสัดส่วนสินทรัพย์ (fl_chart Donut Chart), รายการหลักทรัพย์ที่ถือครอง, และแท็บ Realized P&L แยกรายปี
  - Dialog เพิ่ม/แก้ไขข้อมูลสินทรัพย์ (`AssetFormDialog`)
  - Dialog บันทึกซื้อ/ขาย (`BuySellTradeDialog`): แสดงตัวอย่างยอดเงิน THB แบบ Real-time, ล็อกอัตราแลกเปลี่ยน, และแสดงกล่องข้อความเตือนเมื่อทำรายการย้อนหลังข้ามปีภาษี
  - หน้าจออัปเดตราคาตลาดสิ้นเดือน (`MonthlyValuationScreen`): บันทึกราคาปิดสิ้นเดือนและเรต FX คำนวณ Mark-to-Market
  - Dialog บันทึกเงินปันผล/ดอกเบี้ย (`DividendIncomeDialog`): ซ่อนเครดิตภาษีอัตโนมัติหากเป็นเงินได้ต่างประเทศ
  - หน้าจอตรวจสอบ Lot (`LotInspectionScreen`): ตรวจสอบที่มาของแต่ละ Lot และประวัติการตัดขาย

- [x] **การปรับปรุงความสมบูรณ์และประสบการณ์ผู้ใช้ (Phase 2.1 UX & Engine Enhancements)**:
  - **บัญชีสกุลต่างประเทศ (USD Account)**: หน้าบัญชีและหน้ารายละเอียดบัญชีแสดงยอดเงินคงเหลือสกุล USD ($) ควบคู่กับมูลค่าเทียบเท่าเงินบาท (≈ ฿) โดยแปลงด้วยอัตราแลกเปลี่ยนล่าสุดอัตโนมัติ และคำนวณเข้าความมั่งคั่งสุทธิ (Net Worth) อย่างถูกต้อง
  - **การอัปเดตอัตราแลกเปลี่ยนและ FX P&L ทันที**: ปรับปรุงหน้าอัปเดตราคาตลาดสิ้นเดือน (`MonthlyValuationScreen`) ให้โหลดเรต USD ล่าสุด และเมื่อบันทึกจะซิงค์เรตลงตาราง `fx_rates` อัตโนมัติ พร้อมอัปเดตราคาและเรตของทุกสินทรัพย์ในพอร์ต ทำให้ค่ากำไร/ขาดทุนจากอัตราแลกเปลี่ยน (FX P&L) อัปเดตแบบ Real-time ทันที
  - **รายการสินทรัพย์ที่ยังไม่มีการซื้อขาย (Watchlist / 0 หน่วย)**: แสดงหมวดสินทรัพย์ที่รอเข้าซื้อแยกต่างหากในหน้าพอร์ตลงทุน พร้อมปุ่ม "ซื้อ", "แก้ไขข้อมูลสินทรัพย์", และปุ่ม "ลบ" พร้อม Dialog ยืนยันความปลอดภัย
  - **การมองเห็นและความคมชัดของเมนู (Contrast & Visibility)**: เพิ่มปุ่ม Quick Action ที่ชัดเจนใต้การ์ดสรุปพอร์ต (`+ เพิ่มสินทรัพย์`, `อัปเดตราคาตลาด`, `บันทึกเงินปันผล`), ปรับสีตัวอักษรและ Subtitle ให้คมชัดตาม ColorScheme, ปรับ Bottom Navigation Bar ให้แสดงป้ายชื่อเมนูตลอดเวลา (`alwaysShow`) และย่อชื่อเป็น "พอร์ต" ป้องกันการล้นจอ
  - **การบันทึกรายการขายสินทรัพย์เข้าหมวดหมู่ "ขายสินทรัพย์" (Asset Sale)**: เมื่อทำการขายสินทรัพย์ ระบบจะสร้างธุรกรรมรายรับเงินสดเข้าบัญชีโดยผูกกับหมวดหมู่ระบบ "ขายสินทรัพย์" อัตโนมัติ พร้อมกำหนดประเภทภาษีเป็น `non_taxable` (ยกเว้นภาษี) เพื่อป้องกันไม่ให้เงินค่าขายรวมต้นทุนถูกนำไปคำนวณเป็นรายได้เสียภาษีซ้ำซ้อน โดยกำไรที่แท้จริง (Capital Gain) จะถูกคำนวณผ่าน FIFO Engine และระบบโอนเงินกลับประเทศ (Foreign Remittance) อย่างถูกต้องตามเกณฑ์กรมสรรพากร

---

### Phase 3: ระบบสุขภาพการเงิน พยากรณ์การใช้เงิน ทะเบียนหนี้สิน/ประกัน และรายการอัตโนมัติ (Financial Health, Liabilities, Insurance & Recurring Engine)
- [x] **Schema Migration v3 -> v4**:
  - สร้างตารางใหม่ `liabilities`: ทะเบียนหนี้สิน พร้อมฟิลด์ `remaining_principal_satang`, `monthly_payment_satang`, `interest_rate_percent`, `is_short_term`, `linked_account_id` รองรับการเชื่อมต่อยอดหนี้บัตรเครดิตสดอัตโนมัติ
  - สร้างตารางใหม่ `insurance_policies`: ทะเบียนกรมธรรม์ประกันภัย พร้อมฟิลด์ `sum_insured_satang` (ทุนประกันชีวิต), `medical_coverage_satang` (วงเงินคุ้มครองค่ารักษา/โรคร้ายแรง), `annual_premium_satang` (เบี้ยประกันต่อปี), และ `due_date`
  - ปรับปรุงตาราง `recurring_rules`: เพิ่มฟิลด์ `interval_units`, `auto_post`, `last_posted_date`, และ `note`
  - ปรับปรุงตาราง `financial_health_settings`: เพิ่มฟิลด์ `warning_value` รองรับเกณฑ์เตือนเฝ้าระวังแบบละเอียด
- [x] **Pure Financial Health Domain Engine (ตัวชี้วัด 8 ด้าน & Weighted Scoring 100 คะแนน)**:
  - 1. อัตราส่วนสภาพคล่องพื้นฐาน (Basic Liquidity Ratio >= 1.0 เท่า) — น้ำหนัก 15 คะแนน
  - 2. เงินสำรองฉุกเฉิน (Emergency Fund Ratio >= 6.0 เดือน) — น้ำหนัก 15 คะแนน
  - 3. หนี้สินต่อสินทรัพย์ (Debt-to-Asset Ratio <= 50.0%) — น้ำหนัก 15 คะแนน
  - 4. ภาระหนี้ต่อรายได้ (Debt Service Ratio / DTI <= 40.0%) — น้ำหนัก 15 คะแนน
  - 5. อัตราการออมต่อเดือน (Savings Rate >= 10.0%) — น้ำหนัก 10 คะแนน
  - 6. สัดส่วนสินทรัพย์ลงทุน (Investment Asset Ratio >= 50.0%) — น้ำหนัก 10 คะแนน
  - 7. ความคุ้มครองชีวิตต่อภาระครอบครัว (Life Insurance Coverage >= หนี้ระยะยาว + เงินสำรองครอบครัว) — น้ำหนัก 10 คะแนน
  - 8. ความคุ้มครองค่ารักษาพยาบาล (Health / Critical Illness Coverage >= ประมาณการค่ารักษาโรคร้ายแรง) — น้ำหนัก 10 คะแนน
  - ระบบตัดเกรด 4 เสาหลัก (สภาพคล่อง 30, หนี้สิน 30, ออม/ลงทุน 20, ความคุ้มครอง 20) พร้อมระบบจัดลำดับคำแนะนำเป็นภาษาไทย (Prioritized Recommendations)
  - ระบบแสดงที่มาของตัวเลขแบบโปร่งใส (Source of Numbers Breakdown) ไม่มีการ Hardcode ตัวเลข
- [x] **Run-rate Forecasting Engine (ระบบพยากรณ์การใช้จ่าย)**:
  - คำนวณอัตราการเผาเงินจริงต่อวัน (Daily Run-rate) ณ วันปัจจุบันของเดือน
  - พยากรณ์ยอดใช้จ่ายสิ้นเดือน (Projected Month-end) เทียบกับเพดานงบประมาณรายเดือน พร้อมคำนวณส่วนต่างงบ (+/-)
  - คำนวณวงเงินที่แนะนำให้ใช้ต่อวัน (Recommended Daily Spend) สำหรับวันที่เหลือในเดือนเพื่อให้ยอดรวมไม่เกินงบ
  - พยากรณ์ยอดใช้จ่ายสิ้นปี (Projected Year-end) ตามแนวโน้มการใช้จ่ายสะสม
- [x] **Recurring Transactions Engine (ระบบรายการธุรกรรมอัตโนมัติ)**:
  - รองรับความถี่รอบ รายวัน (Daily), รายสัปดาห์ (Weekly), รายเดือน (Monthly), รายปี (Yearly) ทุกๆ N หน่วย
  - นโยบาย Month-End Clamping: วันที่ 31 ของเดือนที่ลงท้ายด้วย 30 หรือกุมภาพันธ์ (28/29) จะปัดลงเป็นวันสิ้นเดือนของเดือนนั้นอย่างถูกต้องเสมอ
  - นโยบาย Idempotency & Timezone Safety: ใช้เฉพาะ Date Component (`yyyy-MM-dd`) ในการตัดสิน ทำให้ไม่เกิดรายการซ้ำซ้อนแม้เปิดแอปข้ามโซนเวลา
  - Catch-up Posting: หากไม่ได้เปิดแอปมาหลายวัน/เดือน ระบบจะตรวจจับและลงบัญชีย้อนหลังให้อัตโนมัติทีละรอบอย่างครบถ้วน
  - รองรับทั้ง Auto-Post (บันทึกอัตโนมัติ) และ Manual Confirmation (รอยืนยัน)
  - พยากรณ์กระแสเงินสดล่วงหน้า 30 วัน (30-Day Projection) เรียงตามลำดับเวลา
- [x] **Database Access Objects (DAOs)**:
  - `LiabilitiesDao`: จัดการหนี้สิน พร้อมฟังก์ชัน `getTotalLiabilitiesSatang()` ดึงยอดหนี้บัตรเครดิตสดอัตโนมัติ ป้องกันการนับหนี้ซ้อน 100%
  - `InsuranceDao`: จัดการกรมธรรม์ประกัน สรุปทุนชีวิต วงเงินค่ารักษา และเบี้ยต่อปี
  - `RecurringTransactionsDao`: ประมวลผลกฎอัตโนมัติ บันทึกรายการลง Ledger พร้อม Audit Log
  - `FinancialHealthDao`: กรองรายจ่ายแท้จริงย้อนหลัง 6 เดือน (ตัดรายการโอนเงินและรายการซื้อหุ้น/คริปโตออก), รวมสินทรัพย์สภาพคล่อง และประเมินสุขภาพการเงินรวม
- [x] **ส่วนติดต่อผู้ใช้ (UI Presentation Layer)**:
  - หน้าจอสุขภาพการเงิน (`FinancialHealthScreen`): การ์ดคะแนนรวม 100 คะแนนและเกรด, การ์ด Run-rate พยากรณ์สิ้นเดือนและวงเงินรายวัน, การ์ดตัวชี้วัด 8 ด้านพร้อมสถานะสี เขียว/เหลือง/แดง, และกล่องข้อแนะนำ
  - หน้าต่างที่มาของตัวเลข (`MetricDetailSheet`): แสดงสูตรการคำนวณและรายการแยกย่อยของตัวเลขทุกตัวชี้วัดอย่างโปร่งใส
  - หน้าต่างตั้งค่าเกณฑ์ (`HealthSettingsDialog`): ปรับแต่งเป้าหมายทางการเงินและค่ารักษาพยาบาลส่วนบุคคลได้เอง
  - หน้าจอหนี้สินและประกัน (`LiabilitiesInsuranceScreen`): แท็บภาระหนี้สินและแท็บกรมธรรม์ประกันภัย พร้อม Dialog เพิ่ม/แก้ไข
  - หน้าจอรายการอัตโนมัติ (`RecurringRulesScreen`): แท็บรายการกฎ และแท็บพยากรณ์กระแสเงินสด 30 วันข้างหน้า
  - การ์ดสรุปสุขภาพการเงินบนแดชบอร์ด (`DashboardScreen`): สรุปคะแนนและ Run-rate พร้อมทางลัดเข้าหน้ารายงาน
  - เมนูใหม่ในหน้าตั้งค่า (`SettingsScreen`): เข้าถึงสุขภาพการเงิน หนี้สิน/ประกัน และรายการอัตโนมัติได้สะดวกรวดเร็ว
  - ประมวลผลรอบรายการอัตโนมัติเบื้องหลังทันทีที่เปิดแอป (`MainShell.initState`)
- [x] **การทดสอบความถูกต้อง (Test Coverage 100%)**:
  - ชุดทดสอบ Unit Test และ Integration Test ทั้งหมด 63 รายการ ผ่าน 100% (63/63 passing)
  - `flutter analyze` 0 errors, 0 warnings

---

### Phase 3.1: การยกระดับฟังก์ชันตามคำขอผู้ใช้ (User-Requested Enhancements)
- [x] **Schema Migration v4 -> v5**:
  - เพิ่มตารางใหม่ `projects` รองรับการกำหนดงบประมาณโครงการพิเศษ (Special Projects) มีฟิลด์ `id`, `name`, `description`, `target_budget_satang`, `start_date`, `end_date`, `icon`, `color`, `is_active`
  - เชื่อมโยงรายการใช้จ่ายเข้าโครงการผ่านแท็ก `project:<projectId>` อย่างยืดหยุ่น
- [x] **1. การสร้างรายการประจำ (Recurring Rule) จากหน้าบันทึกด่วน (Quick Add)**:
  - เพิ่มตัวเลือกในหน้า "บันทึกด่วน" ให้ผู้ใช้สามารถติ๊กตั้งค่าเป็นรายการประจำได้ทันที พร้อมเลือกความถี่ (รายวัน, รายสัปดาห์, รายเดือน), วันที่ตัดรอบ, และตัวเลือกลงบัญชีอัตโนมัติ (Auto-post)
  - แยกหมวดหมู่อย่างเคร่งครัดตามประเภทธุรกรรม (รายรับ vs รายจ่าย) ป้องกันการนำหมวดหมู่มาปนกัน
- [x] **2. การแก้ไขและลบงบประมาณรายเดือน (Editable Monthly Budgets)**:
  - ในหน้างบประมาณ ผู้ใช้สามารถแตะที่การ์ดงบประมาณของแต่ละหมวดหมู่เพื่อเปิดหน้าต่างแก้ไขเพดานงบประมาณใหม่ หรือกดยืนยันลบงบประมาณได้ทันที
- [x] **3. ระบบจัดการหมวดหมู่รายรับ-รายจ่ายที่กำหนดเอง (Custom Category Management)**:
  - เพิ่มหน้าจอ "จัดการหมวดหมู่รายรับ-รายจ่าย (Categories)" ในเมนูการตั้งค่า
  - เพิ่มปุ่ม `+ เพิ่มหมวดหมู่` ทั้งในหน้ารวมหมวดหมู่และในแถบชิปเลือกหมวดหมู่ของหน้าบันทึกด่วน
  - รองรับการสร้างหมวดหมู่ใหม่ กำหนดชื่อภาษาไทย ชื่อภาษาอังกฤษ ประเภท (รายรับ/รายจ่าย) และเลือกไอคอน
  - สามารถแก้ไขชื่อหรือสั่งปิดการใช้งานหมวดหมู่ที่ไม่ได้ใช้งานแล้วได้
- [x] **4. ระบบโครงการพิเศษและงบประมาณตามช่วงเวลา (Special Project Budgeting)**:
  - เพิ่มแท็บ "โครงการพิเศษ" ในหน้างบประมาณและการวางแผน
  - สร้างโครงการ กำหนดเป้าหมายงบประมาณ และช่วงเวลาเริ่มต้น-สิ้นสุด (เช่น ไปเที่ยวต่างประเทศ, ซ่อมแซมบ้าน, จัดงานแต่งงาน)
  - คำนวณยอดเงินที่ใช้ไปจริงเทียบกับงบประมาณ พร้อมคำนวณจำนวนวันที่เหลือจนถึงวันสิ้นสุดโครงการ
  - แสดงรายการธุรกรรมย่อยทั้งหมดที่ผูกกับโครงการ สามารถแก้ไขข้อมูลโครงการหรือลบโครงการได้
- [x] **5. ปุ่มย้อนกลับและยกเลิกสำหรับหน้าจอใส่รหัส PIN (PIN Lock Cancel/Back Button)**:
  - เพิ่มปุ่มไอคอนกากบาท (ปิดหน้าต่าง) และปุ่ม "ยกเลิก / ย้อนกลับ" ที่ด้านล่างของหน้าจอใส่รหัส PIN
  - ผู้ใช้ที่ลืมรหัส PIN หรือเปลี่ยนใจ จะไม่ติดค้างอยู่ในหน้านั้น และสามารถกดย้อนกลับมาใช้งานหน้าแดชบอร์ดหรือหน้าบันทึกด่วนได้อย่างปลอดภัย
- [x] **6. ระบบเปลี่ยนรหัส PIN พร้อมยืนยันรหัสเดิม และปุ่มกดยกเลิก (Old PIN Verification & Cancel Support)**:
  - สร้าง `PinSetupDialog` แบบ Multi-step Keypad สวยงามตามมาตรฐานความปลอดภัย
  - เมื่อกด "เปลี่ยน PIN" ระบบจะให้ใส่รหัส PIN 6 หลักเดิมก่อน หากรหัสเดิมไม่ถูกต้องจะแจ้งเตือนและไม่อนุญาตให้เปลี่ยน
  - เมื่อยืนยันรหัสเดิมผ่าน จึงจะเข้าสู่ขั้นตอนตั้งรหัสใหม่และยืนยันรหัสใหม่อีกครั้ง
  - รองรับปุ่ม "ยกเลิก" และปุ่มกากบาท `X` ในทุกขั้นตอน ให้ผู้ใช้สามารถกดยกเลิกออกจากหน้าต่างได้ตลอดเวลา
- [x] **การทดสอบความถูกต้อง (Test Coverage 100%)**:
  - เพิ่มชุดทดสอบ `pin_setup_dialog_test.dart` รวมชุดทดสอบเป็น 68 รายการ ผ่าน 100% (68/68 passing)
  - `flutter analyze` 0 errors, 0 warnings

---

### Phase 4: ระบบคำนวณภาษีเงินได้, การนำเงินได้ต่างประเทศกลับไทย และรายงานการเงินรอบด้าน (Tax Engine, Foreign Remittance, Reports & Export)
- [x] **Schema Migration v5 -> v6**:
  - สร้างตารางใหม่ `tax_rules`: จัดเก็บอัตราภาษีก้าวหน้า ค่าลดหย่อน และเพดานหักค่าใช้จ่ายในรูปแบบ dynamic JSON แยกตามปีภาษี ปรับแก้ได้ผ่าน UI โดยไม่ต้องแก้โค้ด
  - สร้างตารางใหม่ `tax_residency`: จัดเก็บบันทึกจำนวนวันที่พำนักอยู่ในประเทศไทยในแต่ละปีภาษี (เกณฑ์ 180 วัน)
  - สร้างตารางใหม่ `foreign_remittances`: ทะเบียนบันทึกการนำเงินได้ต่างประเทศกลับเข้าไทย พร้อมฟิลด์ `remittance_transaction_id`, `source_account_id`, `destination_account_id`, `amount_original_satang`, `currency_code`, `fx_rate`, `amount_thb_satang`, `tax_year_earned`, `tax_year_remitted`, `income_source_type`, `is_principal`
  - ปรับปรุงตาราง `transactions`: เพิ่มฟิลด์ `tax_category` (เช่น 40_1, 40_2, 40_4_dividend, 40_6_medical, 40_8) และ `withholding_tax_satang` (ภาษีหัก ณ ที่จ่าย)
  - ข้อมูลตั้งต้น (Seed Data) กฎภาษีปี 2025 และ 2026 ตามโครงสร้างภาษีสรรพากรปัจจุบัน
- [x] **Pure Tax Calculator Domain Engine**:
  - คำนวณภาษีเงินได้บุคคลธรรมดา (ภ.ง.ด. 90/91) ตามขั้นบันไดภาษีอัตราก้าวหน้า 5% - 35%
  - รองรับเงินได้ ม.40(1) เงินเดือน, ม.40(2) รับจ้างทั่วไป (หักค่าใช้จ่ายรวมกัน 50% ไม่เกิน 100,000 บาท)
  - รองรับเงินได้ ม.40(6) วิชาชีพอิสระ (การประกอบโรคศิลปะ/แพทย์เวรคลินิก หักค่าใช้จ่ายเหมา 60%)
  - รองรับเงินได้ ม.40(4) เงินปันผลไทย, เงินปันผลต่างประเทศ, คริปโต, ดอกเบี้ย
  - รองรับเงินได้ ม.40(8) อื่นๆ และเงินได้ต่างประเทศที่ต้องนำมารวมคำนวณภาษี
  - ระบบเปรียบเทียบกลยุทธ์เงินปันผลหุ้นไทย (`compareDividendStrategy`): Final Tax 10% vs นำมารวมคำนวณพร้อมเครดิตภาษีเงินปันผล (Dividend Tax Credit) แนะนำทางเลือกที่ประหยัดภาษีที่สุดให้ผู้ใช้อัตโนมัติ
  - ระบบตรวจสอบความโปร่งใสแบบ Line-by-Line Audit Step Breakdown แสดงขั้นตอนการคำนวณและที่มาของตัวเลขทุกบรรทัด
- [x] **Pure Foreign Remittance Assessment Engine (คำสั่งกรมสรรพากรที่ ป.161/2566 & ป.162/2566)**:
  - ตรวจสอบสถานะการเป็นผู้มีถิ่นที่อยู่ในไทย (Tax Resident) จากจำนวนวันที่อยู่ในไทย (>= 180 วัน)
  - ยกเว้นภาษีสำหรับเงินต้นเดิมที่ส่งออกไปลงทุน (`isPrincipal = true`)
  - ยกเว้นภาษีสำหรับเงินได้ที่เกิดขึ้นก่อนวันที่ 1 มกราคม 2024 ตามคำสั่งกรมสรรพากรที่ ป.162/2566
  - ประเมินสถานะการเสียภาษีของรายการนำเงินเข้าไทยทุกรายการ (Taxable vs Tax-Exempt) พร้อมระบุเหตุผลทางกฎหมายชัดเจน
- [x] **Comprehensive Financial Reports Service (บริการสรุปรายงานการเงิน 7 ประเภท)**:
  - 1. สรุปรายรับรายจ่ายประจำเดือน (Monthly Summary) เทียบกับงบประมาณและเดือนก่อนหน้า
  - 2. สรุปรายรับรายจ่ายประจำปี (Annual Summary) แจกแจง 12 เดือนเคียงข้างกันและเทียบปีก่อนหน้า
  - 3. งบกระแสเงินสดส่วนบุคคล (Cash Flow Statement) แยกกิจกรรมดำเนินงาน, กิจกรรมลงทุน, และกิจกรรมจัดหาเงิน
  - 4. งบแสดงฐานะการเงินส่วนบุคคล (Personal Balance Sheet) สินทรัพย์, หนี้สิน, และความมั่งคั่งสุทธิ
  - 5. รายงานพอร์ตการลงทุน (Investment Portfolio Report) หุ้น/คริปโตที่ถือครอง, Realized P/L, Unrealized P/L, และเงินปันผล
  - 6. ชุดเตรียมยื่นภาษี (Tax Preparation Bundle) สรุปเงินได้แยกตาม 40(1)-(8), ภาษีหัก ณ ที่จ่าย, ภาษีที่ต้องชำระ/ขอคืน
  - 7. รายงานสุขภาพการเงิน (Financial Health Report) สรุปตัวชี้วัด 8 ด้าน คะแนน และคำแนะนำ
- [x] **Export Services (Excel & PDF)**:
  - **Excel Export (.xlsx)**: ส่งออกรายงานแบบหลายชีต (Multi-sheet) พร้อมจัดรูปแบบตัวเลข ตัวหนา และแชร์ผ่านระบบปฏิบัติการ
  - **PDF Export (A4)**: รายงาน A4 สวยงาม พร้อมฝังฟอนต์ภาษาไทย Noto Sans Thai (`notoSansThaiRegular` / `notoSansThaiBold`) ป้องกันปัญหาสระลอย/ตัวอักษรสี่เหลี่ยม พร้อมหัวกระดาษ เลขหน้า และข้อความปฏิเสธความรับผิดชอบทางกฎหมาย (Legal Disclaimer)
- [x] **ส่วนติดต่อผู้ใช้ (UI Presentation Layer)**:
  - หน้าจอภาษีเงินได้ (`TaxScreen`): สรุปภาษีที่ต้องจ่าย/ขอคืน, กล่องแนะนำกลยุทธ์เงินปันผล, ตารางแยกขั้นตอนการคำนวณ, ปุ่มส่งออก Excel/PDF, และปุ่มเปิดแก้ไขเกณฑ์ภาษี
  - หน้าต่างแก้ไขกฎภาษี (`TaxRulesEditDialog`): ปรับแต่งขั้นบันไดภาษีและค่าลดหย่อนแยกตามปีภาษีได้อย่างอิสระ
  - หน้าจอนำเงินเข้าไทย (`ForeignRemittanceScreen`): สรุปยอดเงินนำเข้า, สถานะผู้มีถิ่นที่อยู่ในไทย (180 วัน), ประวัติรายการพร้อมชิปสถานะทางภาษี, และ Dialog บันทึกการนำเงินเข้าไทย (ซิงค์ลง Ledger ธุรกรรมโอนเงินอัตโนมัติ)
  - หน้าจอรายงานทางการเงิน (`ReportsScreen`): รวมแท็บรายงานทั้ง 7 ประเภท กรองช่วงเวลาได้ตามใจ และส่งออกไฟล์ได้ทันที
  - อัปเดตหน้าตั้งค่า (`SettingsScreen`): เพิ่มหมวดภาษีและรายงานการเงิน
- [x] **ระบบตรวจจับและเชื่อมโยงการนำเงินเข้าไทยอัตโนมัติจากการโอนเงิน (Transfer Auto-Detection & Two-Way Sync)**:
  - เมื่อบันทึกรายการโอนเงิน (`transfer`) จากบัญชีต่างประเทศ (Offshore) มายังบัญชีในประเทศ (Domestic THB) ระบบจะตรวจจับและสร้างเรคคอร์ดใน `foreign_remittances` ให้อัตโนมัติทันที
  - หน้าบันทึกด่วน (`QuickAddScreen`) จะแสดงการ์ด "🇹🇭 การนำเงินต่างประเทศเข้าไทย" เมื่อเลือกคู่บัญชี Offshore -> Domestic เพื่อให้ผู้ใช้ติ๊กเลือกได้ทันทีว่าเงินก้อนนี้เป็นเงินต้นเดิมหรือไม่ (ยกเว้นภาษี) และเลือกปีที่เกิดเงินได้
  - เมื่อแก้ไขหรือลบรายการโอนเงิน ข้อมูลใน `foreign_remittances` จะอัปเดตยอดเงิน เรต FX หรือถูก Soft Delete ตามรายการหลักอย่างสมบูรณ์
  - ฟังก์ชัน `syncAllTransferTransactions()` ตรวจหาและกวาดรายการโอนเงินต่างประเทศในอดีตมาแสดงในหน้าติดตามเงินได้ต่างประเทศให้อัตโนมัติเมื่อเปิดหน้าจอ
  - ในหน้า `ForeignRemittanceScreen` สามารถแตะที่การ์ดเพื่อเปิด Dialog แก้ไขข้อมูลภาษี (สลับเงินต้นเดิม/กำไร, แก้ไขปีที่เกิดเงินได้) ได้ตลอดเวลา
- [x] **ระบบรองรับปีอนาคตอัตโนมัติแบบไร้รอยต่อ (Future-Proof Dynamic Years & Auto-Inherit)**:
  - เมนูเลือกปีในหน้าภาษีและหน้านำเงินเข้าต่างประเทศ จะสร้างรายการปีแบบ Dynamic อัตโนมัติตามปีปัจจุบันและอนาคต (เช่น 2570, 2571, 2572...)
  - `TaxDao.getTaxRuleForYear`: เมื่อก้าวเข้าสู่ปีภาษีใหม่ที่ยังไม่เคยมีในฐานข้อมูล ระบบจะคัดลอก (Auto-inherit) โครงสร้างภาษีและค่าลดหย่อนจากปีล่าสุดมาตั้งเป็นปีใหม่อัตโนมัติทันที
- [x] **การปรับปรุงระบบเงินได้ต่างประเทศและ UX ตามข้อกำหนดผู้ใช้ (Foreign Remittance FIFO & UX Refinements)**:
  - **1. ตรวจจับและคำนวณเงินต้นลงทุนต่างประเทศคงเหลืออัตโนมัติ (FIFO Principal Tracking)**: เพิ่มฟังก์ชัน `getRemainingForeignPrincipalSatang` คำนวณเงินต้นคงเหลือที่ส่งออกไปลงทุนต่างประเทศ (Inflow: Domestic -> Offshore หักลบ Outflow: Offshore -> Domestic) พร้อมแสดงกล่องข้อมูลยอดเงินต้นคงเหลือแบบ Real-time บนหน้าบันทึกด่วน โดยระบบจะตัดสินให้เป็นเงินต้น (`isPrincipal = true`) หรือกำไรตามเกณฑ์ FIFO ให้อัตโนมัติโดยผู้ใช้ไม่ต้องเลือกเอง
  - **2. กำหนดสถานะ Dime! FCD เป็นบัญชีในประเทศ (Domestic USD Account)**: ปรับแก้เงื่อนไขการตรวจจับใน `RemittancesDao` ให้ตรวจสอบ `!src.isDomestic && dst.isDomestic` อย่างเคร่งครัด โดยการโอนเงินระหว่าง SCB (Domestic THB) กับ Dime! FCD (Domestic USD) ถือเป็นการโอนเงินภายในประเทศ จะไม่ถูกนำไปบันทึกเป็นเงินได้ต่างประเทศนำเข้าไทยเด็ดขาด
  - **3. กรองบัญชีปลายทางไม่ให้ซ้ำกับบัญชีต้นทาง (Destination Account Dropdown Filtering)**: ทั้งในหน้าบันทึกด่วน (`QuickAddScreen`) และหน้าต่างแก้ไขธุรกรรม (`EditTransactionDialog`) บัญชีปลายทางจะถูกกรองเอาบัญชีต้นทางที่เลือกอยู่ออกโดยอัตโนมัติ ป้องกันการเลือกบัญชีเดียวกัน
  - **4. จำกัดการแสดงปีภาษีไม่ให้แสดงปีในอนาคตล่วงหน้า (Current Year Tax Range Capping)**: ปรับปรุงตัวเลือกปีในหน้าภาษี (`TaxScreen`), หน้านำเงินเข้าไทย (`ForeignRemittanceScreen`), และหน้าบันทึกด่วน ให้แสดงปีสูงสุดไม่เกินปีปัจจุบัน (`DateTime.now().year`) และจะค่อยๆ ปรากฏขึ้นเองเมื่อก้าวเข้าสู่ปีภาษีนั้นๆ
- [x] **การแยกธุรกรรมซื้อขายหุ้นไปยังเมนูพอร์ตลงทุน บันทึก-แสดงเงินต้น และแจกแจงสรุปการซื้อขายหุ้นในหมวดกำไรที่รับรู้แล้ว**:
  - **1. แยกธุรกรรมซื้อขายหุ้นออกจากเมนูรายการรวม (Transactions List Filtering)**: ปรับปรุง `TransactionsDao.searchTransactions` เพิ่มตัวกรอง `excludeInvestments: true` และกำหนดให้หน้า `TransactionListScreen` กรองรายการที่มีแท็ก `investment_` ออกทั้งหมด เพื่อให้หน้ารายการรวมมีเฉพาะรายรับ-รายจ่ายทั่วไปและการโอนเงิน ไม่ปะปนกับรายการซื้อขายหุ้น
  - **2. แท็บประวัติการซื้อ-ขายในหน้าพอร์ตลงทุน (Portfolio Trade History Tab)**: เพิ่มแท็บที่ 3 ในหน้าพอร์ตลงทุน (`_buildTradeHistoryTab`) แสดงประวัติรายการซื้อขายหุ้นทั้งหมดเรียงตามลำดับเวลา พร้อมข้อมูลครบถ้วน: ซื้อ/ขาย, สัญลักษณ์หุ้น/ชื่อหุ้น, วันที่, จำนวนหน่วย, ราคาต่อหน่วย, อัตราแลกเปลี่ยน, เงินต้น/ยอดรวม (THB), ค่าธรรมเนียม, บัญชีที่ตัดเงิน และปุ่มทางลัดตรวจสอบ Lot FIFO
  - **3. แสดงเงินต้นทั้งหมดและยอดขายรวมในหมวดกำไรที่รับรู้แล้ว (Cost Basis & Proceeds in Realized P&L)**: ปรับปรุง `RealizedGainLossYearSummary` และ `_buildRealizedGainLossTab` ให้แสดง **"เงินต้นทั้งหมดที่ขาย (Cost Basis)"**, **"ยอดขายรวมทั้งหมด (Proceeds)"**, และ **"เงินต้นที่ซื้อใหม่ในปีนี้"** ในการ์ดสรุปของแต่ละปีภาษี
  - **4. สรุปการซื้อขายหุ้นรายตัวใต้ข้อมูลสรุปของปีนั้น (Traded Stocks Breakdown per Tax Year)**: ใต้ข้อมูลสรุปของแต่ละปีภาษี เพิ่มการ์ดแสดงรายละเอียดหุ้นแต่ละตัวที่มีการซื้อขายในปีนั้น: ชื่อหุ้น/สัญลักษณ์, จำนวนหุ้นสุทธิ (ซื้อ/ขาย/สุทธิ), เงินต้นที่ขาย, ยอดขายรวม, กำไร-ขาดทุนสุทธิ (แจกแจงกำไรจากราคาและ FX) และเงินต้นที่เข้าซื้อใหม่ในปีนั้น
- [x] **ระบบกู้คืนหุ้นที่ลบ และถังขยะสินทรัพย์ 30 วัน (Asset Trash Bin & Recovery System)**:
  - **1. การลบแบบ Soft Delete**: เมื่อสั่งลบหุ้นจากหน้าพอร์ตลงทุน ข้อมูลจะไม่ถูกลบออกจากฐานข้อมูลทันที แต่จะประทับเวลา `deleted_at` ย้ายไปพักไว้ในถังขยะ
  - **2. ปุ่มกู้คืนทันที (Immediate Undo SnackBar)**: เมื่อกดลบหุ้น จะมี SnackBar เด้งขึ้นมาพร้อมปุ่ม "กู้คืน" นาน 4 วินาที สามารถกดดึงหุ้นกลับมาได้ทันที
  - **3. ถังขยะแยกแท็บในหน้าตั้งค่า (TrashBinScreen 2 Tabs)**: ปรับปรุงหน้าจอถังขยะให้แบ่งเป็น 2 แท็บ (แท็บ 1: บัญชี, แท็บ 2: หุ้น / สินทรัพย์) แสดงรายการหุ้นที่ถูกลบพร้อมการนับถอยหลังอายุ 30 วัน (`เหลือ X วัน`), ปุ่ม "กู้คืน", และปุ่ม "ลบถาวร"
  - **4. ทางลัดไปยังถังขยะหุ้นในหน้าพอร์ต (Portfolio AppBar Shortcut)**: เมนูเพิ่มเติม `...` ใน AppBar ของหน้าพอร์ตลงทุน มีตัวเลือก "ถังขยะหุ้น (กู้คืนหุ้นที่ลบ)" กดแล้วเปิดเข้าแท็บถังขยะหุ้นได้ทันที
  - **5. ระบบล้างข้อมูลที่หมดอายุ 30 วันอัตโนมัติ (`cleanupExpiredDeletedAssets`)**: ตรวจสอบและล้างหุ้นที่ค้างในถังขยะเกิน 30 วันทิ้งถาวรเมื่อเปิดหน้าจอถังขยะ
- [x] **การยกเครื่องดีไซน์ UI/UX, โหมดมืด (Dark Mode) และจัดระเบียบหมวดซื้อขายหุ้น (UI/UX Overhaul & Stock Clutter Elimination)**:
  - **1. โทนสีหลัก 3 สี (Tri-Color Theme)**:
    - **Primary (เขียวมินต์มรกต - Emerald Mint)**: โทน `0xFF059669` (โหมดสว่าง) / `0xFF34D399` (โหมดมืด) สื่อถึงการเติบโตทางการเงิน ความมั่งคั่ง และความสดใส
    - **Secondary (น้ำเงินคราม - Royal Indigo)**: โทน `0xFF4F46E5` (โหมดสว่าง) / `0xFF818CF8` (โหมดมืด) สื่อถึงความมั่นคง น่าเชื่อถือ ความปลอดภัย
    - **Accent/Tertiary (ทองอำพัน - Warm Amber Gold)**: โทน `0xFFD97706` (โหมดสว่าง) / `0xFFFBBF24` (โหมดมืด) ใช้เน้นจุดสำคัญ ตัวชี้วัด และการแจ้งเตือน
  - **2. ยกเครื่องโหมดกลางคืน (Midnight Slate Dark Mode)**:
    - แก้ไขสีมืดอมเขียวโคลนเดิมที่เกิดจาก Material seed generation โดยเปลี่ยนเป็นโทน Slate/Navy คมเข้มสไตล์ Premium Fintech (`0xFF0B0F19` พื้นหลัง, `0xFF1E293B` การ์ดพื้นผิว)
    - เส้นขอบการ์ดบางเบา ละมุนตา ไม่กลืนไปกับพื้นหลัง และตัวหนังสือสี Slate 50 (`0xFFF8FAFC`) คอนทราสต์สูง อ่านง่าย ไม่ปวดตา
  - **3. จัดระเบียบหน้าสรุปภาพรวม (Dashboard Cleanup)**:
    - ตัดยอด "รายจ่ายเดือนนี้" ที่แสดงซ้ำซ้อนออก
    - การ์ดหลัก (Hero Card) แสดงงบประมาณคงเหลือพร้อมแถบเปอร์เซ็นต์ไล่สีและยอดเปรียบเทียบชัดเจน
    - แถวสรุปข้อมูล 3 กล่อง ไม่ซ้ำซ้อน: สินทรัพย์สุทธิ (Net Worth), รายรับเดือนนี้, เงินออมสุทธิ พร้อมแถบเตือนยอดตัดรอบบิลบัตรเครดิตล่วงหน้า
    - กราฟวงกลมและกราฟแท่งปรับโทนสีสดใส เข้ากันได้ทั้งในโหมดสว่างและมืด
  - **4. จัดระเบียบหมวดซื้อขายหุ้นและกำไรที่รับรู้แล้ว (Portfolio Realized P&L & Trade History)**:
    - **แท็บกำไรที่รับรู้แล้ว (Realized P&L)**: แทนที่กล่องรายการเดิมที่ลายตาด้วยแถบสรุป 3 ตัวชี้วัดแนวนอน (`ยอดขายรวม | ต้นทุนที่ขาย | ซื้อเพิ่มปีนี้`) พร้อมบรรทัดแยกกำไรราคาและกำไร FX ที่กระชับ และปรับรายละเอียดหุ้นแต่ละตัวเป็นแบบ `ExpansionTile` แตะเพื่อขยายดูรายละเอียดได้ ไม่รกตา
    - **แท็บประวัติการซื้อ-ขาย (Trade History)**: ตัดข้อความ "เงินต้นที่ลงทุน" ที่พิมพ์ยอดรวมซ้ำกับหัวการ์ดออก จัดเป็นการ์ดดีไซน์โมเดิร์นพร้อมแท็ก BUY/SELL สีชัดเจน แสดงยอดสุทธิ ยูนิต ราคา และบัญชี แตะเพื่อดูรายละเอียดลึกได้
  - **5. จัดกลุ่มรายการธุรกรรมตามวัน (Daily Grouped Transactions)**:
    - แสดงหัวข้อแยกตามวัน ("วันนี้", "เมื่อวานนี้", หรือ วันที่ไทย) พร้อมยอดรวมรายรับ-รายจ่ายสุทธิประจำวัน
    - ไอคอนหมวดหมู่ทรงสี่เหลี่ยมขอบมน (Squircle) สวยงาม และซ่อน "ค่าธรรมเนียม: ฿0" เพื่อลดความรกรุงรังของหน้าจอ
- [x] **การสลับภาษาไทย / อังกฤษแบบถาวร (Persistent Language Switching)**:
  - เชื่อมโยงระบบ `AppLocalizations` เข้ากับแถบนำทาง (MainShell), หน้า Dashboard, หน้ารายการ, หน้าตั้งค่า และหน้าบันทึกด่วน
  - บันทึกการเลือกภาษาและโหมดธีมลงใน `SharedPreferences` ทำให้แอปจำภาษาที่ผู้ใช้เลือกไว้ได้อย่างถาวรแม้ปิดแล้วเปิดแอปใหม่
- [x] **ยกเครื่องช่องกรอก USD ในหน้าโอนเงิน และแก้ไขสีในโหมดมืด (USD Dedicated Card & Dark Theme Polish)**:
  - แยกช่องกรอกจำนวนเงิน USD ออกมาเป็นการ์ดต่างหากที่มีความโดดเด่น ไม่เบียดเสียดในช่อง THB เดิม
  - ลบพื้นหลังสีขาว/ฟ้าอ่อนที่กลืนกับตัวหนังสือในโหมดมืดออก แทนที่ด้วยการ์ดสี Slate คอนทราสต์สูง (`#1E293B`, `#0F172A`)
  - ตัวเลขขนาดใหญ่ 22px พร้อมสัญลักษณ์สกุลเงิน และตัวช่วยคำนวณเรตคร่าวๆ แบบ Real-time
  - ปรับปรุงการ์ดนำเงินเข้าไทย (Remittance) ให้เป็นมิตรกับโหมดมืด 100% ตัวหนังสือคมชัด อ่านง่าย ไม่ปวดตา
- [x] **แก้ไขระบบโอนเงินสกุล USD และการโอนเงินข้ามสกุล 2 ทิศทาง (USD Transfer & Foreign Currency Audit Fix)**:
  - **ช่องกรอกเงินหลักแบบไดนามิก**: แสดงสัญลักษณ์ `$ ` และหัวข้อ "จำนวนเงินที่โอนออก (USD)" ทันทีที่เลือกบัญชีต้นทางเป็น USD (ไม่ค้างเป็น `฿` อีกต่อไป)
  - **การ์ดโอนข้ามสกุลเงินแบบ 2 ทิศทาง**: รองรับทั้ง THB -> USD และ USD -> THB โดยกรณี USD -> THB การ์ดด้านล่างจะให้ระบุ "ยอดเงินบาทปลายทางที่ได้รับ (THB)" พร้อมสัญลักษณ์ `฿ ` และคำนวณอัตราแลกเปลี่ยนแบบ Real-time
  - **ความถูกต้องของสมุดบัญชีแยกประเภท**: เมื่อโอนจาก USD -> THB บันทึก `currency_code` เป็น `'USD'`, `amount_original_satang` เป็น USD (cents) และ `amount_thb_satang` เป็น THB (satang) พร้อมตัด/เพิ่มยอดในแต่ละบัญชีอย่างถูกต้อง
  - **ระบบซ่อมแซมข้อมูลเก่าอัตโนมัติ (`repairMisclassifiedRemittanceCurrencies`)**: ตรวจสอบและแก้ไขเรคคอร์ดในอดีตที่เคยถูกบันทึกผิดเป็น `THB` ให้กลับมาเป็น `'USD'` อัตโนมัติ ทำให้ตารางในหน้าภาษีและการส่งออก PDF เดิมที่เคยแสดง `333.00 THB` กลับมาแสดงเป็น `333.00 USD` อย่างถูกต้อง
- [x] **การรีแบรนด์และยกเครื่องสถาปัตยกรรม UI/UX สไตล์ "VAULT" (Quiet Luxury Redesign)**:
  - **Rebranding สู่ "VAULT"**: เปลี่ยนชื่อแอปและตราสัญลักษณ์เป็น **VAULT** (Private Local-First Personal Wealth) ทั่วทั้งระบบทั้งในภาษาไทยและภาษาอังกฤษ
  - **ระบบภาพ Quiet Luxury (Single Accent System)**: 
    * ตัด Gradient ฉูดฉาด และ Glassmorphism ออกทั้งหมด
    * ชุดสี **Midnight Slate** (`#111315`, `#1A1E21`, `#262A2E`) และ **Warm Ivory** (`#F7F4EE`, `#FFFFFF`, `#E5E0D6`)
    * สีเน้นเดี่ยว **Warm Amber** (`#C99A52` / `#A9782E`) สำหรับ Action สำคัญ และ Selected state
    * สีเขียว Sage (`#6CA68A`) และ สีแดง Rose (`#D27A72`) ใช้เฉพาะตัวเลขผลตอบแทนพร้อมเครื่องหมาย `+` และ `−`
    * บังคับใช้ **Tabular Figures** (`FontFeature.tabularFigures()`) สำหรับตัวเลขทางการเงินทุกจำนวน ทำให้หลักตัวเลขตรงกันเป๊ะ
  - **การนำทางหลัก 5 แท็บ และปุ่มลอย FAB `+ Add`**:
    * ล็อกจำนวนเมนูไม่เกิน 5 รายการ: `Home`, `Money`, `Invest`, `Plan`, `More`
    * ปุ่มลอยตรงกลางทรงมนกำกับว่า **`+ Add`** แตะแล้วเปิด Bottom Sheet 4 รายการ: `Expense`, `Income`, `Transfer`, `Trade`
    * ย้ายปุ่ม Duplicate Last ออกจากหน้าแรก ไปแสดงเป็นทางเลือกเสริม "บันทึกรายการเดิมอีกครั้ง" หลังบันทึกรายการสำเร็จ
  - **หน้าแรก (Home Screen) — "สถานะ + สิ่งที่ควรทำ"**:
    * **Header สงบนิ่ง**: ชื่อ `VAULT` และเดือนปัจจุบัน (เช่น March 2026) พร้อมไอคอนค้นหาและตั้งค่า
    * **Master Budget Hero Card**: การ์ดเด่นใบเดียวของหน้า แสดงตัวเลขใหญ่เงินที่เหลือใช้ได้, สัดส่วนงบประมาณคงเหลือ, แถบความคืบหน้าเส้นบาง
    * **Today / Attention**: กล่องแจ้งเตือนข้อมูลสำคัญ 1 เรื่อง (แจ้งเตือนบัตรเครดิตใกล้ตัดรอบ หรืออัตราการออม)
    * **Financial Position**: Net Worth ตัวเลขเด่นคู่แนวโน้มเทียบเดือนก่อนหน้า (`↑ 2.4% vs last month`)
    * **Snapshot**: แถวเดียว 2 ช่อง (`Portfolio` และ `Credit Card`) เป็นทางเข้าสู่หน้ารายละเอียด
    * **Recent Activity**: แสดง 3 รายการล่าสุด พร้อมปุ่ม `View all transactions` ไปยังแท็บ Money
  - **หน้าเงิน (Money Screen)**:
    * รวม `Transactions | Accounts | Budgets & Projects` ด้วยแถบเมนูด้านบน (Top Tab Bar)
    * จัดกลุ่มบัญชีเป็น Cash & Bank, Credit Cards, และ Foreign Currency (USD แสดงป้ายเรียบหรูพร้อมยอดเทียบเคียง THB)
  - **หน้าลงทุน (Invest Screen)**:
    * ดีไซน์แบบ Portfolio Statement สุขุม นิ่ง ไม่กระพริบตา
    * 3 หมวดหมู่: Holdings, Realized P&L แยกตามปีภาษี, History พร้อมตัวกรอง
  - **หน้าแผนการเงิน (Plan Screen)**:
    * 3 Entry Cards: `Tax Planning`, `Foreign Remittance`, `Financial Health`
    * สไตล์ Progressive Disclosure เห็นคำตอบสรุปก่อน แล้วค่อยแตะดูวิธีคำนวณและ Audit Trail
  - **ระบบความปลอดภัยและการตั้งค่า (Security & Privacy Toggles)**:
    * เพิ่มสวิตช์เปิด-ปิดการล็อกแอปด้วย PIN (`isPinLockEnabled`) สามารถเปิด/ปิดได้อย่างอิสระ
    * ต้องใส่รหัส PIN หรือสแกนลายนิ้วมือเพื่อยืนยันตัวตนก่อน จึงจะสามารถปิดระบบล็อกแอปได้
    * สวิตช์เปิด-ปิดการสแกนลายนิ้วมือ/ใบหน้า (`isBiometricsEnabled`) ควบคู่กับ PIN
  - **แก้ไขปัญหาสีและความคมชัดใน Dark Mode (Reports & Remittance Screens)**:
    * **หน้ารายงานทางการเงิน (Reports Screen)**: แก้ไขแถบเลือกเดือน/ปี (Filter Toolbar), การ์ดสรุปตัวเลขภาพรวม (Metric Cards), และการแสดงผลรายงานทั้ง 7 ชนิด ยกเลิกการใช้สีขาว/พาสเทลกระด้าง เปลี่ยนมาใช้สีพื้นผิว `VaultTheme.surface`, ขอบบาง `VaultTheme.border`, และตัวเลขแบบ Tabular Figures สีเขียว Muted Sage / แดง Muted Rose สบายตา คมชัดทุกรายละเอียด
    * **หน้าติดตามเงินได้ต่างประเทศ (Foreign Remittance Screen)**: ปรับปรุงการ์ดสถานะผู้มีถิ่นที่อยู่ในไทย 180 วัน, บัตรรายการนำเงินเข้าไทย (Remittance Cards), เส้นทางบัญชี, ยอดเงินบาท, กล่องเหตุผลทางภาษี, และป้ายกำกับสถานะภาษี (Assessment Badges) สไตล์ Minimal โปร่งแสง ไม่กลืนกับพื้นหลังมืด
  - **การทดสอบความถูกต้อง (Test Coverage 100%)**:
    * ชุดทดสอบทั้งหมด 91 รายการ ผ่าน 100% (91/91 passing)
    * `flutter analyze` 0 errors, 0 warnings

---

### Phase 5: ระบบคลาวด์ซิงค์ Google Drive, Notion CSV Import Wizard, กฎภาษีการแพทย์ และคู่มือผู้ใช้ฉบับสมบูรณ์ (Done)
- [x] **5.1 Cloud Sync ผ่าน Google Drive ส่วนตัว 100% (แทนที่ Supabase ทั้งหมด)**:
  - **Zero Third-Party Cloud**: ตัดการพึ่งพา Supabase และบริการคลาวด์ภายนอกออกทั้งหมด 100% เพื่อความเป็นส่วนตัวสูงสุด ข้อมูลทั้งหมดจัดเก็บใน Google Drive ส่วนตัวของผู้ใช้เท่านั้น
  - **รองรับ Google Drive for Desktop บน Windows 11**:
    * ระบบตรวจจับไดรฟ์ของ Google Drive อัตโนมัติ (`G:\My Drive\VAULT` หรือโฟลเดอร์ Google Drive ในเครื่อง)
    * รองรับการเลือกโฟลเดอร์ Google Drive เองได้อย่างอิสระผ่าน Folder Picker
  - **Atomic Snapshot & SHA-256 Checksum**:
    * ส่งออกฐานข้อมูล `myfinance_vault.db` พร้อมไฟล์ตรวจสอบ `vault_sync_meta.json` (ข้อมูล timestamp, จำนวนบัญชี, จำนวนธุรกรรม, แฮช SHA-256)
    * ตรวจสอบความถูกต้องของ Checksum ก่อนการกู้คืน ป้องกันไฟล์เสียหายระหว่างถ่ายโอน
  - **Zero Data Loss Guarantee (Safety Pre-Sync Backup)**:
    * ระบบจะสร้างไฟล์สำรองฉุกเฉิน `backup_before_sync_<timestamp>.db` ในเครื่องโดยอัตโนมัติทุกครั้งก่อนนำข้อมูลจาก Google Drive มาเขียนทับ
    * มีหน้าต่างตรวจสอบรายการไฟล์สำรองย้อนหลัง พร้อมปุ่มกู้คืนกลับมาได้ในคลิกเดียว
  - **Remote Update Detection**: แจ้งเตือนแถบสีส้มทันทีเมื่อตรวจพบว่าไฟล์บน Google Drive มีการบันทึกใหม่กว่าในเครื่อง
  - สวิตช์ **"ซิงค์อัตโนมัติ (Auto-Sync)"** และ **"ซิงค์ผ่าน Wi-Fi เท่านั้น"**
  - หน้าจอ **`CloudSyncScreen`** สไตล์ Quiet Luxury รองรับทั้งการอัปโหลด, ดาวน์โหลด, เลือกโฟลเดอร์, และการย้อนกลับฉุกเฉิน
- [x] **5.2 Notion CSV Import Wizard**:
  - ตัวแปลงข้อมูลอัจฉริยะ **`CsvImportParser`**:
    * ตัดข้อความ Relation ลิงก์ของ Notion อัตโนมัติ (เช่น `Eating_OCT23 (https://...)` -> `Eating`)
    * ตรวจจับและข้ามแถวสรุปยอดรวม (Total / Summary rows เช่น `รวมทั้งเดือน ก.ย.`) อัตโนมัติ
    * แปลงวันที่ได้หลากหลายรูปแบบ: `26-Sep-23`, `5-Oct-23`, `2024-03-15`, และปี พ.ศ. (แปลงเป็น ค.ศ. อัตโนมัติ)
    * แปลงยอดเงินสกุลบาท (`THB 22,830.00`, `-THB 500.00`, `(1,250.00)`) เป็นจำนวนเต็มสตางค์ (`int`) ปลอดภัย 100%
  - **ระบบตรวจจับรายการซ้ำ (Duplicate Detection)**: เปรียบเทียบวัน, ยอดเงิน, และชื่อรายการกับในฐานข้อมูล พร้อมตัวเลือกข้ามรายการซ้ำ
  - **ระบบสร้างหมวดหมู่และบัญชีใหม่อัตโนมัติ (Auto Provisioning)**: หากพบหมวดหมู่หรือชื่อบัญชีกระเป๋าเงินใหม่ในไฟล์ ระบบจะสร้างให้ทันที
  - หน้าต่างตรวจสอบตัวอย่าง 20 แถวแรก (**`ImportPreviewDialog`**) พร้อมป้ายสถานะ (ปกติ, ซ้ำ, ข้ามแถวสรุป, ผิดพลาด)
  - **ระบบยกเลิกการนำเข้า 1 คลิก (Batch Rollback)**: ตาราง `import_batches` จัดเก็บประวัติการนำเข้าทุกชุด ผู้ใช้สามารถกดปุ่ม Rollback ในหน้า `ImportHistoryScreen` เพื่อลบธุรกรรมทั้งชุดออกได้ในคลิกเดียวอย่างปลอดภัย
- [x] **ระบบภาษีรายได้บุคลากรสาธารณสุขและแพทย์ (Medical Healthcare Income Tax Rules)**:
  - **มาตรา 40(1)**: `เงินเดือนจาก สสจ.` (WHT 0), `เงินประจำตำแหน่ง` (WHT 0), `P4P (Pay for Performance)` (หัก 5% อัตโนมัติเมื่อวันที่ >= ก.ค. 2569 / 2569 BE), `พ.ต.ส.` (หัก 5% อัตโนมัติเมื่อวันที่ >= ก.ค. 2569 / 2569 BE)
  - **มาตรา 40(2)**: `เงินเวรเหมา` (WHT 0), `เงินรายชั่วโมง` (WHT 0), `เงิน DF` (WHT 0), `TTCM` (บันทึกภาษีหัก ณ ที่จ่ายตามเอกสาร)
  - **ยกเว้นภาษี (Non-taxable)**: `เงิน Top up` ได้รับการยกเว้นภาษี 100% ไม่นำมาคำนวณเป็นเงินได้พึงประเมิน
  - ยอดคงเหลือในบัญชีธนาคารคำนวณจากยอดสุทธิหลังหักภาษี ณ ที่จ่าย (`amount - withholdingTaxSatang`) เพื่อให้ตรงกับ Statement ธนาคารจริง
- [x] **5.3 Optimization & User Documentation**:
  - ลบแพ็กเกจ Supabase ที่ไม่ได้ใช้ออกทั้งหมด 21 แพ็กเกจ ลดขนาดแอปให้เบาและรวดเร็ว
  - จัดทำคู่มือการใช้งานภาษาไทยฉบับสมบูรณ์ **`docs/USER_MANUAL_TH.md`** ครอบคลุม 11 ระบบหลัก
  - **ปรับแต่งการแสดงผลปุ่มบันทึกรายรับ-รายจ่าย (+ เพิ่ม) ให้คงไว้เฉพาะ 2 หน้าที่จำเป็น**: ซ่อนปุ่มลอย (+ เพิ่ม) ออกจากแท็บอื่นทั้งหมด และให้แสดงเฉพาะในหน้า **"หน้าแรก (Home)"** และหน้า **"การเงิน -> รายการ (Money-Transactions)"** เท่านั้น โดยซ่อนออกจากหน้า บัญชี (Accounts ที่มีปุ่มเพิ่มบัญชีของตัวเอง), งบประมาณ (Budget), การลงทุน (Invest ที่มีปุ่มซื้อ/ขาย), แผนการเงิน (Plan), และการตั้งค่า (Settings) เพื่อความสะอาดและป้องกันปุ่มซ้อนทับกัน
  - **ระบบจัดการและลบประวัติการซื้อ-ขายการลงทุน (Investment Trade Deletion & FIFO Recalculation)**:
    * เพิ่มปุ่มลบรายการ (ไอคอนถังขยะสีแดง) ในทุกการ์ดของแท็บ **"ประวัติการซื้อ-ขาย"** ในหน้าพอร์ตการลงทุน พร้อมกล่องข้อความยืนยันลบรายการ และคำนวณคืน Lot/FIFO ให้อัตโนมัติ
    * เชื่อมโยงให้ `TransactionsDao.softDeleteTransaction` อัปเดตตาราง `investment_lots`, `investment_sales`, `investment_incomes` และสั่ง replay FIFO อัตโนมัติทุกครั้ง
    * ปรับหน้า **"การเงิน -> รายการ"** ให้ครอบคลุมธุรกรรมลงทุน (`excludeInvestments: false`) เพื่อให้ผู้ใช้มองเห็นและแก้ไขได้ครบถ้วนในที่เดียว
    * ล้างรายการธุรกรรมขาย JEPQ ที่ไม่มีบัญชีผูก (Orphaned trade) ออกจากฐานข้อมูลจริง และปรับสถานะพอร์ตลงทุนให้สะอาดเรียบร้อย 100%
- [x] **5.4 ปรับปรุง UX การลงทุนและการป้อนข้อมูลตัวเลข/PIN (Investment Watchlist & Strict Numeric Input)**:
  - **แสดงรายชื่อสินทรัพย์ที่รอเข้าซื้อในแท็บพอร์ตลงทุนทันที (Uninvested Assets Quick Buy)**:
    * เมื่อสร้างสินทรัพย์เข้าสู่ระบบแต่ยังไม่ได้ซื้อ (ถือครอง 0 หน่วย) ระบบจะไม่แสดงหน้าว่างเปล่า แต่จะนำรายชื่อสินทรัพย์ที่รอซื้อมาแสดงพร้อมปุ่ม **"+ ซื้อ"** ขนาดชัดเจน เพื่อให้กดเริ่มซื้อได้ทันที
  - **บังคับกรอกเฉพาะตัวเลขในทุกช่องราคาและรหัส PIN (Strict Numeric & PIN Input Enforced)**:
    * ติดตั้ง `FilteringTextInputFormatter` ในทุกช่องกรอกตัวเลขทั่วทั้งระบบ (ราคาหุ้น, จำนวนหน่วย, ค่าธรรมเนียม, เรต FX, เงินงบประมาณ, วงเงินสินเชื่อ, ดอกเบี้ย, เบี้ยประกัน, วันที่) ป้องกันการพิมพ์ตัวอักษรหรือสัญลักษณ์จากคีย์บอร์ดคอมพิวเตอร์ (Physical Keyboard) ได้ 100%
    * หน้าต่าง PIN 6 หลัก (`PinLockDialog` และ `PinSetupDialog`) รองรับการพิมพ์ผ่านแป้นพิมพ์จริง (Numpad / ตัวเลขแถวบน) และดักจับเฉพาะตัวเลข 0-9 และปุ่มลบ Backspace เท่านั้น
- [x] **5.5 การจัดการหมวดหมู่และงบประมาณ (Budget & Category Management)**:
  - เพิ่มปุ่มลัดไปยังหน้าจัดการหมวดหมู่บน AppBar ของหน้างบประมาณ
  - รองรับการสร้างหมวดหมู่ใหม่แบบ Inline ในหน้าต่างตั้งงบประมาณ พร้อมเลือกหมวดหมู่ที่สร้างใหม่อัตโนมัติ
  - เพิ่มปุ่มลบงบประมาณในแต่ละการ์ดของหน้างบประมาณรายเดือน
  - อนุญาตให้ซ่อน (Deactivate) หมวดหมู่ค่าเริ่มต้น (System Categories) ได้ และเพิ่มสวิตช์แสดง/กู้คืนหมวดหมู่ที่ถูกซ่อน
  - แก้ไข CSV Import Parser ให้ข้ามแถวว่างและแถวหัวตารางซ้ำอัตโนมัติ (ขจัดข้อผิดพลาดของ Notion CSV)
- [x] **5.6 ตัวกรองประเภทรายการในหน้าประวัติธุรกรรม (Transaction Type Filter Chips)**:
  - เพิ่มตัวกรองแบบ Chip ด่วนใต้ช่องค้นหาในแท็บประวัติรายการธุรกรรม: **"ทั้งหมด"**, **"รายรับ"** (เขียว), **"รายจ่าย"** (แดง), **"โอนเงิน"** (เทา)
  - ผู้ใช้แตะเลือกเพื่อกรองรายการได้ทันทีใน 1 สัมผัส โดยไม่ต้องเปิดหน้าต่างตัวกรอง
  - อัปเดต `TransactionsDao.searchTransactions` ให้รองรับพารามิเตอร์ `transactionType`
  - เชื่อมโยงปุ่มล้างตัวกรองให้รีเซ็ตค่าตัวกรองประเภทรายการกลับสู่ค่าเริ่มต้น ("ทั้งหมด")
- [x] **5.7 ระบบสลับธีมและธีมใหม่ Lumi (Sunny Bloom Theme & Multi-Theme Engine)**:
  - **สถาปัตยกรรม ThemeExtension และ AppThemeStyle**:
    * สร้าง `AppThemeStyle` (รองรับ `vault` และ `lumi`) บันทึกค่าลงใน `SharedPreferences` ถาวร
    * สร้าง `AppThemeColors` เพื่อส่งค่าสีเฉพาะทาง (Semantic Colors, Gradients, Radius) ผ่านระบบ Material 3
    * ปรับปรุง `VaultTheme` context helpers ให้ดึงสีผ่าน ThemeExtension อัตโนมัติ ทำให้ทุกหน้าจอปรับเปลี่ยนสีตามธีมที่เลือกทันที 100%
  - **ธีม Lumi — Sunny Bloom สไตล์น่ารักอบอุ่น**:
    * ชุดสีพาสเทลสดใส: ชมพูแคนดี้โรส (`#FF5C9D`), เหลืองนวล (`#FFF7D6`), ฟ้าสกาย (`#BFE9FF`), เขียวมิ้นต์ (`#D5F7C4`), พีช (`#FFD5A5`)
    * พื้นหลังสีครีมอุ่นนวลตา (`#FFFDF9`), ขอบการ์ดมน 22-24px, ปุ่มทรงแคปซูล Pill-shaped
    * รองรับทั้ง Light Mode (Sunny Bloom) และ Dark Mode (Twilight Bloom โทนพลัมอบอุ่น)
  - **ปรับแต่งหน้าหลัก (Home) ให้เข้ากับสไตล์ Lumi ครบถ้วนตามภาพตัวอย่าง**:
    * การ์ดทักทายสดใส: *"สวัสดีตอนเช้า ☀️"* พร้อมรูปอวาตาร์มาสคอตน้อง Lumi กอดน้องแมวส้มในกรอบวงกลมขอบชมพูหวาน
    * การ์ดงบประมาณ Master Budget ไล่เฉดสีพาสเทลชมพู-เหลืองนวล พร้อมหัวข้อ *"เงินที่ใช้ได้ในเดือนนี้ 🌸"* และ**รูปมาสคอต Lumi ขนาดใหญ่ (Big Mascot) กอดน้องแมวส้ม**ในกรอบมนนูนสวยงามอยู่เคียงข้างยอดเงิน
    * **นำ Quick Action Tiles ออกตามความต้องการของผู้ใช้**: ปรับหน้าจอให้โล่ง สบายตา และขับความโดดเด่นของมาสคอตและการ์ดงบประมาณอย่างเต็มที่
    * **กล่องข้อความให้กำลังใจ (Lumi Tips)**: กล่องการแจ้งเตือนพร้อมไอคอนรูปหน้าน้องแมวส้มคมชัดน่ารัก *"Lumi Tips: การเงินดีเริ่มต้นจากวันละนิด"* และเตือนวันตัดรอบบัตรเครดิต
    * **การ์ดภาพรวมการเงิน (Financial Position)**: แสดงมูลค่าทรัพย์สินสุทธิ พร้อมเปอร์เซ็นต์แนวโน้มรายเดือนและปุ่ม *"ดูทั้งหมด ›"*
    * **การ์ดสรุปย่อยคู่สีพาสเทล (Mini Snapshot Cards)**: การ์ด *"พอร์ตการลงทุน 📈"* (ขอบพาสเทลเขียวมิ้นต์ `#D5F7C4`) และการ์ด *"บัตรเครดิต 💳"* (ขอบพาสเทลฟ้าคราม `#BFE9FF`)
    * **รายการล่าสุด (Recent Activity)**: หัวข้อภาษาไทยพร้อมไอคอนนำหน้าแต่ละรายการในกรอบสี่เหลี่ยมโค้งมนสีพาสเทลสดใส (เขียว/ชมพู/ฟ้า)
  - **เมนูสลับสไตล์ในหน้าตั้งค่า (Settings)**:
    * เพิ่มเมนู *"สไตล์ดีไซน์ (Design Theme)"* ในหน้าตั้งค่า ให้เลือกสลับระหว่าง `VAULT (เรียบหรู คลาสสิก)` กับ `Lumi (สดใส อบอุ่น Sunny Bloom)` ได้ทันที
- [x] **5.8 ปรับปรุงภาษาไทยหน้างบประมาณ + หน้าสรุปภาพรวมรายเดือน (Monthly Summary) + การ์ตูน Lumi + ไอคอน Quick Add**:
  - **กู้คืนภาษาไทยในหน้างบประมาณและหมวดหมู่ 100%**:
    * แก้ไขข้อความเพี้ยน `à¸...` ใน `budget_screen.dart` และ `categories_screen.dart` ให้ถูกต้องสวยงามทุกจุด
    * ปรับแต่งทั้งสองหน้าให้คุมโทนตามธีมอย่างเคร่งครัด: โหมด **VAULT** คงความหรูหรา Quiet Luxury สี Slate/Ivory/Gold Accent และโหมด **Lumi** ใช้โทน Sunny Bloom สดใส
  - **การ์ดงบประมาณ Master Budget ธีม Lumi พร้อมภาพการ์ตูนน้อง Lumi ขยิบตา**:
    * ผสานภาพการ์ตูนน้อง Lumi กอดน้องแมวส้ม (`lumi_budget_character.png`) ลงบนการ์ดอย่างกลมกลืน ไร้กรอบสี่เหลี่ยมหนา
    * แสดงตัวเลขยอดเงินคงเหลือตัวใหญ่, ข้อความ *"จากงบ ฿..."*, และหลอดความคืบหน้าทรงมนสีชมพูพร้อมเปอร์เซ็นต์ (เช่น `62%`) ตรงตามภาพต้นแบบ 100%
  - **ชุดไอคอนหมวดหมู่ 40+ แบบ & แสดงไอคอนจิ๋วใน Quick Add**:
    * สร้าง `CategoryIconHelper` รวบรวมไอคอน Material Icons กว่า 40+ หมวดหมู่ยอดนิยม (อาหาร, คาเฟ่, ช้อปปิ้ง, เดินทาง, บิล, สุขภาพ, บันเทิง, สัตว์เลี้ยง, รายรับเงินเดือน/โบนัส/ปันผล ฯลฯ)
    * เพิ่มตารางเลือกไอคอนแบบแบ่งหมวดหมู่ในหน้าต่างสร้าง/แก้ไขหมวดหมู่ (`CategoryFormDialog`)
    * แสดงไอคอนขนาดเล็ก (Avatar Icon) หน้าชื่อหมวดหมู่ในแถบตัวเลือก (`ChoiceChip`) ของหน้า **บันทึกด่วน (Quick Add)**
  - **หน้าสรุปภาพรวมรายเดือน (Monthly Summary Overview Screen)**:
    * สร้างหน้าจอ `MonthlySummaryScreen` ถอดแบบจากดีไซน์ต้นแบบ 100%
    * มีปุ่ม `<` และ `>` ให้กดเปลี่ยนเดือนดูข้อมูลย้อนหลังหรือล่วงหน้าได้อย่างอิสระ
    * การ์ดสรุปคู่: รายรับ (เขียวพาสเทล) และรายจ่าย (ชมพูพาสเทล) คำนวณยอดเงินจริงจากฐานข้อมูล
    * การ์ดออมได้ (Net Savings): แสดงยอดออมสุทธิ พร้อมเปอร์เซ็นต์เปรียบเทียบกับเดือนที่แล้ว (`↑ % จากเดือนที่แล้ว`) และรูปภาพน้องแมวยิ้มนั่งข้างกองเหรียญทอง (`lumi_savings_cat.png`)
    * กราฟแนวโน้มรายจ่าย (Expense Trend Curve): กราฟเส้นโค้งสีชมพู Smooth Spline ด้วย `fl_chart` แสดงการสะสมของรายจ่ายตลอดเดือน (วันที่ 1, 8, 15, 22, สิ้นเดือน) พร้อมจุดกลมสีชมพู แถบป้ายยอดเงิน และสีไล่เฉดใต้กราฟ
- [x] **5.9 ปรับโฉมหน้าจอหลัก Home Dashboard เป็น Lumi (Desktop 2-Column Grid) สมบูรณ์แบบ**:
  - **โครงสร้าง Desktop 2-Column Grid (สัดส่วน 58% / 42%)**:
    * ออกแบบให้กว้างสูงสุด `1240px` จัดวางกลางจอสวยงาม พร้อมรองรับการย่อหน้าจอ Responsive สู่ 1 คอลัมน์บน Tablet และ Mobile โดยไม่เกิด RenderFlex Overflow
    * **คอลัมน์ซ้าย (58%)**:
      1. ส่วนหัวทักทายสดใส *"สวัสดีตอนเช้า ☀️"* พร้อม Avatar มาสคอต Lumi กรอบวงกลมและปุ่มเครื่องมือค้นหา
      2. `BudgetHeroCard`: การ์ดงบประมาณรายเดือนขนาดใหญ่ ไล่เฉดสีครีม-พีชพาสเทล พร้อมรูปมาสคอตน้อง Lumi กอดน้องแมวนั่งอยู่อย่างพอดี, ยอดคงเหลือตัวใหญ่เด่นชัด, ยอดใช้ไป/งบรวม, และหลอดแสดงเปอร์เซ็นต์
      3. `LumiTipCard`: การ์ดข้อความคำแนะนำสีส้มพีช (`#FFF4E3`) พร้อมรูปแมว Momo และคำแนะนำทางการเงิน
      4. `FinancialOverviewCard`: การ์ดภาพรวมสถานะการเงินสีขาว รัศมี 24px แสดง Net Worth, MoM %, และสรุปรายรับ vs รายจ่าย
      5. `RecentActivityCard`: การ์ดรายการธุรกรรมล่าสุดสไตล์สมุดบันทึก (Journal-style) พร้อมไอคอนพาสเทลและสถานะ Empty State
    * **คอลัมน์ขวา (42%)**:
      1. `GoalsCard`: การ์ดเป้าหมายเงินออม (เชื่อมข้อมูลจริงจากตาราง `projects`) แสดงหลอด Progress Bar พร้อมไอคอนแยกประเภท และสถานะแนะนำการเริ่มออม
      2. `PortfolioCard`: การ์ดพอร์ตลงทุนสีเขียวมิ้นต์อ่อน (`#F0FAF2`) แสดงยอดพอร์ตและ % กำไรสะสม
      3. `CreditCardCard`: การ์ดบัตรเครดิตสีฟ้าสกายบลู (`#EEF8FF`) แสดงยอดหนี้รอบบิลและวันตัดรอบ
  - **คุมธีมโหมด VAULT (Quiet Luxury) คงเดิม 100%**:
    * แยกการเรนเดอร์ผ่าน `isLumi` อย่างสมบูรณ์แบบ เมื่อสลับเป็นโหมด VAULT หน้าแรกจะแสดงผลในสไตล์ Quiet Luxury คลาสสิกโทนสีดำ/ทองเดิม ไม่มีการปนเปื้อนของสีชมพูหรือมาสคอตการ์ตูนเด็ดขาด
  - **แถบนำทางข้าง Desktop (NavigationRail) สไตล์ Lumi**:
    * กว้าง 92px พื้นหลังสีนวล `#FFF9F5` มี Avatar น้อง Lumi พร้อมชื่อ "Lumi" ตัวเลือกเป็นแคปซูลมนสีชมพู และปุ่มลอย FAB สีชมพู Bubblegum Rose (`#FF5B9A`)
- [x] **5.10 ขยายสู่แพลตฟอร์ม Web App (PWA) Offline-First และระบบ Multi-Platform**:
  - **เปิดใช้งานแพลตฟอร์ม Web (Flutter Web)**:
    * สร้างโฟลเดอร์ `web/` และคอนฟิก `manifest.json` สไตล์ Lumi (`#FFF9F5`)
    * กำหนดคุณสมบัติ PWA Standalone (เปิดเต็มจอเสมือนแอปจริงบน Safari iPhone/iPad และ Chrome)
    * เพิ่ม App Shortcuts สำหรับกดค้างที่ไอคอนแอปบนหน้าจอมือถือ (+ บันทึกรายจ่าย, + บันทึกรายรับ, สรุปเดือนนี้)
  - **สถาปัตยกรรมฐานข้อมูล Multi-Platform (Conditional Connection)**:
    * ผสาน `drift_flutter` จัดการการเชื่อมต่อฐานข้อมูลอัตโนมัติตามแพลตฟอร์ม
    * บน Windows Desktop และ Android: ใช้ Native SQLite ในเครื่องเดิม 100%
    * บน Web: ใช้ IndexedDB / OPFS จัดเก็บข้อมูลการเงินในเครื่องบราวเซอร์แบบ Offline-First (ใช้งานตอนไม่มีเน็ตได้ 100%)
  - **สคริปต์เปิดทดสอบเว็บในเครื่องทันที (`เปิดเว็บ_Lumi_Web.bat`)**:
    * ดับเบิลคลิกเปิดเซิร์ฟเวอร์จำลองและเปิดบราวเซอร์ที่ `http://localhost:8080` ได้ในคลิกเดียว
  - **การทดสอบความถูกต้องและคุณภาพโค้ด (Quality Assurance)**:
    * ชุดทดสอบทั้งหมด **116 รายการ ผ่าน 100% (116/116 passing)**
    * `flutter analyze` **0 errors, 0 warnings, 0 issues**
    * คอมไพล์ Web Release สำเร็จสมบูรณ์ (`√ Built build\web`)
    * คอมไพล์ Windows Debug สำเร็จสมบูรณ์ (`√ Built build\windows\x64\runner\Debug\myfinance.exe`)
- [x] **5.11 ระบบ Hybrid Personal Backup และเตรียมเผยแพร่ออนไลน์ผ่าน GitHub Pages**:
  - **ระบบสำรองข้อมูลส่วนบุคคล Multi-Platform (Hybrid Backup Engine)**:
    * สร้าง `HybridBackupService` สำหรับแปลงฐานข้อมูล (บัญชี, รายการธุรกรรม, หมวดหมู่, งบประมาณ, หนี้สิน, ประกันภัย) ออกมาเป็นโครงสร้างไฟล์ JSON มาตรฐานความปลอดภัยสูง
    * รองรับการส่งออกข้ามทุกระบบ (Web / Windows / Android) โดยบนเบราว์เซอร์จะสั่งดาวน์โหลดไฟล์ `myfinance_backup_YYYY-MM-DD.json` อัตโนมัติ ผู้ใช้สามารถนำไปบันทึกลงใน **Google Drive ส่วนตัว**, iCloud หรือแฟลชไดรฟ์ได้ทันที
    * รองรับการกู้คืนข้อมูล (Restore) จากไฟล์สำรองผ่าน File Picker โดยมีการยืนยันความถูกต้องของข้อมูลก่อนนำเข้าสู่ SQLite / IndexedDB
  - **ระบบเชื่อมต่อ GitHub Actions & 1-Click Deploy สู่ GitHub Pages**:
    * สร้าง Workflow `.github/workflows/deploy.yml` รองรับการคอมไพล์และอัปเดตเว็บแอปอัตโนมัติ 100% บนเซิร์ฟเวอร์ของ GitHub
    * สร้างสคริปต์คลิกเดียว [`อัปโหลดขึ้น_GitHub_Pages.bat`](file:///c:/Projects/myfinance/อัปโหลดขึ้น_GitHub_Pages.bat) ช่วยส่งโปรเจกต์ขึ้น GitHub อัตโนมัติ
  - **ความถูกต้องและการรับประกันคุณภาพ (Quality Assurance)**:
    * Unit Tests ทั้งหมดเพิ่มเป็น **116/116 รายการ ผ่านฉลุย 100%**
    * `flutter analyze` **0 errors, 0 warnings**
    * คอมไพล์ผ่านสมบูรณ์ทั้ง Web Release และ Windows Native Debug

- [x] **5.12 ปรับแบรนด์เป็น JP Money, แปลภาษาอังกฤษ 100%, ปรับคอนทราสต์ตัวอักษร และแก้ไขสคริปต์อัปโหลด**:
  - **รีแบรนด์ชื่อแอปพลิเคชันเป็น "JP Money" ทุกแพลตฟอร์ม**:
    * เปลี่ยนชื่อระบบทั้งหมดเป็น "JP Money" (Web `<title>`, `manifest.json`, Android `AndroidManifest.xml`, Windows `main.cpp`, Navigation Bar, Headers)
    * ปรับให้ "VAULT" และ "LUMI" เป็นเพียงโหมดธีมสไตล์ (Style Themes) ที่ผู้ใช้เลือกสลับได้ตามความชอบ
  - **ระบบรองรับภาษาอังกฤษสมบูรณ์ 100% (Full English Localization)**:
    * ขยายคลังข้อความใน `app_th.arb` และ `app_en.arb` รวมกว่า 80 ข้อความใหม่ ครอบคลุมทุกหน้าจอ ทุกเมนู ทุกไดอะล็อก และการแจ้งเตือน
    * แปลหน้า SettingsScreen, Navigation Bar, Home Greeting, และข้อความระบบทั้งหมดให้เป็นภาษาอังกฤษทั้งหมดเมื่อเลือกโหมด English
  - **ปรับปรุงคอนทราสต์ตัวอักษรให้อ่านง่ายขึ้นทุกธีม (Readability & Contrast Tuning)**:
    * ปรับสีข้อความรอง (Secondary Text) และข้อความกลืน (Muted Text) ใน `VaultTheme` และ `LumiTheme` ทั้ง Light และ Dark ให้มีค่า Contrast Ratio สูงขึ้น ผ่านมาตรฐาน WCAG AA (>4.5:1)
    * แก้ไขสีหัวข้อเมนูในหน้าการตั้งค่าไม่ให้กลืนกับพื้นหลังในโหมดมืด
  - **แก้ไขสคริปต์อัปโหลดขึ้น GitHub Pages**:
    * ย้ายกระบวนการจาก batch script เก่ามาเป็น PowerShell `upload_github.ps1` ร่วมกับ UTF-8 ทำให้ไม่ติดปัญหา syntax parentheses และไม่ติดปัญหาภาษาไทย
    * สร้าง git commit และตั้งค่าความพร้อมสำหรับ push สู่ GitHub ได้ทันที
  - **รับประกันคุณภาพ (Quality Assurance)**:
    * Unit Tests ทั้งหมด **116/116 ผ่านฉลุย 100%**
    * `flutter analyze`: **0 errors, 0 warnings**
    * `flutter build web --release`: คอมไพล์ผ่านสมบูรณ์ 100%

- [x] **5.13 ประกอบไฟล์ติดตั้ง Android APK สำเร็จสมบูรณ์ (Release APK Ready)**:
  - ติดตั้งคอมโพเนนต์ Android NDK (`ndk/28.2.13676358`) และ CMake เข้าสู่ Android SDK
  - แก้ไข `MyFinanceWidgetProvider.kt` ป้องกัน Null Safety issue ใน Kotlin
  - คอนฟิก `android/build.gradle.kts` ให้ปลั๊กอินภายนอก (เช่น `file_picker`) ขยับ `compileSdkVersion` เป็น 36 ตามข้อกำหนดของ Flutter Lifecycle
  - แก้ไขโครงสร้างไฟล์ [`สร้างไฟล์_Android_APK.bat`](file:///c:/Projects/myfinance/สร้างไฟล์_Android_APK.bat) ให้ใช้คำสั่ง `goto` แทนบล็อกวงเล็บ ทำให้รันได้ลื่นไหล 100%
  - สร้างไฟล์ติดตั้ง **`app-release.apk`** ขนาด **76.1 MB** สำเร็จสมบูรณ์ พร้อมติดตั้งลงมือถือ Android ได้ทันที

- [x] **5.14 ปรับปรุงดีไซน์ครั้งใหญ่ รีแบรนด์ OURS และประสานหน้า Home / Settings (Live Verified on Device)**:
  - **รีแบรนด์ชื่อแอปเป็น "OURS"**:
    * สโลแกนใหม่: *"Our money, our journey."*
    * อัปเดตชื่อแสดงในระบบแอนดรอยด์ `AndroidManifest.xml`, `web/index.html` และหน้าตั้งค่า
  - **ประสานหน้า Home ระหว่างโหมด Lumi และ Vault ให้มีโครงสร้างเหมือนกัน**:
    * ลบการ์ด Financial Health & Goals ออกจากหน้า Home ตามที่ผู้ใช้สั่ง เพื่อความเรียบง่าย ไม่รกรุงรัง
    * เรียงลำดับการ์ดมาตรฐาน 6 การ์ด: Greeting Header -> Master Budget -> Tip/Advice -> Financial Overview -> Snapshot (Portfolio + Credit Card) -> Recent Activity
  - **แก้ไขปัญหายอดงบประมาณหลอก 30,000 บาท**:
    * ปรับเป็นระบบดึงงบจริงจากฐานข้อมูล หากยังไม่ได้ตั้งงบจะแสดงกล่องแจ้งเตือนน่ารัก "ยังไม่ได้ตั้งงบประมาณเดือนนี้ / No budget set this month" พร้อมปุ่มกด `+ ตั้งงบประมาณ / + Set Budget`
  - **ยกเครื่องหน้าการตั้งค่า (Settings Overhaul)**:
    * เปลี่ยนจากการ์ดซ้อนกันแน่นขนัดมาเป็นดีไซน์ Section Card โค้งมนสวยงาม พร้อม Inset Divider
    * ไอคอนหัวข้อบรรจุใน Icon Badge ทรงโค้งมน (36x36dp) แยกสีสดใสตามหมวดหมู่ ไม่ล้นกรอบ
    * จัดวาง Dropdown และ Switch แบบ Compact ไม่เบียดบังตัวหนังสือ
    * ใส่ข้อมูลเวอร์ชันและสโลแกนใต้หน้าจออย่างลงตัว
  - **แก้ปัญหาคอนทราสต์ในหน้าสุขภาพการเงิน (Financial Health)**:
    * ปรับสีการ์ด Run-rate forecast และสรุปหนี้สิน/ประกัน ให้สว่าง คมชัด เข้ากับธีม ไม่มืดทะมึนกลืนตัวหนังสือ
  - **รองรับภาษาอังกฤษสมบูรณ์ 100% (Full Localization)**:
    * แปลและทดสอบทุกจุดสำคัญในหน้า Home, Money, Invest, Plan และ Settings
    * ปรับความยาวคำในช่องแสดงผลย่อย (Income, Expense, Cash Flow) ให้อ่านได้ครบถ้วนสวยงามบนหน้าจอมือถือทุกขนาด
  - **ทดสอบและยืนยันผลบนมือถือจริง Oppo Find X9 (ColorOS 16 / Android 16)**:
    * ติดตั้งผ่าน ADB Streamed Install และตรวจสอบภาพหน้าจอจริง แอปเปิดได้ลื่นไหล ไม่เด้ง หน้าตาตรงปก 100%
  - **การรับประกันคุณภาพ**:
    * `flutter analyze`: **0 errors, 0 warnings**
    * `flutter test`: **116/116 ผ่านฉลุย 100%**
    * `flutter build apk --release`: คอมไพล์ผ่านสมบูรณ์ ได้ไฟล์ `OURS.apk` (39.9 MB)

- [x] **5.16 ปรับปรุงแบรนด์ Web Desktop, ฝังฟอนต์ Noto Sans Thai บน Android, แปลภาษาอังกฤษครบทุกเมนู, ปุ่มลบหมวดหมู่ที่กำหนดเอง, และยกเครื่องระบบสำรองข้อมูล Google Drive Only ผ่าน Gmail**:
  - **ปรับปรุงแบรนด์ Web Desktop และขอบ Status Bar**:
    * อัปเดตแถบนำทางด้านซ้าย (`NavigationRail`) บน Desktop จาก "JP Money" เป็น **"OURS"** พร้อมแสดงโลโก้จริง `assets/images/app_logo.png`
    * แก้ไขสีขอบ Status Bar / ขอบบนของจอให้กลมกลืนเป็นสีเดียวกับตัวแอปด้วย `AnnotatedRegion<SystemUiOverlayStyle>` และ `web/index.html` theme-color
  - **ฝังฟอนต์แท้ Noto Sans Thai ลงในแอปพลิเคชัน Android**:
    * ดาวน์โหลดและติดตั้งไฟล์ฟอนต์ TTF แท้ (`NotoSansThai-Regular.ttf`, `NotoSansThai-Medium.ttf`, `NotoSansThai-SemiBold.ttf`, `NotoSansThai-Bold.ttf`) ลงใน `assets/fonts/`
    * ลงทะเบียนฟอนต์ใน `pubspec.yaml` ทำให้ตัวอักษรภาษาไทยบน Android แสดงผลสวยงาม ละมุนตา เหมือนกับบนเบราว์เซอร์ 100%
  - **แปลภาษาอังกฤษครบถ้วน 100% (Full English Localization)**:
    * **หน้าบัญชี (Money -> Accounts)**: แปลหน้ารายการบัญชี, หน้ารายละเอียดบัญชี (`AccountDetailScreen`), ไดอะล็อกสร้างบัญชี (`AddAccountDialog`), และหน้าสรุปบิลบัตรเครดิต (`CreditCardSummaryScreen`)
    * **หน้าโครงการพิเศษ (Budget -> Special Projects)**: แปลสถานะโครงการ, รายการธุรกรรมย่อยในโครงการ, และไดอะล็อกสร้างโครงการ
    * **หน้าพอร์ตการลงทุน (Invest)**: แปลครบทั้ง 3 แท็บ (Holdings, Realized P&L แยกรายปี, Trade History), กราฟสัดส่วนสินทรัพย์ Donut Chart, ป้ายประเภทสินทรัพย์, และไดอะล็อกยืนยันการลบ
    * **เมนูเพิ่ม (+ Vault Add Sheet)**: แปลคำอธิบายใต้ปุ่มบันทึกด่วน, โอนเงิน, ซื้อ/ขายสินทรัพย์, และโครงการพิเศษ
  - **เพิ่มปุ่มลบหมวดหมู่ที่ผู้ใช้สร้างเอง (Delete Custom Category)**:
    * เพิ่มปุ่มไอคอนถังขยะสีแดงสำหรับหมวดหมู่ที่ผู้ใช้สร้างเอง (`!isSystem`) ในหน้าจัดการหมวดหมู่ (`CategoriesScreen`) พร้อมกล่องข้อความยืนยันความปลอดภัย และบันทึก Soft Delete ลงฐานข้อมูล
  - **ยกเครื่องระบบสำรองข้อมูลเป็น Google Drive Only พร้อมปุ่ม Login ผ่าน Gmail**:
    * นำตัวเลือกสำรอง/กู้คืน JSON และนำเข้า Notion CSV ออกจากหน้าตั้งค่าตามคำขอผู้ใช้
    * รวมศูนย์เป็นส่วน "สำรองข้อมูลบนคลาวด์ (Google Drive)" พร้อมการ์ดสถานะบัญชี Gmail, ปุ่มเข้าสู่ระบบ Google (Gmail Login), ปุ่ม "สำรองข้อมูลเดี๋ยวนี้" และปุ่ม "ดึงข้อมูลจากไดรฟ์"
    * รักษาเมนูถังขยะกู้คืนข้อมูล 30 วัน (Trash Bin) ไว้ในหน้าตั้งค่าเพื่อให้ผู้ใช้กู้คืนข้อมูลที่เผลอลบได้ตลอดเวลา
  - **การรับประกันคุณภาพ (Quality Assurance)**:
    * `flutter analyze`: **0 errors, 0 warnings, 0 issues**
- [x] **5.17 ปรับปรุงความคมชัด Dark Mode, แปลภาษาอังกฤษครบทุกหน้าจอ (Foreign Remittance, Financial Health, Debts & Insurance, Quick Add, Trade Dialog), ฟอนต์แท้ Noto Sans Thai, และรวมศูนย์ Google Drive Sync**:
  - **แก้ไขฟอนต์ Noto Sans Thai แท้ 100% บน Android**:
    * ดาวน์โหลดไฟล์ฟอนต์ TrueType (`.ttf`) ตัวจริงจาก Google Fonts ทั้ง 4 น้ำหนัก (Regular, Medium, SemiBold, Bold) แทนที่ไฟล์เดิมที่มีปัญหา
    * ตัวอักษรแสดงผลสวยงาม คมชัด และสอดคล้องกับบน Web Desktop
  - **รวมศูนย์เมนู Google Drive Sync ในหน้าตั้งค่า**:
    * ยุบรวมการตั้งค่า Google Drive ให้เหลือเพียงเมนูเดียวในหน้าตั้งค่า เข้าถึงหน้า `CloudSyncScreen` โดยตรง
    * เพิ่มระบบสำรองด้วยการกรอก Gmail เมื่ออุปกรณ์ Android ไม่พบ Google Sign-In Client ID (หลีกเลี่ยงข้อผิดพลาด `ApiException 10`)
  - **ปรับปรุงคอนทราสต์และความคมชัดหน้า Debts & Insurance**:
    * ปรับสีการ์ดสรุปหนี้สินและกรมธรรม์ประกันภัยให้ใช้ `VaultTheme.surface(context)` และข้อความคมชัดสูง ไม่มืดกลืนใน Dark Mode
  - **แปลภาษาอังกฤษครบถ้วน 100% (Bilingual Support)**:
    * **ภาษีนำเงินเข้าประเทศ (Foreign Remittance)**: รองรับทั้งหน้าจอ การประเมินกฎหมาย ป.161/ป.162 และการคำนวณเงินได้
    * **สุขภาพการเงิน (Financial Health)**: แปลเกณฑ์ประเมินทั้ง 8 มิติ, การ์ดแนะนำ, Breakdown, แผ่นลากดูรายละเอียด (Metric Detail Sheet), และหน้าต่างตั้งค่าเกณฑ์ (Health Settings Dialog)
    * **หนี้สินและประกันภัย (Debts & Insurance)**: แปลรายการหนี้สิน, กรมธรรม์, ฟอร์มเพิ่ม/แก้ไขหนี้สิน, และฟอร์มเพิ่ม/แก้ไขกรมธรรม์
    * **บันทึกรายการด่วน (Quick Add)**: แปลชิปหมวดหมู่, ตัวเลือกเพิ่มเติม (บันทึกช่วยจำ, ผูกโครงการ, รายการประจำ), การ์ดโอนเงินข้ามสกุลเงิน, ส่วนแจ้งเตือนนำเงินเข้าประเทศ และข้อความบันทึกสำเร็จ
    * **บันทึกซื้อ/ขายสินทรัพย์ (Buy/Sell Trade Dialog)**: แปลกล่องสลับซื้อ/ขาย, ช่องกรอกจำนวน/ราคา/เรต FX/ค่าธรรมเนียม, การคำนวณยอดเงินสุทธิ, และกล่องเตือนทำรายการข้ามปีภาษี
  - **การรับประกันคุณภาพ (Quality Assurance)**:
    * `flutter analyze`: **0 errors, 0 warnings, 0 issues**
    * `flutter test`: **116/116 ผ่านฉลุย 100%**
    * คอมไพล์ APK รุ่นล่าสุด: `build\app\outputs\flutter-apk\app-release.apk` และคัดลอกมาไว้ที่ `c:\Projects\myfinance\app-release.apk` (40.2 MB)

---

### Phase 3.2: การปรับปรุง UI, การแปลภาษา และระบบคลาวด์ Google Drive (UI Polish, Localization & Cloud Streamlining)
- [x] **Google Drive Sync UI Streamlining**:
  - ปรับการแสดงผลชื่อโฟลเดอร์ Google Drive ให้สะอาดตา ไม่แสดงเส้นทางภายในเครื่อง (`/data/user/0/...`) โดยแสดงเป็น `Google Drive: /MyFinance_Backup` บนมือถือ หรือตำแหน่ง Drive บน Desktop
  - ลดทอนการ์ดที่ไม่จำเป็น ทำให้หน้าจอกระชับ คงไว้เฉพาะปุ่มหลัก: บัญชี Google, การตั้งค่าโฟลเดอร์, สวิตช์ Auto-Sync, สวิตช์ Sync over Wi-Fi only และปุ่ม Backup/Restore
  - ปรับระยะขอบและ padding ของปุ่ม "เข้าสู่ระบบ" เพื่อไม่ให้อักษรและสระภาษาไทยถูกตัดขอบ
  - ยุบส่วนประวัติ Safety Backups ให้เป็น ExpansionTile เพื่อไม่ให้เกะกะสายตา
- [x] **Trash Bin Localization (หน้าถังขยะรองรับสองภาษา 100%)**:
  - แปลข้อความทั้งหมดในหน้าถังขยะ (`trash_bin_screen.dart`) ทั้งชื่อหน้าจอ, แท็บบัญชี/สินทรัพย์, สถานะว่าง, จำนวนวันที่เหลือ, และกล่องยืนยันการกู้คืน/ลบถาวร
- [x] **Tax Planning Text Overflow Fix (แก้ไขตัวอักษรล้นกรอบ)**:
  - แก้ไข `_buildRemittanceStat`, การ์ดเปรียบเทียบกลยุทธ์เงินปันผล และแถบเลือกปีภาษี ให้ใช้ `Expanded` และกำหนดการตัดบรรทัดป้องกันข้อความล้นขอบจอ
- [x] **VAULT Mode Monthly Report (เพิ่มทางเข้ารายงานรายเดือน)**:
  - เพิ่มไอคอนรายงาน `Icons.assessment_outlined` บน AppBar ด้านบนของหน้าหลักในโหมด VAULT
  - เพิ่มแถบกดดูรายงานรายเดือน `ดูรายงานสรุปรายเดือน ›` ในการ์ด FINANCIAL POSITION สไตล์ Quiet Luxury
- [x] **Lumi Budget Mascot Layout Fix (แก้รูปทับซ้อนตัวอักษร)**:
  - จัดโครงสร้าง `budget_hero_card.dart` ใหม่เป็น `Row` ควบคู่กับ `Expanded` เพื่อแยกพื้นที่ข้อความตัวเลขงบประมาณกับรูปภาพน้อง Lumi อย่างชัดเจน หมดปัญหาการทับซ้อนกัน 100%
  - เพิ่ม `FittedBox` ป้องกันตัวเลขงบประมาณล้นในทุกขนาดหน้าจอ
- [x] **การรับประกันคุณภาพ (Quality Assurance)**:
  - `flutter analyze`: **0 errors, 0 warnings, 0 issues**
  - `flutter test`: **116/116 ผ่านฉลุย 100%**
  - คอมไพล์ APK รุ่นล่าสุด: `build\app\outputs\flutter-apk\app-release.apk` และคัดลอกมาไว้ที่ `c:\Projects\myfinance\app-release.apk` (40.2 MB)

---

### Phase 3.3: ระบบนำเข้าข้อมูล Notion เต็มรูปแบบ (Notion Data Import: Expense, Income & US Stocks)
- [x] **New Seed Categories**:
  - เพิ่ม 2 หมวดหมู่รายจ่ายเริ่มต้นใหม่: "ของขวัญ / ของฝาก" (`Gifts`) และ "ยูซุ" (`Yuzu` - แมว)
- [x] **Notion Category Mapper (`NotionCategoryMapper`)**:
  - แปลงหมวดหมู่จาก Notion มาเป็นหมวดหมู่มาตรฐานของแอปอัตโนมัติ:
    * `Eating` -> "อาหารและเครื่องดื่ม" (Food & Dining)
    * `Transportation` -> "การเดินทาง" (Transportation)
    * `Health & Fitness` -> "สุขภาพและรักษาพยาบาล" (Healthcare)
    * `Home` -> "ที่อยู่อาศัย" (Housing)
    * `Entertainment` -> "บันเทิงและการพักผ่อน" (Entertainment)
    * `Lover` -> "ของขวัญ / ของฝาก" (Gifts)
    * `Cat` -> "ยูซุ" (Yuzu)
    * `Salary` -> "เงินเดือน" (Salary)
    * `Top up` -> "รายรับอื่นๆ" (Other Income - non-taxable)
    * `On duty` -> "รับจ้าง / ค่าอยู่เวร" (Freelance / Shift)
- [x] **Notion Invest-Stocks Parser (`NotionInvestParser`)**:
  - อ่านและวิเคราะห์ไฟล์ `Invest-Stocks *.csv` ของ Notion:
    * แยก Ticker สัญลักษณ์หุ้น (เช่น O, JEPQ, NVDA, MSFT) โดยตัดลิงก์ URL อัตโนมัติ
    * คำนวณวันที่ซื้อ, จำนวนหน่วย (ความแม่นยำ Decimal), ต้นทุน USD, ต้นทุน THB และอัตราแลกเปลี่ยน FX Rate
    * แยกแยะวิธีการชำระเงินจากคอลัมน์ Text (`THB`, `USD`, `FCD`, `ปันผล`)
- [x] **Investment Import Executor (`NotionInvestImportExecutor`)**:
  - ตรวจสอบและสร้าง Asset ให้อัตโนมัติหากยังไม่มีในระบบ (ประเภท `foreign_stock`, สกุลเงิน `USD`)
  - บันทึกการซื้อหุ้นลงสมุดบัญชีแยกประเภท (`transactions`) และตารางล็อตการลงทุน (`investment_lots`) พร้อม Audit Log แบบ Atomic Transaction ผ่าน `InvestmentsDao.recordBuyTrade`
  - ตรวจจับและข้ามรายการซ้ำอัตโนมัติ (Duplicate Detection)
- [x] **Import Wizard UI & Preview Dialog**:
  - เพิ่มแท็บตัวเลือก "Notion ซื้อหุ้น US" ในหน้า Import Wizard
  - สร้างหน้าจอตรวจสอบ `NotionInvestPreviewDialog` ให้ผู้ใช้เลือกติ๊กรายการที่ต้องการนำเข้า พร้อมแสดงรายละเอียด Ticker, จำนวนหุ้น, ต้นทุน USD, ต้นทุน THB
- [x] **การรับประกันคุณภาพ (Quality Assurance)**:
  - `flutter analyze`: **0 errors, 0 warnings, 0 issues**
  - `flutter test`: **128/128 ผ่านฉลุย 100%**

---

### Phase 4.3: ระบบนำเข้า Notion Income & ระบบติดตามรายได้ค้างรับ/เงินตกเบิกแพทย์ (Medical Accrued Income & Arrears Tracker)
- [x] **Schema Migration v7 -> v8**:
  - เพิ่มคอลัมน์ในตาราง `transactions`:
    * `work_period` (TEXT nullable): บันทึกรอบเดือนของการทำงาน (เช่น `'2025-12'`, `'2026-07'`)
    * `expected_amount_satang` (INT nullable): ยอดเงินที่คาดว่าจะได้รับ (จากคอลัมน์ `Budget`)
    * `is_cleared` (BOOL default true): สถานะเงินเข้าบัญชีแล้ว (`true`) หรือเป็นรายได้ค้างรับ/เงินตกเบิก (`false`)
- [x] **Ledger Invariant Isolation**:
  - อัปเดต `AccountsDao.getAccountBalanceSatang()` และการคำนวณเงินสดในหน้าต่างต่าง ๆ ให้ **ไม่นำ** รายได้ที่ `is_cleared == false` มารวมในยอดเงินสดคงเหลือของบัญชีธนาคาร (ป้องกันยอดเงินในแอปไม่ตรงกับ Mobile Banking ของจริง)
- [x] **Notion Income CSV Parser**:
  - ตรวจจับคอลัมน์ `Date`, `Income`, `Category`, `Budget`, `Amount`, `Property`, `Monthly Overview`, `Type` อัตโนมัติ
  - แปลง `Monthly Overview` เช่น `"December 25 (url)"` -> `'2025-12'`, `"July 26"` -> `'2026-07'`
  - กำหนด `is_cleared = false` เมื่อ `Property == 'No'`
  - จัดหมวดภาษีเงินได้แพทย์ไทยอัตโนมัติ: เงินเดือน, พ.ต.ส., เงินประจำตำแหน่ง = 40(1); ค่าเวรเหมา, เงินรายชั่วโมง, DF, เงินหมื่นไม่ทำเวชฯ = 40(2); Top up = ยกเว้นภาษี
- [x] **Accrued Income & Arrears Screen (`AccruedIncomeScreen`)**:
  - แสดงการ์ดยอดรวมเงินค้างรับทั้งหมด, จำนวนรายการ, และจำนวนรอบเดือนที่ค้าง
  - จัดกลุ่มรายการตามรอบเดือนที่ทำงาน (`workPeriod`) เรียงจากเดือนล่าสุด
  - ปุ่มบันทึกรับเงินเข้าบัญชีจริง (**Mark Received**): ให้ผู้ใช้เลือกบัญชีปลายทาง (เช่น KTB, SCB) ระบุวันที่เงินเข้าจริง และปรับยอดเงินที่ได้รับจริง (หากมีการหักภาษี) พร้อมอัปเดตเป็น `is_cleared = true` ยอดเงินสดจะเข้าบัญชีทันที และบันทึก Audit Log
  - ปุ่มรับเงินทั้งรอบเดือน (**Receive All in Period**) ช่วยให้กดเคลียร์เงินเข้าทั้งงวดได้ในคลิกเดียว
  - ปุ่ม "+ บันทึกค้างรับใหม่" สำหรับลงรายการค่าเวรหรือเงินพิเศษที่ทำไปแล้วแต่ยังรอเงินออก
- [x] **การเชื่อมต่อ Navigation & UI Enhancements**:
  - เพิ่มไอคอนทางลัดติดตามเงินตกเบิก (`Icons.pending_actions_outlined`) บน AppBar ของหน้า Money และหน้าประวัติรายการ
  - หน้าประวัติรายการแสดงป้ายกำกับสีส้ม `[ค้างรับ (YYYY-MM)]` สำหรับรายการที่ยังไม่ได้รับเงิน
  - ปรับปรุง `ImportPreviewDialog` แสดงแถบสรุปและสถานะแถวค้างรับ/ตกเบิกอย่างชัดเจนก่อนกดยืนยันนำเข้า
- [x] **การปรับปรุงประสบการณ์ผู้ใช้งานและระบบติดตามรายได้ตกเบิก (UX & Accrued Income Enhancements)**:
  1. **ล็อคหน้า Web App บนมือถือให้เป็นแนวตั้งตลอด (Orientation Lock)**: ตั้งค่า manifest และ JavaScript Screen Orientation API บังคับแนวตั้ง (portrait) บนมือถือ
  2. **ปรับปรุงการ์ด Accrued Income**: ปุ่ม "รับเงินแล้ว (Mark Received)" เปลี่ยนเป็นชิปขนาดกะทัดรัด พร้อมซ่อน badge ประเภทภาษีออกจากการ์ดเพื่อความสบายตา
  3. **ตัวเลือก Accrued Income ในหน้าบันทึกด่วน (Quick Add)**: เมื่อเลือกรายรับ ผู้ใช้สามารถเปิดสวิตช์ "รายได้ค้างรับ / เงินตกเบิก" พร้อมเลือกรอบเดือนทำงาน (`workPeriod`) เพื่อบันทึกเป็นรายการรอรับเงิน
  4. **ตั้งรายการประจำ (Recurring) ในหน้า Add Accrued Income**: สามารถกำหนดวันเงินออกของทุกเดือน เพื่อสร้างรายการรอรับเงินอัตโนมัติ
  5. **ประเมินประเภทภาษีเงินได้อัตโนมัติ (Tax Inference with Manual Override)**: ระบบวิเคราะห์ชื่อรายการ/หมวดหมู่เพื่อเลือกประเภทภาษี 40(1), 40(2), 40(6), 40(8) หรือยกเว้นภาษีทันที พร้อมให้ผู้ใช้ปรับเปลี่ยนได้เอง
  6. **เปลี่ยนหมวดหมู่เป็น Dropdown & ดึงช่องบันทึกย่อขึ้นหน้าหลัก**: แก้ปัญหาเลือกหมวดหมู่ยากในหน้า Quick Add โดยเปลี่ยนเป็น Dropdown พร้อมปุ่มเพิ่มหมวดหมู่ใหม่ และดึงช่อง Note/ชื่อรายการ มาไว้บนฟอร์มหลักให้พิมพ์ง่าย
  7. **สลับไปหน้าประวัติรายการทันทีหลังบันทึก**: เมื่อกดบันทึกรายการ ระบบจะปิดฟอร์มและพาผู้ใช้ไปยังหน้ารายการธุรกรรม (Transactions) ทันที
  8. **ลบรายการแบบ Optimistic in-place**: ลบรายการธุรกรรมออกจากหน้าจอทันทีโดยไม่โหลดหน้าใหม่หรือรีเซ็ตตำแหน่ง Scroll Bar ทำให้ไม่เสียจังหวะในการเลื่อนดู
- [x] **การรับประกันคุณภาพ (Quality Assurance)**:
  - `flutter test`: **131/131 ผ่าน 100%** (เพิ่มชุดทดสอบ `quick_add_accrued_income_test.dart`)
  - `flutter analyze`: **0 errors, 0 warnings, 0 issues**

---

### Phase 4.4: ระบบ Cloud Master Vault (Full Snapshot Sync) & Clean Slate Master Restoration
- [x] **Core Snapshot Architecture (`CloudVaultSnapshotHelper`)**:
  - ใช้ `dumpDriftDatabaseToSqliteBytes()` ดึงข้อมูลสดครบถ้วนทั้ง 25 ตารางจาก Drift Database (ผ่าน WAL checkpointing) ทั้งบน Native (Windows/Android) และ Web
  - บีบอัด SQLite Binary ด้วย pure Dart GZip (`archive` package) และแปลงเป็น Base64
  - ระบบถอดรหัสและกู้คืน Clean Slate: ล้างและเขียนทับทุกตารางอย่างแม่นยำ รวมถึงตารางที่ถูกลบจนว่างเปล่าใน Master (เช่น GPF, หนี้บัตรที่จ่ายแล้ว)
- [x] **Cloud Master Integration (`SyncService`)**:
  - `_pushMasterSnapshot`: อัปโหลด Master Snapshot ขึ้นสู่ Supabase `cloud_vault_backup` (พร้อมระบบ Fallback ไปยัง `projects` อัตโนมัติแบบ seamless หากตารางยังไม่ได้ถูกสร้างบน Supabase)
  - `pullMasterSnapshotFromCloud`: ดึงข้อมูล Master Snapshot ล่าสุด แตกไฟล์ และกู้คืนเข้า SQLite พร้อม Live Table Injection ในเครื่องทันที
  - `getMasterSnapshotInfo`: ตรวจสอบและดึงข้อมูลสรุปของ Master Snapshot บนคลาวด์
  - แยก `__cloud_vault_master_backup__` ออกจากการซิงค์ Projects ปกติ
  - คงฟังก์ชัน `quickStartupSync()` ทำหน้าที่ซิงค์เฉพาะ Delta รายการเปลี่ยนแปลงตอนเปิดแอปตามเดิม
- [x] **UI & User Experience (`BackupRestoreScreen` & `SyncStatusWidget`)**:
  - เพิ่มปุ่มเด่นชัด:
    * **"เขียนทับข้อมูลบนคลาวด์ด้วยเครื่องนี้ 100% (Master Push)"** (สีส้ม) สำหรับส่งข้อมูลจากเครื่องหลัก
    * **"ดึงข้อมูล Master จากคลาวด์แทนที่เครื่องนี้ 100% (Master Pull)"** (สีน้ำเงิน) สำหรับเครื่องปลายทาง (มือถือ/แท็บเล็ต) ให้ตรงกับเครื่องหลักเป๊ะเหมือนไฟล์ `.db`
    * **"ซิงค์ข้อมูลเดี๋ยวนี้ (Sync All Data)"** (สีเขียว) สำหรับการซิงค์ปกติ
  - กล่องข้อความแจ้งเตือนและการยืนยันพร้อมระบบ Safety Backup กันเหนียวอัตโนมัติก่อนเขียนทับ
- [x] **การรับประกันคุณภาพ (Quality Assurance)**:
  - Unit tests: เพิ่ม `test/core/cloud_vault_snapshot_test.dart`
  - `flutter test`: **184/184 ผ่านฉลุย 100%**
  - `flutter analyze`: **0 errors, 0 warnings**

---

## 2. สิ่งที่ต้องทำในอนาคต (Future Enhancements)

- [ ] การสร้าง Release Installer สำหรับ Windows (.msi / .exe)
- [ ] วิดเจ็ตเพิ่มเติมตามความต้องการใช้งานเพิ่มเติมในอนาคต

---

## 3. ปัญหาที่พบและวิธีแก้ไข (Known Issues & Lessons Learned)

- **การซ้อนทับกันของ Floating Action Button (FAB) ระหว่าง MainShell และหน้าจอย่อย**: เมื่อหน้าจอหลักมี FAB รวมและหน้ารายละเอียดมี FAB เฉพาะทาง (เช่น หน้าบัญชี หรือ หน้าลงทุนที่มีปุ่ม "ซื้อ/ขาย") ได้แก้ไขโดยเชื่อมต่อสถานะ Sub-Tab ผ่าน callback `onTabChanged` ทำให้ปุ่มลอย (+ เพิ่ม) แสดงเฉพาะในหน้า Home และหน้าประวัติรายการธุรกรรม (Money-Transactions) เท่านั้น
- **การทำ Tabular Figures ใน Flutter Text**: ตัวเลขทางการเงินปกติจะมีความกว้างของตัวเลขแต่ละตัวไม่เท่ากัน ทำให้ตัวเลขในตารางหรือสรุปยอดแกว่ง แก้ไขโดยการกำหนด `fontFeatures: [FontFeature.tabularFigures()]` ใน `VaultTheme.tabular()` สไตล์ Quiet Luxury
- **ความปลอดภัยในการปิดระบบล็อกแอป**: ป้องกันการกดปิดสวิตช์ PIN โดยไม่ยืนยันตัวตน โดยบังคับให้ยืนยันตัวตนด้วย PIN เดิมหรือสแกนลายนิ้วมือก่อนเสมอ
- **Foreign Key Constraint ในการนำเข้า Batch**: ในการนำเข้าธุรกรรมที่ผูกกับ `import_batches(id)` ต้องบันทึกแถว Batch ลงในตาราง `import_batches` ก่อนเริ่มลูปเพิ่มธุรกรรม เพื่อไม่ให้ SQLite ละเมิดข้อกำหนด Foreign Key
- **ตัวแบ่งบรรทัดและเครื่องหมายจุลภาคในไฟล์ CSV**: ไฟล์ CSV ที่มีตัวเลขใส่เครื่องหมายจุลภาคคั่นหลักพัน เช่น `"THB 1,200.00"` ต้องครอบด้วยเครื่องหมายคำพูด (Quotes) และต้องปรับการแปลงตัวแบ่งบรรทัดทั้ง `\r\n` และ `\n` ให้เป็นมาตรฐานเดียวกัน เพื่อให้อ่านข้อมูลได้ถูกต้องบนทุกระบบปฏิบัติการ
- **วงเล็บในคำสั่ง Windows Batch (.bat)**: บรรทัดคำสั่ง `cmd.exe` แปลความหมายวงเล็บปิด `)` ภายในบล็อก `if (...) else (...)` ว่าเป็นการปิดบล็อกคำสั่งก่อนเวลาอันควร ทำให้เกิด error สคริปต์หยุดทำงาน จึงเปลี่ยนมาเรียกใช้ PowerShell Script (`.ps1`) หรือใช้โครงสร้าง `goto :LABEL` แทน
- **Android NDK & compileSdkVersion 36 Mismatch**: การคอมไพล์แอปพลิเคชัน Android ที่มีแพ็กเกจ C++ / JNI (เช่น SQLite / Biometrics) ต้องการ NDK และการบังคับ `compileSdkVersion 36` ให้กับปลั๊กอินทั้งหมดใน `afterEvaluate` ของ `build.gradle.kts` เพื่อไม่ให้เกิด AAR metadata version check failure
- **Android App เด้งปิดทันทีตอนเปิด (Crash on Launch)**:
  1. ปลั๊กอิน `local_auth` (ระบบความปลอดภัยสแกนลายนิ้วมือ) บน Android กำหนดให้ Activity หลักต้องสืบทอดจาก `FlutterFragmentActivity` และใช้ธีม `Theme.AppCompat`
  2. การตั้งค่า `?android:colorBackground` ใน `drawable/launch_background.xml` และ `styles.xml` ทำให้ระบบ Android เกิด `Resources$NotFoundException / InflateException` ก่อนที่ Flutter Engine จะเริ่มต้นทำงาน แก้ไขโดยเปลี่ยนเป็น `@android:color/white` และ `@android:color/black` โดยตรง
  3. ไลบรารี SQLite native C++ (`sqlite3_flutter_libs`) ต้องการการแตกไฟล์ `.so` แบบ uncompressed (`packaging { jniLibs { useLegacyPackaging = true } }`) และการเรียกใช้ `applyWorkaroundToOpenSqlite3OnOldAndroidVersions()` ใน `main.dart` เพื่อป้องกัน `UnsatisfiedLinkError` บนเครื่อง Android หลากหลายรุ่น
  4. เพิ่มการดักจับข้อผิดพลาดทั่วทั้งระบบด้วย `PlatformDispatcher.instance.onError` และ `try/catch` ในจุดอ่าน Secure Storage และ Recurring Rules เมื่อเปิดแอป เพื่อป้องกันการแครชแบบฉับพลัน
  5. ระบบย่อโค้ด R8 บดบังคลาส WorkDatabase (`androidx.work.impl.WorkDatabase`): ในโหมด Release ระบบ Gradle ทำการย่อโค้ดและเปลี่ยนชื่อคลาสของ Room/WorkManager ทำให้ `InitializationProvider` ตอนเริ่มแอปพลิเคชันพังทันทีก่อนหน้าต่างแรกจะแสดง แก้ไขโดยสร้างไฟล์ `proguard-rules.pro` เพื่อรักษากลุ่มคลาสของ WorkManager และ Room พร้อมปิด `isMinifyEnabled = false` ทดสอบบนเครื่องจริง Oppo Find X9 (ColorOS 16 / Android 16) เปิดใช้งานได้สำเร็จสมบูรณ์ 100%
- **GitHub Actions Build Web ล้มเหลวเนื่องจาก `dart:ffi` ใน `sqlite3_flutter_libs`**: บนเว็บไม่มีโมดูล `dart:ffi` การเรียกใช้แพ็กเกจ SQLite โดยตรงใน `main.dart` ทำให้การคอมไพล์ Web บน GitHub Actions พัง แก้ไขโดยสร้างชั้นสวิตช์แบบข้ามแพลตฟอร์ม (Conditional Export) ทำให้ระบบเว็บคอมไพล์ผ่านฉลุย 100% ส่วน Android/Windows ยังคงทำงานร่วมกับ SQLite ได้เต็มประสิทธิภาพ
- **Google Drive Sync บน WebApp ค้างหน้า Loading และกู้คืน (Restore) ไม่สำเร็จ**:
  1. *ปัญหาหน้าโหลดค้าง*: ใน WebApp เมื่อเปิดหน้า Sync ตัวแอปเรียก `getStatus()` ซึ่งพยายามเรียก `requestScopes` ใน `initState` โดยไม่ได้เกิดจากการคลิกของผู้ใช้ เบราว์เซอร์จึงบล็อกหน้าต่าง OAuth Popup ทำให้การทำงานค้าง แก้ไขโดยตั้งค่า `requestScopesIfNeeded: false` ในการตรวจสอบสถานะ และเพิ่ม Timeout 5 วินาที พร้อมขอสิทธิ์เฉพาะเมื่อผู้ใช้กดปุ่มสำรอง/กู้คืนข้อมูลโดยตรง
  2. *ปัญหากู้คืนข้อมูลไม่สำเร็จ*: เดิมฟังก์ชันกู้คืนเรียกใช้ `dart:io` `File` และโฟลเดอร์เครื่องซึ่งไม่มีอยู่บน Web (`UnsupportedError`) แก้ไขโดยเพิ่ม `web_db_helper_web.dart` เพื่อเขียนข้อมูลฐานข้อมูลสำรองลงสู่ IndexedDB (`IndexedDbFileSystem`) และ Origin Private File System (OPFS) ของเบราว์เซอร์โดยตรง พร้อมสั่งรีเฟรชหน้าเว็บอัตโนมัติเพื่อให้แอปโหลดฐานข้อมูลกู้คืนขึ้นมาใช้งานได้ทันที
- **การแสดงผลหน้าบันทึกซื้อขายสินทรัพย์ (`BuySellTradeScreen`) จอดำว่างเปล่าบน Web และ Desktop**: การใช้ `Center` ครอบปุ่มกดยืนยันใน `bottomNavigationBar` ของ `Scaffold` โดยไม่มีการจำกัดขอบเขตความสูง ทำให้ `Center` ขยายตัวจนกินพื้นที่แนวตั้งเต็มหน้าจอ ส่งผลให้ส่วน `body` (ฟอร์มกรอกสินทรัพย์, ราคา, บัญชี) ถูกบีบอัดจนความสูงกลายเป็น 0 แก้ไขโดยกำหนด `heightFactor: 1.0` และห่อหุ้มด้วย `Container` ที่มีขอบเขตความสูงแน่นอน พร้อมปรับ `body` ให้จัดชิดด้านบน (`Alignment.topCenter`) และเพิ่ม Error Boundary ดักจับข้อผิดพลาด ทำให้ฟอร์มแสดงผลเต็มหน้าจอและเลื่อนดูได้ลื่นไหล 100%




