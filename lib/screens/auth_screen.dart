import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:todo/Services/shared_pref_service.dart';
import 'package:todo/screens/forgot_password_screen.dart';
import 'package:todo/screens/home_screen.dart';
import 'package:todo/Services/database_service.dart';
import 'package:todo/services/fa_service.dart';
import 'package:todo/services/fcm_service.dart';
import 'package:todo/shared/functions.dart';
import 'package:todo/widgets/auth_field_validation_widget.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _faService = FirebaseAnalyticsService();
  final _fcmService = FirebaseMessagingService();
  final _sharedPrefService = SharedPrefService();

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final _showCaseAuthButton = GlobalKey();
  final _showCaseAccountButton = GlobalKey();
  final _showCaseForgotPasswordButton = GlobalKey();

  bool _isSigningIn = true;
  bool _isFetchingData = false;
  bool _isObscurePassword = true;
  final ValueNotifier<bool> _usernameCannotBeEmpty = ValueNotifier(false);
  final ValueNotifier<bool> _passwordCannotBeEmpty = ValueNotifier(false);
  final ValueNotifier<bool> _hasMinimum4Length = ValueNotifier(false);
  final ValueNotifier<bool> _hasMinimum6Length = ValueNotifier(false);
  final ValueNotifier<bool> _containsOnlyValidCharacters = ValueNotifier(false);
  final ValueNotifier<bool> _usernameShouldNotContainUppercase =
      ValueNotifier(false);
  final ValueNotifier<bool> _passwordMustContainUppercase =
      ValueNotifier(false);
  final ValueNotifier<bool> _containLowercase = ValueNotifier(false);
  final ValueNotifier<bool> _containsDigitAndSymbol = ValueNotifier(false);

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _onInit());
    super.initState();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onInit() {
    _checkShowCase();
  }

  void _checkShowCase() async {
    bool test1 = await _sharedPrefService.getShowCaseAuthButtonKey();
    bool test2 = await _sharedPrefService.getShowCaseAccountButtonKey();
    bool test3 = await _sharedPrefService.getShowCaseForgotPasswordButtonKey();
    if (!test1 && !test2 && !test3) {
      // ignore: use_build_context_synchronously
      ShowCaseWidget.of(context).startShowCase([
        _showCaseAuthButton,
        _showCaseAccountButton,
        _showCaseForgotPasswordButton
      ]);
    }
    _sharedPrefService.setShowCaseAuthButtonKey(true);
    _sharedPrefService.setShowCaseAccountButtonKey(true);
    _sharedPrefService.setShowCaseForgotPasswordButtonKey(true);
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
    } on HttpException catch (e) {
      debugPrint(e.toString());
      Future.delayed(Duration.zero, () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            duration: const Duration(seconds: 3),
          ),
        );
      });
    } catch (e) {
      debugPrint(e.toString());
      Future.delayed(Duration.zero, () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            duration: const Duration(seconds: 3),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0).w,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                ),
                maxLines: 1,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter your username';
                  }
                  if (!_isSigningIn) {
                    if (!hasMinimumLength(value ?? '', 4)) {
                      return 'Username must have at least 4 characters';
                    }
                    if (hasMaximumLength(value ?? '', 255)) {
                      return 'Username must not exceed 255 characters';
                    }
                    if (!containsOnlyValidCharacters(value ?? '')) {
                      return 'Username can only contain symbol underscores';
                    }
                  }
                  return null;
                },
                onChanged: (value) {
                  _usernameCannotBeEmpty.value = value.isNotEmpty;
                  _hasMinimum4Length.value = hasMinimumLength(value, 4);
                  _containsOnlyValidCharacters.value =
                      containsOnlyValidCharacters(value);
                  _usernameShouldNotContainUppercase.value =
                      doesNotContainUppercase(value);
                },
              ),
              SizedBox(height: 8.0.h),
              ValueListenableBuilder<bool>(
                valueListenable: _usernameCannotBeEmpty,
                builder: (context, value, child) {
                  return AuthFieldValidationWidget(
                    title: 'Cannot Be Empty',
                    isValid: value,
                  );
                },
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                transitionBuilder: (child, animation) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(-1.0, 0.0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  );
                },
                child: !_isSigningIn
                    ? ValueListenableBuilder<bool>(
                        valueListenable: _hasMinimum4Length,
                        builder: (context, value, child) {
                          return AuthFieldValidationWidget(
                            title: 'Has Minimum 4 Length',
                            isValid: value,
                          );
                        },
                      )
                    : const SizedBox.shrink(),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                transitionBuilder: (child, animation) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1.0, 0.0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  );
                },
                child: !_isSigningIn
                    ? ValueListenableBuilder<bool>(
                        valueListenable: _containsOnlyValidCharacters,
                        builder: (context, value, child) {
                          return AuthFieldValidationWidget(
                            title: 'Contains Only Valid Symbol [a-z0-9_]',
                            isValid: value,
                          );
                        },
                      )
                    : const SizedBox.shrink(),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                transitionBuilder: (child, animation) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(-1.0, 0.0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  );
                },
                child: !_isSigningIn
                    ? ValueListenableBuilder<bool>(
                        valueListenable: _usernameShouldNotContainUppercase,
                        builder: (context, value, child) {
                          return AuthFieldValidationWidget(
                            title: 'Should Not Contain Uppercase',
                            isValid: value,
                          );
                        },
                      )
                    : const SizedBox.shrink(),
              ),
              SizedBox(height: 16.0.h),
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
                maxLines: 1,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter your password';
                  }
                  if (!_isSigningIn) {
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
                  }
                  return null;
                },
                onChanged: (value) {
                  _passwordCannotBeEmpty.value = value.isNotEmpty;
                  _hasMinimum6Length.value = hasMinimumLength(value, 6);
                  _passwordMustContainUppercase.value =
                      !doesNotContainUppercase(value);
                  _containLowercase.value = containLowercase(value);
                  _containsDigitAndSymbol.value = containsDigitAndSymbol(value);
                },
              ),
              SizedBox(height: 8.0.h),
              ValueListenableBuilder<bool>(
                valueListenable: _passwordCannotBeEmpty,
                builder: (context, value, child) {
                  return AuthFieldValidationWidget(
                    title: 'Cannot Be Empty',
                    isValid: value,
                  );
                },
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                transitionBuilder: (child, animation) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(-1.0, 0.0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  );
                },
                child: !_isSigningIn
                    ? ValueListenableBuilder<bool>(
                        valueListenable: _hasMinimum6Length,
                        builder: (context, value, child) {
                          return AuthFieldValidationWidget(
                            title: 'Has Minimum 6 Length',
                            isValid: value,
                          );
                        },
                      )
                    : const SizedBox.shrink(),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                transitionBuilder: (child, animation) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1.0, 0.0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  );
                },
                child: !_isSigningIn
                    ? ValueListenableBuilder<bool>(
                        valueListenable: _containLowercase,
                        builder: (context, value, child) {
                          return AuthFieldValidationWidget(
                            title: 'Contain Lowercase',
                            isValid: value,
                          );
                        },
                      )
                    : const SizedBox.shrink(),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                transitionBuilder: (child, animation) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(-1.0, 0.0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  );
                },
                child: !_isSigningIn
                    ? ValueListenableBuilder<bool>(
                        valueListenable: _containsDigitAndSymbol,
                        builder: (context, value, child) {
                          return AuthFieldValidationWidget(
                            title: 'Contains Digit And Symbol',
                            isValid: value,
                          );
                        },
                      )
                    : const SizedBox.shrink(),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                transitionBuilder: (child, animation) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1.0, 0.0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  );
                },
                child: !_isSigningIn
                    ? ValueListenableBuilder<bool>(
                        valueListenable: _passwordMustContainUppercase,
                        builder: (context, value, child) {
                          return AuthFieldValidationWidget(
                            title: 'Must Contain Uppercase',
                            isValid: value,
                          );
                        },
                      )
                    : const SizedBox.shrink(),
              ),
              SizedBox(height: 16.0.h),
              Showcase(
                key: _showCaseAuthButton,
                title: 'Sign In/Sign Up',
                description: 'Tap this button to sign in or sign up',
                targetPadding: const EdgeInsets.all(4).w,
                child: AnimatedSwitcher(
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
              ),
              Showcase(
                key: _showCaseAccountButton,
                title: 'Account Toggle',
                description: 'Tap here to manage your account',
                targetPadding: const EdgeInsets.all(4).w,
                child: TextButton(
                  onPressed: _toggleSignInSignUpState,
                  child: Text(_isSigningIn
                      ? 'Need an account? Sign up'
                      : 'Already have an account? Sign in'),
                ),
              ),
              Showcase(
                key: _showCaseForgotPasswordButton,
                title: 'Reset Password',
                description: 'Tap here to reset your password',
                targetPadding: const EdgeInsets.all(4).w,
                child: TextButton(
                  onPressed: () => Navigator.of(context).push(
                      CupertinoPageRoute(
                          builder: (context) => const ForgotPasswordScreen())),
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
