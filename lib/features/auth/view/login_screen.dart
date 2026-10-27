import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/models.dart';
import '../../../shared/widgets/app_logo.dart';
import '../../../shared/widgets/avatar.dart';
import '../providers/auth_provider.dart';
import 'selfie_verification_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _membershipNumber = TextEditingController();
  final _mobileNumber = TextEditingController();
  final _remarks = TextEditingController();

  CountryCode _country = CountryCode.sriLanka;
  bool _isSigningUp = false;
  bool _loading = false;
  bool _verifyingSelfie = false;
  String? _error;
  Uint8List? _photoBytes;

  @override
  void dispose() {
    _name.dispose();
    _membershipNumber.dispose();
    _mobileNumber.dispose();
    _remarks.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    if (_isSigningUp && _photoBytes == null) {
      setState(() => _error = 'Please take a selfie to continue.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final mobileNumber = _fullMobileNumber;
      if (_isSigningUp) {
        await ref
            .read(authProvider.notifier)
            .signUp(
              SignUpRequest(
                name: _name.text,
                membershipNumber: _membershipNumber.text,
                mobileNumber: mobileNumber,
                remarks: _remarks.text,
                photoBytes: _photoBytes,
              ),
            );
      } else {
        await ref.read(authProvider.notifier).signInWithMobile(mobileNumber);
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String get _fullMobileNumber {
    final digits = _mobileNumber.text.replaceAll(RegExp(r'\D'), '');
    final nationalNumber = digits.replaceFirst(RegExp(r'^0+'), '');
    return '${_country.dialCode}$nationalNumber';
  }

  String? _validateMobileNumber(String? value) {
    final digits = value?.replaceAll(RegExp(r'\D'), '') ?? '';
    if (digits.isEmpty) return 'Please enter your mobile number';
    if (digits.length < 6 || digits.length > 15) {
      return 'Enter a valid mobile number';
    }
    return null;
  }

  Future<void> _chooseCountry() async {
    final country = await showModalBottomSheet<CountryCode>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => const _CountryPickerSheet(),
    );
    if (country != null && mounted) {
      setState(() => _country = country);
    }
  }

  Future<void> _pickPhoto() async {
    setState(() {
      _verifyingSelfie = true;
      _error = null;
    });
    try {
      final photoBytes = await Navigator.of(context).push<Uint8List>(
        MaterialPageRoute(builder: (_) => const SelfieVerificationScreen()),
      );
      if (photoBytes != null && mounted) {
        setState(() {
          _photoBytes = photoBytes;
          _error = null;
        });
      }
    } finally {
      if (mounted) setState(() => _verifyingSelfie = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!_isSigningUp) ...[
                      const Center(child: _Logo()),
                      const SizedBox(height: 28),
                    ],
                    Text(
                      _isSigningUp ? 'Join ChatWBee' : 'Welcome back 👋',
                      textAlign: TextAlign.center,
                      style: textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isSigningUp
                          ? 'Create your member account'
                          : 'Log in to your account',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: context.subtext, fontSize: 15),
                    ),
                    const SizedBox(height: 36),
                    if (_isSigningUp) ...[
                      Center(
                        child: Column(
                          children: [
                            if (_photoBytes == null)
                              Container(
                                width: 88,
                                height: 88,
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.person_outline_rounded,
                                  size: 42,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              )
                            else
                              Avatar(
                                user: User(
                                  id: 'signup-photo',
                                  name: _name.text.isEmpty
                                      ? 'New Member'
                                      : _name.text,
                                  photoBytes: _photoBytes,
                                ),
                                size: 88,
                                showOnline: false,
                              ),
                            TextButton.icon(
                              onPressed: _verifyingSelfie ? null : _pickPhoto,
                              icon: _verifyingSelfie
                                  ? const SizedBox.square(
                                      dimension: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.face_retouching_natural),
                              label: Text(
                                _verifyingSelfie
                                    ? 'Opening verification...'
                                    : _photoBytes == null
                                    ? 'Start face verification'
                                    : 'Verify again',
                              ),
                            ),
                            Text(
                              _photoBytes == null
                                  ? 'Follow the camera prompts: look ahead, turn left and right, look up and down, then blink.'
                                  : 'Face-direction steps completed. This does not guarantee protection from every spoofing attempt.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: context.subtext,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      const _FieldLabel('Full name'),
                      TextFormField(
                        controller: _name,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          hintText: 'Your full name',
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Please enter your name'
                            : null,
                      ),
                      const SizedBox(height: 18),
                      const _FieldLabel('Membership number'),
                      TextFormField(
                        controller: _membershipNumber,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          hintText: 'Enter your membership number',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Please enter your membership number'
                            : null,
                      ),
                      const SizedBox(height: 18),
                    ],
                    const _FieldLabel('Mobile number'),
                    _MobileNumberField(
                      controller: _mobileNumber,
                      country: _country,
                      onChooseCountry: _chooseCountry,
                      onSubmitted: (_) => _submit(),
                      validator: _validateMobileNumber,
                    ),
                    if (_isSigningUp) ...[
                      const SizedBox(height: 18),
                      const _FieldLabel('Remarks (optional)'),
                      TextFormField(
                        controller: _remarks,
                        minLines: 2,
                        maxLines: 4,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          hintText: 'Anything else you would like us to know?',
                          prefixIcon: Icon(Icons.notes_rounded),
                          alignLabelWithHint: true,
                        ),
                      ),
                    ],
                    if (_error != null) ...[
                      _ErrorBanner(message: _error!),
                      const SizedBox(height: 12),
                    ],
                    const SizedBox(height: 8),
                    _PrimaryButton(
                      label: _isSigningUp ? 'Create account' : 'Continue',
                      loading: _loading,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 28),
                    Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        Text(
                          _isSigningUp
                              ? 'Already have an account? '
                              : "Don't have an account? ",
                          style: TextStyle(color: context.subtext),
                        ),
                        GestureDetector(
                          onTap: _loading
                              ? null
                              : () => setState(() {
                                  _isSigningUp = !_isSigningUp;
                                  _error = null;
                                }),
                          child: Text(
                            _isSigningUp ? 'Login' : 'Sign up',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CountryCode {
  final String name;
  final String flag;
  final String dialCode;

  const CountryCode({
    required this.name,
    required this.flag,
    required this.dialCode,
  });

  static const sriLanka = CountryCode(
    name: 'Sri Lanka',
    flag: '🇱🇰',
    dialCode: '+94',
  );

  static const values = [
    sriLanka,
    CountryCode(name: 'India', flag: '🇮🇳', dialCode: '+91'),
    CountryCode(name: 'United States', flag: '🇺🇸', dialCode: '+1'),
    CountryCode(name: 'United Kingdom', flag: '🇬🇧', dialCode: '+44'),
    CountryCode(name: 'Australia', flag: '🇦🇺', dialCode: '+61'),
    CountryCode(name: 'Canada', flag: '🇨🇦', dialCode: '+1'),
    CountryCode(name: 'United Arab Emirates', flag: '🇦🇪', dialCode: '+971'),
    CountryCode(name: 'Qatar', flag: '🇶🇦', dialCode: '+974'),
    CountryCode(name: 'Saudi Arabia', flag: '🇸🇦', dialCode: '+966'),
    CountryCode(name: 'Singapore', flag: '🇸🇬', dialCode: '+65'),
    CountryCode(name: 'Malaysia', flag: '🇲🇾', dialCode: '+60'),
    CountryCode(name: 'Japan', flag: '🇯🇵', dialCode: '+81'),
    CountryCode(name: 'Germany', flag: '🇩🇪', dialCode: '+49'),
    CountryCode(name: 'France', flag: '🇫🇷', dialCode: '+33'),
    CountryCode(name: 'Italy', flag: '🇮🇹', dialCode: '+39'),
    CountryCode(name: 'New Zealand', flag: '🇳🇿', dialCode: '+64'),
    CountryCode(name: 'South Africa', flag: '🇿🇦', dialCode: '+27'),
    CountryCode(name: 'Pakistan', flag: '🇵🇰', dialCode: '+92'),
    CountryCode(name: 'Bangladesh', flag: '🇧🇩', dialCode: '+880'),
    CountryCode(name: 'Nepal', flag: '🇳🇵', dialCode: '+977'),
  ];
}

class _MobileNumberField extends StatelessWidget {
  final TextEditingController controller;
  final CountryCode country;
  final VoidCallback onChooseCountry;
  final ValueChanged<String> onSubmitted;
  final FormFieldValidator<String> validator;

  const _MobileNumberField({
    required this.controller,
    required this.country,
    required this.onChooseCountry,
    required this.onSubmitted,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.done,
      autofillHints: const [AutofillHints.telephoneNumber],
      onFieldSubmitted: onSubmitted,
      validator: validator,
      decoration: InputDecoration(
        hintText: 'Mobile number',
        prefixIconConstraints: const BoxConstraints(
          minWidth: 112,
          minHeight: 56,
        ),
        prefixIcon: InkWell(
          onTap: onChooseCountry,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.only(left: 14, right: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(country.flag, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 5),
                Text(
                  country.dialCode,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Icon(Icons.arrow_drop_down_rounded),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CountryPickerSheet extends StatefulWidget {
  const _CountryPickerSheet();

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();
    final countries = CountryCode.values
        .where(
          (country) =>
              country.name.toLowerCase().contains(query) ||
              country.dialCode.contains(query),
        )
        .toList();

    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.75,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Text(
                'Choose country code',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
                decoration: const InputDecoration(
                  hintText: 'Search country or code',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: countries.length,
                itemBuilder: (context, index) {
                  final country = countries[index];
                  return ListTile(
                    leading: Text(
                      country.flag,
                      style: const TextStyle(fontSize: 24),
                    ),
                    title: Text(country.name),
                    trailing: Text(
                      country.dialCode,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    onTap: () => Navigator.of(context).pop(country),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return const AppLogo(markSize: 92, showName: true);
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback onPressed;

  const _PrimaryButton({
    required this.label,
    required this.loading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Color.lerp(
              Theme.of(context).colorScheme.primary,
              Colors.black,
              0.22,
            )!,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          backgroundColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(label),
      ),
    );
  }
}
