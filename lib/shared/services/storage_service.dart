import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

final storageServiceProvider = Provider<StorageService>((ref) => StorageService());

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _uuid = const Uuid();

  Future<String> uploadFile(
    File file,
    String folder, {
    String? customFileName,
  }) async {
    try {
      final fileName = customFileName ?? _generateFileName(file);
      final ref = _storage.ref().child('$folder/$fileName');
      
      final metadata = SettableMetadata(
        contentType: _getContentType(fileName),
        customMetadata: {'uploaded_at': DateTime.now().toIso8601String()},
      );

      final uploadTask = ref.putFile(file, metadata);
      
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  Future<String> uploadData(
    List<int> data,
    String fileName,
    String folder,
  ) async {
    try {
      final ref = _storage.ref().child('$folder/$fileName');
      
      final metadata = SettableMetadata(
        contentType: _getContentType(fileName),
        customMetadata: {'uploaded_at': DateTime.now().toIso8601String()},
      );

      final uploadTask = ref.putData(data, metadata);
      
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload data: $e');
    }
  }

  Future<void> deleteFile(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }

  Future<Map<String, String>> uploadMultipleFiles(
    List<File> files,
    String folder,
  ) async {
    try {
      final Map<String, String> urls = {};
      
      for (final file in files) {
        final url = await uploadFile(file, folder);
        urls[path.basename(file.path)] = url;
      }
      
      return urls;
    } catch (e) {
      throw Exception('Failed to upload multiple files: $e');
    }
  }

  String _generateFileName(File file) {
    final extension = path.extension(file.path);
    final uniqueId = _uuid.v4();
    return '$uniqueId$extension';
  }

  String _getContentType(String fileName) {
    final extension = path.extension(fileName).toLowerCase();
    
    switch (extension) {
      case '.jpeg':
      case '.jpg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.pdf':
        return 'application/pdf';
      case '.doc':
        return 'application/msword';
      case '.docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case '.xls':
        return 'application/vnd.ms-excel';
      case '.xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      default:
        return 'application/octet-stream';
    }
  }

  Future<void> deleteFolder(String folder) async {
    try {
      final ListResult result = await _storage.ref().child(folder).listAll();
      
      for (var item in result.items) {
        await item.delete();
      }
      
      for (var prefix in result.prefixes) {
        await deleteFolder(prefix.fullPath);
      }
    } catch (e) {
      throw Exception('Failed to delete folder: $e');
    }
  }

  Future<List<String>> listFiles(String folder) async {
    try {
      final ListResult result = await _storage.ref().child(folder).listAll();
      final List<String> urls = [];
      
      for (var item in result.items) {
        final url = await item.getDownloadURL();
        urls.add(url);
      }
      
      return urls;
    } catch (e) {
      throw Exception('Failed to list files: $e');
    }
  }

  Future<Map<String, String>> getFileMetadata(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      final metadata = await ref.getMetadata();
      
      return {
        'name': metadata.name,
        'path': metadata.fullPath,
        'size': '${metadata.size}',
        'contentType': metadata.contentType ?? 'unknown',
        'createdAt': metadata.timeCreated?.toIso8601String() ?? 'unknown',
        'updatedAt': metadata.updated?.toIso8601String() ?? 'unknown',
        ...metadata.customMetadata ?? {},
      };
    } catch (e) {
      throw Exception('Failed to get file metadata: $e');
    }
  }
} 