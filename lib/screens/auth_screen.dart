import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:todo/screens/home_screen.dart';
import 'package:todo/Services/database_service.dart';
import 'package:todo/services/fa_service.dart';
import 'package:todo/services/fcm_service.dart';
import 'package:todo/shared/functions.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _faService = FirebaseAnalyticsService();
  final _fcmService = FirebaseMessagingService();

  bool _isSigningIn = true;
  bool _isFetchingData = false;
  bool _isObscurePassword = true;
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _toggleSignInSignUpState() {
    setState(() {
      _isSigningIn = !_isSigningIn;
    });
  }

  void _handleAuth() async {
    if (_formKey.currentState?.validate() == false) {
      return;
    }

    setState(() => _isFetchingData = true);
    try {
      if (_isSigningIn) {
        await _faService.logLogin();
        await _fcmService.saveTokenToSharedPref();
        await DatabaseService()
            .signin(_usernameController.text, _passwordController.text);
      } else {
        await _faService.logSignUp();
        await _fcmService.saveTokenToSharedPref();
        await DatabaseService()
            .signup(_usernameController.text, _passwordController.text);
      }

      await _faService.logUserInformation();

      // ignore: use_build_context_synchronously
      Navigator.of(context).pushReplacement(
          CupertinoPageRoute(builder: (context) => const HomeScreen()));
    } catch (e) {
      debugPrint(e.toString());
      Future.delayed(Duration.zero, () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Oops, An error occurred, please try again'),
            duration: Duration(seconds: 3),
          ),
        );
      });
    } finally {
      setState(() => _isFetchingData = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isSigningIn ? 'Sign In' : 'Sign Up'),
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
                  if (!hasMinimumLength(value ?? '', 4)) {
                    return 'Username must have at least 4 characters';
                  }
                  if (hasMaximumLength(value ?? '', 15)) {
                    return 'Username must not exceed 15 characters';
                  }
                  if (!doesNotContainUppercase(value ?? '')) {
                    return 'Username cannot contain uppercase letters';
                  }
                  if (!containsOnlyValidCharacters(value ?? '')) {
                    return 'Username can only contain symbol underscores';
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
                  if (!hasMinimumLength(value ?? '', 8)) {
                    return 'Password must have at least 8 characters';
                  }
                  if (hasMaximumLength(value ?? '', 200)) {
                    return 'Password must not exceed 200 characters';
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
                        onPressed: _handleAuth,
                        child: Text(_isSigningIn ? 'Sign In' : 'Sign Up'),
                      ),
              ),
              TextButton(
                onPressed: _toggleSignInSignUpState,
                child: Text(_isSigningIn
                    ? 'Need an account? Sign up'
                    : 'Already have an account? Sign in'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
