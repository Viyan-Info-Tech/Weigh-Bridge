import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/weighments_table.dart';

part 'bill_dao.g.dart';

@DriftAccessor(tables: [Weighments])
class BillDao extends DatabaseAccessor<AppDatabase> with _$BillDaoMixin {
  BillDao(super.db);

  Future<int> insertWeighment(WeighmentsCompanion entry) async {
    return into(weighments).insert(entry);
  }

  /// Reads the bill number the next saved weighment would receive.
  ///
  /// This is a *preview* only. It does not reserve the number, so two callers
  /// asking at the same time will get the same answer. Use
  /// [insertWeighmentWithNextBillNumber] to actually consume a number.
  Future<String> peekNextBillNumber({
    required String prefix,
    required int digits,
    int? startingNumber,
  }) async {
    final start = startingNumber ?? 1;
    if (!RegExp(r'^[A-Z]{1,5}$').hasMatch(prefix) ||
        digits < 1 ||
        digits > 9 ||
        start < 1 ||
        start.toString().length > digits) {
      throw ArgumentError('Invalid bill number settings.');
    }

    final maximumNumber = int.parse(List.filled(digits, '9').join());
    final used = await _highestAllocatedNumber(prefix);
    final next = (used == null || used < start) ? start : used + 1;
    if (next > maximumNumber) {
      throw StateError(
        'The $digits-digit bill number sequence for $prefix is exhausted.',
      );
    }
    return _format(prefix, digits, next);
  }

  /// Allocates the next bill number and inserts [build] with it, atomically.
  ///
  /// The number is read and consumed inside one transaction, so two concurrent
  /// saves can never be handed the same number: the second one blocks until the
  /// first commits and then sees the updated maximum.
  ///
  /// [build] receives the allocated number and returns the row to insert. The
  /// returned record carries the number that was actually stored, which the
  /// caller must use for display and printing rather than any previously
  /// previewed value.
  Future<({int id, String billNumber})> insertWeighmentWithNextBillNumber(
    WeighmentsCompanion Function(String billNumber) build, {
    required String prefix,
    required int digits,
    int? startingNumber,
  }) {
    // Fail fast on bad prefix/digits or an exhausted sequence, before opening
    // a transaction that could never commit.
    return peekNextBillNumber(
      prefix: prefix,
      digits: digits,
      startingNumber: startingNumber,
    ).then((_) {
      return transaction(() async {
        // Bounded so a pathological retry loop cannot spin forever; each pass
        // either inserts or proves the collision was not ours to fix.
        for (var attempt = 0; attempt < 10; attempt++) {
          final candidate = await peekNextBillNumber(
            prefix: prefix,
            digits: digits,
            startingNumber: startingNumber,
          );
          try {
            final id = await into(weighments).insert(build(candidate));
            return (id: id, billNumber: candidate);
          } catch (e) {
            // The UNIQUE index is the last line of defence. If the number was
            // taken by another writer, the next pass recomputes from the
            // updated maximum. Anything else (a foreign key, a disk error) is
            // not ours to work around, so it surfaces unchanged.
            if (!_isUniqueViolation(e)) rethrow;
            final current = await peekNextBillNumber(
              prefix: prefix,
              digits: digits,
              startingNumber: startingNumber,
            );
            if (current == candidate) rethrow;
          }
        }
        throw StateError('Could not allocate a unique bill number.');
      });
    });
  }

  /// Highest numeric suffix already stored for [prefix], or null when the
  /// prefix has never been used.
  Future<int?> _highestAllocatedNumber(String prefix) async {
    final row = await customSelect(
      'SELECT MAX(CAST(SUBSTR(bill_number, ?) AS INTEGER)) AS max_num '
      'FROM weighments WHERE bill_number LIKE ? ESCAPE ?',
      variables: [
        Variable.withInt(prefix.length + 2),
        Variable.withString('${_escapeLike(prefix)}-%'),
        Variable.withString('\\'),
      ],
    ).getSingleOrNull();
    return row?.data['max_num'] as int?;
  }

  String _format(String prefix, int digits, int value) =>
      '$prefix-${value.toString().padLeft(digits, '0')}';

  /// Whether [error] is SQLite reporting a UNIQUE constraint failure.
  ///
  /// Drift does not surface a typed SQLite exception through its public API, so
  /// this matches on the message. Only used to decide whether a bill number
  /// collision is retryable, so a false negative just surfaces the original
  /// database error instead of hiding it.
  static bool _isUniqueViolation(Object error) {
    final message = error.toString();
    return message.contains('UNIQUE constraint failed') ||
        message.contains('2067');
  }

  static String _escapeLike(String value) => value
      .replaceAll(r'\', r'\\')
      .replaceAll('%', r'\%')
      .replaceAll('_', r'\_');

  Future<int> updateWeighment(int id, WeighmentsCompanion entry) async {
    return (update(weighments)..where((w) => w.id.equals(id))).write(entry);
  }

  Future<List<Weighment>> getRecentBills({DateTime? date, int? limit}) async {
    final day = date ?? DateTime.now();
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    final query = select(weighments)
      ..where(
        (w) =>
            w.createdAt.isBiggerOrEqualValue(start) &
            w.createdAt.isSmallerThanValue(end),
      )
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    if (limit != null) {
      query.limit(limit);
    }
    return query.get();
  }

  Future<List<Weighment>> getRecentBillsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    int? limit,
  }) async {
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
    final query = select(weighments)
      ..where(
        (w) =>
            w.createdAt.isBiggerOrEqualValue(start) &
            w.createdAt.isSmallerOrEqualValue(end),
      )
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    if (limit != null) {
      query.limit(limit);
    }
    return query.get();
  }

  Future<Weighment?> getWeighmentById(int id) async {
    final query = select(weighments)..where((w) => w.id.equals(id));
    return query.getSingleOrNull();
  }

  Future<Weighment?> getWeighmentByBillNumber(String billNumber) async {
    final query = select(weighments)
      ..where((w) => w.billNumber.equals(billNumber));
    return query.getSingleOrNull();
  }

  Future<String> generateNextBillNumber() async {
    return peekNextBillNumber(prefix: 'WB', digits: 5);
  }

  Future<List<Weighment>> searchBills({
    String? billNumber,
    String? vehicleNumber,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  }) async {
    final query = select(weighments);

    if (billNumber != null && billNumber.isNotEmpty) {
      query.where((w) => w.billNumber.like('%$billNumber%'));
    }

    if (startDate != null) {
      query.where((w) => w.createdAt.isBiggerOrEqualValue(startDate));
    }

    if (endDate != null) {
      query.where((w) => w.createdAt.isSmallerOrEqualValue(endDate));
    }

    query.orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    query.limit(limit);

    return query.get();
  }

  Future<int> deleteWeighment(int id) async {
    return (delete(weighments)..where((w) => w.id.equals(id))).go();
  }
}
