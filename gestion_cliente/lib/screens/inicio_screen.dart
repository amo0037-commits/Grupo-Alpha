import 'dart:math';
import 'dart:ui';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:gestion_cliente/core/app_colors.dart';
import 'package:gestion_cliente/screens/login_screen.dart';
import 'package:gestion_cliente/screens/reserva_screen.dart';
import 'package:gestion_cliente/screens/services_screen.dart';

class PaginaInicio extends StatefulWidget {
  const PaginaInicio({super.key});

  @override
  State<PaginaInicio> createState() => _PaginaInicioState();
}

class _PaginaInicioState extends State<PaginaInicio>
    with SingleTickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _logoAnim;

  bool _showText = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _showText = true;
      });
    });

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _logoAnim = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).chain(CurveTween(curve: Curves.easeInOut)).animate(_logoController);

    _logoController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //Variable para el tamaño de los iconos en el AppBar
    double sizeIcono = min(
      max(MediaQuery.of(context).size.width * 0.07, 24),
      50,
    );
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
             IconButton(
              icon: Icon(Icons.info, size: sizeIcono),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ServicePage()),
                );
              },
            ),  
          ],
        ),

        // SinglechildScrollView para permitir scroll en caso de pantallas pequeñas.
        body: LayoutBuilder(
          builder: (context, constraints) {
            double screenHeight = constraints.maxHeight;
            double screenWidth = constraints.maxWidth;

            double logoSize = screenWidth < 600
                ? screenWidth *
                      0.9 // Telefono ocupa mas
                : min(screenWidth * 0.5, 750); // PC: máximo 750px

            double textFontSize = screenWidth < 600
                ? 24.0 // móvil
                : min(screenHeight * 0.05, 48); // PC
            double spacing = screenHeight * 0.05;

            return SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: screenHeight * 0.05,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo animado
                      AnimatedBuilder(
                        animation: _logoAnim,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _logoAnim.value,
                            child: child,
                          );
                        },
                        child: Image.asset(
                          'assets/images/LogoAlphaAppPagInicio.png',
                          width: logoSize,
                          fit: BoxFit.contain,
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.2),

                      // Texto animado con fondo difuminado
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.05,
                              vertical: screenHeight * 0.02,
                            ),
                            color: Color(0xFF4B5563).withAlpha(40),
                            child: SizedBox(
                              width: min(
                                screenWidth * 0.6,
                                600,
                              ), // ancho máximo para PC
                              child: DefaultTextStyle(
                                style: TextStyle(
                                  fontSize: textFontSize,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                child: AnimatedTextKit(
                                  animatedTexts: [
                                    ColorizeAnimatedText(
                                      'Bienvenido a AlphaApp',
                                      textAlign: TextAlign.center,
                                      textStyle: TextStyle(
                                        fontSize: textFontSize,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Roboto',
                                      ),
                                      colors: [
                                        Color(0xFF0D47A1),
                                        Color(0xFF1565C0),
                                        Color(0xFF64B5F6),
                                        Color(0xFF9CA3AF),
                                      ],
                                      speed: Duration(milliseconds: 400),
                                    ),
                                  ],
                                  repeatForever: true,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
