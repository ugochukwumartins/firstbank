// Shows brief errors, information messages and the designed success modal.

import 'package:flutter/material.dart';
import 'colors.dart';

/// The compact success modal used after downloading or saving an invoice.
class SuccessDialog extends StatelessWidget {
  const SuccessDialog({
    super.key,
    required this.title,
    required this.message,
    this.buttonLabel = 'Done',
  });

  final String title;
  final String message;
  final String buttonLabel;

  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.transparent,
    insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 342),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 30, 24, 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 24,
                  color: Color(0xff0dcc40),
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.25,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff111111),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: Color(0xff333333),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: SizedBox(
                    width: 200,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: blue,
                        foregroundColor: navy,
                        minimumSize: const Size(200, 40),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        shape: const StadiumBorder(),
                        textStyle: TextStyle(
                          fontSize: buttonLabel == 'Done' ? 14 : 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(buttonLabel),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 12,
            top: 12,
            child: IconButton(
              tooltip: 'Close',
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, size: 18, color: Color(0xff333333)),
            ),
          ),
        ],
      ),
    ),
  );
}

// Show a short error message at the bottom of the current screen.
void showError(
  BuildContext context, [
  String message = 'Something went wrong. Please try again.',
]) => ScaffoldMessenger.of(
  context,
).showSnackBar(SnackBar(content: Text(message)));
// Choose the designed success modal or a plain informational dialog.
Future<void> notice(
  BuildContext context,
  String title,
  String message, {
  bool success = false,
}) => showDialog<void>(
  context: context,
  builder: (context) => success
      ? SuccessDialog(title: title, message: message)
      : AlertDialog(
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
