import 'dart:math';
import 'dart:ui';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Asegúrate de tener este import
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gestion_cliente/screens/dashboard_page.dart';
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
  
  // Variable para controlar el estado de carga al pulsar Dashboard
  bool _isLoadingDashboard = false;

  @override
  void initState() {
    super.initState();

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

  // Función para obtener negocios y navegar
  Future<void> _irAlDashboard() async {
    setState(() => _isLoadingDashboard = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          final data = userDoc.data() as Map<String, dynamic>;
          List<String> negocios = List<String>.from(data['negocios'] ?? []);

          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DashboardPage(negocios: negocios),
              ),
            );
          }
        } else {
          _mostrarMensaje("No se encontró tu perfil de usuario.");
        }
      }
    } catch (e) {
      _mostrarMensaje("Error al cargar datos: $e");
    } finally {
      if (mounted) setState(() => _isLoadingDashboard = false);
    }
  }

  void _mostrarMensaje(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    double sizeIcono = min(max(MediaQuery.of(context).size.width * 0.07, 24), 50);

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
          titleSpacing: 0,
          centerTitle: false,
          toolbarHeight: 100,
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
              icon: Icon(Icons.logout, size: sizeIcono),
              onPressed: () async => await FirebaseAuth.instance.signOut(),
            ),
            IconButton(
              icon: Icon(Icons.search, size: sizeIcono),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReservaPage())),
            ),
            IconButton(
              icon: Icon(Icons.info, size: sizeIcono),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ServicePage())),
            ),
            
            // BOTÓN DASHBOARD ACTUALIZADO
            _isLoadingDashboard 
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))),
                )
              : IconButton(
                  icon: Icon(Icons.calendar_month_outlined, size: sizeIcono),
                  onPressed: _irAlDashboard,
                ),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            double screenHeight = constraints.maxHeight;
            double screenWidth = constraints.maxWidth;

            double logoSize = screenWidth < 600 ? screenWidth * 0.9 : min(screenWidth * 0.5, 750);
            double textFontSize = screenWidth < 600 ? 24.0 : min(screenHeight * 0.05, 48);

            return SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: screenHeight * 0.05),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _logoAnim,
                        builder: (context, child) => Transform.scale(scale: _logoAnim.value, child: child),
                        child: Image.asset('assets/images/LogoAlphaAppPagInicio.png', width: logoSize, fit: BoxFit.contain),
                      ),
                      SizedBox(height: screenHeight * 0.2),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: screenHeight * 0.02),
                            color: const Color(0xFF4B5563).withAlpha(40),
                            child: SizedBox(
                              width: min(screenWidth * 0.6, 600),
                              child: DefaultTextStyle(
                                style: TextStyle(fontSize: textFontSize, fontWeight: FontWeight.bold, color: Colors.white),
                                child: AnimatedTextKit(
                                  animatedTexts: [
                                    ColorizeAnimatedText(
                                      'Bienvenido a AlphaApp',
                                      textAlign: TextAlign.center,
                                      textStyle: TextStyle(fontSize: textFontSize, fontWeight: FontWeight.bold, fontFamily: 'Roboto'),
                                      colors: [const Color(0xFF0D47A1), const Color(0xFF1565C0), const Color(0xFF64B5F6), const Color(0xFF9CA3AF)],
                                      speed: const Duration(milliseconds: 400),
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