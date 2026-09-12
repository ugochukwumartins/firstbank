import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/store.dart';
import '../../shared/ui.dart';
import '../invoices/invoice.dart';

class Onboarding extends ConsumerStatefulWidget {
  const Onboarding({super.key});
  @override
  ConsumerState<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends ConsumerState<Onboarding> {
  final form = GlobalKey<FormState>();
  final email = TextEditingController(),
      password = TextEditingController(),
      confirmation = TextEditingController();
  bool profile = false, busy = false;
  String type = '';
  Uint8List? logo;
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
    email.dispose();
    password.dispose();
    confirmation.dispose();
    super.dispose();
  }

  Future<void> pickLogo() async {
    setState(() => busy = true);
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['png', 'jpg', 'jpeg'],
      );
      if (file == null) return;
      if (await file.length() >= 20 * 1024 * 1024 ||
          !['png', 'jpg', 'jpeg'].contains(file.extension?.toLowerCase())) {
        if (mounted) {
          showError(context, 'Choose a PNG or JPG smaller than 20 MB.');
        }
        return;
      }
      final codec = await ui.instantiateImageCodec(
        await file.readAsBytes(),
        targetWidth: 512,
      );
      try {
        final frame = await codec.getNextFrame();
        final data = await frame.image.toByteData(
          format: ui.ImageByteFormat.png,
        );
        frame.image.dispose();
        if (data == null) throw StateError('Invalid image');
        if (mounted) setState(() => logo = data.buffer.asUint8List());
      } finally {
        codec.dispose();
      }
    } catch (_) {
      if (mounted) {
        showError(
          context,
          'Could not open that image. Choose a valid PNG or JPG.',
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> finish({bool skip = false}) async {
    setState(() => busy = true);
    try {
      await ref
          .read(appStoreProvider.notifier)
          .completeProfile(skip ? '' : type, skip ? null : logo);
    } catch (_) {
      if (mounted) {
        showError(context, 'Could not save your profile. Please try again.');
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: PageBody(
      key: ValueKey(profile),
      children: profile ? profileWidgets() : signupWidgets(),
    ),
  );
  List<Widget> signupWidgets() => [
    Align(
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          IconButton(
            tooltip: 'Back to sign up',
            onPressed: busy ? null : () => setState(() => profile = false),
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
      key: form,
      child: Column(
        children: [
          Field(
            'Email Address',
            email,
            hint: 'Enter your email address',
            showCompletion: true,
            keyboard: TextInputType.emailAddress,
            validator: (v) =>
                RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v?.trim() ?? '')
                ? null
                : 'Enter a valid email address',
          ),
          Field(
            'Password',
            password,
            hint: 'Enter your password',
            showCompletion: true,
            obscure: true,
            validator: (v) =>
                (v?.length ?? 0) >= 8 ? null : 'Use at least 8 characters',
          ),
          Field(
            'Confirm Password',
            confirmation,
            hint: 'Confirm your password',
            showCompletion: true,
            validationDependencies: [password],
            obscure: true,
            validator: (v) =>
                requiredText(v) ??
                (v == password.text ? null : 'Passwords do not match'),
          ),
        ],
      ),
    ),
    const SizedBox(height: 14),
    ActionButton(
      'Sign Up',
      onPressed: () {
        if (form.currentState!.validate()) {
          FocusScope.of(context).unfocus();
          password.clear();
          confirmation.clear();
          setState(() => profile = true);
        }
      },
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
    Padding(
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
    ),
  ];
  List<Widget> profileWidgets() => [
    const Center(child: Brand()),
    const SizedBox(height: 28),
    const Text(
      'Let’s Get to Know you Better',
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
    ),
    const Steps(current: 0, labels: ['Set Up Profile', 'Personal Details']),
    const SizedBox(height: 12),
    const Text('Upload your logo/personal branding'),
    const SizedBox(height: 24),
    OutlinedButton(
      style: OutlinedButton.styleFrom(
        shape: const RoundedRectangleBorder(),
        padding: const EdgeInsets.all(24),
      ),
      onPressed: busy ? null : pickLogo,
      child: Column(
        children: [
          if (logo == null)
            const Icon(
              Icons.add_photo_alternate_outlined,
              size: 32,
              color: Colors.grey,
            )
          else ...[
            Image.memory(logo!, height: 48),
            const Icon(Icons.check_circle, color: Colors.green),
          ],
          const SizedBox(height: 8),
          Text(logo == null ? 'Select a file' : 'Upload successful'),
        ],
      ),
    ),
    const SizedBox(height: 8),
    const Text(
      'Upload a logo\nPNG or JPG less than 20 MB',
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 12, color: Colors.grey),
    ),
    const SizedBox(height: 32),
    const Text('How will you like to use your Lancebox?'),
    const SizedBox(height: 24),
    for (final option in ['As a Business Owner', 'As an Individual/Freelancer'])
      Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 76),
            foregroundColor: type == option ? Colors.white : Colors.black87,
            backgroundColor: type == option ? navy : Colors.white,
            side: BorderSide(
              color: type == option ? navy : const Color(0xffe4e4e4),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: busy ? null : () => setState(() => type = option),
          child: Text(option),
        ),
      ),
    const SizedBox(height: 18),
    ActionButton(
      'Proceed',
      busy: busy,
      onPressed: type.isEmpty ? null : () => finish(),
    ),
    const SizedBox(height: 8),
    TextButton(
      onPressed: busy ? null : () => finish(skip: true),
      child: const Text('Skip for now'),
    ),
  ];
}
