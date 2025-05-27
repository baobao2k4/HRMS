import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/services/base_repository.dart';

class UserRepository extends BaseRepository<UserModel> {
  UserRepository() : super('users');

  @override
  UserModel fromJson(Map<String, dynamic> json) => UserModel.fromJson(json);

  Future<UserModel?> getUserByEmail(String email) async {
    try {
      final snapshot = await collection
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;
      return fromJson(snapshot.docs.first.data());
    } catch (e) {
      throw Exception('Failed to get user by email: $e');
    }
  }

  Future<List<UserModel>> getUsersByDepartment(String department) async {
    return query(
      filters: [
        ['department', '==', department]
      ],
    );
  }

  Future<List<UserModel>> getUsersByRole(String role) async {
    return query(
      filters: [
        ['role', '==', role]
      ],
    );
  }

  Future<List<UserModel>> searchUsers(String searchTerm) async {
    try {
      final snapshot = await collection
          .orderBy('firstName')
          .startAt([searchTerm])
          .endAt([searchTerm + '\uf8ff'])
          .get();

      return snapshot.docs.map((doc) => fromJson(doc.data())).toList();
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }

  Future<void> updateUserStatus(String userId, String status) async {
    try {
      await collection.doc(userId).update({
        'employmentStatus': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update user status: $e');
    }
  }

  Future<void> updateUserPermissions(
    String userId,
    Map<String, dynamic> permissions,
  ) async {
    try {
      await collection.doc(userId).update({
        'permissions': permissions,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update user permissions: $e');
    }
  }

  Stream<List<UserModel>> streamUsersByDepartment(String department) {
    return collection
        .where('department', isEqualTo: department)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => fromJson(doc.data())).toList());
  }
} 