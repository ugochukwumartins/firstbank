import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../app/store.dart';
import '../../shared/ui.dart';
import 'invoice.dart';
import 'export.dart';

class InvoicePreview extends ConsumerStatefulWidget {
  final Invoice invoice;
  const InvoicePreview({super.key, required this.invoice});
  @override
  ConsumerState<InvoicePreview> createState() => _InvoicePreviewState();
}

class _InvoicePreviewState extends ConsumerState<InvoicePreview> {
  bool busy = false;
  Invoice get invoice => widget.invoice;
  String get filename =>
      'invoice-${invoice.number.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_')}.pdf';
  Future<void> export({bool share = false}) async {
    final box = context.findRenderObject() as RenderBox?;
    final origin = box == null
        ? null
        : box.localToGlobal(Offset.zero) & box.size;
    setState(() => busy = true);
    try {
      final bytes = await invoicePdf(invoice, ref.read(appStoreProvider).logo);
      if (share) {
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile.fromData(bytes, mimeType: 'application/pdf')],
            fileNameOverrides: [filename],
            subject: 'Invoice #${invoice.number} — ${invoice.title}',
            text: 'Please find your invoice attached.',
            sharePositionOrigin: origin,
          ),
        );
      } else {
        final path = await FilePicker.saveFile(
          dialogTitle: 'Download invoice',
          fileName: filename,
          mimeType: 'application/pdf',
          type: FileType.custom,
          allowedExtensions: ['pdf'],
          bytes: bytes,
        );
        if (path == null && !kIsWeb) return;
        if (mounted) {
          await notice(
            context,
            kIsWeb ? 'Download Started' : 'Download Successful',
            kIsWeb
                ? 'Your browser is downloading the invoice PDF.'
                : 'Your invoice was downloaded successfully.',
            success: true,
          );
        }
      }
    } catch (_) {
      if (mounted) {
        showError(context, 'Could not export the invoice. Please try again.');
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> save() async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Invoice'),
        content: const Text(
          'Would you like to save your invoice to be able to edit it later?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
    if (yes != true || !mounted) return;
    setState(() => busy = true);
    try {
      await ref.read(appStoreProvider.notifier).save(invoice);
      if (!mounted) return;
      setState(() => busy = false);
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          icon: const Icon(Icons.check_circle, color: Colors.green),
          title: const Text('Success'),
          content: const Text(
            'Your invoice was saved successfully. Go to Dashboard to view.',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      );
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (mounted) {
        showError(context, 'Could not save your invoice. Please try again.');
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !busy,
    child: Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back to bank details',
          onPressed: busy ? null : () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: PageBody(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Preview',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                ),
              ),
              TextButton(
                onPressed: busy ? null : () => Navigator.pop(context, false),
                child: const Text(
                  'Edit Invoice',
                  style: TextStyle(decoration: TextDecoration.underline),
                ),
              ),
            ],
          ),
          const Steps(current: 2),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xffe4e4e4)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (ref.watch(
                          appStoreProvider.select((state) => state.logo),
                        ) !=
                        null)
                      Image.memory(
                        ref.read(appStoreProvider).logo!,
                        width: 40,
                        height: 40,
                      )
                    else
                      const CircleAvatar(backgroundColor: Color(0xffdddddd)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Invoice No. #${invoice.number}',
                        style: const TextStyle(
                          color: navy,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: info('Bill To:', invoice.client)),
                    const SizedBox(width: 16),
                    Expanded(child: info('From:', invoice.sender)),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: info('Invoice Title', invoice.title)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: info('Issuance date', dateLabel(invoice.date)),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    horizontalMargin: 8,
                    columnSpacing: 18,
                    headingTextStyle: const TextStyle(
                      color: navy,
                      fontWeight: FontWeight.w600,
                    ),
                    columns: [
                      const DataColumn(label: Text('Description')),
                      const DataColumn(label: Text('Qty'), numeric: true),
                      DataColumn(
                        label: Text('Unit Price\n(${invoice.currency})'),
                        numeric: true,
                      ),
                      DataColumn(
                        label: Text('Amount\n(${invoice.currency})'),
                        numeric: true,
                      ),
                    ],
                    rows: [
                      for (var i = 0; i < invoice.items.length; i++)
                        DataRow(
                          color: WidgetStatePropertyAll(
                            i.isEven ? const Color(0xffedf6ff) : Colors.white,
                          ),
                          cells: [
                            DataCell(
                              SizedBox(
                                width: 110,
                                child: Text(invoice.items[i].description),
                              ),
                            ),
                            DataCell(Text('${invoice.items[i].quantity}')),
                            DataCell(
                              Text(money(invoice.items[i].unitPrice, '')),
                            ),
                            DataCell(Text(money(invoice.items[i].total, ''))),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                for (final row in [
                  ('Subtotal', invoice.subtotal),
                  ('Tax', invoice.tax),
                  ('Shipping', invoice.shipping),
                  ('Total', invoice.total),
                ])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Text(row.$1),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            money(row.$2, invoice.currency),
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: navy,
                              fontWeight: row.$1 == 'Total'
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const Divider(),
                const SizedBox(height: 16),
                info('Terms Of Payment', invoice.terms),
                info(
                  'Payment Details',
                  'Bank Number: ${invoice.bankNumber}\nBank Name: ${invoice.bankName}\nAccount Name: ${invoice.accountName}',
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          ActionButton('Download Pdf', busy: busy, onPressed: () => export()),
          const SizedBox(height: 12),
          ActionButton(
            'Send To Client Email',
            outlined: true,
            onPressed: busy ? null : () => export(share: true),
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose your email app from the share menu and enter the recipient.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ActionButton(
            'Save Invoice',
            outlined: true,
            onPressed: busy ? null : save,
          ),
        ],
      ),
    ),
  );
  Widget info(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(color: navy, fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}
