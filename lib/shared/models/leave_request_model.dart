import 'package:cloud_firestore/cloud_firestore.dart';
import 'base_model.dart';

enum LeaveStatus {
  pending,
  approved,
  rejected,
  cancelled
}

enum LeaveType {
  annual,
  sick,
  personal,
  maternity,
  paternity,
  unpaid
}

class LeaveRequestModel extends BaseModel {
  final String employeeId;
  final String employeeName;
  final LeaveType type;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final LeaveStatus status;
  final String? approverComment;
  final String? approverId;
  final DateTime? approvedAt;
  final List<String>? attachments;

  LeaveRequestModel({
    required String id,
    required this.employeeId,
    required this.employeeName,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.approverComment,
    this.approverId,
    this.approvedAt,
    this.attachments,
  }) : super(
          id: id,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'type': type.toString().split('.').last,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'reason': reason,
      'status': status.toString().split('.').last,
      'approverComment': approverComment,
      'approverId': approverId,
      'approvedAt': approvedAt != null ? Timestamp.fromDate(approvedAt!) : null,
      'attachments': attachments,
    };
  }

  factory LeaveRequestModel.fromJson(Map<String, dynamic> json) {
    return LeaveRequestModel(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      employeeName: json['employeeName'] as String,
      type: LeaveType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      startDate: (json['startDate'] as Timestamp).toDate(),
      endDate: (json['endDate'] as Timestamp).toDate(),
      reason: json['reason'] as String,
      status: LeaveStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      approverComment: json['approverComment'] as String?,
      approverId: json['approverId'] as String?,
      approvedAt: json['approvedAt'] != null
          ? (json['approvedAt'] as Timestamp).toDate()
          : null,
      attachments: (json['attachments'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  int get leaveDuration {
    return endDate.difference(startDate).inDays + 1;
  }

  bool get isPending => status == LeaveStatus.pending;
  bool get isApproved => status == LeaveStatus.approved;
  bool get isRejected => status == LeaveStatus.rejected;
  bool get isCancelled => status == LeaveStatus.cancelled;

  LeaveRequestModel copyWith({
    String? employeeId,
    String? employeeName,
    LeaveType? type,
    DateTime? startDate,
    DateTime? endDate,
    String? reason,
    LeaveStatus? status,
    String? approverComment,
    String? approverId,
    DateTime? approvedAt,
    List<String>? attachments,
  }) {
    return LeaveRequestModel(
      id: id,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      approverComment: approverComment ?? this.approverComment,
      approverId: approverId ?? this.approverId,
      approvedAt: approvedAt ?? this.approvedAt,
      attachments: attachments ?? this.attachments,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
} 