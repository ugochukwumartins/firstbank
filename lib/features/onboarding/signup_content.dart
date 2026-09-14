// Lays out sign-up fields and social buttons; the parent handles actions.

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../shared/ui.dart';
import '../../shared/validation.dart';
import 'signup_footer.dart';

/// The signup design. The parent screen decides what happens when submitted.
class SignupContent extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController email;
  final TextEditingController password;
  final TextEditingController confirmation;
  final bool busy;
  final VoidCallback onSignUp;
  final VoidCallback onBack;
  const SignupContent({
    super.key,
    required this.formKey,
    required this.email,
    required this.password,
    required this.confirmation,
    required this.busy,
    required this.onSignUp,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) => PageBody(
    key: const ValueKey(false),
    children: [
      Align(
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            IconButton(
              tooltip: 'Back to sign up',
              onPressed: busy ? null : onBack,
              icon: const Icon(Icons.arrow_back),
            ),
            const Text(
              'Back',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
      const SizedBox(height: 40),
      const Center(child: Brand()),
      const SizedBox(height: 28),
      const Text(
        'Looks like you’re new here!',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 8),
      const Text('Let’s create your account', textAlign: TextAlign.center),

      const SizedBox(height: 32),
      Form(
        key: formKey,
        child: Column(
          children: [
            Field(
              'Email Address',
              email,
              hint: 'Enter your email address',
              showCompletion: true,
              readOnly: busy,
              keyboard: TextInputType.emailAddress,
              validator: emailError,
            ),
            Field(
              'Password',
              password,
              hint: 'Enter your password',
              showCompletion: true,
              readOnly: busy,
              obscure: true,
              validator: passwordError,
            ),
            Field(
              'Confirm Password',
              confirmation,
              hint: 'Confirm your password',
              showCompletion: true,
              readOnly: busy,
              validationDependencies: [password],
              obscure: true,
              validator: (v) => confirmationError(v, password.text),
            ),
          ],
        ),
      ),
      const SizedBox(height: 14),
      ActionButton(
        busy ? 'Signing Up' : 'Sign Up',
        busy: busy,
        onPressed: onSignUp,
      ),
      const SizedBox(height: 12),
      const Text(
        'Or',
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (final provider in ['Google', 'Facebook'])
            Padding(
              padding: const EdgeInsets.all(8),
              child: Semantics(
                button: true,
                label: 'Sign in with $provider',
                child: Tooltip(
                  message: 'Sign in with $provider',
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => notice(
                      context,
                      '$provider sign-in',
                      'Social sign-in is not connected in this local demonstration.',
                    ),
                    child: SvgPicture.asset(
                      'assets/icons/${provider.toLowerCase()}.svg',
                      width: 48,
                      height: 48,
                      excludeFromSemantics: true,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      const SizedBox(height: 42),
      const SignupFooter(),
    ],
  );
}
