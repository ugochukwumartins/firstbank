import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/store.dart';
import '../../shared/ui.dart';
import 'invoice.dart';
import 'preview.dart';

class InvoiceEditor extends ConsumerStatefulWidget {
  final Invoice? invoice;
  const InvoiceEditor({super.key, this.invoice});
  @override
  ConsumerState<InvoiceEditor> createState() => _InvoiceEditorState();
}

class _InvoiceEditorState extends ConsumerState<InvoiceEditor> {
  final form = GlobalKey<FormState>();
  final number = TextEditingController(),
      client = TextEditingController(),
      sender = TextEditingController(),
      title = TextEditingController(),
      dateText = TextEditingController(),
      vat = TextEditingController(text: '0'),
      shipping = TextEditingController(text: '0'),
      bankNumber = TextEditingController(),
      bankName = TextEditingController(),
      accountName = TextEditingController(),
      terms = TextEditingController();
  final List<_ItemFields> items = [];
  DateTime date = DateTime.now();
  String currency = 'NGN';
  int step = 0;
  bool dirty = false, leaving = false;
  late final String id;
  List<TextEditingController> get controllers => [
    number,
    client,
    sender,
    title,
    dateText,
    vat,
    shipping,
    bankNumber,
    bankName,
    accountName,
    terms,
  ];
  @override
  void initState() {
    super.initState();
    final invoice = widget.invoice;
    id = invoice?.id ?? DateTime.now().microsecondsSinceEpoch.toString();
    number.text =
        invoice?.number ??
        (ref.read(appStoreProvider).invoices.length + 1).toString().padLeft(
          4,
          '0',
        );
    if (invoice != null) {
      client.text = invoice.client;
      sender.text = invoice.sender;
      title.text = invoice.title;
      date = invoice.date;
      currency = invoice.currency;
      vat.text = '${invoice.vat}';
      shipping.text = (invoice.shipping / 100).toStringAsFixed(2);
      bankNumber.text = invoice.bankNumber;
      bankName.text = invoice.bankName;
      accountName.text = invoice.accountName;
      terms.text = invoice.terms;
      items.addAll(invoice.items.map((e) => _ItemFields(e)));
    } else {
      items.add(_ItemFields());
    }
    dateText.text = dateLabel(date);
    for (final c in controllers) {
      c.addListener(changed);
    }
    for (final item in items) {
      item.listen(changed);
    }
  }

  void changed() {
    setState(() => dirty = true);
  }

  @override
  void dispose() {
    for (final c in controllers) {
      c.dispose();
    }
    for (final i in items) {
      i.dispose();
    }
    super.dispose();
  }

  double parse(TextEditingController c) {
    final n = double.tryParse(c.text);
    return n != null && n.isFinite && n >= 0 && n <= 1000000000 ? n : 0;
  }

