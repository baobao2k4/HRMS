import 'package:cloud_firestore/cloud_firestore.dart';
import 'base_model.dart';

class PayrollModel extends BaseModel {
  final String employeeId;
  final String employeeName;
  final DateTime payPeriodStart;
  final DateTime payPeriodEnd;
  final double basicSalary;
  final double overtimePay;
  final double bonus;
  final Map<String, double> allowances;
  final Map<String, double> deductions;
  final double totalEarnings;
  final double totalDeductions;
  final double netSalary;
  final String paymentStatus; // 'pending', 'paid', 'failed'
  final DateTime? paymentDate;
  final String? paymentMethod;
  final String? paymentReference;
  final String? notes;

  PayrollModel({
    required String id,
    required this.employeeId,
    required this.employeeName,
    required this.payPeriodStart,
    required this.payPeriodEnd,
    required this.basicSalary,
    required this.overtimePay,
    required this.bonus,
    required this.allowances,
    required this.deductions,
    required this.totalEarnings,
    required this.totalDeductions,
    required this.netSalary,
    required this.paymentStatus,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.paymentDate,
    this.paymentMethod,
    this.paymentReference,
    this.notes,
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
      'payPeriodStart': Timestamp.fromDate(payPeriodStart),
      'payPeriodEnd': Timestamp.fromDate(payPeriodEnd),
      'basicSalary': basicSalary,
      'overtimePay': overtimePay,
      'bonus': bonus,
      'allowances': allowances,
      'deductions': deductions,
      'totalEarnings': totalEarnings,
      'totalDeductions': totalDeductions,
      'netSalary': netSalary,
      'paymentStatus': paymentStatus,
      'paymentDate': paymentDate != null ? Timestamp.fromDate(paymentDate!) : null,
      'paymentMethod': paymentMethod,
      'paymentReference': paymentReference,
      'notes': notes,
    };
  }

  factory PayrollModel.fromJson(Map<String, dynamic> json) {
    return PayrollModel(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      employeeName: json['employeeName'] as String,
      payPeriodStart: (json['payPeriodStart'] as Timestamp).toDate(),
      payPeriodEnd: (json['payPeriodEnd'] as Timestamp).toDate(),
      basicSalary: (json['basicSalary'] as num).toDouble(),
      overtimePay: (json['overtimePay'] as num).toDouble(),
      bonus: (json['bonus'] as num).toDouble(),
      allowances: Map<String, double>.from(json['allowances'] as Map),
      deductions: Map<String, double>.from(json['deductions'] as Map),
      totalEarnings: (json['totalEarnings'] as num).toDouble(),
      totalDeductions: (json['totalDeductions'] as num).toDouble(),
      netSalary: (json['netSalary'] as num).toDouble(),
      paymentStatus: json['paymentStatus'] as String,
      paymentDate: json['paymentDate'] != null
          ? (json['paymentDate'] as Timestamp).toDate()
          : null,
      paymentMethod: json['paymentMethod'] as String?,
      paymentReference: json['paymentReference'] as String?,
      notes: json['notes'] as String?,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  bool get isPaid => paymentStatus == 'paid';
  bool get isPending => paymentStatus == 'pending';
  bool get isFailed => paymentStatus == 'failed';

  PayrollModel copyWith({
    String? employeeId,
    String? employeeName,
    DateTime? payPeriodStart,
    DateTime? payPeriodEnd,
    double? basicSalary,
    double? overtimePay,
    double? bonus,
    Map<String, double>? allowances,
    Map<String, double>? deductions,
    double? totalEarnings,
    double? totalDeductions,
    double? netSalary,
    String? paymentStatus,
    DateTime? paymentDate,
    String? paymentMethod,
    String? paymentReference,
    String? notes,
  }) {
    return PayrollModel(
      id: id,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      payPeriodStart: payPeriodStart ?? this.payPeriodStart,
      payPeriodEnd: payPeriodEnd ?? this.payPeriodEnd,
      basicSalary: basicSalary ?? this.basicSalary,
      overtimePay: overtimePay ?? this.overtimePay,
      bonus: bonus ?? this.bonus,
      allowances: allowances ?? this.allowances,
      deductions: deductions ?? this.deductions,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      totalDeductions: totalDeductions ?? this.totalDeductions,
      netSalary: netSalary ?? this.netSalary,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentDate: paymentDate ?? this.paymentDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentReference: paymentReference ?? this.paymentReference,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
} 