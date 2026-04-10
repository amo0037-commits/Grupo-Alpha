import 'package:flutter/material.dart';

class GimnasioPage extends StatelessWidget {
  const GimnasioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gimnasio')),
      body: const Center(child: Text('Pantalla de Gimnasio')),
    );
  }
}