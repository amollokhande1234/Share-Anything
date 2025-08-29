import 'dart:ui';

import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shareanything/Provider/private_messages_provider.dart';
import 'package:shareanything/popup.dart';

// Widget PrivateMessagesPage() {
//   return Center(child: Text("Public"));
// }

class PrivateMessagesPage extends StatelessWidget {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _passController = TextEditingController();
  void _showPrivateMessageDialog(BuildContext context, VoidCallback onSendTap) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text("Share Private Message"),
            content: Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: "Title"),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descController,
                    decoration: const InputDecoration(labelText: "Description"),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _passController,
                    decoration: const InputDecoration(labelText: "Password"),
                    obscureText: true,
                  ),
                ],
              ),
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text("Cancel"),
                  ),
                  OutlinedButton(
                    onPressed: onSendTap,
                    child: const Text("Send"),
                  ),
                ],
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PrivateMessagesProvider>().fetchMessages();
    });
    return Consumer<PrivateMessagesProvider>(
      builder: (context, provider, __) {
        return Scaffold(
          body:
              provider.privateDocumet.isEmpty
                  ? const Center(child: Text("No messages yet"))
                  : Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(12),
                      shrinkWrap:
                          true, // 👈 allows GridView to size itself by content
                      physics:
                          const NeverScrollableScrollPhysics(), // 👈 disables scrolling
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5, // 👈 max 5 boxes in a row
                            crossAxisSpacing: 5,
                            mainAxisSpacing: 5,
                            childAspectRatio: 1, // 👈 make boxes square
                          ),
                      itemCount: provider.privateDocumet.length,
                      itemBuilder: (ctx, i) {
                        final doc = provider.privateDocumet[i].data;
                        return GestureDetector(
                          child: privateMessagesBox(
                            doc['title'] ?? "No Title",
                            // doc['desc'] ?? "No Description",
                            doc['time'] ?? "",
                            provider.privateDocumet.length,
                          ),
                          onTap: () {
                            _showPasswordDialog(
                              context,
                              provider.privateDocumet[i],
                            );
                          },
                        );
                      },
                    ),
                  ),
          floatingActionButton: SizedBox(
            width: 80, // increase width
            height: 80, // increase height
            child: FloatingActionButton(
              onPressed: () {
                _showPrivateMessageDialog(context, () {
                  context.read<PrivateMessagesProvider>().sendPrivateMessages(
                    _titleController.text.trim(),
                    _descController.text.trim(),
                    _passController.text.trim(),
                  );
                  Navigator.pop(context);
                });

                // if (_titleController.text.isEmpty ||
                //     _descController.text.isEmpty ||
                //     _passController.text.isEmpty) {
                //   showRequiredFieldPopup(context, "All Feild are required");
                // }
              },
              backgroundColor: Colors.blue,
              child: const Icon(
                Icons.add,
                size: 40, // increase icon size
              ),
            ),
          ),
        );
      },
    );
  }
}

Widget privateMessagesBox(String title, String time, int length) {
  String formatTime(String isoString) {
    try {
      final dateTime = DateTime.parse(isoString);
      return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
    } catch (e) {
      return isoString; // fallback if parsing fails
    }
  }

  return Container(
    decoration: BoxDecoration(
      color: Colors.blue[100],
      borderRadius: BorderRadius.circular(12),
    ),
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Text(title), Text(formatTime(time))],
      ),
    ),
  );
}

void _showPasswordDialog(BuildContext context, Document doc) {
  final _passwordController = TextEditingController();
  final pass = doc.data['pass'] ?? "";

  showDialog(
    context: context,
    builder:
        (ctx) => AlertDialog(
          title: const Text("Enter Password"),
          content: TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(hintText: "Password"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (_passwordController.text.trim() == pass) {
                  Navigator.pop(ctx);
                  _showDescriptionDialog(
                    context,
                    doc.data['title'],
                    doc.data['desc'] ?? "",
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Wrong password!")),
                  );
                }
              },
              child: const Text("Submit"),
            ),
          ],
        ),
  );
}

void _showDescriptionDialog(
  BuildContext context,
  String title,
  String description,
) {
  showDialog(
    context: context,
    builder:
        (ctx) => AlertDialog(
          title: Text("Private Message of" + title),
          content: SingleChildScrollView(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                child: Expanded(
                  child: Text(
                    " Code " + description,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Close"),
            ),
          ],
        ),
  );
}
