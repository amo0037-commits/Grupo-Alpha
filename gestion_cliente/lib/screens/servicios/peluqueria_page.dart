import 'package:flutter/material.dart';

class PeluqueriaPage extends StatelessWidget {
  const PeluqueriaPage({super.key, required String userId, required String negocio});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Peluquería')),
      body: const Center(child: Text('Pantalla de Peluquería')),
    );
  }
}