  Invoice draft() => Invoice(
    id: id,
    number: number.text.trim(),
    client: client.text.trim(),
    sender: sender.text.trim(),
    title: title.text.trim(),
    currency: currency,
    date: date,
    items: items
        .map(
          (i) => InvoiceItem(
            description: i.description.text.trim(),
            quantity: parse(i.quantity),
            unitPrice: (parse(i.price) * 100).round(),
          ),
        )
        .toList(),
    vat: parse(vat),
    shipping: (parse(shipping) * 100).round(),
    bankNumber: bankNumber.text.trim(),
    bankName: bankName.text.trim(),
    accountName: accountName.text.trim(),
    terms: terms.text.trim(),
  );
  bool get validDetails =>
      [
        number,
        client,
        sender,
        title,
      ].every((c) => requiredText(c.text) == null) &&
      items.every(
        (i) =>
            requiredText(i.description.text) == null &&
            positiveNumber(i.quantity.text) == null &&
            nonNegativeNumber(i.price.text) == null,
      ) &&
      nonNegativeNumber(shipping.text) == null &&
      vatError(vat.text) == null;
  String? vatError(String? value) =>
      nonNegativeNumber(value) ??
      ((double.tryParse(value ?? '') ?? 0) > 100 ? 'VAT must be 0–100%' : null);
  bool get validBank => [
    bankNumber,
    bankName,
    accountName,
    terms,
  ].every((c) => requiredText(c.text) == null);
  Future<void> close() async {
    if (step == 1) {
      setState(() => step = 0);
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
      setState(() => leaving = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pop(context);
      });
    }
  }

  Future<void> next() async {
    if (!form.currentState!.validate()) return;
    if (step == 0) {
      setState(() => step = 1);
      return;
    }
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => InvoicePreview(invoice: draft())),
    );
    if (saved == false && mounted) setState(() => step = 0);
    if (saved == true && mounted) {
      setState(() => leaving = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pop(context);
      });
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
          tooltip: step == 0 ? 'Close invoice' : 'Back to invoice details',
          onPressed: close,
          icon: Icon(step == 0 ? Icons.close : Icons.arrow_back),
        ),
      ),
      body: PageBody(
        children: [
          Text(
            step == 0 ? 'New Invoice' : 'Bank Details',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          Steps(current: step),
          Form(
            key: form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: step == 0 ? details() : bank(),
            ),
          ),
          const SizedBox(height: 20),
          ActionButton(
            step == 0 ? 'Next' : 'Preview Invoice',
            onPressed: (step == 0 ? validDetails : validBank) ? next : null,
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
  List<Widget> details() {
    final invoice = draft();
    return [
      SizedBox(
        width: 164,
        child: Field('Invoice Number', number, validator: requiredText),
      ),
      Field(
        'Client’s Name',
        client,
        hint: 'Enter Client’s Name',
        validator: requiredText,
      ),
      Field(
        'Your Name',
        sender,
        hint: 'Enter Your Name',
        validator: requiredText,
      ),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Field(
              'Issuance Date',
              dateText,
              readOnly: true,
              onTap: () async {
                final selected = await showDatePicker(
                  context: context,
                  initialDate: date,
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2200),
                );
                if (selected != null && mounted) {
                  date = selected;
                  dateText.text = dateLabel(date);
                }
              },
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
                  initialValue: currency,
                  items: ['NGN', 'USD', 'GBP', 'EUR']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setState(() {
                        currency = v;
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
        title,
        hint: 'Enter Invoice Title',
        validator: requiredText,
      ),
      for (var index = 0; index < items.length; index++)
        Container(
          key: ObjectKey(items[index]),
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(12),
          color: const Color(0xfff9f9f9),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Field(
                'Item Description',
                items[index].description,
                hint: 'Enter a description',
                validator: requiredText,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Field(
                      'Quantity',
                      items[index].quantity,
                      hint: 'e.g. 2.00',
                      keyboard: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: positiveNumber,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Field(
                      'Price',
                      items[index].price,
                      hint: 'e.g. 3000.00',
                      keyboard: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: nonNegativeNumber,
                    ),
                  ),
                ],
              ),
              const Text('Amount'),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(money(invoice.items[index].total, currency)),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Remove item ${index + 1}',
                    onPressed: items.length == 1
                        ? null
                        : () {
                            final removed = items[index];
                            setState(() {
                              items.removeAt(index);
                              dirty = true;
                            });
                            removed.dispose();
                          },
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
            ],
          ),
        ),
      TextButton(
        onPressed: () {
          final item = _ItemFields()..listen(changed);
          setState(() {
            items.add(item);
            dirty = true;
          });
        },
        child: const Text(
          'Add New Item',
          style: TextStyle(decoration: TextDecoration.underline),
        ),
      ),
      const SizedBox(height: 30),
      _total('Subtotal', money(invoice.subtotal, currency)),
      const SizedBox(height: 12),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Field(
              'VAT (%)',
              vat,
              validator: vatError,
              keyboard: const TextInputType.numberWithOptions(decimal: true),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Field(
              'Shipping',
              shipping,
              validator: nonNegativeNumber,
              keyboard: const TextInputType.numberWithOptions(decimal: true),
            ),
          ),
        ],
      ),
      _total('Total', money(invoice.total, currency)),
    ];
  }

  Widget _total(String label, String value) => Row(
    children: [
      Text(label),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          value,
          textAlign: TextAlign.right,
          style: const TextStyle(fontWeight: FontWeight.w600, color: navy),
        ),
      ),
    ],
  );
  List<Widget> bank() => [
    Field(
      'Bank Number',
      bankNumber,
      hint: 'Enter your Bank Number',
      validator: requiredText,
      keyboard: TextInputType.number,
    ),
    Field(
      'Name of Bank',
      bankName,
      hint: 'Enter your Bank Name',
      validator: requiredText,
    ),
    Field(
      'Name of Account',
      accountName,
      hint: 'Enter the Name on Account',
      validator: requiredText,
    ),
    Field(
      'Terms of Payment',
      terms,
      hint: 'e.g. Payment will be made in installments',
      validator: requiredText,
    ),
  ];
}

class _ItemFields {
  final description = TextEditingController(),
      quantity = TextEditingController(),
      price = TextEditingController();
  _ItemFields([InvoiceItem? item]) {
    if (item != null) {
      description.text = item.description;
      quantity.text = '${item.quantity}';
      price.text = (item.unitPrice / 100).toStringAsFixed(2);
    }
  }
  void listen(VoidCallback callback) {
    description.addListener(callback);
    quantity.addListener(callback);
    price.addListener(callback);
  }

  void dispose() {
    description.dispose();
    quantity.dispose();
    price.dispose();
  }
}
