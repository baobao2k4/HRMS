import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../models/payroll_model.dart';
import '../models/attendance_model.dart';
import '../models/leave_request_model.dart';

final pdfServiceProvider = Provider<PdfService>((ref) => PdfService());

class PdfService {
  Future<File> generatePayslip(PayrollModel payroll) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader('Payslip'),
              pw.SizedBox(height: 20),
              _buildEmployeeInfo(payroll),
              pw.SizedBox(height: 20),
              _buildPayrollDetails(payroll),
              pw.SizedBox(height: 20),
              _buildEarningsDeductions(payroll),
              pw.SizedBox(height: 20),
              _buildTotal(payroll),
            ],
          );
        },
      ),
    );

    return await _saveDocument('payslip_${payroll.employeeId}.pdf', pdf);
  }

  Future<File> generateAttendanceReport(
    List<AttendanceModel> attendance,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader('Attendance Report'),
              pw.SizedBox(height: 20),
              _buildDateRange(startDate, endDate),
              pw.SizedBox(height: 20),
              _buildAttendanceTable(attendance),
              pw.SizedBox(height: 20),
              _buildAttendanceSummary(attendance),
            ],
          );
        },
      ),
    );

    return await _saveDocument(
      'attendance_${DateFormat('yyyyMMdd').format(startDate)}_${DateFormat('yyyyMMdd').format(endDate)}.pdf',
      pdf,
    );
  }

  Future<File> generateLeaveReport(
    List<LeaveRequestModel> leaves,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader('Leave Report'),
              pw.SizedBox(height: 20),
              _buildDateRange(startDate, endDate),
              pw.SizedBox(height: 20),
              _buildLeaveTable(leaves),
              pw.SizedBox(height: 20),
              _buildLeaveSummary(leaves),
            ],
          );
        },
      ),
    );

    return await _saveDocument(
      'leave_${DateFormat('yyyyMMdd').format(startDate)}_${DateFormat('yyyyMMdd').format(endDate)}.pdf',
      pdf,
    );
  }

  pw.Widget _buildHeader(String title) {
    return pw.Header(
      level: 0,
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 24,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  pw.Widget _buildEmployeeInfo(PayrollModel payroll) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Employee ID: ${payroll.employeeId}'),
        pw.Text('Name: ${payroll.employeeName}'),
        pw.Text(
          'Pay Period: ${DateFormat('MMM dd, yyyy').format(payroll.payPeriodStart)} - ${DateFormat('MMM dd, yyyy').format(payroll.payPeriodEnd)}',
        ),
      ],
    );
  }

  pw.Widget _buildPayrollDetails(PayrollModel payroll) {
    return pw.Table(
      border: pw.TableBorder.all(),
      children: [
        pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Text('Basic Salary'),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Text('\$${payroll.basicSalary.toStringAsFixed(2)}'),
            ),
          ],
        ),
        pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Text('Overtime Pay'),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Text('\$${payroll.overtimePay.toStringAsFixed(2)}'),
            ),
          ],
        ),
        pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Text('Bonus'),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Text('\$${payroll.bonus.toStringAsFixed(2)}'),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildEarningsDeductions(PayrollModel payroll) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Allowances',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ...payroll.allowances.entries.map(
                (entry) => pw.Text(
                  '${entry.key}: \$${entry.value.toStringAsFixed(2)}',
                ),
              ),
            ],
          ),
        ),
        pw.SizedBox(width: 20),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Deductions',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ...payroll.deductions.entries.map(
                (entry) => pw.Text(
                  '${entry.key}: \$${entry.value.toStringAsFixed(2)}',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildTotal(PayrollModel payroll) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(),
      ),
      padding: const pw.EdgeInsets.all(10),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Net Salary',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Text(
            '\$${payroll.netSalary.toStringAsFixed(2)}',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildDateRange(DateTime startDate, DateTime endDate) {
    return pw.Text(
      'Period: ${DateFormat('MMM dd, yyyy').format(startDate)} - ${DateFormat('MMM dd, yyyy').format(endDate)}',
    );
  }

  pw.Widget _buildAttendanceTable(List<AttendanceModel> attendance) {
    return pw.Table(
      border: pw.TableBorder.all(),
      children: [
        pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Text('Date'),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Text('Check In'),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Text('Check Out'),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Text('Status'),
            ),
          ],
        ),
        ...attendance.map(
          (record) => pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text(
                  DateFormat('MMM dd, yyyy').format(record.checkIn),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text(
                  DateFormat('HH:mm').format(record.checkIn),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text(
                  record.checkOut != null
                      ? DateFormat('HH:mm').format(record.checkOut!)
                      : '-',
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text(record.status),
              ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildAttendanceSummary(List<AttendanceModel> attendance) {
    final present = attendance.where((a) => a.status == 'present').length;
    final absent = attendance.where((a) => a.status == 'absent').length;
    final late = attendance.where((a) => a.status == 'late').length;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Summary', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.Text('Present: $present days'),
        pw.Text('Absent: $absent days'),
        pw.Text('Late: $late days'),
      ],
    );
  }

  pw.Widget _buildLeaveTable(List<LeaveRequestModel> leaves) {
    return pw.Table(
      border: pw.TableBorder.all(),
      children: [
        pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Text('Type'),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Text('Start Date'),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Text('End Date'),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Text('Status'),
            ),
          ],
        ),
        ...leaves.map(
          (leave) => pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text(leave.type.toString().split('.').last),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text(
                  DateFormat('MMM dd, yyyy').format(leave.startDate),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text(
                  DateFormat('MMM dd, yyyy').format(leave.endDate),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text(leave.status.toString().split('.').last),
              ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildLeaveSummary(List<LeaveRequestModel> leaves) {
    final approved = leaves.where((l) => l.isApproved).length;
    final pending = leaves.where((l) => l.isPending).length;
    final rejected = leaves.where((l) => l.isRejected).length;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Summary', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.Text('Approved: $approved'),
        pw.Text('Pending: $pending'),
        pw.Text('Rejected: $rejected'),
      ],
    );
  }

  Future<File> _saveDocument(String name, pw.Document pdf) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$name');
    await file.writeAsBytes(await pdf.save());
    return file;
  }
} 