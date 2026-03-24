import 'package:flutter/material.dart';
import 'package:gestion_cliente/screens/login_screen.dart';

class PaginaInicio extends StatelessWidget {
  const PaginaInicio({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0, // Elimina el espacio predeterminado a la izquierda del título
        centerTitle: false, // Alinea el título a la izquierda
        toolbarHeight: 100, // Aumenta la altura del AppBar para acomodar el logo
        title: SizedBox(
          height: 120, 
          child: Image.asset(
            'assets/images/Icono_AlphaApp.png',
            height: 65,
            alignment: Alignment.topLeft, //Se posiciona el logo en la parte superior izquierda del AppBar
            fit: BoxFit.contain, 
          ),
        ),
       
        actions: [
          IconButton(
            icon: const Icon(Icons.person, size: 45, color: Color(0xFF1565C0)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            height: MediaQuery.of(context).size.height - 100, // Ajusta la altura del contenedor    
           padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Alinea el contenido al final del contenedor
           
              children: [
                const SizedBox(height: 60), // Mover el contenido hacia abajo para dejar espacio al logo en el AppBar

                Image.asset('assets/images/LogoAlphaAppPagInicio.png', 
               width: 800, 
             
               fit: BoxFit.contain,
               ),
               const SizedBox(height: 60),
              
              
               const Text('Bienvenido a AlphaApp', style: TextStyle(fontSize: 28, 
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 14, 76, 146))
                ),
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
      ),
    );
  }
}
