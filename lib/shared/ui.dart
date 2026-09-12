import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const navy = Color(0xff103d66);
const blue = Color(0xff50a7ff);

class DashedRectangleBorder extends OutlinedBorder {
  const DashedRectangleBorder({super.side});

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.width);

  @override
  DashedRectangleBorder copyWith({BorderSide? side}) =>
      DashedRectangleBorder(side: side ?? this.side);

  @override
  ShapeBorder scale(double t) => DashedRectangleBorder(side: side.scale(t));

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      Path()..addRect(rect);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      Path()..addRect(rect.deflate(side.width));

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side.style == BorderStyle.none || rect.isEmpty) return;
    final path = Path()..addRect(rect.deflate(side.width / 2));
    final paint = side.toPaint();
    for (final metric in path.computeMetrics()) {
      for (double offset = 0; offset < metric.length; offset += 16) {
        final end = (offset + 10).clamp(0.0, metric.length).toDouble();
        canvas.drawPath(metric.extractPath(offset, end), paint);
      }
    }
  }
}

class Brand extends StatelessWidget {
  final bool wordmark;
  const Brand({super.key, this.wordmark = false});
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: blue,
          borderRadius: BorderRadius.circular(14),
        ),
        child: CustomPaint(painter: _Mark()),
      ),
      if (wordmark)
        const Padding(
          padding: EdgeInsets.only(left: 7),
          child: Text(
            'Lancebox',
            style: TextStyle(
              color: blue,
              fontSize: 26,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
    ],
  );
}

/// Full-screen transition matching the supplied loading-state design.
class BrandLoading extends StatelessWidget {
  const BrandLoading({super.key});

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: Colors.white,
    child: Center(
      child: Semantics(
        label: 'Loading, please wait',
        child: SizedBox(
          width: 114,
          height: 114,
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Positioned.fill(
                child: CircularProgressIndicator(color: blue, strokeWidth: 1.5),
              ),
              Transform.scale(scale: 1.55, child: const Brand()),
            ],
          ),
        ),
      ),
    ),
  );
}

class _Mark extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Path()
      ..moveTo(6, 18)
      ..lineTo(19, 12)
      ..lineTo(17, 22)
      ..lineTo(5, 27)
      ..close();
    canvas.drawPath(p, Paint()..color = navy);
    final q = Path()
      ..moveTo(19, 12)
      ..lineTo(27, 24)
      ..lineTo(36, 20)
      ..lineTo(34, 29)
      ..lineTo(24, 33)
      ..lineTo(17, 22)
      ..close();
    canvas.drawPath(q, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ActionButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool busy, outlined;
  const ActionButton(
    this.text, {
    super.key,
    this.onPressed,
    this.busy = false,
    this.outlined = false,
  });
  @override
  Widget build(BuildContext context) {
    final child = busy
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 12),
              Text(text),
            ],
          )
        : Text(text);
    return SizedBox(
      width: double.infinity,
      child: outlined
          ? OutlinedButton(onPressed: busy ? null : onPressed, child: child)
          : FilledButton(onPressed: busy ? null : onPressed, child: child),
    );
  }
}

class Field extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final String? Function(String?)? validator;
  final TextInputType? keyboard;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscure, readOnly, showCompletion;
  final List<TextEditingController> validationDependencies;
  final VoidCallback? onTap;
  const Field(
    this.label,
    this.controller, {
    super.key,
    this.hint,
    this.validator,
    this.keyboard,
    this.inputFormatters,
    this.obscure = false,
    this.readOnly = false,
    this.onTap,
    this.showCompletion = false,
    this.validationDependencies = const [],
  });
  @override
  State<Field> createState() => _FieldState();
}

class _FieldState extends State<Field> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label),
        const SizedBox(height: 8),
        ListenableBuilder(
          listenable: Listenable.merge([
            _focusNode,
            widget.controller,
            ...widget.validationDependencies,
          ]),
          builder: (context, _) => TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            onTapOutside: (_) => _focusNode.unfocus(),
            validator: widget.validator,
            keyboardType: widget.keyboard,
            inputFormatters: widget.inputFormatters,
            obscureText: widget.obscure,
            readOnly: widget.readOnly,
            onTap: widget.onTap,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
              hintText: widget.hint,
              errorMaxLines: 3,
              suffixIcon:
                  widget.showCompletion &&
                      !_focusNode.hasFocus &&
                      widget.controller.text.trim().isNotEmpty &&
                      widget.validator != null &&
                      widget.validator!(widget.controller.text) == null
                  ? Icon(
                      Icons.check,
                      color: navy,
                      semanticLabel: '${widget.label} valid',
                    )
                  : null,
            ),
          ),
        ),
      ],
    ),
  );
}

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

class Steps extends StatelessWidget {
  final int current;
  final List<String> labels;
  const Steps({
    super.key,
    required this.current,
    this.labels = const [
      'Invoice\nDetails',
      'Bank\nDetails',
      'Preview\nInvoice',
      'Download\ninvoice/Send\n to client',
    ],
  });
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 24),
    child: Row(
      children: [
        for (var i = 0; i < labels.length; i++) ...[
          Flexible(
            child: Text(
              labels[i],
              style: TextStyle(
                fontSize: 11,
                color: i == current ? Colors.black87 : Colors.grey,
                fontWeight: i == current ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
          SizedBox(width: 5),
          if (i < labels.length - 1)
            const Icon(Icons.chevron_right, size: 18, color: Colors.black),
          if (i == labels.length - 1)
            const Icon(Icons.chevron_right, size: 18, color: Colors.black),
        ],
        SizedBox(width: 5),
        const Icon(Icons.check_circle, color: Color(0xff13c443), size: 20),
      ],
    ),
  );
}

void showError(
  BuildContext context, [
  String message = 'Something went wrong. Please try again.',
]) => ScaffoldMessenger.of(
  context,
).showSnackBar(SnackBar(content: Text(message)));
Future<void> notice(
  BuildContext context,
  String title,
  String message, {
  bool success = false,
}) => showDialog<void>(
  context: context,
  builder: (context) => AlertDialog(
    icon: success ? const Icon(Icons.check_circle, color: Colors.green) : null,
    title: Text(title),
    content: Text(message, textAlign: TextAlign.center),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Done'),
      ),
    ],
  ),
);
