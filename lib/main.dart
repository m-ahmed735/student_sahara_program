import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_sahara_program/providers/auth_provider.dart';
import 'package:student_sahara_program/views/auth/login_screen.dart';
import 'package:student_sahara_program/views/home/dashboard_screen.dart';
import 'package:student_sahara_program/views/intro/splash_screen.dart';
import 'package:student_sahara_program/views/intro/onboarding_screen.dart';
import 'package:student_sahara_program/views/intro/welcome_page.dart';
import 'package:student_sahara_program/views/auth/register_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:student_sahara_program/firebase_options.dart'; // Auto-generated Firebase configuration

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Sahara Program',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      routes: {
     //   '/': (context) => OnboardingScreen(),
        '/welcome': (context) => WelcomeScreen(),
        '/register': (context) => RegistrationScreen(),
        '/login':(context) => LoginScreen(),
        '/dashboard':(context) => DashboardScreen(),
      },
    );
  }
}
