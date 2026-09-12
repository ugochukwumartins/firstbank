import 'package:pdf/pdf.dart';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'invoice.dart';

Future<Uint8List> invoicePdf(Invoice invoice, Uint8List? logo) async {
  final regular = pw.Font.ttf(
    await rootBundle.load('assets/fonts/Pretendard-Regular.ttf'),
  );
  final bold = pw.Font.ttf(
    await rootBundle.load('assets/fonts/Pretendard-Bold.ttf'),
  );
  final document = pw.Document(
    theme: pw.ThemeData.withFont(base: regular, bold: bold),
  );
  document.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(36),
      build: (_) => [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Lancebox',
              style: pw.TextStyle(
                fontSize: 26,
                color: PdfColors.blue900,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            if (logo != null)
              pw.Image(pw.MemoryImage(logo), width: 48, height: 48),
          ],
        ),
        pw.SizedBox(height: 24),
        pw.Text(
          'Invoice #${invoice.number}',
          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 20),
        pw.Text('Bill to: ${invoice.client}'),
        pw.Text('From: ${invoice.sender}'),
        pw.Text('Title: ${invoice.title}'),
        pw.Text('Issuance date: ${dateLabel(invoice.date)}'),
        pw.SizedBox(height: 24),
        pw.TableHelper.fromTextArray(
          headers: [
            'Description',
            'Qty',
            'Unit price (${invoice.currency})',
            'Amount (${invoice.currency})',
          ],
          data: invoice.items
              .map(
                (i) => [
                  i.description,
                  '${i.quantity}',
                  money(i.unitPrice, ''),
                  money(i.total, ''),
                ],
              )
              .toList(),
          headerStyle: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue900,
          ),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.blue50),
          cellStyle: const pw.TextStyle(fontSize: 10),
          cellPadding: const pw.EdgeInsets.all(8),
        ),
        pw.SizedBox(height: 24),
        for (final row in [
          ('Subtotal', invoice.subtotal),
          ('VAT (${invoice.vat}%)', invoice.tax),
          ('Shipping', invoice.shipping),
          ('Total', invoice.total),
        ])
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 8),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Text('${row.$1}:  '),
                pw.Text(money(row.$2, invoice.currency)),
              ],
            ),
          ),
        pw.Divider(),
        pw.SizedBox(height: 16),
        pw.Text('Terms of payment: ${invoice.terms}'),
        pw.SizedBox(height: 16),
        pw.Text('Bank number: ${invoice.bankNumber}'),
        pw.Text('Bank name: ${invoice.bankName}'),
        pw.Text('Account name: ${invoice.accountName}'),
      ],
    ),
  );
  return document.save();
}
