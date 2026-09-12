import 'package:flutter/material.dart';
import '../../shared/ui.dart';
import '../../shared/validation.dart';
import 'invoice.dart';

/// Displays totals and lets the user enter optional VAT and shipping charges.
class InvoiceSummary extends StatelessWidget {
  final Invoice invoice;
  final TextEditingController vatController;
  final TextEditingController shippingController;
  const InvoiceSummary({
    super.key,
    required this.invoice,
    required this.vatController,
    required this.shippingController,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _total('SubTotal', invoice.subtotal),
      const SizedBox(height: 8),
      _summaryInput(
        'VAT',
        vatController,
        width: 64,
        validator: vatError,
        percent: true,
      ),
      const SizedBox(height: 8),
      _summaryInput(
        'Shipping',
        shippingController,
        width: 104,
        validator: shippingError,
      ),
      const SizedBox(height: 12),
      _total('Total', invoice.total),
    ],
  );

  Widget _summaryInput(
    String label,
    TextEditingController controller, {
    required double width,
    required String? Function(String?) validator,
    bool percent = false,
  }) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(label),
        ),
      ),
      const SizedBox(width: 12),
      SizedBox(
        width: width,
        child: TextFormField(
          key: ValueKey('summary-$label'),
          controller: controller,
          validator: validator,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textAlign: TextAlign.right,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 8,
            ),
            errorMaxLines: 5,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(3)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(3),
              borderSide: const BorderSide(color: Color(0xffe4e4e4), width: 2),
            ),
          ),
        ),
      ),
      if (percent)
        const Padding(
          padding: EdgeInsets.only(left: 4, top: 10),
          child: Text('%'),
        ),
    ],
  );

  Widget _total(String label, int amount) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(label),
      const SizedBox(width: 8),
      Flexible(
        child: Text(
          money(amount, invoice.currency == 'NGN' ? 'N' : invoice.currency),
          textAlign: TextAlign.left,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: amount == 0 ? const Color(0xffb2b2b2) : navy,
          ),
        ),
      ),
    ],
  );
}
