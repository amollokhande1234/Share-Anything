import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:shareanything/app_config.dart';

class PublicMessagesProvider extends ChangeNotifier {
  final Databases databases;
  PublicMessagesProvider(this.databases);
  List<Document> publicDocumet = [];

  // Share Message
  Future<bool> sendMessage(String title, String desc) async {
    if (title.isEmpty || desc.isEmpty) return false;

    try {
      final _newMessage = await databases.createDocument(
        databaseId: AppConfig.DatabseId,
        collectionId: AppConfig.PrivateCollectionInd,
        documentId: 'unique()',
        data: {
          'title': title,
          'desc': desc,
          'time': DateTime.now().toIso8601String(),
        },
        permissions: [
          Permission.read(Role.any()),
          Permission.write(Role.any()),
        ],
      );

      debugPrint("✅ Message sent: ${_newMessage.data}");
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("💀 Appwrite Error: $e");
      return false;
    }
  }

  // Fetch Messages
  Future<void> fetchMessages() async {
    try {
      final result = await databases.listDocuments(
        databaseId: AppConfig.DatabseId,
        collectionId: AppConfig.PublicCollectionId,
      );
      publicDocumet = result.documents;
      notifyListeners();
    } catch (e) {
      print("Error fetching messages: $e");
    }
  }
}
