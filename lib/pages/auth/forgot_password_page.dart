import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/api/api_service.dart';
import '../onboarding/onboarding_flow.dart';

/// Two-step password recovery:
///   1. Enter the account email → request a reset code.
///   2. Enter the code + a new password → reset and sign in.
///
/// Login is by email (there's no separate username), so "forgot username"
/// reduces to "use the email you signed up with" — called out in the UI copy.
class ForgotPasswordPage extends StatefulWidget {
  /// Optional email to prefill (e.g. whatever the user typed on the login
  /// screen), so they don't have to retype it.
  final String? initialEmail;
  const ForgotPasswordPage({super.key, this.initialEmail});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  // false → step 1 (request code); true → step 2 (enter code + new password).
  bool _codeSent = false;
  bool _loading = false;
  bool _obscure = true;

  // Populated only when the backend returns a dev_code (demo env without email
  // delivery). Shown to the user so the flow is usable; null in production.
  String? _devCode;

  @override
  void initState() {
    super.initState();
    if (widget.initialEmail != null) _emailCtrl.text = widget.initialEmail!;
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _codeCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _snack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: error ? Colors.red : null),
    );
  }

  Future<void> _requestCode() async {
    final email = _emailCtrl.text.trim().toLowerCase();
    if (email.isEmpty) {
      _snack('Enter your email', error: true);
      return;
    }

    setState(() => _loading = true);
    final res = await ApiService().requestPasswordReset(email);
    if (!mounted) return;
    setState(() => _loading = false);

    if (!res.isOk) {
      _snack(res.error ?? 'Could not send reset code', error: true);
      return;
    }

    final devCode = res.data?['dev_code'] as String?;
    setState(() {
      _codeSent = true;
      _devCode = devCode;
      if (devCode != null) _codeCtrl.text = devCode; // demo convenience
    });
    _snack(devCode == null
        ? 'If that email is registered, a reset code is on its way.'
        : 'Demo mode: reset code shown below.');
  }

  Future<void> _resetPassword() async {
    final email = _emailCtrl.text.trim().toLowerCase();
    final code = _codeCtrl.text.trim();
    final pass = _passCtrl.text;
    final confirm = _confirmCtrl.text;

    if (code.isEmpty) {
      _snack('Enter the reset code', error: true);
      return;
    }
    if (pass.length < 6) {
      _snack('Password must be at least 6 characters', error: true);
      return;
    }
    if (pass != confirm) {
      _snack('Passwords do not match', error: true);
      return;
    }

    setState(() => _loading = true);
    final err = await ApiService().resetPassword(email: email, code: code, password: pass);
    if (!mounted) return;
    setState(() => _loading = false);

    if (err != null) {
      _snack(err, error: true);
      return;
    }

    // resetPassword() already persisted the JWT, so we're signed in — route the
    // same way login does.
    final onboarded = await isOnboardingComplete();
    if (!mounted) return;
    _snack('Password updated — you\'re signed in.');
    if (onboarded) {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingFlow()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Reset Password'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _codeSent ? 'Enter your code' : 'Forgot your password?',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _codeSent
                    ? 'Enter the 6-digit code and choose a new password.'
                    : 'Enter the email you signed up with and we\'ll send a reset code. '
                        '(Your login is your email — there\'s no separate username.)',
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 24),

              // Email — always visible; locked once a code has been sent so the
              // code stays tied to the address it was issued for.
              TextField(
                controller: _emailCtrl,
                enabled: !_codeSent,
                keyboardType: TextInputType.emailAddress,
                textCapitalization: TextCapitalization.none,
                autocorrect: false,
                enableSuggestions: false,
                decoration: _decoration('Email', Icons.email_outlined),
              ),

              if (_codeSent) ...[
                const SizedBox(height: 18),
                if (_devCode != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 18),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE19A3D)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Color(0xFFE19A3D)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Demo mode (email delivery off): your reset code is $_devCode',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                TextField(
                  controller: _codeCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  decoration: _decoration('6-digit code', Icons.pin_outlined),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  decoration: _decoration('New password', Icons.lock_outline).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: _confirmCtrl,
                  obscureText: _obscure,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _resetPassword(),
                  decoration: _decoration('Confirm new password', Icons.lock_outline),
                ),
              ],

              const SizedBox(height: 28),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _loading
                      ? null
                      : (_codeSent ? _resetPassword : _requestCode),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text(_codeSent ? 'Reset Password' : 'Send Reset Code',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),

              if (_codeSent) ...[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _loading ? null : _requestCode,
                  child: const Text('Resend code',
                      style: TextStyle(color: Color(0xFF2E7D32))),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _decoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2)),
    );
  }
}
