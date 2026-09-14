// Defines invoice data, calculates totals and converts values for storage/display.

// One billed service or product. Unit price is stored in minor units (100 = 1.00).
class InvoiceItem {
  final String description;
  final double quantity;
  final int unitPrice;
  const InvoiceItem({
    required this.description,
    required this.quantity,
    required this.unitPrice,
  });
  int get total => (quantity * unitPrice).round();
  // Convert this object to named values that can be stored as JSON.
  Map<String, dynamic> toJson() => {
    'description': description,
    'quantity': quantity,
    'unitPrice': unitPrice,
  };
  // Recreate an item from its saved values.
  factory InvoiceItem.fromJson(Map<String, dynamic> j) => InvoiceItem(
    description: j['description'] as String,
    quantity: (j['quantity'] as num).toDouble(),
    unitPrice: j['unitPrice'] as int,
  );
}

// A complete invoice shared by the editor, preview, local storage and PDF.
class Invoice {
  final String id,
      number,
      client,
      sender,
      title,
      currency,
      bankNumber,
      bankName,
      accountName,
      terms;
  final DateTime date;
  final List<InvoiceItem> items;
  final double vat;
  final int shipping;
  Invoice({
    required this.id,
    required this.number,
    required this.client,
    required this.sender,
    required this.title,
    required this.currency,
    required this.date,
    required List<InvoiceItem> items,
    required this.vat,
    required this.shipping,
    required this.bankNumber,
    required this.bankName,
    required this.accountName,
    required this.terms,
  }) : items = List.unmodifiable(items);
  // Add the rounded totals of all invoice lines.
  int get subtotal => items.fold(0, (sum, item) => sum + item.total);
  // Apply the VAT percentage to the subtotal and round to a minor unit.
  int get tax => (subtotal * vat / 100).round();
  // The final amount includes the subtotal, tax and shipping.
  int get total => subtotal + tax + shipping;
  // Convert this object to named values that can be stored as JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'number': number,
    'client': client,
    'sender': sender,
    'title': title,
    'currency': currency,
    'date': date.toIso8601String(),
    'items': items.map((e) => e.toJson()).toList(),
    'vat': vat,
    'shipping': shipping,
    'bankNumber': bankNumber,
    'bankName': bankName,
    'accountName': accountName,
    'terms': terms,
  };
  // Recreate a saved invoice, including its date and item objects.
  factory Invoice.fromJson(Map<String, dynamic> j) => Invoice(
    id: j['id'] as String,
    number: j['number'] as String,
    client: j['client'] as String,
    sender: j['sender'] as String,
    title: j['title'] as String,
    currency: j['currency'] as String,
    date: DateTime.parse(j['date'] as String),
    items: (j['items'] as List)
        .map((e) => InvoiceItem.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList(),
    vat: (j['vat'] as num).toDouble(),
    shipping: j['shipping'] as int,
    bankNumber: j['bankNumber'] as String,
    bankName: j['bankName'] as String,
    accountName: j['accountName'] as String,
    terms: j['terms'] as String,
  );
}

// Convert minor units to a readable amount with grouping and two decimal places.
String money(int minor, [String currency = 'NGN']) {
  final parts = (minor / 100).toStringAsFixed(2).split('.');
  final whole = parts[0].replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  );
  return '$currency $whole.${parts[1]}';
}

// Format the date as day/month/year with two-digit days and months.
String dateLabel(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
// Reject missing or whitespace-only text.
String? requiredText(String? value) =>
    value == null || value.trim().isEmpty ? 'This field is required' : null;
// Allow ordinary decimals greater than zero, capped at one billion.
String? positiveNumber(String? value) {
  if (!RegExp(r'^\d+(?:\.\d{1,2})?$').hasMatch(value?.trim() ?? '')) {
    return 'Enter a number with up to 2 decimal places';
  }
  final n = double.tryParse(value!.trim());
  return n == null || !n.isFinite || n <= 0 || n > 1000000000
      ? 'Enter a number greater than 0 (up to 1 billion)'
      : null;
}

// Use the same decimal format for prices and charges, allowing zero.
String? nonNegativeNumber(String? value) {
  if (!RegExp(r'^\d+(?:\.\d{1,2})?$').hasMatch(value?.trim() ?? '')) {
    return 'Enter a number with up to 2 decimal places';
  }
  final n = double.tryParse(value!.trim());
  return n == null || !n.isFinite || n < 0 || n > 1000000000
      ? 'Enter a number from 0 to 1 billion'
      : null;
}
