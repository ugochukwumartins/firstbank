// Uses one button layout for normal, outlined, disabled and loading actions.

import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool busy, outlined;
  const ActionButton(
    this.text, {
    super.key,
    this.onPressed,
    this.busy = false,
    this.outlined = false,
  });
  @override
  Widget build(BuildContext context) {
    final child = busy
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 12),
              Text(text),
            ],
          )
        : Text(text);
    return SizedBox(
      width: double.infinity,
      child: outlined
          ? OutlinedButton(onPressed: busy ? null : onPressed, child: child)
          : FilledButton(onPressed: busy ? null : onPressed, child: child),
    );
  }
}
