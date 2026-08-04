// lib/screens/auth/signup_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'app_colors.dart';
import 'common_widgets.dart';
import 'api_servic.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey            = GlobalKey<FormState>();
  final _nameController     = TextEditingController();
  final _emailController    = TextEditingController();
  final _phoneController    = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController  = TextEditingController();
  bool _obscurePassword     = true;
  bool _obscureConfirm      = true;
  bool _agreedToTerms       = false;
  bool _isLoading           = false;
  int  _step                = 0;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please agree to the Terms of Service',
            style: GoogleFonts.poppins(fontSize: 13)),
        backgroundColor: AppColors.accentRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      return;
    }
    setState(() => _isLoading = true);

    final result = await ApiService.signup(
      name:            _nameController.text.trim(),
      email:           _emailController.text.trim(),
      phone:           _phoneController.text.trim(),
      password:        _passwordController.text,
      confirmPassword: _confirmController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Account created! Please sign in.',
            style: GoogleFonts.poppins(fontSize: 13)),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result.error ?? 'Signup failed',
            style: GoogleFonts.poppins(fontSize: 13)),
        backgroundColor: AppColors.accentRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(Iconsax.arrow_left_2,
                          color: AppColors.textPrimary, size: 20),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Logo
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Iconsax.user_add,
                        color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 20),

                  Text('Create Account',
                      style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.8)),
                  Text('Start your journey to financial freedom',
                      style: GoogleFonts.poppins(
                          fontSize: 14, color: AppColors.textSecondary)),
                  const SizedBox(height: 32),

                  // Step indicator
                  Row(children: [
                    _stepDot(0, 'Personal'),
                    Expanded(
                      child: Container(
                        height: 2,
                        color: _step >= 1
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                    ),
                    _stepDot(1, 'Security'),
                  ]),
                  const SizedBox(height: 32),

                  // ── Step 0: Personal ──────────────────────────────────────
                  if (_step == 0) ...[
                    AppTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      hint: 'Arjun Kumar',
                      prefixIcon: Iconsax.user,
                      validator: (v) =>
                      v!.isEmpty ? 'Enter your name' : null,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _emailController,
                      label: 'Email Address',
                      hint: 'arjun@example.com',
                      prefixIcon: Iconsax.sms,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) =>
                      v!.isEmpty ? 'Enter your email' : null,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      hint: '+91 98765 43210',
                      prefixIcon: Iconsax.call,
                      keyboardType: TextInputType.phone,
                      validator: (v) =>
                      v!.isEmpty ? 'Enter phone number' : null,
                    ),
                    const SizedBox(height: 32),
                    GradientButton(
                      text: 'Continue',
                      onPressed: () => setState(() => _step = 1),
                      icon: Iconsax.arrow_right_2,
                    ),

                    // ── Step 1: Security ──────────────────────────────────────
                  ] else ...[
                    AppTextField(
                      controller: _passwordController,
                      label: 'Password',
                      hint: '••••••••',
                      prefixIcon: Iconsax.lock_1,
                      obscureText: _obscurePassword,
                      suffixIcon: _obscurePassword
                          ? Iconsax.eye
                          : Iconsax.eye_slash,
                      onSuffixTap: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                      validator: (v) =>
                      v!.length < 6 ? 'Min 6 characters' : null,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _confirmController,
                      label: 'Confirm Password',
                      hint: '••••••••',
                      prefixIcon: Iconsax.shield_tick,
                      obscureText: _obscureConfirm,
                      suffixIcon: _obscureConfirm
                          ? Iconsax.eye
                          : Iconsax.eye_slash,
                      onSuffixTap: () => setState(
                              () => _obscureConfirm = !_obscureConfirm),
                      validator: (v) => v != _passwordController.text
                          ? 'Passwords do not match'
                          : null,
                    ),
                    const SizedBox(height: 20),

                    // Terms checkbox
                    GestureDetector(
                      onTap: () =>
                          setState(() => _agreedToTerms = !_agreedToTerms),
                      child: Row(children: [
                        Container(
                          width: 22, height: 22,
                          decoration: BoxDecoration(
                            color: _agreedToTerms
                                ? AppColors.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: _agreedToTerms
                                  ? AppColors.primary
                                  : AppColors.border,
                              width: 2,
                            ),
                          ),
                          child: _agreedToTerms
                              ? const Icon(Iconsax.tick_square,
                              color: Colors.white, size: 14)
                              : null,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'I agree to the Terms of Service and Privacy Policy',
                            style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppColors.textSecondary),
                          ),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 32),

                    GradientButton(
                      text: 'Create Account',
                      onPressed: _submit,
                      isLoading: _isLoading,
                      icon: Iconsax.tick_circle,
                    ),
                    const SizedBox(height: 12),

                    Center(
                      child: TextButton(
                        onPressed: () => setState(() => _step = 0),
                        child: Text('← Back',
                            style: GoogleFonts.poppins(
                                color: AppColors.textSecondary,
                                fontSize: 13)),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Already have an account? ',
                          style: GoogleFonts.poppins(
                              color: AppColors.textSecondary, fontSize: 13)),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Text('Sign In',
                            style: GoogleFonts.poppins(
                                color: AppColors.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _stepDot(int step, String label) {
    final isActive = _step >= step;
    return Column(children: [
      Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.bgCard,
          shape: BoxShape.circle,
          border: Border.all(
              color: isActive ? AppColors.primary : AppColors.border),
        ),
        child: Center(
          child: isActive && _step > step
              ? const Icon(Iconsax.tick_circle, color: Colors.white, size: 16)
              : Text('${step + 1}',
              style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isActive ? Colors.white : AppColors.textMuted)),
        ),
      ),
      const SizedBox(height: 4),
      Text(label,
          style: GoogleFonts.poppins(
              fontSize: 10,
              color: isActive ? AppColors.primary : AppColors.textMuted)),
    ]);
  }
}