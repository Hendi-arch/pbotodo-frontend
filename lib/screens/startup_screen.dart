// ignore_for_file: use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:todo/screens/auth_screen.dart';
import 'package:todo/screens/home_screen.dart';
import 'package:todo/Services/shared_pref_service.dart';
import 'package:todo/services/fa_service.dart';

class StartupScreen extends StatefulWidget {
  const StartupScreen({super.key});

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {
  final _faService = FirebaseAnalyticsService();

  void _handleStartup() {
    Future.delayed(const Duration(milliseconds: 1000), () async {
      await _faService.logAppOpen();
      
      var hasCredentials = await SharedPrefService().isHaveCredentials();
      if (hasCredentials) {
        Navigator.of(context).pushReplacement(
            CupertinoPageRoute(builder: (context) => const HomeScreen()));
      } else {
        Navigator.of(context).pushReplacement(
            CupertinoPageRoute(builder: (context) => const AuthScreen()));
      }
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _handleStartup());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Redirecting, please wait..."),
            SizedBox(height: 15),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
