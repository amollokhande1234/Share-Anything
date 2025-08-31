import 'dart:typed_data';
import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shareanything/Provider/file_share_provider.dart';
import 'package:toggle_switch/toggle_switch.dart';

class FileSharePage extends StatefulWidget {
  @override
  _FileSharePageState createState() => _FileSharePageState();
}

class _FileSharePageState extends State<FileSharePage> {
  final TextEditingController _passwordController = TextEditingController();
  PlatformFile? selectedFile;
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FileShareProvider>().fetchFiles();
    });
    return Consumer<FileShareProvider>(
      builder: (cxt, fileProvider, child) {
        print(fileProvider.allFiles.toString());
        return Scaffold(
          appBar: AppBar(title: Text('File Portal')),
          body: GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5, // number of columns
              crossAxisSpacing: 12, // horizontal spacing
              mainAxisSpacing: 12, // vertical spacing
              childAspectRatio: 0.8, // width/height ratio of each grid tile
            ),
            itemCount: fileProvider.allFiles.length,
            itemBuilder: (context, index) {
              final file = fileProvider.allFiles[index].data;

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Expanded(
                    child: FutureBuilder<Uint8List?>(
                      future: fileProvider.getFilePreview(file['fileId']),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (snapshot.hasError) {
                          return const Icon(Icons.error, color: Colors.red);
                        }
                        if (!snapshot.hasData) {
                          return const Center(child: Text("No preview"));
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              file['fileName'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  if (file['isPrivate'] == false) {
                                    // Public file, show preview directly
                                    showDialog(
                                      context: context,
                                      builder:
                                          (context) => Dialog(
                                            backgroundColor: Colors.transparent,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: Column(
                                                children: [
                                                  InteractiveViewer(
                                                    child: Image.memory(
                                                      snapshot.data!,
                                                      fit: BoxFit.contain,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                    );
                                  } else {
                                    // Private file, ask for password first
                                    TextEditingController passwordController =
                                        TextEditingController();
                                    showDialog(
                                      context: context,
                                      builder:
                                          (context) => AlertDialog(
                                            title: const Text("Enter Password"),
                                            content: TextField(
                                              controller: passwordController,
                                              obscureText: true,
                                              decoration: const InputDecoration(
                                                hintText: "Password",
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed:
                                                    () => Navigator.pop(
                                                      context,
                                                    ), // Close dialog
                                                child: const Text("Cancel"),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  if (passwordController.text ==
                                                      file['password']) {
                                                    // Password matches, show the image preview
                                                    Navigator.pop(
                                                      context,
                                                    ); // Close password dialog
                                                    showDialog(
                                                      context: context,
                                                      builder:
                                                          (context) => Dialog(
                                                            backgroundColor:
                                                                Colors
                                                                    .transparent,
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    12,
                                                                  ),
                                                              child: InteractiveViewer(
                                                                child: Image.memory(
                                                                  snapshot
                                                                      .data!,
                                                                  fit:
                                                                      BoxFit
                                                                          .contain,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                    );
                                                  } else {
                                                    // Wrong password
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                          "Incorrect password",
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                },
                                                child: const Text("Submit"),
                                              ),
                                            ],
                                          ),
                                    );
                                  }
                                },

                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child:
                                      file['isPrivate'] == false
                                          ? Image.memory(
                                            snapshot.data!,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity,
                                          )
                                          : Stack(
                                            children: [
                                              Image.memory(
                                                snapshot.data!,
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                height: double.infinity,
                                              ),
                                              Positioned.fill(
                                                child: BackdropFilter(
                                                  filter: ImageFilter.blur(
                                                    sigmaX: 5,
                                                    sigmaY: 5,
                                                  ), // adjust blur intensity
                                                  child: Container(
                                                    color: Colors.black.withOpacity(
                                                      0,
                                                    ), // required for BackdropFilter
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                ),
                              ),
                            ),

                            Row(
                              children: [
                                Text(
                                  file['time'],
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                file['isPrivate'] == 0
                                    ? IconButton(
                                      onPressed: () {
                                        FileShareProvider.downloadFileWeb(
                                          snapshot.data!,
                                          file['fileName'],
                                        );
                                      },
                                      icon: Icon(Icons.download_outlined),
                                    )
                                    : IconButton(
                                      onPressed: () {
                                        TextEditingController
                                        passwordController =
                                            TextEditingController();
                                        showDialog(
                                          context: context,
                                          builder:
                                              (context) => AlertDialog(
                                                title: const Text(
                                                  "Enter Password",
                                                ),
                                                content: TextField(
                                                  controller:
                                                      passwordController,
                                                  obscureText: true,
                                                  decoration:
                                                      const InputDecoration(
                                                        hintText: "Password",
                                                      ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed:
                                                        () => Navigator.pop(
                                                          context,
                                                        ), // Close dialog
                                                    child: const Text("Cancel"),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      if (passwordController
                                                              .text ==
                                                          file['password']) {
                                                        // Password matches, show the image preview

                                                        FileShareProvider.downloadFileWeb(
                                                          snapshot.data!,
                                                          file['fileName'],
                                                        );
                                                        Navigator.pop(
                                                          context,
                                                        ); // Close password dialog
                                                        showDialog(
                                                          context: context,
                                                          builder:
                                                              (
                                                                context,
                                                              ) => Dialog(
                                                                backgroundColor:
                                                                    Colors
                                                                        .transparent,
                                                                child: ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        12,
                                                                      ),
                                                                  child: InteractiveViewer(
                                                                    child: Image.memory(
                                                                      snapshot
                                                                          .data!,
                                                                      fit:
                                                                          BoxFit
                                                                              .contain,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                        );
                                                      } else {
                                                        // Wrong password
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          const SnackBar(
                                                            content: Text(
                                                              "Incorrect password",
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                    },
                                                    child: const Text("Submit"),
                                                  ),
                                                ],
                                              ),
                                        );
                                      },
                                      icon: Icon(Icons.download_outlined),
                                    ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),

          floatingActionButton: FloatingActionButton(
            onPressed: () {
              showUploadSheet(
                uploadOnTap: () {
                  fileProvider.uploadFileWeb(
                    selectedFile,
                    _selectedIndex,
                    _passwordController.text.trim(),
                  );
                },
              );
            },
            child: Icon(Icons.add),
          ),
        );
      },
    );
  }

  Future<void> selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      withData: true,
    );

    if (result != null) {
      setState(() {
        selectedFile = result.files.single;
      });
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

  void showUploadSheet({VoidCallback? uploadOnTap}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("File Share"),
                SizedBox(height: 10),
                Divider(),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      width: 200, // full width
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue, // button color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              12,
                            ), // rounded corners
                          ),
                        ),
                        onPressed: selectFile,
                        child: Text(
                          'Select File',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    if (selectedFile != null) ...[
                      SizedBox(height: 10),
                      Text('Selected File: ${selectedFile!.name}'),
                    ],
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Access'),
                        SizedBox(width: 10),
                        ToggleSwitch(
                          minWidth: 90.0,
                          cornerRadius: 20.0,
                          activeBgColors: [
                            [Colors.blue],
                            [Colors.red],
                          ],
                          activeFgColor: Colors.white,
                          inactiveBgColor: Colors.grey[300],
                          inactiveFgColor: Colors.black,
                          initialLabelIndex: _selectedIndex,
                          totalSwitches: 2,
                          labels: ['Public', 'Private'],
                          onToggle: (index) {
                            setState(() {
                              _selectedIndex = index!;
                            });
                            print(
                              'Switched to: ${index == 0 ? 'Public' : 'Private'}',
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 15),
                passwordTextFeild(_passwordController, "Password"),

                if (selectedFile != null) ...[
                  SizedBox(height: 15),
                  Row(
                    children: [
                      Icon(Icons.insert_drive_file, color: Colors.grey),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selectedFile!.name,
                              style: TextStyle(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${(selectedFile!.size / 1024).toStringAsFixed(2)} KB',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],

                SizedBox(height: 10),
                Divider(),
                SizedBox(height: 10),
                SizedBox(
                  width: double.infinity, // full width
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // button color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          12,
                        ), // rounded corners
                      ),
                    ),
                    onPressed: uploadOnTap,
                    child: Text(
                      'Upload',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
    );
  }
}

Widget passwordTextFeild(TextEditingController controller, String hintText) {
  return TextField(
    controller: controller,
    obscureText: true,
    //  disable typing when false
    decoration: InputDecoration(
      hintText: hintText,
      filled: true,
      // fillColor:
      //     enabled ? Colors.grey[100] : Colors.grey[300], // gray if disabled
      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.blue, width: 2),
      ),
      suffixIcon: Icon(Icons.visibility_off, color: Colors.grey),
    ),
  );
}
