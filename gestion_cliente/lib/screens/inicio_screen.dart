import 'dart:math';
import 'dart:ui';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gestion_cliente/screens/dashboard_page.dart';
import 'package:gestion_cliente/screens/reserva_screen.dart';
import 'package:gestion_cliente/screens/services_screen.dart';
import 'package:gestion_cliente/screens/profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PaginaInicio extends StatefulWidget {
  const PaginaInicio({super.key});

  @override
  State<PaginaInicio> createState() => _PaginaInicioState();
}

class _PaginaInicioState extends State<PaginaInicio>
    with SingleTickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _logoAnim;
  
  //Declarar la variable de estado para la carga
  bool _isLoadingDashboard = false;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _logoAnim = Tween<double>(
      begin: 0.97, // valor base móvil
      end: 1.03,   // valor máximo móvil
    ).chain(CurveTween(curve: Curves.easeInOut)).animate(_logoController);

    _logoController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }

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
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // Ajuste de tamaño del logo
    double logoSize = screenWidth < 600
        ? screenWidth * 0.9
        : min(screenWidth * 0.4, 800);

    // Ajuste de animación según tamaño de pantalla
    double scaleBegin = screenWidth < 600 ? 0.97 : 0.93;
    double scaleEnd = screenWidth < 600 ? 1.03 : 1.07;

    // Solo se actualiza Tween si cambió la pantalla
    _logoAnim = Tween<double>(begin: scaleBegin, end: scaleEnd)
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(_logoController);

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
              icon: Icon(Icons.logout, size: min(max(screenWidth * 0.07, 24), 50)),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
              },
            ),
            IconButton(
              icon: Icon(Icons.search, size: min(max(screenWidth * 0.07, 24), 50)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ReservaPage()),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.info, size: min(max(screenWidth * 0.07, 24), 50)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ServicePage()),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.person, size: min(max(screenWidth * 0.07, 24), 50)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const profile_page()),
                );
              },
            ),
       ],
        
            
            _isLoadingDashboard 
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Center(
                    child: SizedBox(
                      width: 20, 
                      height: 20, 
                      child: CircularProgressIndicator(
                        color: Colors.white, 
                        strokeWidth: 2
                      )
                    )
                  ),
                )
              : IconButton(
                  icon: Icon(Icons.calendar_month_outlined, size: min(max(screenWidth * 0.07, 24), 50)),
                  onPressed: _irAlDashboard,
                ),
          ],
        ),
        body: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: screenHeight),
            child: Center(
              child: AnimatedBuilder(
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
            ),
          ),
        ),
      ),
    );
  }
}


