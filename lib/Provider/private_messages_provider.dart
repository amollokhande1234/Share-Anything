import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:shareanything/app_config.dart';

class PrivateMessagesProvider extends ChangeNotifier {
  final Databases databases;
  PrivateMessagesProvider(this.databases);
  List<Document> privateDocumet = [];

  // send privateMessage
  Future<bool> sendPrivateMessages(
    String title,
    String desc,
    String pass,
  ) async {
    if (title.isEmpty || desc.isEmpty || pass.isEmpty) return false;

    try {
      final _newMessage = await databases.createDocument(
        databaseId: AppConfig.DatabseId,
        collectionId: AppConfig.PrivateCollectionInd,
        documentId: 'unique()',
        data: {
          'title': title,
          'desc': desc,
          'pass': pass,
          'time': DateTime.now().toIso8601String(),
        },
        permissions: [
          Permission.read(Role.any()),
          Permission.write(Role.any()),
        ],
      );

      debugPrint("✅ Private Message sent: ${_newMessage.data}");
      print("✅ Private Message sent: ${privateDocumet}");
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("💀 Appwrite Error: $e");
      return false;
    }
  }

  // fetch Data
  Future<void> fetchMessages() async {
    try {
      final result = await databases.listDocuments(
        databaseId: AppConfig.DatabseId,
        collectionId: AppConfig.PrivateCollectionInd,
      );
      privateDocumet = result.documents;
      notifyListeners();
    } catch (e) {
      print("Error fetching messages: $e");
    }
  }
}
