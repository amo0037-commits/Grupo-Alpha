import 'package:flutter/material.dart ';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gestion_cliente/screens/inicio_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _opacityAnim;
  late Animation<double> _rotationAnim;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _scaleAnim = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).chain(CurveTween(curve: Curves.elasticOut)).animate(_controller);

    _opacityAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _rotationAnim = Tween<double>(
      begin: -0.05,
      end: 0.05,
    ).chain(CurveTween(curve: Curves.easeInOut)).animate(_controller);

    _glowAnim = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Repetir animación de glow y rotación
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.repeat(reverse: true);
      }
    });

    _controller.forward();

    _cargarApp();
  }

  Future<void> _cargarApp() async {
    await Future.delayed(const Duration(seconds: 3));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const PaginaInicio()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxLogoWidth = 300.0; // máximo para logo
    double logoWidth = (screenWidth * 0.9).clamp(250, 400).toDouble();
    double spinSize = (screenWidth * 0.1).clamp(30, 60).toDouble();

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
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                double glowSize = (logoWidth * _glowAnim.value).clamp(150, 350).toDouble();

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Glow pulsante detrás del logo
                    Container(
                      width: glowSize,
                      height: glowSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF1976D2).withAlpha(180),
                            const Color(0xFF42A5F5).withAlpha(130),
                            const Color(0xFF90CAF9).withAlpha(50),
                            Colors.transparent, // borde totalmente difuminado
                          ],
                          stops: const [0.0, 0.3, 0.6, 1.0],
                        ),
                      ),
                    ),
                    // Logo con animación de escala, rotación y opacidad
                    Opacity(
                      opacity: _opacityAnim.value,
                      child: Transform.rotate(
                        angle: _rotationAnim.value,
                        child: Transform.scale(
                          scale: _scaleAnim.value,
                          child: child,
                        ),
                      ),
                    ),
                  ],
                );
              },
              child: Image.asset(
                'assets/images/LogoAlphaAppPagInicio.png',
                width: logoWidth,
              ),
            ),
            const SizedBox(height: 30),
            ShaderMask(
              shaderCallback: (rect) {
                return const LinearGradient(
                  colors: [
                    Color(0xFF2F343B),
                    Color(0xFF4B5563),
                    Color(0xFF6C7080),
                    Color(0xFF1565C0),
                  ],
                ).createShader(Rect.fromLTWH(0, 0, rect.width, rect.height));
              },
              child:  SpinKitWave(color: Colors.white, size: spinSize),
            ),
          ],
        ),
      ),
    );
  }
}
