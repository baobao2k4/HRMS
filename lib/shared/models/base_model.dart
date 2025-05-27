import 'package:cloud_firestore/cloud_firestore.dart';

abstract class BaseModel {
  String id;
  DateTime createdAt;
  DateTime updatedAt;

  BaseModel({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson();

  factory BaseModel.fromJson(Map<String, dynamic> json) {
    throw UnimplementedError('fromJson() must be implemented in derived classes');
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json['createdAt'] = Timestamp.fromDate(createdAt);
    json['updatedAt'] = Timestamp.fromDate(updatedAt);
    return json;
  }

  static DateTime timestampToDateTime(Timestamp timestamp) {
    return timestamp.toDate();
  }

  @override
  String toString() {
    return '${runtimeType.toString()}(id: $id)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BaseModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 