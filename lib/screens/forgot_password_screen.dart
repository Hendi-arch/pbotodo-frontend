import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:todo/services/database_service.dart';
import 'package:todo/shared/functions.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isFetchingData = false;
  bool _isObscurePassword = true;

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _resetPassword() async {
    if (_formKey.currentState?.validate() == false) {
      return;
    }

    setState(() => _isFetchingData = true);
    try {
      await DatabaseService()
          .forgotPassword(_usernameController.text, _passwordController.text);

      _showSnackBar(
          'Congratulations! Your password has been successfully reset. You can now log in to your account using your new password.');
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } on HttpException catch (e) {
      debugPrint(e.toString());
      _showSnackBar(e.message);
    } catch (e) {
      debugPrint(e.toString());
      _showSnackBar('Oops, an error occurred. ${e.toString()}');
    } finally {
      if (mounted) {
        FocusScope.of(context).unfocus();
        setState(() => _isFetchingData = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0).w,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter your username';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () => setState(
                        () => _isObscurePassword = !_isObscurePassword),
                  ),
                ),
                obscureText: _isObscurePassword,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter your password';
                  }
                  if (!hasMinimumLength(value ?? '', 6)) {
                    return 'Password must have at least 6 characters';
                  }
                  if (hasMaximumLength(value ?? '', 255)) {
                    return 'Password must not exceed 255 characters';
                  }
                  if (doesNotContainUppercase(value ?? '')) {
                    return 'Password must contain at least one uppercase letters';
                  }
                  if (!containLowercase(value ?? '')) {
                    return 'Password must contain at least one lowercase letters';
                  }
                  if (!containsDigitAndSymbol(value ?? '')) {
                    return 'Password must contain at least one digit and one symbol';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0.h),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                    scale: animation,
                    alignment: Alignment.center,
                    filterQuality: FilterQuality.high,
                    child: child,
                  );
                },
                child: _isFetchingData
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _resetPassword,
                        child: const Text('Reset Password'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
