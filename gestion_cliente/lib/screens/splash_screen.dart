import 'package:flutter/material.dart';
import 'dart:async';
import 'package:gestion_cliente/screens/inicio_screen.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  double _opacity = 0.0;
  double _scale = 0.5;

  @override
  void initState() {
    super.initState();

    // Inicia la animación del logo
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        _opacity = 1.0;
        _scale = 1.0;
      });
    });

    _cargarApp();
  }

  // Espera 3 segundos y nos dirige a la pantalla de inicio.
  Future<void> _cargarApp() async {
    await Future.delayed(const Duration(seconds: 3));
    //Hace que el usuario no pueda volver a esta pantalla luego de que se haya mostrado
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const PaginaInicio()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0E3E7), Color(0xFF64B5F6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedOpacity(
              duration: const Duration(seconds: 1),
              opacity: _opacity,
              child: AnimatedScale(
                duration: const Duration(seconds: 1),
                scale: _scale,
                curve: Curves.easeOutBack, // con esto el logo " rebota" un poco
                child: Image.asset(
                  'assets/images/LogoAlphaAppPagInicio.png',
                  width: MediaQuery.of(context).size.width * 0.9,
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Se añade de flutter spinkit una barra de carga mas elaborada, hay que envolverla en un ShaderMask para darle 
            //degradado , si no el elemento spinkit solo acepta un color.
            ShaderMask(
              shaderCallback: (rect) {
                return LinearGradient(
                  colors: [
                    const Color(0xFF2F343B),
                    const Color(0xFF4B5563),
                    const Color(0xFF6C7080),
                    Color(0xFF1565C0),
                  ],
                ).createShader(Rect.fromLTWH(0, 0, rect.width, rect.height));
              },
              child: SpinKitWave(
                color: Colors
                    .white, 
                size: 50.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
