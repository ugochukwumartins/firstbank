// Lays out the on-screen invoice: parties, items, totals and payment details.

import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../shared/ui.dart';
import 'invoice.dart';

/// Compact invoice layout matching the supplied preview, with wrapping text.
class InvoiceDocument extends StatelessWidget {
  final Invoice invoice;
  final Uint8List? logo;
  const InvoiceDocument({super.key, required this.invoice, this.logo});

  String get currencyLabel =>
      invoice.currency == 'NGN' ? 'N' : invoice.currency;
  String amount(int value) => money(value, '').trim();

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 486),
    padding: const EdgeInsets.fromLTRB(13, 24, 13, 40),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color(0xffe4e4e4)),
      borderRadius: BorderRadius.circular(4),
      boxShadow: const [
        BoxShadow(
          color: Color(0x09000000),
          blurRadius: 6,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: DefaultTextStyle.merge(
      style: const TextStyle(
        fontSize: 11,
        height: 1.4,
        color: Color(0xff333333),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (logo != null)
                Image.memory(logo!, width: 26, height: 26, fit: BoxFit.contain)
              else
                const CircleAvatar(
                  radius: 13,
                  backgroundColor: Color(0xffd9d9d9),
                ),
              const SizedBox(width: 9),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: 'Invoice No. '),
                      TextSpan(
                        text: '#${invoice.number}',
                        style: const TextStyle(
                          color: navy,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _columns(
            _info('Bill To:', invoice.client),
            _info('From:', invoice.sender),
          ),
          const SizedBox(height: 18),
          _columns(
            _info('Invoice Title', invoice.title),
            _info('Issuance date', dateLabel(invoice.date)),
          ),
          const SizedBox(height: 18),
          const Divider(height: 1, thickness: .5, color: Color(0xffdddddd)),
          const SizedBox(height: 10),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(3.3),
              1: FlexColumnWidth(1.2),
              2: FlexColumnWidth(2.8),
              3: FlexColumnWidth(2.8),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              TableRow(
                children: [
                  _cell('Description', header: true),
                  _cell('Qty', header: true),
                  _cell('Unit Price($currencyLabel)', header: true),
                  _cell('Amount($currencyLabel)', header: true),
                ],
              ),
              for (var i = 0; i < invoice.items.length; i++)
                TableRow(
                  decoration: BoxDecoration(
                    color: i.isEven ? const Color(0xffedf6ff) : Colors.white,
                  ),
                  children: [
                    _cell(invoice.items[i].description),
                    _cell(invoice.items[i].quantity.toStringAsFixed(2)),
                    _cell(amount(invoice.items[i].unitPrice)),
                    _cell(amount(invoice.items[i].total)),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: .75,
              child: Column(
                children: [
                  _total('Subtotal:', invoice.subtotal),
                  _total('Tax:', invoice.tax),
                  _total('Shipping:', invoice.shipping),
                  const Divider(
                    height: 8,
                    thickness: .5,
                    color: Color(0xffdddddd),
                  ),
                  _total('Total:', invoice.total, bold: true),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          const Divider(height: 1, thickness: .5, color: Color(0xffdddddd)),
          const SizedBox(height: 16),
          _columns(
            _info('Terms Of Payment', invoice.terms),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Payment Details',
                  style: TextStyle(color: Color(0xffb2b2b2)),
                ),
                const SizedBox(height: 3),
                _bankLine('Bank Number:', invoice.bankNumber),
                _bankLine('Bank Name:', invoice.bankName),
                _bankLine('Account Name:', invoice.accountName),
              ],
            ),
            leftFlex: 3,
            rightFlex: 2,
          ),
        ],
      ),
    ),
  );

  // Place related information side by side within the available width.
  Widget _columns(
    Widget left,
    Widget right, {
    int leftFlex = 2,
    int rightFlex = 1,
  }) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(flex: leftFlex, child: left),
      const SizedBox(width: 12),
      Expanded(flex: rightFlex, child: right),
    ],
  );

  // Display a muted label above its value.
  Widget _info(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: Color(0xffb2b2b2))),
      const SizedBox(height: 3),
      Text(
        value,
        style: const TextStyle(color: navy, fontWeight: FontWeight.w600),
      ),
    ],
  );

  // Apply consistent padding and text styling to an invoice-table cell.
  Widget _cell(String text, {bool header = false}) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 6),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 10,
        color: header ? navy : Colors.black87,
        fontWeight: header ? FontWeight.w600 : FontWeight.normal,
      ),
    ),
  );

  // Keep each total label and its amount together on one row.
  Widget _total(String label, int value, {bool bold = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          maxLines: 1,
          softWrap: false,
          style: TextStyle(
            fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              money(value, currencyLabel),
              maxLines: 1,
              softWrap: false,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: bold ? navy : null,
                fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
              ),
            ),
          ),
        ),
      ],
    ),
  );

  // Emphasize the label while keeping the bank value on the same text line.
  Widget _bankLine(String label, String value) => Text.rich(
    TextSpan(
      style: const TextStyle(color: navy),
      children: [
        TextSpan(
          text: '$label ',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        TextSpan(text: value),
      ],
    ),
  );
}
