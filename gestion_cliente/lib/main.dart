import 'package:flutter/material.dart';
import 'package:gestion_cliente/core/app_themes.dart';
import 'package:gestion_cliente/screens/inicio_screen.dart';

void main() {
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
    );
  }
}