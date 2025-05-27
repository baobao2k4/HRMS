import 'package:cloud_firestore/cloud_firestore.dart';
import 'base_model.dart';

class AttendanceModel extends BaseModel {
  final String employeeId;
  final String employeeName;
  final DateTime checkIn;
  final DateTime? checkOut;
  final String status; // 'present', 'absent', 'late', 'half-day'
  final GeoPoint? checkInLocation;
  final GeoPoint? checkOutLocation;
  final String? notes;
  final double? workingHours;
  final bool isOvertime;

  AttendanceModel({
    required String id,
    required this.employeeId,
    required this.employeeName,
    required this.checkIn,
    required this.status,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.checkOut,
    this.checkInLocation,
    this.checkOutLocation,
    this.notes,
    this.workingHours,
    this.isOvertime = false,
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
      'checkIn': Timestamp.fromDate(checkIn),
      'checkOut': checkOut != null ? Timestamp.fromDate(checkOut!) : null,
      'status': status,
      'checkInLocation': checkInLocation,
      'checkOutLocation': checkOutLocation,
      'notes': notes,
      'workingHours': workingHours,
      'isOvertime': isOvertime,
    };
  }

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      employeeName: json['employeeName'] as String,
      checkIn: (json['checkIn'] as Timestamp).toDate(),
      checkOut: json['checkOut'] != null
          ? (json['checkOut'] as Timestamp).toDate()
          : null,
      status: json['status'] as String,
      checkInLocation: json['checkInLocation'] as GeoPoint?,
      checkOutLocation: json['checkOutLocation'] as GeoPoint?,
      notes: json['notes'] as String?,
      workingHours: (json['workingHours'] as num?)?.toDouble(),
      isOvertime: json['isOvertime'] as bool? ?? false,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  double calculateWorkingHours() {
    if (checkOut == null) return 0;
    final difference = checkOut!.difference(checkIn);
    return difference.inMinutes / 60;
  }

  bool get isCheckedOut => checkOut != null;

  AttendanceModel copyWith({
    String? employeeId,
    String? employeeName,
    DateTime? checkIn,
    DateTime? checkOut,
    String? status,
    GeoPoint? checkInLocation,
    GeoPoint? checkOutLocation,
    String? notes,
    double? workingHours,
    bool? isOvertime,
  }) {
    return AttendanceModel(
      id: id,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      status: status ?? this.status,
      checkInLocation: checkInLocation ?? this.checkInLocation,
      checkOutLocation: checkOutLocation ?? this.checkOutLocation,
      notes: notes ?? this.notes,
      workingHours: workingHours ?? this.workingHours,
      isOvertime: isOvertime ?? this.isOvertime,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
} 