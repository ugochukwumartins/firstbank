import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../shared/validation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/store.dart';
import '../../shared/ui.dart';
import 'invoice.dart';
import 'preview.dart';
import 'invoice_form_data.dart';
import 'invoice_item_editor.dart';
import 'invoice_summary.dart';

enum InvoiceStep { details, bank }

class InvoiceEditor extends ConsumerStatefulWidget {
  final Invoice? invoice;
  const InvoiceEditor({super.key, this.invoice});
  @override
  ConsumerState<InvoiceEditor> createState() => _InvoiceEditorState();
}

class _InvoiceEditorState extends ConsumerState<InvoiceEditor> {
  final form = GlobalKey<FormState>();
  late final InvoiceFormData formData;
  InvoiceStep step = InvoiceStep.details;
  bool dirty = false;
  bool leaving = false;

  @override
  void initState() {
    super.initState();
    final savedInvoices = ref.read(appStoreProvider).invoices;
    formData = InvoiceFormData(
      invoice: widget.invoice,
      nextInvoiceNumber: savedInvoices.length + 1,
    );
    formData.addListeners(markAsChanged);
  }

  void markAsChanged() {
    setState(() => dirty = true);
  }

  @override
  void dispose() {
    formData.dispose();
    super.dispose();
  }

  Future<void> selectDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: formData.date,
      firstDate: DateTime(1900),
      lastDate: DateTime(2200),
    );
    if (selectedDate == null || !mounted) return;
    formData.date = selectedDate;
    formData.dateText.text = dateLabel(selectedDate);
  }

  void addItem() {
    final item = InvoiceItemInputs();
    item.addListeners(markAsChanged);
    setState(() {
      formData.items.add(item);
      dirty = true;
    });
  }

  void removeItem(int index) {
    final removedItem = formData.items[index];
    setState(() {
      formData.items.removeAt(index);
      dirty = true;
    });
    removedItem.dispose();
  }

  // PopScope must rebuild before this screen is allowed to close.
  void leaveEditor() {
    setState(() => leaving = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.pop(context);
    });
  }

  Future<void> close() async {
    if (step == InvoiceStep.bank) {
      setState(() => step = InvoiceStep.details);
      return;
    }
    final discard =
        !dirty ||
        await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Discard changes?'),
                content: const Text('Your unsaved changes will be lost.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Keep editing'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Discard'),
                  ),
                ],
              ),
            ) ==
            true;
    if (discard && mounted) {
      leaveEditor();
    }
  }

  Future<void> goToNextStep() async {
    if (!form.currentState!.validate()) return;
    if (step == InvoiceStep.details) {
      setState(() => step = InvoiceStep.bank);
      return;
    }
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => InvoicePreview(invoice: formData.toInvoice()),
      ),
    );
    if (saved == false && mounted) setState(() => step = InvoiceStep.details);
    if (saved == true && mounted) {
      leaveEditor();
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: leaving,
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop) close();
    },
    child: Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: step == InvoiceStep.details
              ? 'Close invoice'
              : 'Back to invoice details',
          onPressed: close,
          icon: Icon(Icons.close),
        ),
      ),
      body: PageBody(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        children: [
          Text(
            step == InvoiceStep.details ? 'New Invoice' : 'Bank Details',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          Steps(current: step.index),
          Form(
            key: form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: step == InvoiceStep.details
                  ? buildInvoiceFields()
                  : buildBankFields(),
            ),
          ),
          const SizedBox(height: 20),
          ActionButton(
            step == InvoiceStep.details ? 'Next' : 'Preview Invoice',
            onPressed:
                (step == InvoiceStep.details
                    ? formData.hasValidInvoiceDetails
                    : formData.hasValidBankDetails)
                ? goToNextStep
                : null,
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
  List<Widget> buildInvoiceFields() {
    final invoice = formData.toInvoice();
    return [
      SizedBox(
        width: 164,
        child: Field(
          'Invoice Number',
          formData.number,
          validator: invoiceNumberError,
        ),
      ),
      Field(
        'Client’s Name',
        formData.client,
        hint: 'Enter Client’s Name',
        validator: nameError,
      ),
      Field(
        'Your Name',
        formData.sender,
        hint: 'Enter Your Name',
        validator: nameError,
      ),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Field(
              'Issuance Date',
              formData.dateText,
              readOnly: true,
              onTap: selectDate,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Currency'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: formData.currency,
                  items: ['NGN', 'USD', 'GBP', 'EUR']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setState(() {
                        formData.currency = v;
                        dirty = true;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      const Text(
        'Invoice Details',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 20),
      Field(
        'Invoice Title',
        formData.title,
        hint: 'Enter Invoice Title',
        validator: titleError,
      ),
      for (var index = 0; index < formData.items.length; index++)
        InvoiceItemEditor(
          key: ObjectKey(formData.items[index]),
          fields: formData.items[index],
          index: index,
          amount: invoice.items[index].total,
          onRemove: () => removeItem(index),
        ),
      TextButton(
        onPressed: addItem,
        child: const Text(
          'Add New Item',
          style: TextStyle(
            decoration: TextDecoration.underline,
            color: Colors.blue,
            decorationColor: Colors.blue,
          ),
        ),
      ),
      const SizedBox(height: 30),
      InvoiceSummary(
        invoice: invoice,
        vatController: formData.vat,
        shippingController: formData.shipping,
      ),
    ];
  }

  List<Widget> buildBankFields() => [
    Field(
      'Bank Number',
      formData.bankNumber,
      hint: 'Enter your Bank Number',
      validator: bankNumberError,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      keyboard: TextInputType.number,
    ),
    Field(
      'Name of Bank',
      formData.bankName,
      hint: 'Enter your Bank Name',
      validator: bankNameError,
    ),
    Field(
      'Name of Account',
      formData.accountName,
      hint: 'Enter the Name on Account',
      validator: nameError,
    ),
    Field(
      'Terms of Payment',
      formData.terms,
      hint: 'e.g. Payment will be made in installments',
      validator: termsError,
    ),
  ];
}
