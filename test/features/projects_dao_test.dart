import 'package:drift/drift.dart' hide isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:myfinance/core/database/app_database.dart';
import 'package:myfinance/core/database/connection/connection.dart';
import 'package:uuid/uuid.dart';

void main() {
  late AppDatabase db;
  const uuid = Uuid();

  setUp(() {
    db = AppDatabase.forTesting(inMemoryConnection());
  });

  tearDown(() async {
    await db.close();
  });

  test('ProjectsDao - CRUD and Project Budget Calculation with Tagged Transactions', () async {
    final dao = db.projectsDao;
    final txDao = db.transactionsDao;
    final accounts = await db.accountsDao.getActiveAccounts();
    final bankAccount = accounts.first;

    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, 1);
    final endDate = DateTime(now.year, now.month, 15);
    final projectId = uuid.v4();

    // 1. Create Project
    await dao.createProject(
      ProjectsCompanion.insert(
        id: projectId,
        name: 'ทริปเที่ยวญี่ปุ่น',
        targetBudgetSatang: 5000000, // 50,000 THB
        startDate: startDate,
        endDate: endDate,
        description: const Value('เที่ยวโตเกียวและฟูจิ'),
        createdAt: now,
        updatedAt: now,
      ),
    );

    // Verify created
    final active = await dao.getActiveProjects();
    expect(active.length, 1);
    expect(active.first.name, 'ทริปเที่ยวญี่ปุ่น');
    expect(active.first.targetBudgetSatang, 5000000);

    // Initial project status: spent = 0, remaining = 50,000 THB
    var status = await dao.getProjectStatus(projectId);
    expect(status, isNotNull);
    expect(status!.spentSatang, 0);
    expect(status.remainingSatang, 5000000);
    expect(status.percentUsed, 0.0);
    expect(status.transactions.isEmpty, true);

    // 2. Add Transactions tagged with project:projectId
    await txDao.insertTransaction(
      TransactionsCompanion.insert(
        id: uuid.v4(),
        transactionType: 'expense',
        amountOriginalSatang: 1500000, // 15,000 THB (ticket)
        currencyCode: 'THB',
        amountThbSatang: 1500000,
        sourceAccountId: Value(bankAccount.id),
        transactionDate: DateTime(now.year, now.month, 2),
        tag: Value('project:$projectId'),
        note: const Value('ตั๋วเครื่องบิน'),
        createdAt: now,
        updatedAt: now,
      ),
    );

    await txDao.insertTransaction(
      TransactionsCompanion.insert(
        id: uuid.v4(),
        transactionType: 'expense',
        amountOriginalSatang: 2000000, // 20,000 THB (hotel)
        currencyCode: 'THB',
        amountThbSatang: 2000000,
        sourceAccountId: Value(bankAccount.id),
        transactionDate: DateTime(now.year, now.month, 3),
        tag: Value('project:$projectId'),
        note: const Value('โรงแรมโตเกียว'),
        createdAt: now,
        updatedAt: now,
      ),
    );

    // Also add another expense NOT tagged with project to ensure isolation
    await txDao.insertTransaction(
      TransactionsCompanion.insert(
        id: uuid.v4(),
        transactionType: 'expense',
        amountOriginalSatang: 500000,
        currencyCode: 'THB',
        amountThbSatang: 500000,
        sourceAccountId: Value(bankAccount.id),
        transactionDate: DateTime(now.year, now.month, 4),
        tag: const Value('regular_food'),
        createdAt: now,
        updatedAt: now,
      ),
    );

    // Verify project status
    status = await dao.getProjectStatus(projectId);
    expect(status, isNotNull);
    expect(status!.spentSatang, 3500000); // 35,000 THB
    expect(status.remainingSatang, 1500000); // 15,000 THB remaining
    expect(status.percentUsed, closeTo(0.70, 0.001)); // 70%
    expect(status.isOverBudget, false);
    expect(status.transactions.length, 2);

    // 3. Update project budget
    await dao.updateProject(
      ProjectsCompanion(
        id: Value(projectId),
        targetBudgetSatang: const Value(3000000), // Reduce budget to 30,000 THB
      ),
    );

    status = await dao.getProjectStatus(projectId);
    expect(status!.spentSatang, 3500000);
    expect(status.remainingSatang, -500000); // Over budget by 5,000 THB
    expect(status.isOverBudget, true);

    // 4. Soft delete project
    await dao.deleteProject(projectId);
    final remainingActive = await dao.getActiveProjects();
    expect(remainingActive.isEmpty, true);
  });
}
