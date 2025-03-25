import 'package:eco_circuit/firebase_options.dart';
import 'package:eco_circuit/screens/home_screen.dart';
import 'package:eco_circuit/screens/login_screen.dart';
import 'package:eco_circuit/screens/signup_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

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
      home: HomeScreen(),
    );
  }
}
