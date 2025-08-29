import 'dart:typed_data';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shareanything/app_config.dart';

// class FileShareProvider extends ChangeNotifier {}

class FileShareProvider extends ChangeNotifier {
  final Client client;
  final Storage storage;
  final Databases databases;
  FileShareProvider(this.client, this.databases, this.storage);

  // Configuration
  static const String bucketId = AppConfig.BucketId;
  static const String databaseId = AppConfig.FileShareCollectionId;
  static const String collectionId = "";

  // Data list
  List<Map<String, dynamic>> _files = [];

  bool _isLoading = false;
  String? _error;

  // Getters
  List<Map<String, dynamic>> get files => _files;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Upload Function
  Future<bool> uploadFile({
    required PlatformFile file,
    required bool isPrivate,
    required String userId,
    String password = "",
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Upload file to storage
      final uploadedFile = await storage.createFile(
        bucketId: bucketId,
        fileId: ID.unique(),
        file: InputFile.fromBytes(bytes: file.bytes!, filename: file.name),
      );

      // Get file URL
      final fileUrl =
          storage
              .getFileDownload(bucketId: bucketId, fileId: uploadedFile.$id)
              .toString();

      // Prepare data for database
      final fileData = {
        'fileName': file.name,
        'url': fileUrl,
        'time': DateTime.now().toIso8601String(),
        'isPrivate': isPrivate,
        'password': isPrivate ? password : "",
        'userId': userId,
        'fileId': uploadedFile.$id,
      };

      // Save to database
      await databases.createDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: ID.unique(),
        data: fileData,
      );

      // Add to local list
      files.add(fileData);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Fetch Function
  Future<void> fetchFiles({String? userId}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      List<String> queries = [Query.orderDesc('time')];

      // If userId provided, get user's files, otherwise get all public files
      if (userId != null) {
        queries.add(Query.equal('userId', userId));
      } else {
        queries.add(Query.equal('isPrivate', false));
      }

      final response = await databases.listDocuments(
        databaseId: databaseId,
        collectionId: collectionId,
        queries: queries,
      );

      _files =
          response.documents.map((doc) {
            final data = doc.data;
            return {
              'fileName': data['fileName'] ?? '',
              'url': data['url'] ?? '',
              'time': data['time'] ?? '',
              'isPrivate': data['isPrivate'] ?? false,
              'password': data['password'] ?? '',
              'userId': data['userId'] ?? '',
              'fileId': data['fileId'] ?? '',
            };
          }).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
