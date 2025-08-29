import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shareanything/Provider/public_messages_provider.dart';
import 'package:shareanything/popup.dart';

import 'package:intl/intl.dart';

class PublicMessagesPage extends StatelessWidget {
  TextEditingController _descController = TextEditingController();
  TextEditingController _msgController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PublicMessagesProvider>().fetchMessages();
    });
    return Consumer<PublicMessagesProvider>(
      builder: (context, provider, __) {
        if (provider.publicDocumet.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return Scaffold(
          appBar: AppBar(title: Text("Public Messages")),
          body: ListView.builder(
            padding: EdgeInsets.all(12),
            itemCount: provider.publicDocumet.length,
            itemBuilder: (context, index) {
              final _doc = provider.publicDocumet[index].data;
              return docBloc(
                title: _doc['title'],
                description: _doc['desc'],
                isoTime: _doc['time'],
              );
            },
          ),
          persistentFooterButtons: [
            PublicMessagesInput(
              descriptionController: _descController,
              messageController: _msgController,
              onSend: () async {
                // Check required fields
                if (_descController.text.trim().isEmpty ||
                    _msgController.text.trim().isEmpty) {
                  showRequiredFieldPopup(context, "All fields are required");
                  return;
                }

                // Send message via provider
                bool isSent = await context
                    .read<PublicMessagesProvider>()
                    .sendMessage(
                      _descController.text.trim(),
                      _msgController.text.trim(),
                    );

                if (isSent) {
                  // Clear controllers after successful send
                  _descController.clear();
                  _msgController.clear();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Message sent!")),
                  );
                } else {
                  // Show error if sending failed
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Failed to send message.")),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}

Widget PublicMessagesInput({
  required TextEditingController descriptionController,
  required TextEditingController messageController,
  required VoidCallback onSend,
}) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, -2)),
      ],
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Description field
        TextField(
          controller: descriptionController,
          maxLines: null,
          decoration: InputDecoration(
            hintText: "Enter description...",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Message/Code field
        Expanded(
          child: TextField(
            controller: messageController,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(
              hintText: "Write your message or code...",
              filled: true,
              fillColor: Colors.black87,
              hintStyle: TextStyle(color: Colors.white54),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        const SizedBox(height: 8),
        // Send button
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: onSend,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text("Send"),
          ),
        ),
      ],
    ),
  );
}

Widget docBloc({
  required String title,
  required String description,
  required String isoTime,
}) {
  // Function to format ISO timestamp
  String formatTime(String isoString) {
    try {
      final dateTime = DateTime.parse(isoString);
      return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
    } catch (e) {
      return isoString; // fallback if parsing fails
    }
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Title
      Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),

      const SizedBox(height: 4),

      // Formatted Time
      Text(
        formatTime(isoTime),
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),

      const SizedBox(height: 8),

      // Description as code block
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(10),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Text(
            description,
            style: const TextStyle(
              fontFamily: "monospace",
              fontSize: 14,
              color: Colors.greenAccent,
            ),
          ),
        ),
      ),

      const SizedBox(height: 16),
    ],
  );
}
