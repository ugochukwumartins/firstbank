import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../../shared/ui.dart';

class SignupFooter extends StatefulWidget {
  const SignupFooter({super.key});
  @override
  State<SignupFooter> createState() => _SignupFooterState();
}

class _SignupFooterState extends State<SignupFooter> {
  late final _termsLink = TapGestureRecognizer()
    ..onTap = () => notice(context, 'Terms and Conditions', '');
  late final _policyLink = TapGestureRecognizer()
    ..onTap = () => notice(
      context,
      'Policy',
      'This demo stores profile and invoices on this device. Passwords are not saved. No remote account is created.',
    );
  @override
  void dispose() {
    _termsLink.dispose();
    _policyLink.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Text.rich(
      TextSpan(
        children: [
          const TextSpan(text: 'By signing up you agree to our '),
          TextSpan(
            text: 'Terms and\nConditions',
            style: const TextStyle(
              color: navy,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
              decorationColor: navy,
            ),
            recognizer: _termsLink,
          ),
          const TextSpan(text: ' and '),
          TextSpan(
            text: 'Policy',
            style: const TextStyle(
              color: navy,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
              decorationColor: navy,
            ),
            recognizer: _policyLink,
          ),
        ],
      ),
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 14,
        height: 1.7,
        letterSpacing: 0,
        wordSpacing: 0,
        color: Color(0xff333333),
      ),
    ),
  );
}
