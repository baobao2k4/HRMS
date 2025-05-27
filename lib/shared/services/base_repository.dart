import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/base_model.dart';

abstract class BaseRepository<T extends BaseModel> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionPath;

  BaseRepository(this.collectionPath);

  CollectionReference<Map<String, dynamic>> get collection =>
      _firestore.collection(collectionPath);

  T fromJson(Map<String, dynamic> json);

  Future<List<T>> getAll() async {
    try {
      final snapshot = await collection.get();
      return snapshot.docs.map((doc) => fromJson(doc.data())).toList();
    } catch (e) {
      throw Exception('Failed to get documents: $e');
    }
  }

  Future<T?> getById(String id) async {
    try {
      final doc = await collection.doc(id).get();
      if (!doc.exists) return null;
      return fromJson(doc.data()!);
    } catch (e) {
      throw Exception('Failed to get document: $e');
    }
  }

  Future<List<T>> query({
    List<List<dynamic>> filters = const [],
    String? orderBy,
    bool descending = false,
    int? limit,
  }) async {
    try {
      Query<Map<String, dynamic>> query = collection;

      for (final filter in filters) {
        if (filter.length != 3) continue;
        query = query.where(
          filter[0] as String,
          isEqualTo: filter[1] == '==' ? filter[2] : null,
          isGreaterThan: filter[1] == '>' ? filter[2] : null,
          isLessThan: filter[1] == '<' ? filter[2] : null,
          isGreaterThanOrEqualTo: filter[1] == '>=' ? filter[2] : null,
          isLessThanOrEqualTo: filter[1] == '<=' ? filter[2] : null,
          arrayContains: filter[1] == 'array-contains' ? filter[2] : null,
        );
      }

      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => fromJson(doc.data())).toList();
    } catch (e) {
      throw Exception('Failed to query documents: $e');
    }
  }

  Future<T> add(T item) async {
    try {
      final docRef = collection.doc(item.id);
      await docRef.set(item.toFirestore());
      return item;
    } catch (e) {
      throw Exception('Failed to add document: $e');
    }
  }

  Future<T> update(T item) async {
    try {
      final docRef = collection.doc(item.id);
      await docRef.update(item.toFirestore());
      return item;
    } catch (e) {
      throw Exception('Failed to update document: $e');
    }
  }

  Future<void> delete(String id) async {
    try {
      await collection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete document: $e');
    }
  }

  Stream<List<T>> streamAll() {
    return collection.snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => fromJson(doc.data())).toList(),
        );
  }

  Stream<T?> streamById(String id) {
    return collection.doc(id).snapshots().map(
          (doc) => doc.exists ? fromJson(doc.data()!) : null,
        );
  }

  Future<void> batchWrite(List<T> items) async {
    try {
      final batch = _firestore.batch();
      for (final item in items) {
        final docRef = collection.doc(item.id);
        batch.set(docRef, item.toFirestore());
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to batch write documents: $e');
    }
  }

  Future<void> batchDelete(List<String> ids) async {
    try {
      final batch = _firestore.batch();
      for (final id in ids) {
        final docRef = collection.doc(id);
        batch.delete(docRef);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to batch delete documents: $e');
    }
  }
} 