import 'package:flutter/material.dart';
import '../../services/api/api_service.dart';
import '../onboarding/onboarding_flow.dart';
import 'forgot_password_page.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    // Lowercase + trim defensively: iOS autocapitalization and autocomplete
    // will happily submit "Sarah@Demo.com" which the backend treats as a
    // different user than "sarah@demo.com". Normalizing client-side keeps
    // legit users from bouncing off case-sensitive email matching.
    final email = _emailCtrl.text.trim().toLowerCase();
    final pass = _passCtrl.text;
    if (email.isEmpty || pass.isEmpty) return;

    setState(() => _loading = true);
    debugPrint('[Login] calling login email=$email');
    final err = await ApiService().login(email: email, password: pass);
    debugPrint('[Login] login returned err=$err');
    if (!mounted) return;
    setState(() => _loading = false);

    if (err != null) {
      debugPrint('[Login] showing error snackbar: $err');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err), backgroundColor: Colors.red),
      );
    } else {
      if (!mounted) return;
      final onboarded = await isOnboardingComplete();
      debugPrint('[Login] onboarded=$onboarded → ${onboarded ? "/home" : "OnboardingFlow"}');
      if (!mounted) return;
      if (onboarded) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const OnboardingFlow()),
          (_) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ── Green header ─────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(32, 60, 32, 48),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(32),
                  ),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('🌱', style: TextStyle(fontSize: 44)),
                    SizedBox(height: 8),
                    Text('Beanstalk',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 12),
                    Text('Welcome back',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w600)),
                    SizedBox(height: 6),
                    Text('Learn. Trade. Win.',
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontStyle: FontStyle.italic)),
                  ],
                ),
              ),

              // ── Form ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
                child: Column(
                  children: [
                    // Email
                    TextField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      // iOS autocapitalizes the first character and tries to
                      // autocomplete to domains like .app (matching the
                      // bundle id). Both produce emails that don't match the
                      // seeded accounts. Disable here and lowercase in _login.
                      textCapitalization: TextCapitalization.none,
                      autocorrect: false,
                      enableSuggestions: false,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Color(0xFF2E7D32), width: 2)),
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Password
                    TextField(
                      controller: _passCtrl,
                      obscureText: _obscure,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _login(),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscure
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () =>
                              setState(() => _obscure = !_obscure),
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Color(0xFF2E7D32), width: 2)),
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Sign In button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _login,
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
                            : const Text('Sign In',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Forgot password link — carries whatever email is already
                    // typed so the user doesn't re-enter it.
                    Align(
                      alignment: Alignment.center,
                      child: TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ForgotPasswordPage(
                              initialEmail: _emailCtrl.text.trim().isEmpty
                                  ? null
                                  : _emailCtrl.text.trim(),
                            ),
                          ),
                        ),
                        child: const Text('Forgot password?',
                            style: TextStyle(color: Color(0xFF2E7D32))),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Sign Up link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account? ",
                            style: TextStyle(color: Colors.grey)),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SignUpPage()),
                          ),
                          child: const Text('Sign Up',
                              style: TextStyle(
                                  color: Color(0xFF2E7D32),
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
