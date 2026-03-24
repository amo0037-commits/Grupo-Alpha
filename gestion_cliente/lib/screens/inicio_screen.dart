import 'package:flutter/material.dart';
import 'package:gestion_cliente/screens/login_screen.dart';

class PaginaInicio extends StatelessWidget {
  const PaginaInicio({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        title: SizedBox(
          height: 65,
          child: Image.asset(
            'assets/images/LogoAlphaAppPagInicio.png',
            height: 65,
            fit: BoxFit.contain,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, size: 30, color: Color(0xFF1565C0)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/LogoAlphaAppPagInicio.png', width: 300, fit: BoxFit.contain,),
              const SizedBox(height: 60),
              const Text('Bienvenido a AlphaApp', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold,
               color: Color.fromARGB(255, 14, 76, 146))),
              const SizedBox(height: 20),
              const Text(
                'La app para gestionar tu negocio de forma fiable',
                style: TextStyle(fontSize: 20, color: Color(0xFF448AFF)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
