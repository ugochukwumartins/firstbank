import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../shared/validation.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
      invoiceNumberError(number.text) == null &&
      nameError(client.text) == null &&
      nameError(sender.text) == null &&
      titleError(title.text) == null &&
      items.isNotEmpty &&
      items.every(
        (i) =>
            descriptionError(i.description.text) == null &&
            positiveNumber(i.quantity.text) == null &&
            nonNegativeNumber(i.price.text) == null,
      ) &&
      shippingError(shipping.text) == null &&
      vatError(vat.text) == null;
  String? shippingError(String? value) =>
      value == null || value.trim().isEmpty ? null : nonNegativeNumber(value);

  String? vatError(String? value) => value == null || value.trim().isEmpty
      ? null
      : nonNegativeNumber(value) ??
            ((double.tryParse(value) ?? 0) > 100 ? 'VAT must be 0–100%' : null);
  bool get validBank =>
      bankNumberError(bankNumber.text) == null &&
      bankNameError(bankName.text) == null &&
      nameError(accountName.text) == null &&
      termsError(terms.text) == null;
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
          icon: Icon(Icons.close),
        ),
      ),
      body: PageBody(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
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
        child: Field('Invoice Number', number, validator: invoiceNumberError),
      ),
      Field(
        'Client’s Name',
        client,
        hint: 'Enter Client’s Name',
        validator: nameError,
      ),
      Field('Your Name', sender, hint: 'Enter Your Name', validator: nameError),
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
        validator: titleError,
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
                validator: descriptionError,
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
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: InputDecorator(
                      decoration: const InputDecoration(),
                      child: Text(
                        money(invoice.items[index].total, '').trim(),
                        style: TextStyle(
                          color: invoice.items[index].total == 0
                              ? const Color(0xffb2b2b2)
                              : const Color(0xff333333),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
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
          style: TextStyle(
            decoration: TextDecoration.underline,
            color: Colors.blue,
            decorationColor: Colors.blue,
          ),
        ),
      ),
      const SizedBox(height: 30),
      _total('SubTotal', invoice.subtotal),
      const SizedBox(height: 8),
      _summaryInput('VAT', vat, width: 64, validator: vatError, percent: true),
      const SizedBox(height: 8),
      _summaryInput('Shipping', shipping, width: 104, validator: shippingError),
      const SizedBox(height: 12),
      _total('Total', invoice.total),
    ];
  }

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
    children: [
      Text(label),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          money(amount, currency == 'NGN' ? 'N' : currency),
          textAlign: TextAlign.right,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: amount == 0 ? const Color(0xffb2b2b2) : navy,
          ),
        ),
      ),
    ],
  );

  List<Widget> bank() => [
    Field(
      'Bank Number',
      bankNumber,
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
      bankName,
      hint: 'Enter your Bank Name',
      validator: bankNameError,
    ),
    Field(
      'Name of Account',
      accountName,
      hint: 'Enter the Name on Account',
      validator: nameError,
    ),
    Field(
      'Terms of Payment',
      terms,
      hint: 'e.g. Payment will be made in installments',
      validator: termsError,
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
