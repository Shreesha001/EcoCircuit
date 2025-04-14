import 'package:eco_circuit/firebase_options.dart';
import 'package:eco_circuit/responsive/mobilescreen_layout.dart';
import 'package:eco_circuit/screens/auth_screen/login_screen.dart';
import 'package:eco_circuit/screens/market/market_place.dart';
import 'package:eco_circuit/screens/market/seller_notification_screen.dart';
import 'package:eco_circuit/screens/services/recycle_screen.dart';
import 'package:eco_circuit/screens/auth_screen/signup_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

final model = FirebaseVertexAI.instance.generativeModel(
  model: 'gemini-2.0-flash',
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EcoCircuit',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromRGBO(56, 118, 29, 255),
        ),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            );
          }

          if (snapshot.hasData) {
            return const MobileScreenLayout();
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          return const LoginScreen();
        },
      ),
    );
  }
}
