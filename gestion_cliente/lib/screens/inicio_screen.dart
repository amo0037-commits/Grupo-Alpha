import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gestion_cliente/screens/auth/login_screen.dart';
import 'package:gestion_cliente/core/app_colors.dart';
import 'package:gestion_cliente/screens/login_screen.dart';
import 'package:gestion_cliente/screens/reserva_screen.dart';

class PaginaInicio extends StatelessWidget {
  const PaginaInicio({super.key});

  @override
  Widget build(BuildContext context) {
    //Variable para el tamaño de los iconos en el AppBar
    double sizeIcono = min(MediaQuery.of(context).size.width * 0.07, 70);
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
                colors: [Color(0xFF9CA3AF), Color(0xFF4B5563)],
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
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  const SizedBox(height: 60),

                  Image.asset(
                    'assets/images/LogoAlphaAppPagInicio.png',
                    /* se ha cambiado el width de 800 a esto porque puede dar problemas con moviles, con este
                     codigo calcula el ancho de la pantalla y lo multiplica por 0,8 (80%), haciendo que ocupe el 80%
                     de la pantalla evitando desbordamientos en telefonos con pantallas pequeñas  */
                    width: MediaQuery.of(context).size.width * 0.8,

                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 60),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        color: Color(0xFF4B5563).withAlpha(40),
                        
                        child: ShaderMask(
                          shaderCallback: (rect) {
                            return LinearGradient(
                              colors: [  Color(0xFF0D47A1), Color(0xFF1565C0) ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(
                              Rect.fromLTWH(0, 0, rect.width, rect.height),
                            );
                          },
                          blendMode: BlendMode.srcIn,
                          child: const Text(
                            'Bienvenido a AlphaApp',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'La app para gestionar tu negocio de forma fiable',
                    style: TextStyle(
                      fontSize: 20,
                      color: Color(0xFF0D47A1),
                      shadows: [
                        Shadow(
                          offset: Offset(1, 1),
                          blurRadius: 2,
                          color: Colors.black12,
                        ),
                      ],
                    ),
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
