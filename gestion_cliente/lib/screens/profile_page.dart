import 'package:flutter/material.dart';


class profile_page extends StatelessWidget {
  const profile_page({super.key});

  
@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // Sección de Cabecera
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.lightBlue,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            padding: const EdgeInsets.only(bottom: 30),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(''),
                ),
                const SizedBox(height: 15),
                const Text(
                  'Nombre de Usuario',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  'usuario@email.com',
                  style: TextStyle(color: Colors.grey[600]),
                ),
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
  