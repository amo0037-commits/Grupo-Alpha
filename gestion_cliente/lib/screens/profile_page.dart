import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class profile_page extends StatelessWidget {
  const profile_page({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    double screenWidth = MediaQuery.of(context).size.width;
    
    // Ancho responsivo para que no se vea vacío pero tampoco toque los bordes
    double containerWidth = screenWidth > 600 ? 400 : screenWidth * 0.88;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F172A),
            Color(0xFF1E293B),
            Color(0xFF334155),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Mi Perfil', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: SizedBox(
              width: containerWidth,
              child: Column(
                children: [
                  // --- CABECERA RECONECTADA A FIREBASE ---
                  _buildHeader(user),
                  
                  const SizedBox(height: 30),
                  
                  // --- BOTONES INDIVIDUALES (CÁPSULAS) ---
                  _buildMenuButton(Icons.person_outline, "Editar Información"),
                  _buildMenuButton(Icons.notifications_none, "Notificaciones"),
                  _buildMenuButton(Icons.lock_outline, "Privacidad"),
                  _buildMenuButton(Icons.help_outline, "Ayuda y Soporte"),
                  
                  const SizedBox(height: 25),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Divider(color: Colors.white10, thickness: 1),
                  ),
                  const SizedBox(height: 25),
                  
                  _buildLogoutButton(),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // WIDGET DE CABECERA: Aquí es donde recuperamos Nombre, Apellidos y Email
  Widget _buildHeader(User? user) {
    if (user == null) return const SizedBox();

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
        }

        // Valores por defecto si no hay datos o hay error
        String nombreCompleto = "Usuario";
        String email = user.email ?? "Sin correo";
        String iniciales = "U";

        if (snapshot.hasData && snapshot.data!.exists) {
          var data = snapshot.data!.data() as Map<String, dynamic>;
          
          String nombre = data['nombre'] ?? "";
          String apellidos = data['apellidos'] ?? "";
          email = data['email'] ?? user.email ?? "Sin correo";

          // Construimos el nombre completo
          if (nombre.isNotEmpty || apellidos.isNotEmpty) {
            nombreCompleto = "$nombre $apellidos".trim();
          }

          // Generamos iniciales para el avatar
          String iNombre = nombre.isNotEmpty ? nombre[0].toUpperCase() : "";
          String iApellido = apellidos.isNotEmpty ? apellidos[0].toUpperCase() : "";
          iniciales = (iNombre + iApellido).isEmpty ? "U" : iNombre + iApellido;
        }

        return Column(
          children: [
            // Círculo del Avatar
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blueAccent.withOpacity(0.5), width: 2),
              ),
              child: CircleAvatar(
                radius: 45,
                backgroundColor: const Color(0xFF64B5F6),
                child: Text(
                  iniciales,
                  style: const TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 15),
            // Nombre del usuario (recuperado de Firestore)
            Text(
              nombreCompleto,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            // Gmail del usuario
            Text(
              email,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54, fontSize: 16),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMenuButton(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(22),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  child: Row(
                    children: [
                      Icon(icon, color: const Color(0xFF64B5F6), size: 24),
                      const SizedBox(width: 15),
                      Text(
                        title,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 14),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: 180,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.redAccent.withOpacity(0.1),
          child: InkWell(
            onTap: () => FirebaseAuth.instance.signOut(),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.redAccent.withOpacity(0.2)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout, color: Colors.redAccent, size: 18),
                  SizedBox(width: 8),
                  Text("Cerrar Sesión", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}