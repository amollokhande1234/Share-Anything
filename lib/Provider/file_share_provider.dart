import 'dart:io';
import 'dart:html' as html;

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
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
  // static const String databaseId = AppConfig.FileShareCollectionId;
  static const String collectionId = "";

  // Data list
  // List<Map<String, dynamic>> _files = [];

  bool _isLoading = false;
  String? _error;

  // Getters
  // List<Map<String, dynamic>> get files => _files;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<FileData> _files = [];

  List<FileData> get files => _files;
  List<Document> allFiles = [];

  Future<Uint8List?> getFilePreview(String fileId) async {
    try {
      final client = Client()
          .setEndpoint('https://cloud.appwrite.io/v1')
          .setProject(AppConfig.ProjectId);

      final storage = Storage(client);

      // For previewable formats (image/pdf), use getFilePreview
      final result = await storage.getFileView(
        bucketId: AppConfig.BucketId,
        fileId: fileId,
      );

      return result;
    } catch (e) {
      print("💀 Error fetching file: $e");
      return null;
    }
  }

  Future<bool?> uploadFileWeb(
    PlatformFile? selectedFile,
    int index,
    String password,
  ) async {
    try {
      if (selectedFile != null && selectedFile.bytes != null) {
        final fileBytes = selectedFile.bytes!;
        final fileName = selectedFile.name;

        // Upload file to Appwrite
        final response = await storage.createFile(
          bucketId: AppConfig.BucketId, // Appwrite storage bucket
          fileId: ID.unique(),
          file: InputFile(bytes: fileBytes, filename: fileName),
        );

        print('File uploaded successfully! File ID: ${response.$id}');
        notifyListeners();
        return uploadtoDatabse(fileName, index, response.$id, password);
      } else {
        print('No file selected');
        notifyListeners();
        return null;
      }
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }

  // Upload to the Database
  Future<bool> uploadtoDatabse(
    String fileName,
    int index,
    String id,
    String password,
  ) async {
    try {
      // if (isPrivate == true) {
      final _newFileData = await databases.createDocument(
        databaseId: AppConfig.DatabseId,
        collectionId: AppConfig.FileShareCollectionId,
        documentId: 'unique()',
        data: {
          'fileName': fileName,
          'isPrivate': index == 0 ? false : true,
          'password': index == 0 ? null : password,
          'fileId': id,
          'time': DateTime.now().toIso8601String().toString(),
        },
        permissions: [
          Permission.read(Role.any()),
          Permission.write(Role.any()),
        ],
      );
      debugPrint("✅ Message sent: ${_newFileData.data}");
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("💀 Appwrite Error: $e");
      return false;
    }
  }

  Future<void> fetchFiles() async {
    try {
      final result = await databases.listDocuments(
        databaseId: AppConfig.DatabseId,
        collectionId: AppConfig.FileShareCollectionId,
      );
      allFiles = result.documents;
      notifyListeners();
    } catch (e) {
      print("Error fetching messages: $e");
    }
  }

  bool validatePassword(String fileId, String enteredPassword) {
    final file = _files.firstWhere((f) => f.id == fileId);
    return file.password == enteredPassword;
  }

  Future<File> getFileBytes(String fileId) async {
    try {
      final bytes = await storage.getFile(
        fileId: fileId,
        bucketId: AppConfig.BucketId,
      );
      return bytes; // Uint8List of file content
    } catch (e) {
      print("Download error: $e");
      rethrow;
    }
  }

  // download files
  static void downloadFileWeb(Uint8List bytes, String filename) {
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor =
        html.document.createElement('a') as html.AnchorElement
          ..href = url
          ..download = filename
          ..style.display = 'none';
    html.document.body!.children.add(anchor);
    anchor.click();
    html.document.body!.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }
}

class FileData {
  final String id;
  final String name;
  final String access;
  final String password;

  FileData({
    required this.id,
    required this.name,
    required this.access,
    required this.password,
  });
}
