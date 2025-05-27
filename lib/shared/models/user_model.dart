import 'package:cloud_firestore/cloud_firestore.dart';
import 'base_model.dart';

class UserModel extends BaseModel {
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final String department;
  final String employeeId;
  final String phoneNumber;
  final String address;
  final DateTime dateOfBirth;
  final DateTime joiningDate;
  final String designation;
  final String employmentStatus;
  final double salary;
  final Map<String, dynamic> permissions;
  final String? profileImageUrl;

  UserModel({
    required String id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.department,
    required this.employeeId,
    required this.phoneNumber,
    required this.address,
    required this.dateOfBirth,
    required this.joiningDate,
    required this.designation,
    required this.employmentStatus,
    required this.salary,
    required this.permissions,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.profileImageUrl,
  }) : super(
          id: id,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'role': role,
      'department': department,
      'employeeId': employeeId,
      'phoneNumber': phoneNumber,
      'address': address,
      'dateOfBirth': Timestamp.fromDate(dateOfBirth),
      'joiningDate': Timestamp.fromDate(joiningDate),
      'designation': designation,
      'employmentStatus': employmentStatus,
      'salary': salary,
      'permissions': permissions,
      'profileImageUrl': profileImageUrl,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      role: json['role'] as String,
      department: json['department'] as String,
      employeeId: json['employeeId'] as String,
      phoneNumber: json['phoneNumber'] as String,
      address: json['address'] as String,
      dateOfBirth: (json['dateOfBirth'] as Timestamp).toDate(),
      joiningDate: (json['joiningDate'] as Timestamp).toDate(),
      designation: json['designation'] as String,
      employmentStatus: json['employmentStatus'] as String,
      salary: (json['salary'] as num).toDouble(),
      permissions: json['permissions'] as Map<String, dynamic>,
      profileImageUrl: json['profileImageUrl'] as String?,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  String get fullName => '$firstName $lastName';

  UserModel copyWith({
    String? email,
    String? firstName,
    String? lastName,
    String? role,
    String? department,
    String? employeeId,
    String? phoneNumber,
    String? address,
    DateTime? dateOfBirth,
    DateTime? joiningDate,
    String? designation,
    String? employmentStatus,
    double? salary,
    Map<String, dynamic>? permissions,
    String? profileImageUrl,
  }) {
    return UserModel(
      id: id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
      department: department ?? this.department,
      employeeId: employeeId ?? this.employeeId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      joiningDate: joiningDate ?? this.joiningDate,
      designation: designation ?? this.designation,
      employmentStatus: employmentStatus ?? this.employmentStatus,
      salary: salary ?? this.salary,
      permissions: permissions ?? this.permissions,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
} 