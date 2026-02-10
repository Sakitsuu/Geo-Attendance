import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();

  bool isLoading = false;
  String errorMessage = '';
  String successMessage = '';

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> _sendReset() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      setState(() {
        successMessage = '';
        errorMessage = 'Please enter your email.';
      });
      return;
    }

    final emailOk = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
    if (!emailOk) {
      setState(() {
        successMessage = '';
        errorMessage = 'Email format is invalid.';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
      successMessage = '';
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      if (!mounted) return;

      setState(() {
        successMessage = 'Reset link sent! Check your email inbox.';
        errorMessage = '';
      });
    } on FirebaseAuthException catch (e) {
      String msg = 'Failed to send reset email.';
      switch (e.code) {
        case 'user-not-found':
          msg = 'No account found for this email.';
          break;
        case 'invalid-email':
          msg = 'Email format is invalid.';
          break;
        case 'network-request-failed':
          msg = 'Network error. Check your internet connection.';
          break;
        case 'too-many-requests':
          msg = 'Too many requests. Try again later.';
          break;
        default:
          msg = e.message ?? msg;
      }

      if (!mounted) return;

      setState(() {
        successMessage = '';
        errorMessage = msg;
      });
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    final cs = Theme.of(context).colorScheme;
    // final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF1D4ED8), Color(0xFF2563EB), Color(0xFF0EA5E9)],
    );

    return Scaffold(
      body: Stack(
        children: [
          Container(decoration: BoxDecoration(gradient: bgGradient)),

          Positioned(
            left: -70,
            top: 140,
            child: _blob(170, Colors.white.withOpacity(0.18)),
          ),
          Positioned(
            right: -90,
            top: 50,
            child: _blob(240, Colors.white.withOpacity(0.12)),
          ),
          Positioned(
            right: -60,
            bottom: 120,
            child: _blob(200, Colors.white.withOpacity(0.10)),
          ),

          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isMobile ? 360 : 420),
              child: _glassCard(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 26,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        'Geo-Attendant',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 18),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Reset Password',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Enter your email and we will send you a reset link.',
                          style: TextStyle(
                            color: cs.onSurface.withOpacity(0.75),
                            fontSize: 13,
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      _label(context, 'Email'),
                      const SizedBox(height: 8),
                      _input(
                        controller: emailController,
                        hint: 'username@gmail.com',
                        obscureText: false,
                        suffix: null,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => isLoading ? null : _sendReset(),
                      ),

                      const SizedBox(height: 14),

                      if (errorMessage.isNotEmpty)
                        Text(
                          errorMessage,
                          style: TextStyle(color: cs.error),
                          textAlign: TextAlign.center,
                        ),
                      if (successMessage.isNotEmpty)
                        Text(
                          successMessage,
                          style: TextStyle(color: Colors.green.shade400),
                          textAlign: TextAlign.center,
                        ),

                      const SizedBox(height: 14),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _sendReset,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: cs.primary,
                            foregroundColor: cs.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Send reset link',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: cs.onSurface.withOpacity(0.85),
                        ),
                        child: const Text(
                          'Back to Login',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _blob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size / 2),
      ),
    );
  }

  static Widget _glassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.14),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: Colors.white.withOpacity(0.22), width: 1),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _label(BuildContext context, String text) {
    final cs = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          color: cs.onSurface.withOpacity(0.9),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String hint,
    required bool obscureText,
    required Widget? suffix,
    TextInputAction? textInputAction,
    void Function(String)? onSubmitted,
  }) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      alignment: Alignment.center,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        textInputAction: textInputAction,
        onSubmitted: onSubmitted,

        style: const TextStyle(color: Colors.black, fontSize: 14),
        cursorColor: Colors.black,

        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black45),
          suffixIcon: suffix,
        ),
      ),
    );
  }
}
