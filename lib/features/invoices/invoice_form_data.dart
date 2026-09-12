import 'package:flutter/material.dart';
import '../../shared/validation.dart';
import 'invoice.dart';

/// Values being edited on one screen. They are saved to Riverpod only on save.
/// This class owns its controllers so they can be disposed together.
class InvoiceFormData {
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
  final List<InvoiceItemInputs> items = [];
  DateTime date = DateTime.now();
  String currency = 'NGN';
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

  InvoiceFormData({Invoice? invoice, required int nextInvoiceNumber}) {
    id = invoice?.id ?? DateTime.now().microsecondsSinceEpoch.toString();
    number.text =
        invoice?.number ?? nextInvoiceNumber.toString().padLeft(4, '0');
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
      items.addAll(invoice.items.map((item) => InvoiceItemInputs(item)));
    } else {
      items.add(InvoiceItemInputs());
    }
    dateText.text = dateLabel(date);
  }

  void addListeners(VoidCallback onChanged) {
    for (final controller in controllers) {
      controller.addListener(onChanged);
    }
    for (final item in items) {
      item.addListeners(onChanged);
    }
  }

  void dispose() {
    for (final controller in controllers) {
      controller.dispose();
    }
    for (final item in items) {
      item.dispose();
    }
  }

  double parse(TextEditingController controller) {
    final value = double.tryParse(controller.text);
    if (value == null || !value.isFinite || value < 0 || value > 1000000000) {
      return 0;
    }
    return value;
  }

  Invoice toInvoice() => Invoice(
    id: id,
    number: number.text.trim(),
    client: client.text.trim(),
    sender: sender.text.trim(),
    title: title.text.trim(),
    currency: currency,
    date: date,
    items: items
        .map(
          (item) => InvoiceItem(
            description: item.description.text.trim(),
            quantity: parse(item.quantity),
            unitPrice: (parse(item.price) * 100).round(),
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
  bool get hasValidInvoiceDetails =>
      invoiceNumberError(number.text) == null &&
      nameError(client.text) == null &&
      nameError(sender.text) == null &&
      titleError(title.text) == null &&
      items.isNotEmpty &&
      items.every(
        (item) =>
            descriptionError(item.description.text) == null &&
            positiveNumber(item.quantity.text) == null &&
            nonNegativeNumber(item.price.text) == null,
      ) &&
      shippingError(shipping.text) == null &&
      vatError(vat.text) == null;
  bool get hasValidBankDetails =>
      bankNumberError(bankNumber.text) == null &&
      bankNameError(bankName.text) == null &&
      nameError(accountName.text) == null &&
      termsError(terms.text) == null;
}

/// The three editable values in one invoice line.
class InvoiceItemInputs {
  final description = TextEditingController(),
      quantity = TextEditingController(),
      price = TextEditingController();
  InvoiceItemInputs([InvoiceItem? item]) {
    if (item != null) {
      description.text = item.description;
      quantity.text = '${item.quantity}';
      price.text = (item.unitPrice / 100).toStringAsFixed(2);
    }
  }
  void addListeners(VoidCallback callback) {
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
