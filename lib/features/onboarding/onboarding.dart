import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/store.dart';
import '../../shared/ui.dart';
import 'logo_picker.dart';
import 'profile_setup.dart';
import 'signup_content.dart';

enum OnboardingStage { signup, loading, profile }

class Onboarding extends ConsumerStatefulWidget {
  const Onboarding({super.key});
  @override
  ConsumerState<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends ConsumerState<Onboarding> {
  final formKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmation = TextEditingController();
  OnboardingStage stage = OnboardingStage.signup;
  bool busy = false;
  String accountType = '';
  Uint8List? logo;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    confirmation.dispose();
    super.dispose();
  }

  Future<void> signUp() async {
    if (busy || !formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => busy = true);
    // These delays are intentional: button spinner, then the branded loader.
    await Future<void>.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    setState(() => stage = OnboardingStage.loading);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    password.clear();
    confirmation.clear();
    setState(() {
      busy = false;
      stage = OnboardingStage.profile;
    });
  }

  Future<void> selectLogo() async {
    setState(() => busy = true);
    try {
      final selectedLogo = await pickProfileLogo();
      if (selectedLogo != null && mounted) {
        setState(() => logo = selectedLogo);
      }
    } on FormatException catch (error) {
      if (mounted) showError(context, error.message);
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

  Future<void> completeProfile({bool skip = false}) async {
    setState(() => busy = true);
    try {
      await ref
          .read(appStoreProvider.notifier)
          .completeProfile(skip ? '' : accountType, skip ? null : logo);
    } catch (_) {
      if (mounted) {
        showError(context, 'Could not save your profile. Please try again.');
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(body: buildCurrentStage());

  Widget buildCurrentStage() {
    switch (stage) {
      case OnboardingStage.loading:
        return const BrandLoading();
      case OnboardingStage.profile:
        return ProfileSetup(
          hasLogo: logo != null,
          busy: busy,
          accountType: accountType,
          onPickLogo: selectLogo,
          onAccountTypeChanged: (value) => setState(() => accountType = value),
          onProceed: () => completeProfile(),
          onSkip: () => completeProfile(skip: true),
        );
      case OnboardingStage.signup:
        return SignupContent(
          formKey: formKey,
          email: email,
          password: password,
          confirmation: confirmation,
          busy: busy,
          onSignUp: signUp,
          onBack: () => setState(() => stage = OnboardingStage.signup),
        );
    }
  }
}
