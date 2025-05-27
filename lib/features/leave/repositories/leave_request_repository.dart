import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../shared/models/leave_request_model.dart';
import '../../../shared/services/base_repository.dart';

class LeaveRequestRepository extends BaseRepository<LeaveRequestModel> {
  LeaveRequestRepository() : super('leave_requests');

  @override
  LeaveRequestModel fromJson(Map<String, dynamic> json) =>
      LeaveRequestModel.fromJson(json);

  Future<List<LeaveRequestModel>> getLeaveRequestsByEmployee(
    String employeeId,
  ) async {
    return query(
      filters: [
        ['employeeId', '==', employeeId]
      ],
      orderBy: 'createdAt',
      descending: true,
    );
  }

  Future<List<LeaveRequestModel>> getPendingLeaveRequests() async {
    return query(
      filters: [
        ['status', '==', LeaveStatus.pending.toString().split('.').last]
      ],
      orderBy: 'createdAt',
    );
  }

  Future<List<LeaveRequestModel>> getLeaveRequestsByStatus(
    LeaveStatus status,
  ) async {
    return query(
      filters: [
        ['status', '==', status.toString().split('.').last]
      ],
      orderBy: 'createdAt',
      descending: true,
    );
  }

  Future<List<LeaveRequestModel>> getLeaveRequestsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return query(
      filters: [
        ['startDate', '>=', startDate],
        ['endDate', '<=', endDate],
      ],
      orderBy: 'startDate',
    );
  }

  Future<void> approveLeaveRequest(
    String leaveId,
    String approverId,
    String? comment,
  ) async {
    try {
      await collection.doc(leaveId).update({
        'status': LeaveStatus.approved.toString().split('.').last,
        'approverId': approverId,
        'approverComment': comment,
        'approvedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to approve leave request: $e');
    }
  }

  Future<void> rejectLeaveRequest(
    String leaveId,
    String approverId,
    String comment,
  ) async {
    try {
      await collection.doc(leaveId).update({
        'status': LeaveStatus.rejected.toString().split('.').last,
        'approverId': approverId,
        'approverComment': comment,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to reject leave request: $e');
    }
  }

  Future<void> cancelLeaveRequest(String leaveId) async {
    try {
      await collection.doc(leaveId).update({
        'status': LeaveStatus.cancelled.toString().split('.').last,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to cancel leave request: $e');
    }
  }

  Stream<List<LeaveRequestModel>> streamLeaveRequestsByEmployee(
    String employeeId,
  ) {
    return collection
        .where('employeeId', isEqualTo: employeeId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => fromJson(doc.data())).toList());
  }

  Stream<List<LeaveRequestModel>> streamPendingLeaveRequests() {
    return collection
        .where('status',
            isEqualTo: LeaveStatus.pending.toString().split('.').last)
        .orderBy('createdAt')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => fromJson(doc.data())).toList());
  }
} 