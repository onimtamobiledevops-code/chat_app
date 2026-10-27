import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

/// Second login step: signs in [mobileNumber] once a 4-digit PIN is entered.
class PinScreen extends ConsumerStatefulWidget {
  final String mobileNumber;

  const PinScreen({super.key, required this.mobileNumber});

  @override
  ConsumerState<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends ConsumerState<PinScreen> {
  static const _pinLength = 4;

  final _pin = TextEditingController();

  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _pin.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    setState(() => _error = null);
    if (value.length == _pinLength && !_loading) _submit(value);
  }

  Future<void> _submit(String pin) async {
    setState(() => _loading = true);
    try {
      await ref
          .read(authProvider.notifier)
          .signInWithMobile(widget.mobileNumber, pin);
      // AuthGate has switched to HomeScreen underneath this route.
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      _pin.clear();
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final error = _error;

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lock_outline_rounded,
                        size: 34,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Enter your PIN',
                    textAlign: TextAlign.center,
                    style: textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter the 4-digit PIN for ${widget.mobileNumber}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: context.subtext, fontSize: 15),
                  ),
                  const SizedBox(height: 36),
                  Stack(
                    children: [
                      _PinBoxes(
                        length: _pinLength,
                        filled: _pin.text.length,
                        hasError: error != null,
                      ),
                      // Invisible field on top of the boxes takes the taps
                      // and keyboard input.
                      Positioned.fill(
                        child: Opacity(
                          opacity: 0,
                          child: TextField(
                            controller: _pin,
                            autofocus: true,
                            keyboardType: TextInputType.number,
                            autofillHints: const [AutofillHints.oneTimeCode],
                            showCursor: false,
                            enableInteractiveSelection: false,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(_pinLength),
                            ],
                            onChanged: _onChanged,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 24,
                    child: _loading
                        ? const Center(
                            child: SizedBox.square(
                              dimension: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                              ),
                            ),
                          )
                        : error != null
                        ? Text(
                            error,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton(
                      onPressed: _loading
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: const Text('Change mobile number'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PinBoxes extends StatelessWidget {
  final int length;
  final int filled;
  final bool hasError;

  const _PinBoxes({
    required this.length,
    required this.filled,
    required this.hasError,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < length; i++) ...[
          if (i > 0) const SizedBox(width: 14),
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 58,
            height: 64,
            decoration: BoxDecoration(
              color: context.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                width: 2,
                color: hasError
                    ? scheme.error
                    : i == filled
                    ? scheme.primary
                    : Colors.transparent,
              ),
            ),
            child: i < filled
                ? Center(
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: scheme.onSurface,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                : null,
          ),
        ],
      ],
    );
  }
}
