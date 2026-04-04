import 'package:flutter/material.dart';
import 'package:gestion_cliente/core/app_colors.dart';
import 'package:gestion_cliente/screens/login_screen.dart';
import 'package:gestion_cliente/screens/reserva_screen.dart';

class PaginaInicio extends StatelessWidget {
  const PaginaInicio({super.key});

  @override
  Widget build(BuildContext context) {
    //Variable para el tamaño de los iconos en el AppBar
    double sizeIcono = MediaQuery.of(context).size.width * 0.08;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE0E3E7), Color(0xFF64B5F6)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          titleSpacing:
              0, // Elimina el espacio predeterminado a la izquierda del título
          centerTitle: false, // Alinea el título a la izquierda
          toolbarHeight:
              100, // Aumenta la altura del AppBar para acomodar el logo
          title: SizedBox(
            height: 80,
            child: Image.asset(
              'assets/images/LogoAlphaAppPagInicio.png',
              height: 165,
              fit: BoxFit.contain,
            ),
          ),
          backgroundColor: Colors.transparent,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF9CA3AF),Color(0xFF4B5563) ],
              ),
            ),
          ),

          actions: [
            IconButton(
              icon: Icon(Icons.person, size: sizeIcono),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.search, size: sizeIcono),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ReservaPage()),
                );
              },
            ),
          ],
        ),

        // SinglechildScrollView para permitir scroll en caso de pantallas pequeñas.
        body: SingleChildScrollView(
          child: Center(
            /* Se ha quitado el antiguo Container y su  height: MediaQuery.of(context).size.height - 100, porque 
            forzaba a la pantalla a tener una altura fija, lo que causaba overflow en pantallas pequeñas.
             Ahora el contenido se adapta al tamaño disponible, y el SingleChildScrollView permite hacer scroll 
             si es necesario.
            */
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment
                    .center, // Alinea el contenido al final del contenedor

                children: [
                  const SizedBox(
                    height: 60,
                  ), // Mover el contenido hacia abajo para dejar espacio al logo en el AppBar

                  Image.asset(
                    'assets/images/LogoAlphaAppPagInicio.png',
                    /* se ha cambiado el width de 800 a esto porque puede dar problemas con moviles, con este
                     codigo calcula el ancho de la pantalla y lo multiplica por 0,8 (80%), haciendo que ocupe el 80%
                     de la pantalla evitando desbordamientos en telefonos con pantallas pequeñas  */
                    width: MediaQuery.of(context).size.width * 0.8,

                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 60),

                  const Text(
                    'Bienvenido a AlphaApp',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'La app para gestionar tu negocio de forma fiable',
                    style: TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
