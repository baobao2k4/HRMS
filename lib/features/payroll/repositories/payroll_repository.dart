import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../shared/models/payroll_model.dart';
import '../../../shared/services/base_repository.dart';

class PayrollRepository extends BaseRepository<PayrollModel> {
  PayrollRepository() : super('payroll');

  @override
  PayrollModel fromJson(Map<String, dynamic> json) => PayrollModel.fromJson(json);

  Future<List<PayrollModel>> getPayrollByEmployee(
    String employeeId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var filters = [
      ['employeeId', '==', employeeId]
    ];

    if (startDate != null) {
      filters.add(['payPeriodStart', '>=', startDate]);
    }

    if (endDate != null) {
      filters.add(['payPeriodEnd', '<=', endDate]);
    }

    return query(
      filters: filters,
      orderBy: 'payPeriodStart',
      descending: true,
    );
  }

  Future<List<PayrollModel>> getPayrollByStatus(String status) async {
    return query(
      filters: [
        ['paymentStatus', '==', status]
      ],
      orderBy: 'payPeriodStart',
      descending: true,
    );
  }

  Future<List<PayrollModel>> getPayrollByPeriod(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return query(
      filters: [
        ['payPeriodStart', '>=', startDate],
        ['payPeriodEnd', '<=', endDate],
      ],
      orderBy: 'payPeriodStart',
    );
  }

  Future<void> updatePaymentStatus(
    String payrollId,
    String status, {
    String? paymentMethod,
    String? paymentReference,
  }) async {
    try {
      final data = {
        'paymentStatus': status,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (status == 'paid') {
        data['paymentDate'] = FieldValue.serverTimestamp();
        if (paymentMethod != null) data['paymentMethod'] = paymentMethod;
        if (paymentReference != null) data['paymentReference'] = paymentReference;
      }

      await collection.doc(payrollId).update(data);
    } catch (e) {
      throw Exception('Failed to update payment status: $e');
    }
  }

  Future<Map<String, double>> getPayrollSummary(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final payrolls = await getPayrollByPeriod(startDate, endDate);

      double totalBasicSalary = 0;
      double totalOvertimePay = 0;
      double totalBonus = 0;
      double totalAllowances = 0;
      double totalDeductions = 0;
      double totalNetSalary = 0;

      for (var payroll in payrolls) {
        totalBasicSalary += payroll.basicSalary;
        totalOvertimePay += payroll.overtimePay;
        totalBonus += payroll.bonus;
        totalAllowances +=
            payroll.allowances.values.fold(0, (sum, value) => sum + value);
        totalDeductions +=
            payroll.deductions.values.fold(0, (sum, value) => sum + value);
        totalNetSalary += payroll.netSalary;
      }

      return {
        'totalBasicSalary': totalBasicSalary,
        'totalOvertimePay': totalOvertimePay,
        'totalBonus': totalBonus,
        'totalAllowances': totalAllowances,
        'totalDeductions': totalDeductions,
        'totalNetSalary': totalNetSalary,
      };
    } catch (e) {
      throw Exception('Failed to get payroll summary: $e');
    }
  }

  Stream<List<PayrollModel>> streamPayrollByEmployee(String employeeId) {
    return collection
        .where('employeeId', isEqualTo: employeeId)
        .orderBy('payPeriodStart', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => fromJson(doc.data())).toList());
  }

  Stream<List<PayrollModel>> streamPendingPayrolls() {
    return collection
        .where('paymentStatus', isEqualTo: 'pending')
        .orderBy('payPeriodStart')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => fromJson(doc.data())).toList());
  }
} 