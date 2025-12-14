import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'firebase_notifications.dart';
import 'graduand_login.dart';
import 'graduand_registration.dart';
import 'graduand_main_screen.dart';
import 'notification_screen.dart';
import 'adminLogin.dart';
import 'adminDashboard.dart';
import 'adminMain.dart';
import 'adminBooking.dart';
import 'adminInventory.dart';
import 'adminReport.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Stripe.publishableKey =
      'pk_test_51QYfLJEFOyv3qnq3IHEv48NvpPWX8al8nQlee2vsYlmTfiYyDgmjhrCbBPIzkUKpZtYV6L0v8kdaegE88yYWMoS5001yGlWPbS';
  runApp(const ConvocationApp());
}

class ConvocationApp extends StatelessWidget {
  const ConvocationApp({super.key});

  @override
  Widget build(BuildContext context) {
    FirebaseNotifications.initialize(context);

    return MaterialApp(
      home: GraduandLogin(), // Default entry point: Graduand login screen
      routes: {
        // Graduand routes
        'graduandLogin': (context) => GraduandLogin(),
        'graduandRegistration': (context) => GraduandRegistration(),
        'graduandMainScreen': (context) => GraduandMainScreen(),
        'notificationScreen': (context) => NotificationScreen(),

        // Admin routes
        'adminLogin': (context) => AdminLogin(),
        'adminDashboard': (context) => const AdminDashboard(),
        'adminMain': (context) => const AdminMain(),
        'adminBooking': (context) => const AdminBooking(),
        'adminInventory': (context) => const AdminInventory(),
        'adminReport': (context) => const AdminReport(),
      },
    );
  }
}
