// Keeps page content inside safe screen areas and makes long content scroll.

import 'package:flutter/material.dart';

class PageBody extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry padding;
  const PageBody({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.all(24),
  });
  @override
  Widget build(BuildContext context) => SafeArea(
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: ListView(padding: padding, children: children),
      ),
    ),
  );
}
