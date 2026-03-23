import 'package:flutter/material.dart';

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
      home: const PaginaInicio(),
    );
  }
}

class PaginaInicio extends StatelessWidget {
  const PaginaInicio({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  toolbarHeight: 120, 
  title: Row(
    children: [
      Image.asset(
        'assets/images/LogoAlphaAppPagInicio.png',
        height: 120,
      ),
    ],
  ),
  actions: [
    IconButton(
      icon: const Icon(Icons.person),
      onPressed: () {},
    ),
  ],
),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/LogoAlphaAppPagInicio.png',
              width: 150,
            ),
            const SizedBox(height: 100),
            const Text(
              'Bienvenido a AlphaApp',
              style: TextStyle(fontSize: 28),
            ),
          ],
        ),
      ),
    );
  }
}
