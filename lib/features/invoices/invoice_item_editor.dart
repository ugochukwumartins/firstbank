// Displays one editable item and sends deletion requests to its parent.

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../shared/ui.dart';
import '../../shared/validation.dart';
import 'invoice.dart';
import 'invoice_form_data.dart';

/// One editable invoice line: description, quantity, price and calculated amount.
class InvoiceItemEditor extends StatelessWidget {
  final InvoiceItemInputs fields;
  final int index;
  final int amount;
  final VoidCallback onRemove;
  const InvoiceItemEditor({
    super.key,
    required this.fields,
    required this.index,
    required this.amount,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(12),
    color: const Color(0xfff9f9f9),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Field(
          'Item Description',
          fields.description,
          hint: 'Enter a description',
          validator: descriptionError,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Field(
                'Quantity',
                fields.quantity,
                hint: 'e.g. 2.00',
                keyboard: const TextInputType.numberWithOptions(decimal: true),
                validator: positiveNumber,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Field(
                'Price',
                fields.price,
                hint: 'e.g. 3000.00',
                keyboard: const TextInputType.numberWithOptions(decimal: true),
                validator: nonNegativeNumber,
              ),
            ),
          ],
        ),
        const Text('Amount'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: InputDecorator(
                decoration: const InputDecoration(),
                child: Text(
                  money(amount, '').trim(),
                  style: TextStyle(
                    color: amount == 0
                        ? const Color(0xffb2b2b2)
                        : const Color(0xff333333),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 24),
            IconButton(
              tooltip: 'Remove item ${index + 1}',
              onPressed: onRemove,
              icon: SvgPicture.asset(
                'assets/icons/delete-item.svg',
                width: 36,
                height: 36,
                excludeFromSemantics: true,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
