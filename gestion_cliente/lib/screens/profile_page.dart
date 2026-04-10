import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



class profile_page extends StatelessWidget {
  const profile_page({super.key});
  

  
@override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        centerTitle: true,
        elevation: 0,
        foregroundColor: Colors.black,
        // 1. Quitamos el backgroundColor sólido y usamos flexibleSpace
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,   // Inicia a la izquierda
              end: Alignment.centerRight,    // Termina a la derecha
              colors: [
                Color(0xFF9CA3AF),           // Color gris original
                Color(0xFF4B5563),           // Color azul claro
              ],
            ),
          ),
        ),
      ),
      
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,    // Inicia arriba
            end: Alignment.bottomCenter, // Termina abajo
            colors: [
              Color(0xFFE0E3E7), // Color claro arriba
              Color(0xFF64B5F6), // El azul oscuro que tenías abajo
            ],
          ),
        ),
        
        child: Column(
        children: [
          // Sección de Cabecera
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient (
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              colors: [
               Color(0xFF64B5F6),
               Color(0xFFE0E3E7),
               ],
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            padding: const EdgeInsets.only(bottom: 30),
            child: Column(
              children: [
                const SizedBox(height: 15,),
                const SizedBox(height: 15),
               FutureBuilder<DocumentSnapshot>(
  future: FirebaseFirestore.instance
      .collection('users')
      .doc(user!.uid)
      .get(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const CircularProgressIndicator();
    }

    if (!snapshot.hasData || !snapshot.data!.exists) {
      return const Text("No hay datos");
    }

    var data = snapshot.data!.data() as Map<String, dynamic>;

    String nombre = data['nombre'] ?? "Nombre de Usuario";
    String apellido = data['apellidos'] ?? "Nombre de Usuario";
    String email = data['email'] ?? user.email ?? "";

    String iniciales = "";
            if (nombre.isNotEmpty) iniciales += nombre[0].toUpperCase();
            if (apellido.isNotEmpty) iniciales += apellido[0].toUpperCase();
            if (iniciales.isEmpty) iniciales = "U"; // "U" de Usuario por defecto

    return Column(
      children: [
        CircleAvatar(
                        radius: 50,
                        backgroundColor: Color(0xFF64B5F6),
                        child: Text(
                          iniciales,
                          style: const TextStyle(
                            fontSize: 35,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
        Text(
        [nombre, apellido].where((e) => e.isNotEmpty).join(" "),
        style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        ),
      ),

        Text(
          email,
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  },
)
              ],
                ),
          ),
              
    

          const SizedBox(height: 20),


          // Sección de Opciones
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildOption(Icons.person_outline, "Editar Información"),
                _buildOption(Icons.notifications_none, "Notificaciones"),
                _buildOption(Icons.lock_outline, "Privacidad"),
                _buildOption(Icons.help_outline, "Ayuda y Soporte"),
                const Divider(height: 40),
                _buildOption(Icons.logout, "Cerrar Sesión", isDestructive: true),
              ],
            ),
          ),
          ],
    ),
      ),
    );
     
  }

  // Widget auxiliar para no repetir código de los botones
  Widget _buildOption(IconData icon, String title, {bool isDestructive = false}) {
    final color = isDestructive ? Colors.red : Colors.black87;
    
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(color: color, fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () {
        // Aquí iría la navegación
      },
    );
  }
}
  
