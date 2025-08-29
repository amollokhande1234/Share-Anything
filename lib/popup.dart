import 'package:flutter/material.dart';

void showRequiredFieldPopup(BuildContext context, String fieldName) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Required Field"),
        content: Text("$fieldName is required!"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      );
    },
  );
}
