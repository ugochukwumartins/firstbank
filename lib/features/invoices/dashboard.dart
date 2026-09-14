// Shows invoice history, the create action and the navigation drawer.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/store.dart';
import '../../shared/ui.dart';
import 'invoice.dart';
import 'editor.dart';

class Dashboard extends ConsumerWidget {
  const Dashboard({super.key});
  // Open a blank editor, or populate it with the selected saved invoice.
  void open(BuildContext context, [Invoice? invoice]) => Navigator.push(
    context,
    MaterialPageRoute<void>(builder: (_) => InvoiceEditor(invoice: invoice)),
  );
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(appStoreProvider);
    return Scaffold(
      appBar: AppBar(),
      drawer: Drawer(
        backgroundColor: navy,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
              const Padding(
                padding: EdgeInsets.all(24),
                child: Brand(wordmark: true),
              ),
              for (final entry in [
                (Icons.credit_card, 'Invoices'),
                (Icons.account_box_outlined, 'Profile'),
                (Icons.receipt_long_outlined, 'Receipts'),
                (Icons.settings_outlined, 'Settings'),
              ])
                ListTile(
                  leading: Icon(entry.$1, color: Colors.white),
                  title: Text(
                    entry.$2,
                    style: const TextStyle(color: Colors.white),
                  ),
                  selected: entry.$2 == 'Invoices',
                  selectedTileColor: Colors.white.withValues(alpha: .06),
                  onTap: () {
                    Navigator.pop(context);
                    if (entry.$2 != 'Invoices') {
                      notice(
                        context,
                        entry.$2,
                        entry.$2 == 'Profile'
                            ? (store.accountType.isEmpty
                                  ? 'You skipped profile setup.'
                                  : store.accountType)
                            : 'This section has no supplied design and is outside the assessment flow.',
                      );
                    }
                  },
                ),
              const Spacer(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.white),
                title: const Text(
                  'Log Out',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    await ref.read(appStoreProvider.notifier).logout();
                  } catch (_) {
                    if (context.mounted) showError(context);
                  }
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      body: PageBody(
        children: [
          const Text(
            'Welcome Subomi!',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text('What will you like to do now?'),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _Tile(
                  dark: true,
                  onTap: () => open(context),
                  children: const [
                    Icon(Icons.add, color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Create New Invoice',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 4),
                    Text('Create a quick\nInvoice to send'),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _Tile(
                  onTap: () => showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    builder: (sheetContext) => SafeArea(
                      child: SizedBox(
                        height: MediaQuery.sizeOf(context).height * .65,
                        child: store.invoices.isEmpty
                            ? const Center(child: Text('No saved invoices yet'))
                            : ListView(
                                children: [
                                  const ListTile(title: Text('All invoices')),
                                  for (final invoice in store.invoices)
                                    ListTile(
                                      title: Text(invoice.title),
                                      subtitle: Text(invoice.client),
                                      onTap: () {
                                        Navigator.pop(sheetContext);
                                        open(context, invoice);
                                      },
                                    ),
                                ],
                              ),
                      ),
                    ),
                  ),
                  children: [
                    const Text(
                      'Invoices created',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${store.invoices.length}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Flexible(
                          child: Text(
                            'View All',
                            style: TextStyle(
                              color: Colors.black,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          size: 18,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          const Text(
            'Past Invoices',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          if (store.loadError != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                store.loadError!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          if (store.invoices.isEmpty) ...[
            const SizedBox(height: 28),
            const _EmptyIllustration(),
            const SizedBox(height: 28),
            const Text(
              'You don’t have any Invoice history yet. Click the \n button below to create your first Invoice.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color(0xff333333)),
            ),
          ] else ...[
            const SizedBox(height: 16),
            for (final invoice in store.invoices)
              Card(
                color: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xffe4e4e4)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    invoice.title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '${invoice.client}\n#${invoice.number} · ${dateLabel(invoice.date)}\n${money(invoice.total, invoice.currency)}',
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => open(context, invoice),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final bool dark;
  final List<Widget> children;
  final VoidCallback onTap;
  const _Tile({this.dark = false, required this.children, required this.onTap});
  @override
  Widget build(BuildContext context) => Material(
    color: dark ? navy : const Color(0xffe5eff8),
    borderRadius: BorderRadius.circular(12),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        constraints: const BoxConstraints(minHeight: 124),
        padding: const EdgeInsets.all(12),
        child: DefaultTextStyle.merge(
          style: TextStyle(
            color: dark ? Colors.white : navy,
            fontSize: 14,
            height: 1.4,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ),
    ),
  );
}

class _EmptyIllustration extends StatelessWidget {
  const _EmptyIllustration();
  @override
  Widget build(BuildContext context) => Center(
    child: SizedBox(
      width: 270,
      height: 230,
      child: Stack(
        children: [
          Positioned(
            left: 10,
            top: 0,
            child: Container(
              width: 220,
              height: 220,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xffe2ebfc),
              ),
            ),
          ),
          for (var i = 0; i < 2; i++)
            Positioned(
              left: i == 0 ? 62 : 40,
              top: 48.0 + i * 66,
              child: Container(
                width: 200,
                height: 52,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Color(0xff1685ff),
                      child: Icon(Icons.search, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          height: 8,
                          decoration: BoxDecoration(
                            color: const Color(0xffb3d9ff),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: 74,
                          height: 8,
                          decoration: BoxDecoration(
                            color: const Color(0xffdce8ff),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    ),
  );
}
