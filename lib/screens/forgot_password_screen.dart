import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/auth.dart';
import '../core/theme.dart';
import '../widgets/app_field.dart';
import '../widgets/common.dart';

/// Identity check -> one-time code -> new password.
/// Pops with the new password so the login screen can pre-fill it.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key, this.initialId = ''});

  final String initialId;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late final TextEditingController _id = TextEditingController(text: widget.initialId);
  final _otp = TextEditingController();
  final _pw = TextEditingController();
  final _pw2 = TextEditingController();

  int _step = 0;
  bool _viaEmail = true;
  bool _busy = false;
  bool _resent = false;
  String? _err;
  String? _err2;

  @override
  void dispose() {
    _id.dispose();
    _otp.dispose();
    _pw.dispose();
    _pw2.dispose();
    super.dispose();
  }

  void _back() {
    if (_step == 0) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _step--;
        _err = null;
        _err2 = null;
      });
    }
  }

  Future<void> _sendCode() async {
    if (_busy) return;
    final id = _id.text.trim();
    if (id.isEmpty) {
      setState(() => _err = 'Enter your email or patient ID');
      return;
    }
    if (!AuthService.matchesIdentity(id)) {
      setState(() => _err = "We couldn't find an account with that email or ID");
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _err = null;
    });
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() {
      _busy = false;
      _step = 1;
      _resent = false;
    });
  }

  void _verify() {
    if (_otp.text.trim() != AuthService.resetOtp) {
      setState(() => _err = 'That code is incorrect. Try again.');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _step = 2;
      _err = null;
    });
  }

  void _save() {
    final a = _pw.text;
    final b = _pw2.text;
    String? e1;
    String? e2;
    if (a.length < 8) e1 = 'Use at least 8 characters';
    if (e1 == null && b != a) e2 = "Passwords don't match";
    if (e1 != null || e2 != null) {
      setState(() {
        _err = e1;
        _err2 = e2;
      });
      return;
    }
    AuthService.setPassword(a);
    Navigator.of(context).pop(a);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE2F3E9), Color(0xFFF5FBF8), Colors.white],
            stops: [0, 0.45, 1],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 24, 0),
                    child: Row(
                      children: [
                        Pressable(
                          onTap: _back,
                          semanticLabel: 'Back',
                          child: const SizedBox(
                            width: 48,
                            height: 48,
                            child: Icon(Icons.arrow_back_rounded, color: AppColors.ink),
                          ),
                        ),
                        const Spacer(),
                        for (var i = 0; i < 3; i++)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOut,
                            margin: const EdgeInsets.only(left: 6),
                            width: i == _step ? 24 : 8,
                            height: 6,
                            decoration: BoxDecoration(
                              color: i <= _step ? AppColors.primary : AppColors.line,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        switchInCurve: Curves.easeOut,
                        child: KeyedSubtree(key: ValueKey(_step), child: _content()),
                      ),
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

  Widget _title(String t, String d) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t, style: appText(30, weight: FontWeight.w800, letterSpacing: -0.8)),
          const SizedBox(height: 8),
          Text(d, style: appText(15, color: AppColors.muted, height: 1.45)),
          const SizedBox(height: 28),
        ],
      );

  Widget _content() {
    switch (_step) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _title('Reset password', "Confirm it's you. We'll send a one-time code."),
            AppField(
              label: 'Email or Patient ID',
              controller: _id,
              icon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
              action: TextInputAction.done,
              errorText: _err,
              onChanged: (_) {
                if (_err != null) setState(() => _err = null);
              },
              onSubmitted: (_) => _sendCode(),
            ),
            const SizedBox(height: 18),
            Text('Send the code by', style: appText(12.5, weight: FontWeight.w700)),
            const SizedBox(height: 8),
            Row(
              children: [
                ChoicePill(label: 'Email', selected: _viaEmail, onTap: () => setState(() => _viaEmail = true)),
                const SizedBox(width: 8),
                ChoicePill(label: 'SMS', selected: !_viaEmail, onTap: () => setState(() => _viaEmail = false)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _viaEmail ? 'e•••••••••@wellness.med' : '••• ••• 4821',
              style: appText(13, color: AppColors.muted),
            ),
            const SizedBox(height: 26),
            PrimaryButton(label: 'Send code', loading: _busy, loadingLabel: 'Sending…', onPressed: _sendCode),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _title('Enter the code', 'We sent a 6-digit code by ${_viaEmail ? 'email' : 'SMS'}. Demo code: ${AuthService.resetOtp}'),
            AppField(
              label: 'Verification code',
              controller: _otp,
              icon: Icons.pin_outlined,
              hint: '••••••',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
              errorText: _err,
              autofocus: true,
              onChanged: (_) {
                if (_err != null) setState(() => _err = null);
              },
              onSubmitted: (_) => _verify(),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: Pressable(
                onTap: () => setState(() => _resent = true),
                semanticLabel: 'Resend code',
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 44),
                  child: Align(
                    widthFactor: 1,
                    child: Text(
                      _resent ? 'New code sent ✓' : 'Resend code',
                      style: appText(13, weight: FontWeight.w700, color: AppColors.primary),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            PrimaryButton(label: 'Verify', onPressed: _verify),
          ],
        );
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _title('New password', 'Choose something at least 8 characters long.'),
            AppField(
              label: 'New password',
              controller: _pw,
              icon: Icons.lock_outline_rounded,
              obscure: true,
              action: TextInputAction.next,
              errorText: _err,
              autofocus: true,
              onChanged: (_) {
                if (_err != null) setState(() => _err = null);
              },
            ),
            const SizedBox(height: 16),
            AppField(
              label: 'Confirm password',
              controller: _pw2,
              icon: Icons.lock_outline_rounded,
              obscure: true,
              action: TextInputAction.done,
              errorText: _err2,
              onChanged: (_) {
                if (_err2 != null) setState(() => _err2 = null);
              },
              onSubmitted: (_) => _save(),
            ),
            const SizedBox(height: 26),
            PrimaryButton(label: 'Save password', onPressed: _save),
          ],
        );
    }
  }
}
