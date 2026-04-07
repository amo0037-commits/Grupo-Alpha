import 'package:flutter/material.dart';
import 'package:gestion_cliente/core/app_themes.dart';
import 'package:gestion_cliente/screens/inicio_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:gestion_cliente/screens/auth/login_screen.dart';
import 'package:gestion_cliente/screens/auth/register_screen.dart';
import 'package:gestion_cliente/screens/dashboard/dashboard_page.dart';
import 'package:gestion_cliente/screens/dashboard/admin_page.dart';
import 'package:gestion_cliente/screens/servicios/gimnasio_page.dart';
import 'package:gestion_cliente/screens/servicios/yoga_page.dart';
import 'package:gestion_cliente/screens/servicios/peluqueria_page.dart';
import 'package:gestion_cliente/screens/servicios/fisioterapia_page.dart';
import 'package:gestion_cliente/screens/servicios/academia_page.dart';


void main() async {
  // 👇 NECESARIO para Firebase
  WidgetsFlutterBinding.ensureInitialized();
   // 👇 INICIALIZAR FIREBASE
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);

import 'package:gestion_cliente/screens/splash_screen.dart';

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
      home: const PaginaInicio(),
      routes: {
        // Autenticación
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),

        // Dashboard
        '/dashboard': (context) => DashboardPage(negocios: []), // temporal
        '/admin': (context) => AdminPage(),

        // Servicios
        '/gimnasio': (context) => GimnasioPage(),
        '/yoga': (context) => YogaPage(),
        '/peluqueria': (context) => PeluqueriaPage(),
        '/fisioterapia': (context) => FisioterapiaPage(),
        '/academia': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
          return AcademiaPage(
            userId: args?['userId'] ?? '',
            negocio: args?['negocio'] ?? 'Academia',
          );
        },
      },
      home: const SplashScreen(),
    );
  }
}