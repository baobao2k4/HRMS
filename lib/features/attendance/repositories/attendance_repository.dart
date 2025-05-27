import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../shared/models/attendance_model.dart';
import '../../../shared/services/base_repository.dart';

class AttendanceRepository extends BaseRepository<AttendanceModel> {
  AttendanceRepository() : super('attendance');

  @override
  AttendanceModel fromJson(Map<String, dynamic> json) =>
      AttendanceModel.fromJson(json);

  Future<List<AttendanceModel>> getAttendanceByEmployee(
    String employeeId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var filters = [
      ['employeeId', '==', employeeId]
    ];

    if (startDate != null) {
      filters.add(['checkIn', '>=', startDate]);
    }

    if (endDate != null) {
      filters.add(['checkIn', '<=', endDate]);
    }

    return query(
      filters: filters,
      orderBy: 'checkIn',
      descending: true,
    );
  }

  Future<AttendanceModel?> getTodayAttendance(String employeeId) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final result = await query(
      filters: [
        ['employeeId', '==', employeeId],
        ['checkIn', '>=', startOfDay],
        ['checkIn', '<', endOfDay],
      ],
      limit: 1,
    );

    return result.isNotEmpty ? result.first : null;
  }

  Future<void> checkIn(
    AttendanceModel attendance,
  ) async {
    try {
      await add(attendance);
    } catch (e) {
      throw Exception('Failed to check in: $e');
    }
  }

  Future<void> checkOut(
    String attendanceId,
    DateTime checkOut,
    GeoPoint? checkOutLocation,
  ) async {
    try {
      final workingHours =
          checkOut.difference(await getCheckInTime(attendanceId)).inMinutes / 60;

      await collection.doc(attendanceId).update({
        'checkOut': Timestamp.fromDate(checkOut),
        'checkOutLocation': checkOutLocation,
        'workingHours': workingHours,
        'isOvertime': workingHours > 8,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to check out: $e');
    }
  }

  Future<DateTime> getCheckInTime(String attendanceId) async {
    try {
      final doc = await collection.doc(attendanceId).get();
      if (!doc.exists) {
        throw Exception('Attendance record not found');
      }
      return (doc.data()!['checkIn'] as Timestamp).toDate();
    } catch (e) {
      throw Exception('Failed to get check-in time: $e');
    }
  }

  Future<List<AttendanceModel>> getAttendanceByDateRange(
    DateTime startDate,
    DateTime endDate, {
    String? employeeId,
  }) async {
    var filters = [
      ['checkIn', '>=', startDate],
      ['checkIn', '<=', endDate],
    ];

    if (employeeId != null) {
      filters.add(['employeeId', '==', employeeId]);
    }

    return query(
      filters: filters,
      orderBy: 'checkIn',
    );
  }

  Future<Map<String, int>> getAttendanceStats(
    String employeeId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final attendance = await getAttendanceByDateRange(
        startDate,
        endDate,
        employeeId: employeeId,
      );

      return {
        'present': attendance
            .where((a) => a.status == 'present')
            .length,
        'absent': attendance
            .where((a) => a.status == 'absent')
            .length,
        'late': attendance
            .where((a) => a.status == 'late')
            .length,
        'halfDay': attendance
            .where((a) => a.status == 'half-day')
            .length,
      };
    } catch (e) {
      throw Exception('Failed to get attendance stats: $e');
    }
  }

  Stream<List<AttendanceModel>> streamTodayAttendance() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return collection
        .where('checkIn', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('checkIn', isLessThan: Timestamp.fromDate(endOfDay))
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => fromJson(doc.data())).toList());
  }

  Stream<List<AttendanceModel>> streamEmployeeAttendance(String employeeId) {
    return collection
        .where('employeeId', isEqualTo: employeeId)
        .orderBy('checkIn', descending: true)
        .limit(30)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => fromJson(doc.data())).toList());
  }
} 