import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../../utils/constants.dart';
import '../../utils/validation_helper.dart';
import '../../widgets/modern_widgets.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _remember = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const primaryColor = Color(0xFF6366F1);
    const accentColor = Color(0xFF8B5CF6);
    
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: size.height - MediaQuery.of(context).padding.vertical,
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  // Header with gradient
                  Container(
                    height: size.height * 0.32,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryColor, accentColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.shopping_bag_rounded,
                              size: 36,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'ThriftStock',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Jual & kelola pakaian preloved',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Form card
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Masuk ke Akun',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1E293B),
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Silakan masukkan kredensial Anda',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: const Color(0xFF64748B),
                                ),
                          ),
                          const SizedBox(height: 20),
                          // Email field
                          CustomInputField(
                            hintText: 'nama@email.com',
                            label: 'Email',
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: Icons.email_rounded,
                            validator: ValidationHelper.validateEmail,
                          ),
                          const SizedBox(height: 16),
                          // Password field
                          CustomInputField(
                            hintText: 'Masukkan password',
                            label: 'Password',
                            controller: _passCtrl,
                            isPassword: true,
                            prefixIcon: Icons.lock_rounded,
                            validator: ValidationHelper.validatePassword,
                          ),
                          const SizedBox(height: 16),
                          // Remember me
                          Row(
                            children: [
                              Checkbox(
                                value: _remember,
                                onChanged: (v) =>
                                    setState(() => _remember = v ?? true),
                              ),
                              const Text('Ingat saya'),
                              const Spacer(),
                              TextButton(
                                onPressed: () {},
                                child: Text(
                                  'Lupa password?',
                                  style: TextStyle(color: kPrimaryColor),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Login button
                          GradientButton(
                            label: 'Masuk',
                            isLoading: _loading,
                            onPressed: _onLogin,
                          ),
                          const SizedBox(height: 16),
                          // Register button
                          OutlinedButton.icon(
                            onPressed: () =>
                                Navigator.pushNamed(context, '/register'),
                            icon: const Icon(Icons.person_add_rounded),
                            label: const Text('Buat Akun Baru'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: const BorderSide(color: Color(0xFF6366F1), width: 2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Text(
                      '© ThriftStock 2024',
                      style: TextStyle(
                        color: const Color(0xFF94A3B8),
                        fontSize: 12,
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

  void _onLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final success = await context.read<AuthProvider>().signIn(
            _emailCtrl.text.trim(),
            _passCtrl.text.trim(),
          );

      if (!mounted) return;

      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Email atau password salah'),
            backgroundColor: kErrorColor,
          ),
        );
        setState(() => _loading = false);
        return;
      }

      final user = context.read<AuthProvider>().user!;
      if (user.role == UserRole.admin) {
        Navigator.pushReplacementNamed(context, '/admin');
      } else {
        Navigator.pushReplacementNamed(context, '/user');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: kErrorColor,
        ),
      );
      setState(() => _loading = false);
    }
  }
}
