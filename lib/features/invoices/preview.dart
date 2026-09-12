import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../app/store.dart';
import '../../shared/ui.dart';
import 'invoice.dart';
import 'export.dart';
import 'invoice_document.dart';

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
          icon: const Icon(Icons.close),
        ),
      ),
      body: PageBody(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Preview',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  foregroundColor: blue,
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
                  ),
                ),
                onPressed: busy ? null : () => Navigator.pop(context, false),
                child: const Text(
                  'Edit Invoice',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: blue,
                    decorationColor: blue,
                  ),
                ),
              ),
            ],
          ),
          const Steps(current: 2),
          InvoiceDocument(
            invoice: invoice,
            logo: ref.watch(appStoreProvider.select((state) => state.logo)),
          ),
          const SizedBox(height: 40),
          ActionButton('Download Pdf', busy: busy, onPressed: () => export()),
          const SizedBox(height: 12),
          ActionButton(
            'Send To Client Email',
            outlined: true,
            onPressed: busy ? null : () => export(share: true),
          ),
         
        ],
      ),
    ),
  );
}
