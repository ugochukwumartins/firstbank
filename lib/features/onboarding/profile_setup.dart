// Shows logo upload, account-type selection, Proceed and Skip controls.

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../shared/ui.dart';

/// Profile layout only: upload status, account type and continue/skip actions.
class ProfileSetup extends StatelessWidget {
  final bool hasLogo;
  final bool busy;
  final String accountType;
  final VoidCallback onPickLogo;
  final ValueChanged<String> onAccountTypeChanged;
  final VoidCallback onProceed;
  final VoidCallback onSkip;
  const ProfileSetup({
    super.key,
    required this.hasLogo,
    required this.busy,
    required this.accountType,
    required this.onPickLogo,
    required this.onAccountTypeChanged,
    required this.onProceed,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) => PageBody(
    key: const ValueKey(true),
    children: [
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
          shape: const DashedRectangleBorder(),
          side: const BorderSide(color: blue, width: 2.0),
          padding: const EdgeInsets.all(24),
        ),
        onPressed: busy ? null : onPickLogo,
        child: Column(
          children: [
            if (!hasLogo)
              SvgPicture.asset(
                'assets/icons/upload-logo.svg',
                width: 28,
                height: 28,
                excludeFromSemantics: true,
              )
            else ...[
              const Icon(Icons.check_circle, color: Colors.green, size: 48),
            ],
            const SizedBox(height: 8),
            Text(
              !hasLogo ? 'Drag or select a file' : 'Upload successful',
              style: TextStyle(color: !hasLogo ? Colors.grey : Colors.black87),
            ),
          ],
        ),
      ),
      const SizedBox(height: 8),
      const Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: 'Upload a logo',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w400,
                fontSize: 11,
              ),
            ),
            TextSpan(text: '\nPNG or JPG less than 20mb'),
          ],
        ),
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12, color: Colors.grey),
      ),
      const SizedBox(height: 32),
      const Text('How will you like to use your Lancebox?'),
      const SizedBox(height: 24),
      for (final option in [
        'As a Business Owner',
        'As an Individual/Freelancer',
      ])
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 76),
              foregroundColor: accountType == option
                  ? Colors.white
                  : Colors.black87,
              backgroundColor: accountType == option ? navy : Colors.white,
              side: BorderSide(
                color: accountType == option ? navy : const Color(0xffe4e4e4),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: busy ? null : () => onAccountTypeChanged(option),
            child: Text(option),
          ),
        ),
      const SizedBox(height: 18),
      ActionButton(
        'Proceed',
        busy: busy,
        onPressed: accountType.isEmpty ? null : onProceed,
      ),
      const SizedBox(height: 8),
      TextButton(
        onPressed: busy ? null : onSkip,
        style: TextButton.styleFrom(foregroundColor: blue),
        child: const Text(
          'Skip for now',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
            decorationColor: blue,
          ),
        ),
      ),
    ],
  );
}
