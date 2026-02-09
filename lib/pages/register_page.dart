import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geo_attendance_new_ui/pages/login_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // Focus
  final _idFocus = FocusNode();
  final _nameFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passFocus = FocusNode();
  final _confirmFocus = FocusNode();

  // Controllers
  final TextEditingController idController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController pwController = TextEditingController();
  final TextEditingController verifyPwController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  // Firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Department
  final List<String> departments = const [
    'Administrator',
    'Designer',
    'Finance',
    'GIC',
    'GTR',
    'IT',
    'HR',
    'Sale',
    'Technician',
  ];
  String? selectedDepartment;

  // UI state
  bool hidePw = true;
  bool hideConfirm = true;
  bool isLoading = false;

  // Validation text
  String invalidID = '';
  String invalidName = '';
  String invalidDepartment = '';
  String invalidEmail = '';
  String invalidPW = '';
  String invalidVerifyPW = '';
  String invalidPhone = '';
  String status = '';

  @override
  void dispose() {
    _idFocus.dispose();
    _nameFocus.dispose();
    _phoneFocus.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    _confirmFocus.dispose();

    idController.dispose();
    nameController.dispose();
    emailController.dispose();
    pwController.dispose();
    verifyPwController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  bool _isEmailValid(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email.trim());
  }

  bool _isPhoneValid(String phone) {
    return RegExp(r'^[0-9]{8,15}$').hasMatch(phone.trim());
  }

  void _validateAll() {
    final id = idController.text.trim();
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final pw = pwController.text;
    final confirm = verifyPwController.text;

    invalidID = id.isEmpty ? 'ID is required' : '';
    invalidName = name.isEmpty ? 'Name is required' : '';
    invalidDepartment = (selectedDepartment == null)
        ? 'Please select department'
        : '';
    invalidEmail = _isEmailValid(email) ? '' : 'Invalid email';
    invalidPhone = _isPhoneValid(phone) ? '' : 'Invalid phone number';

    invalidPW = (pw.length >= 6 && pw.length <= 12)
        ? ''
        : 'Password 6-12 chars';
    invalidVerifyPW = (confirm == pw && confirm.isNotEmpty)
        ? ''
        : 'Passwords do not match';
  }

  Future<void> _signUp() async {
    setState(() {
      status = '';
      _validateAll();
    });

    if (invalidID.isNotEmpty ||
        invalidName.isNotEmpty ||
        invalidDepartment.isNotEmpty ||
        invalidEmail.isNotEmpty ||
        invalidPhone.isNotEmpty ||
        invalidPW.isNotEmpty ||
        invalidVerifyPW.isNotEmpty) {
      setState(() => status = 'Please fix the fields above.');
      return;
    }

    setState(() {
      isLoading = true;
      status = 'Signing Up...';
    });

    try {
      final UserCredential user = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: pwController.text.trim(),
      );

      await _firestore.collection('users').doc(user.user!.uid).set({
        'id': idController.text.trim(),
        'name': nameController.text.trim(),
        'department': selectedDepartment,
        'phone': phoneController.text.trim(),
        'role': 'worker',
        'email': user.user!.email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign Up Successful! Please login.')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() => status = e.message ?? 'Sign Up Failed.');
    } catch (e) {
      setState(() => status = 'Sign Up Failed: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1D4ED8),
                  Color(0xFF2563EB),
                  Color(0xFF0EA5E9),
                ],
              ),
            ),
          ),

          //
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

          // Card
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: _glassCard(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 28,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.white),
                            const SizedBox(width: 10),
                            Text(
                              'Geo-Attendant',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.95),
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Create account',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'For worker, staff and manager.',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                          ),
                        ),
                        const SizedBox(height: 26),

                        Wrap(
                          spacing: 22,
                          runSpacing: 18,
                          children: [
                            _fieldBox(
                              width: double.infinity,
                              label: 'ID',
                              errorText: invalidID,
                              child: _input(
                                controller: idController,
                                hint: 'Enter ID',
                                focusNode: _idFocus,
                                textInputAction: TextInputAction.next,
                                onSubmitted: (_) => FocusScope.of(
                                  context,
                                ).requestFocus(_nameFocus),
                                onChanged: (_) => setState(_validateAll),
                              ),
                            ),
                            _fieldBox(
                              width: double.infinity,
                              label: 'Full Name',
                              errorText: invalidName,
                              child: _input(
                                controller: nameController,
                                hint: 'Enter Name',
                                focusNode: _nameFocus,
                                textInputAction: TextInputAction.next,
                                onSubmitted: (_) =>
                                    FocusScope.of(context).unfocus(),
                                onChanged: (_) => setState(_validateAll),
                              ),
                            ),

                            _fieldBox(
                              width: double.infinity,
                              label: 'Department',
                              errorText: invalidDepartment,
                              child: _deptDropdown(),
                            ),

                            _fieldBox(
                              width: double.infinity,
                              label: 'Phone Number',
                              errorText: invalidPhone,
                              child: _input(
                                controller: phoneController,
                                hint: 'Enter Phone Number',
                                keyboardType: TextInputType.phone,
                                focusNode: _phoneFocus,
                                textInputAction: TextInputAction.next,
                                onSubmitted: (_) => FocusScope.of(
                                  context,
                                ).requestFocus(_emailFocus),
                                onChanged: (_) => setState(_validateAll),
                              ),
                            ),
                            _fieldBox(
                              width: double.infinity,
                              label: 'Email',
                              errorText: invalidEmail,
                              child: _input(
                                controller: emailController,
                                hint: 'Enter Email',
                                keyboardType: TextInputType.emailAddress,
                                focusNode: _emailFocus,
                                textInputAction: TextInputAction.next,
                                onSubmitted: (_) => FocusScope.of(
                                  context,
                                ).requestFocus(_passFocus),
                                onChanged: (_) => setState(_validateAll),
                              ),
                            ),
                            _fieldBox(
                              width: double.infinity,
                              label: 'Password',
                              errorText: invalidPW,
                              child: _passwordInput(
                                controller: pwController,
                                hidden: hidePw,
                                focusNode: _passFocus,
                                textInputAction: TextInputAction.next,
                                onSubmitted: (_) => FocusScope.of(
                                  context,
                                ).requestFocus(_confirmFocus),
                                toggle: () => setState(() => hidePw = !hidePw),
                                onChanged: (_) => setState(_validateAll),
                              ),
                            ),
                            _fieldBox(
                              width: double.infinity,
                              label: 'Confirm Password',
                              errorText: invalidVerifyPW,
                              child: _passwordInput(
                                controller: verifyPwController,
                                hidden: hideConfirm,
                                focusNode: _confirmFocus,
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) {
                                  if (!isLoading) _signUp();
                                },
                                toggle: () =>
                                    setState(() => hideConfirm = !hideConfirm),
                                onChanged: (_) => setState(_validateAll),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _signUp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Create account',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                          ),
                        ),

                        if (status.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              status,
                              style: TextStyle(
                                color: Colors.redAccent.shade100,
                              ),
                            ),
                          ),

                        const SizedBox(height: 10),

                        Center(
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                              children: [
                                const TextSpan(
                                  text: 'Already have an account? ',
                                ),
                                TextSpan(
                                  text: 'Log In',
                                  style: const TextStyle(
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const LoginPage(),
                                        ),
                                      );
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _deptDropdown() {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      alignment: Alignment.center,
      child: DropdownButtonFormField<String>(
        value: selectedDepartment,
        isExpanded: true,
        decoration: const InputDecoration(border: InputBorder.none),
        dropdownColor: Colors.white,
        hint: const Text(
          'Select department',
          style: TextStyle(color: Colors.black38),
        ),
        style: const TextStyle(color: Colors.black, fontSize: 14),
        items: departments
            .map((dep) => DropdownMenuItem(value: dep, child: Text(dep)))
            .toList(),
        onChanged: (value) {
          setState(() {
            selectedDepartment = value;
            _validateAll();
          });

          FocusScope.of(context).requestFocus(_phoneFocus);
        },
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

  Widget _fieldBox({
    required double width,
    required String label,
    required String errorText,
    required Widget child,
  }) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          child,
          if (errorText.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              errorText,
              style: const TextStyle(color: Colors.redAccent, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String hint,
    FocusNode? focusNode,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    void Function(String)? onSubmitted,
    void Function(String)? onChanged,
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
        focusNode: focusNode,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onSubmitted: onSubmitted,
        onChanged: onChanged,
        style: const TextStyle(color: Colors.black, fontSize: 14),
        cursorColor: Colors.black,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black38),
        ),
      ),
    );
  }

  Widget _passwordInput({
    required TextEditingController controller,
    required bool hidden,
    required VoidCallback toggle,
    FocusNode? focusNode,
    TextInputAction? textInputAction,
    void Function(String)? onSubmitted,
    required void Function(String) onChanged,
  }) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.only(left: 14, right: 4),
      alignment: Alignment.center,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: hidden,
        onChanged: onChanged,
        textInputAction: textInputAction,
        onSubmitted: onSubmitted,
        style: const TextStyle(color: Colors.black, fontSize: 14),
        cursorColor: Colors.black,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Password',
          hintStyle: const TextStyle(color: Colors.black38),
          suffixIcon: IconButton(
            onPressed: toggle,
            icon: Icon(
              hidden ? Icons.visibility_off : Icons.visibility,
              color: Colors.black45,
            ),
          ),
        ),
      ),
    );
  }
}
