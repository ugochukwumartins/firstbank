import 'package:flutter/material.dart';

void showError(
  BuildContext context, [
  String message = 'Something went wrong. Please try again.',
]) => ScaffoldMessenger.of(
  context,
).showSnackBar(SnackBar(content: Text(message)));
Future<void> notice(
  BuildContext context,
  String title,
  String message, {
  bool success = false,
}) => showDialog<void>(
  context: context,
  builder: (context) => AlertDialog(
    icon: success ? const Icon(Icons.check_circle, color: Colors.green) : null,
    title: Text(title),
    content: Text(message, textAlign: TextAlign.center),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Done'),
      ),
    ],
  ),
);
