import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


import 'package:gestion_cliente/screens/profile_page.dart';
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
  actions: [
    StreamBuilder<DocumentSnapshot>(
      // Obtenemos el documento del usuario actual
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        // Mientras carga o si hay error, mostramos un avatar genérico
        if (!snapshot.hasData || snapshot.hasError) {
          return const Padding(
            padding: EdgeInsets.only(right: 15),
            child: CircleAvatar(
              backgroundColor: Colors.blue,
              child: Icon(Icons.person, color: Colors.white),
            ),
          );
        }

        // Extraemos los datos de Firestore
        var userData = snapshot.data?.data() as Map<String, dynamic>?;
        String nombre = userData?['nombre'] ?? "";
        String apellido = userData?['apellidos'] ?? "";

        // Lógica para obtener las iniciales
        String iniciales = "";
        if (nombre.isNotEmpty) iniciales += nombre[0].toUpperCase();
        if (apellido.isNotEmpty) iniciales += apellido[0].toUpperCase();
        
        // Si no hay nombre ni apellido, ponemos "U" de Usuario
        if (iniciales.isEmpty) iniciales = "U";

        return Padding(
          padding: const EdgeInsets.only(right: 15),
          child: CircleAvatar(
            backgroundColor: Colors.blue,
            child: Text(
              iniciales,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    ),
  ],

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