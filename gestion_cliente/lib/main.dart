import 'package:flutter/material.dart';
import 'package:gestion_cliente/core/app_themes.dart';
import 'package:gestion_cliente/screens/splash_screen.dart';
import 'package:gestion_cliente/screens/inicio_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';



void main() async {
  // 👇 NECESARIO para Firebase
  WidgetsFlutterBinding.ensureInitialized();
   // 👇 INICIALIZAR FIREBASE
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);


  runApp(const AlphaApp());
}

class AlphaApp extends StatelessWidget {
  const AlphaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AlphaApp',
      debugShowCheckedModeBanner: false,
      theme: AppThemes.inicioTheme,
      home: const SplashScreen(),
    );
  }
}