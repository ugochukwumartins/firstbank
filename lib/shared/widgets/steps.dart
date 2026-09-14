// Displays progress through the invoice or profile steps.

import 'package:flutter/material.dart';

class Steps extends StatelessWidget {
  final int current;
  final List<String> labels;
  const Steps({
    super.key,
    required this.current,
    this.labels = const [
      'Invoice\nDetails',
      'Bank\nDetails',
      'Preview\nInvoice',
      'Download\ninvoice/Send\n to client',
    ],
  });
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 24),
    child: Row(
      children: [
        for (var i = 0; i < labels.length; i++) ...[
          Flexible(
            child: Text(
              labels[i],
              style: TextStyle(
                fontSize: 11,
                color: i == current ? Colors.black87 : Colors.grey,
                fontWeight: i == current ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
          SizedBox(width: 5),
          if (i < labels.length - 1)
            const Icon(Icons.chevron_right, size: 18, color: Colors.black),
          if (i == labels.length - 1)
            const Icon(Icons.chevron_right, size: 18, color: Colors.black),
        ],
        SizedBox(width: 5),
        const Icon(Icons.check_circle, color: Color(0xff13c443), size: 20),
      ],
    ),
  );
}
