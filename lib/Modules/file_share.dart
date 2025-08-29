import 'dart:ui' as html;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shareanything/Provider/file_share_provider.dart';

class FileSharePage extends StatefulWidget {
  @override
  _FileSharePageState createState() => _FileSharePageState();
}

class _FileSharePageState extends State<FileSharePage> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isPrivate = false;
  String _userId = "user123"; // Your current user ID

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('File Portal')),
      body: Consumer<FileShareProvider>(
        builder: (context, fileProvider, child) {
          return Column(
            children: [
              // Upload Section
              Card(
                margin: EdgeInsets.all(16),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: _isPrivate,
                            onChanged: (value) {
                              setState(() {
                                _isPrivate = value ?? false;
                              });
                            },
                          ),
                          Text('Private File'),
                        ],
                      ),
                      if (_isPrivate)
                        TextField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _uploadFile(fileProvider),
                        child: Text('Upload File'),
                      ),
                    ],
                  ),
                ),
              ),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => fileProvider.fetchFiles(), // Public files
                    child: Text('Load Public Files'),
                  ),
                  ElevatedButton(
                    onPressed:
                        () => fileProvider.fetchFiles(
                          userId: _userId,
                        ), // User files
                    child: Text('Load My Files'),
                  ),
                ],
              ),

              // Error Display
              if (fileProvider.error != null)
                Container(
                  margin: EdgeInsets.all(16),
                  padding: EdgeInsets.all(8),
                  color: Colors.red.shade100,
                  child: Text('Error: ${fileProvider.error}'),
                ),

              // Loading
              if (fileProvider.isLoading)
                Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),

              // Files List
              Expanded(
                child: ListView.builder(
                  itemCount: fileProvider.files.length,
                  itemBuilder: (context, index) {
                    final file = fileProvider.files[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: Icon(
                          file['isPrivate']
                              ? Icons.lock
                              : Icons.insert_drive_file,
                          color: file['isPrivate'] ? Colors.red : Colors.blue,
                        ),
                        title: Text(file['fileName']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Time: ${_formatTime(file['time'])}'),
                            Text(
                              'Private: ${file['isPrivate'] ? 'Yes' : 'No'}',
                            ),
                            if (file['isPrivate'] &&
                                file['password'].isNotEmpty)
                              Text('Password: ${file['password']}'),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.download),
                          onPressed: () {
                            // Open URL in browser or download
                            print('Download URL: ${file['url']}');
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _uploadFile(FileShareProvider fileProvider) async {
    final result = await FilePicker.platform.pickFiles();

    if (result != null) {
      final file = result.files.first;
      final success = await fileProvider.uploadFile(
        file: file,
        isPrivate: _isPrivate,
        userId: _userId,
        password: _isPrivate ? _passwordController.text : "",
      );

      if (success) {
        _passwordController.clear();
        setState(() {
          _isPrivate = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('File uploaded successfully')));
      }
    }
  }

  String _formatTime(String timeString) {
    try {
      final dateTime = DateTime.parse(timeString);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
    } catch (e) {
      return timeString;
    }
  }
}
