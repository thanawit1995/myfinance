import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../app_database.dart';
import '../tables/all_tables.dart';

part 'projects_dao.g.dart';

class ProjectStatus {
  final Project project;
  final int spentSatang;
  final int remainingSatang;
  final double percentUsed;
  final int daysLeft;
  final List<Transaction> transactions;

  const ProjectStatus({
    required this.project,
    required this.spentSatang,
    required this.remainingSatang,
    required this.percentUsed,
    required this.daysLeft,
    required this.transactions,
  });

  bool get isOverBudget => remainingSatang < 0;
}

@DriftAccessor(tables: [Projects, Transactions, AuditLogs])
class ProjectsDao extends DatabaseAccessor<AppDatabase> with _$ProjectsDaoMixin {
  ProjectsDao(super.db);

  final _uuid = const Uuid();

  Future<List<Project>> getActiveProjects() {
    return (select(projects)
          ..where((p) => p.deletedAt.isNull() & p.isActive.equals(true))
          ..orderBy([(p) => OrderingTerm.asc(p.startDate)]))
        .get();
  }

  Future<List<Project>> getAllProjects() {
    return (select(projects)
          ..where((p) => p.deletedAt.isNull())
          ..orderBy([(p) => OrderingTerm.desc(p.createdAt)]))
        .get();
  }

  Future<Project?> getProjectById(String id) {
    return (select(projects)..where((p) => p.id.equals(id) & p.deletedAt.isNull())).getSingleOrNull();
  }

  Future<void> createProject(ProjectsCompanion entry) async {
    final now = DateTime.now();
    final companion = entry.copyWith(
      createdAt: entry.createdAt.present ? entry.createdAt : Value(now),
      updatedAt: entry.updatedAt.present ? entry.updatedAt : Value(now),
    );
    await into(projects).insert(companion);

    await into(auditLogs).insert(
      AuditLogsCompanion.insert(
        id: _uuid.v4(),
        entityTable: 'projects',
        entityId: companion.id.value,
        action: 'CREATE_PROJECT',
        afterDataJson: Value('{"name": "${companion.name.value}"}'),
        changeTimestamp: now,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Future<void> updateProject(ProjectsCompanion entry) async {
    final now = DateTime.now();
    await (update(projects)..where((p) => p.id.equals(entry.id.value))).write(
      entry.copyWith(updatedAt: Value(now)),
    );

    await into(auditLogs).insert(
      AuditLogsCompanion.insert(
        id: _uuid.v4(),
        entityTable: 'projects',
        entityId: entry.id.value,
        action: 'UPDATE_PROJECT',
        afterDataJson: Value('{"name": "${entry.name.present ? entry.name.value : 'N/A'}"}'),
        changeTimestamp: now,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Future<void> deleteProject(String id) async {
    final now = DateTime.now();
    await (update(projects)..where((p) => p.id.equals(id))).write(
      ProjectsCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
        isActive: const Value(false),
      ),
    );

    await into(auditLogs).insert(
      AuditLogsCompanion.insert(
        id: _uuid.v4(),
        entityTable: 'projects',
        entityId: id,
        action: 'SOFT_DELETE_PROJECT',
        changeTimestamp: now,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Future<ProjectStatus?> getProjectStatus(String projectId) async {
    final project = await getProjectById(projectId);
    if (project == null) return null;

    final projectTag = 'project:$projectId';
    final txRows = await (select(transactions)
          ..where((t) =>
              t.deletedAt.isNull() &
              t.tag.like('%$projectTag%'))
          ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)]))
        .get();

    int spent = 0;
    for (final t in txRows) {
      if (t.transactionType == 'expense') {
        spent += (t.amountThbSatang + t.feeThbSatang);
      } else if (t.transactionType == 'income') {
        // In case of project refund or income
        spent -= t.amountThbSatang;
      }
    }

    final remaining = project.targetBudgetSatang - spent;
    final percent = project.targetBudgetSatang > 0
        ? (spent / project.targetBudgetSatang)
        : 0.0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final projectEnd = DateTime(project.endDate.year, project.endDate.month, project.endDate.day);
    final daysLeft = projectEnd.difference(today).inDays;

    return ProjectStatus(
      project: project,
      spentSatang: spent,
      remainingSatang: remaining,
      percentUsed: percent,
      daysLeft: daysLeft < 0 ? 0 : daysLeft,
      transactions: txRows,
    );
  }

  Future<List<ProjectStatus>> getAllActiveProjectStatuses() async {
    final active = await getActiveProjects();
    final list = <ProjectStatus>[];
    for (final p in active) {
      final status = await getProjectStatus(p.id);
      if (status != null) {
        list.add(status);
      }
    }
    return list;
  }
}
