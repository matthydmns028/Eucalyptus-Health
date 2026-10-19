import 'package:flutter/material.dart';

import '../core/auth.dart';
import '../core/models.dart';
import '../core/routes.dart';
import '../core/theme.dart';
import '../widgets/app_field.dart';
import '../widgets/common.dart';
import '../widgets/sheets.dart';
import 'forgot_password_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Pre-filled with the demo account so a demo is one tap away.
  final _idCtrl = TextEditingController(text: AuthService.demoEmail);
  final _pwCtrl = TextEditingController(text: AuthService.demoPassword);
  final _pwFocus = FocusNode();

  bool _obscure = true;
  bool _remember = true;
  bool _busy = false;
  bool _faceBusy = false;
  String? _idError;
  String? _pwError;
  String? _formError;

  @override
  void dispose() {
    _idCtrl.dispose();
    _pwCtrl.dispose();
    _pwFocus.dispose();
    super.dispose();
  }

  void _enter(Patient patient) {
    Navigator.of(context).pushReplacement(softRoute(HomeScreen(patient: patient)));
  }

  Future<void> _submit() async {
    if (_busy || _faceBusy) return;
    FocusScope.of(context).unfocus();
    final id = _idCtrl.text.trim();
    final pw = _pwCtrl.text;
    setState(() {
      _idError = id.isEmpty ? 'Enter your email or patient ID' : null;
      _pwError = pw.isEmpty ? 'Enter your password' : null;
      _formError = null;
    });
    if (_idError != null || _pwError != null) return;

    setState(() => _busy = true);
    final patient = await AuthService.signIn(id, pw);
    if (!mounted) return;
    if (patient == null) {
      setState(() {
        _busy = false;
        _formError = "That email/ID and password don't match. Try the demo account below.";
      });
      return;
    }
    _enter(patient);
  }

  Future<void> _faceSignIn() async {
    if (_busy || _faceBusy) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _faceBusy = true;
      _formError = null;
    });
    final patient = await AuthService.signInWithFace();
    if (!mounted) return;
    _enter(patient);
  }

  void _fillDemo() {
    setState(() {
      _idCtrl.text = AuthService.demoEmail;
      _pwCtrl.text = AuthService.demoPassword;
      _idError = null;
      _pwError = null;
      _formError = null;
    });
  }

  Future<void> _forgot() async {
    final newPassword = await Navigator.of(context).push<String>(
      softRoute(ForgotPasswordScreen(initialId: _idCtrl.text)),
    );
    if (newPassword != null && mounted) {
      setState(() {
        _pwCtrl.text = newPassword;
        _pwError = null;
        _formError = null;
      });
      showAppSnack(context, 'Password updated. Sign in with your new password.');
    }
  }

  Future<void> _sso(String provider) async {
    final ok = await showSsoSheet(
      context,
      provider: provider,
      name: AuthService.demoPatient.fullName,
      email: AuthService.demoEmail,
    );
    if (ok == true && mounted) _enter(AuthService.demoPatient);
  }

  void _createAccount() {
    showComingSoon(
      context,
      icon: Icons.person_add_alt_1_rounded,
      title: 'New patient registration',
      description: 'Create your account, verify your identity and set up your care team. This onboarding flow is a separate screen.',
    );
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Reveal(index: 0, child: _brand()),
                    const SizedBox(height: 28),
                    Reveal(index: 1, child: _form()),
                    const SizedBox(height: 24),
                    Reveal(index: 2, child: _alternatives()),
                    const SizedBox(height: 22),
                    Reveal(index: 3, child: _demoHint()),
                    const SizedBox(height: 18),
                    Reveal(index: 4, child: _footer()),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _brand() {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFFDCE9E1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.eco_rounded, size: 32, color: AppColors.primary),
        ),
        const SizedBox(height: 14),
        Text.rich(
          TextSpan(
            style: appText(18, weight: FontWeight.w700),
            children: const [
              TextSpan(text: 'Eucalyptus'),
              TextSpan(text: ' Health', style: TextStyle(color: AppColors.primary)),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Text(
          'Welcome back',
          textAlign: TextAlign.center,
          style: appText(34, weight: FontWeight.w800, letterSpacing: -0.9),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to your Eucalyptus Health account.',
          textAlign: TextAlign.center,
          style: appText(15, color: AppColors.muted),
        ),
      ],
    );
  }

  Widget _form() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppField(
          label: 'Email or Patient ID',
          controller: _idCtrl,
          icon: Icons.mail_outline_rounded,
          hint: 'name@example.com or PT-00000',
          keyboardType: TextInputType.emailAddress,
          action: TextInputAction.next,
          errorText: _idError,
          onChanged: (_) {
            if (_idError != null || _formError != null) {
              setState(() {
                _idError = null;
                _formError = null;
              });
            }
          },
          onSubmitted: (_) => _pwFocus.requestFocus(),
        ),
        const SizedBox(height: 16),
        AppField(
          label: 'Password',
          controller: _pwCtrl,
          focusNode: _pwFocus,
          icon: Icons.lock_outline_rounded,
          hint: 'Enter your password',
          obscure: _obscure,
          action: TextInputAction.done,
          errorText: _pwError,
          onChanged: (_) {
            if (_pwError != null || _formError != null) {
              setState(() {
                _pwError = null;
                _formError = null;
              });
            }
          },
          onSubmitted: (_) => _submit(),
          suffix: Pressable(
            onTap: () => setState(() => _obscure = !_obscure),
            semanticLabel: _obscure ? 'Show password' : 'Hide password',
            child: SizedBox(
              width: 44,
              height: 44,
              child: Icon(
                _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                size: 20,
                color: AppColors.muted,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _RememberToggle(
              value: _remember,
              onChanged: (v) => setState(() => _remember = v),
            ),
            Pressable(
              onTap: _forgot,
              semanticLabel: 'Forgot password',
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 44),
                child: Align(
                  widthFactor: 1,
                  child: Text('Forgot password?', style: appText(13, weight: FontWeight.w700)),
                ),
              ),
            ),
          ],
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          alignment: Alignment.topCenter,
          child: _formError == null
              ? const SizedBox(width: double.infinity)
              : Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 14, top: 2),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.dangerSoft,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.error_outline_rounded, size: 18, color: AppColors.danger),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _formError!,
                          style: appText(13, weight: FontWeight.w600, color: AppColors.danger, height: 1.35),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: PrimaryButton(
                label: 'Sign In',
                icon: Icons.arrow_forward_rounded,
                loading: _busy,
                loadingLabel: 'Signing in…',
                onPressed: _faceBusy ? null : _submit,
              ),
            ),
            const SizedBox(width: 12),
            Pressable(
              onTap: _busy ? null : _faceSignIn,
              semanticLabel: 'Sign in with face recognition (demo)',
              child: Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.line),
                ),
                child: _faceBusy
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.primary),
                      )
                    : const Icon(Icons.face_rounded, size: 26, color: AppColors.primary),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _alternatives() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(child: Divider(color: AppColors.line, height: 1)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('OR', style: appText(12, weight: FontWeight.w600, color: AppColors.muted, letterSpacing: 0.8)),
            ),
            const Expanded(child: Divider(color: AppColors.line, height: 1)),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _SocialButton(
                label: 'Apple',
                leading: const Icon(Icons.apple, size: 22, color: Colors.black),
                onTap: () => _sso('Apple'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SocialButton(
                label: 'Google',
                leading: const _GoogleG(),
                onTap: () => _sso('Google'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Center(
          child: Text.rich(
            TextSpan(
              style: appText(14, color: AppColors.muted),
              children: [
                const TextSpan(text: "Don't have an account? "),
                WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: Pressable(
                    onTap: _createAccount,
                    semanticLabel: 'Create an account',
                    child: Text('Create an Account', style: appText(14, weight: FontWeight.w700, color: AppColors.primary)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _demoHint() {
    return Pressable(
      onTap: _fillDemo,
      semanticLabel: 'Fill in demo account credentials',
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.mintSoft,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.mint),
        ),
        child: Row(
          children: [
            const Icon(Icons.science_outlined, size: 20, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Demo account · tap to fill', style: appText(12.5, weight: FontWeight.w800, color: AppColors.primary)),
                  const SizedBox(height: 2),
                  Text(
                    '${AuthService.demoEmail}\nPassword: ${AuthService.demoPassword}',
                    style: appText(12, color: AppColors.muted, height: 1.45),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _footer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.verified_user_outlined, size: 14, color: AppColors.muted),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            'Protected under 256-bit encryption & HIPAA directives',
            textAlign: TextAlign.center,
            style: appText(11.5, color: AppColors.muted),
          ),
        ),
      ],
    );
  }
}

class _RememberToggle extends StatelessWidget {
  const _RememberToggle({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: value,
      child: Pressable(
        onTap: () => onChanged(!value),
        semanticLabel: 'Remember me',
        scale: 0.96,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                width: 36,
                height: 20,
                padding: const EdgeInsets.all(3),
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                decoration: BoxDecoration(
                  color: value ? AppColors.primary : const Color(0xFFCBD7D0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                ),
              ),
              const SizedBox(width: 10),
              Text('Remember me', style: appText(13, weight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.label, required this.leading, required this.onTap});

  final String label;
  final Widget leading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      semanticLabel: 'Continue with $label',
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            leading,
            const SizedBox(width: 10),
            Text(label, style: appText(14.5, weight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _GoogleG extends StatelessWidget {
  const _GoogleG();

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (rect) => const SweepGradient(
        colors: [
          Color(0xFF4285F4),
          Color(0xFF34A853),
          Color(0xFFFBBC05),
          Color(0xFFEA4335),
          Color(0xFF4285F4),
        ],
      ).createShader(rect),
      blendMode: BlendMode.srcIn,
      child: Text('G', style: appText(21, weight: FontWeight.w800, color: Colors.white)),
    );
  }
}
