import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardPage extends StatelessWidget {
  final List<String> negocios;
  const DashboardPage({super.key, required this.negocios});

  // Mapa de negocio → ruta
  final Map<String, String> rutasServicios = const {
    'Gimnasio': '/gimnasio',
    'Centro de Yoga': '/yoga',
    'Peluqueria': '/peluqueria',
    'Centro de Fisioterapia': '/fisioterapia',
    'Academia': '/academia',
  };

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // Si el usuario no está logueado, redirigir al login
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return const SizedBox();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Servicios'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: negocios.isEmpty
            ? const Center(
                child: Text(
                  'No tienes servicios asignados',
                  style: TextStyle(fontSize: 18),
                ),
              )
            : ListView.builder(
                itemCount: negocios.length,
                itemBuilder: (context, index) {
                  final negocio = negocios[index];

                  return Card(
                    color: Colors.blue[50],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: Icon(
                        negocio == 'Gimnasio'
                            ? Icons.fitness_center
                            : negocio == 'Centro de Yoga'
                                ? Icons.self_improvement
                                : negocio == 'Peluqueria'
                                    ? Icons.content_cut
                                    : negocio == 'Centro de Fisioterapia'
                                        ? Icons.health_and_safety
                                        : Icons.school,
                        color: const Color(0xFF1565C0),
                      ),
                      title: Text(
                        negocio,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1565C0),
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward, color: Color(0xFF1565C0)),
                      onTap: () {
                        final ruta = rutasServicios[negocio];
                        if (ruta != null) {
                          Navigator.pushNamed(
                            context,
                            ruta,
                            arguments: {
                              'userId': user.uid,
                              'negocio': negocio,
                            },
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Pantalla no configurada para $negocio')),
                          );
                        }
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}