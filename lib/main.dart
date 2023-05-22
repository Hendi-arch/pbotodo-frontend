import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:todo/firebase_options.dart';
import 'package:todo/screens/startup_screen.dart';
import 'package:todo/models/tasks_data.dart';
import 'package:todo/services/fa_service.dart';
import 'package:todo/services/fcm_service.dart';
import 'package:todo/themes/app_themes.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  debugPrint("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize Firebase Messaging service
  FirebaseMessagingService messagingService = FirebaseMessagingService();
  await messagingService.initialize();

  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };

  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TasksData>(
      create: (context) => TasksData(),
      child: ScreenUtilInit(
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, snapshot) {
          return MaterialApp(
            title: 'TODO',
            theme: AppThemes.data(),
            debugShowCheckedModeBanner: false,
            navigatorObservers: [
              FirebaseAnalyticsService().getAnalyticsObserver()
            ],
            builder: (context, child) {
              final MediaQueryData mqd = MediaQuery.of(context);
              return MediaQuery(
                /// Setting font does not change with system font size
                data: MediaQuery.of(context).copyWith(
                    textScaleFactor: mqd.textScaleFactor >= 1.15 ? 1.15 : 1.0),
                child: child!,
              );
            },
            home: snapshot,
          );
        },
        child: const StartupScreen(),
      ),
    );
  }
}
