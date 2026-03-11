import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../contants/colors.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      bool success;
      if (_isLogin) {
        success = await authProvider.signIn(email, password);
      } else {
        success = await authProvider.signUp(email, password);
      }

      if (success && mounted) {
        // Navigate to HomeScreen after successful login/signup
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? "Authentication failed"),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 80,
                color: AppColors.primary,
              ),
              const SizedBox(height: 32),
              Text(
                _isLogin ? 'Welcome Back!' : 'Create Account',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isLogin
                    ? 'Sign in to continue managing your tasks'
                    : 'Join us and start organizing your life',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 48),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (value) => value != null && value.contains('@')
                          ? null
                          : 'Enter a valid email',
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: "Password",
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      validator: (value) => value != null && value.length >= 6
                          ? null
                          : 'Password must be at least 6 characters',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              authProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submit,
                      child: Text(
                        _isLogin ? "Login" : "Signup",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isLogin
                        ? 'Don\'t have an account? '
                        : 'Already have an account? ',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isLogin = !_isLogin;
                      });
                    },
                    child: Text(
                      _isLogin ? "Signup" : "Login",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
