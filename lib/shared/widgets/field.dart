import 'package:flutter/material.dart';
import '../colors.dart';
import 'package:flutter/services.dart';

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
