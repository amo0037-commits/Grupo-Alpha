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

class PaginaInicio extends StatefulWidget {
  const PaginaInicio({super.key});

  @override
  State<PaginaInicio> createState() => _PaginaInicioState();
}

class _PaginaInicioState extends State<PaginaInicio>
    with SingleTickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _logoAnim;
  bool _isLoadingDashboard = false;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
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

    double logoSize = screenWidth < 600
        ? screenWidth * 0.7
        : min(screenWidth * 0.3, 400);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E293B), Color(0xFF334155), Color(0xFF64B5F6)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          elevation: 0,
          toolbarHeight: 100, // Altura generosa para el logo
          backgroundColor: Colors.transparent,
          leadingWidth: screenWidth * 0.5, // Le damos más espacio al logo
          leading: Padding(
            padding: const EdgeInsets.only(left: 20, top: 10),
            child: Image.asset(
              'assets/images/Icono_AlphaApp.png',
              fit: BoxFit.contain,
              alignment: Alignment.centerLeft,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white70),
              onPressed: () => FirebaseAuth.instance.signOut(),
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
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
            ),
        
            
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
                      ),
          ],
        
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // --- SECCIÓN HERO ---
              SizedBox(
                height: screenHeight * 0.5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _logoAnim,
                      builder: (context, child) => Transform.scale(
                        scale: _logoAnim.value,
                        child: child,
                      ),
                      child: Image.asset(
                        'assets/images/LogoAlphaAppPagInicio.png',
                        width: logoSize,
                      ),
                    ),
                    const SizedBox(height: 30),
                    DefaultTextStyle(
                      style: const TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.w300,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                      child: AnimatedTextKit(
                        animatedTexts: [
                          TypewriterAnimatedText('Bienvenido a AlphaApp'),
                          TypewriterAnimatedText('Gestión inteligente'),
                          TypewriterAnimatedText('Tu negocio, bajo control'),
                        ],
                        repeatForever: true,
                      ),
                    ),
                  ],
                ),
              ),

              // --- SECCIÓN DE TARJETAS ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Accesos rápidos",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: screenWidth > 600 ? 4 : 2,
                      mainAxisSpacing: 15,
                      crossAxisSpacing: 15,
                      children: [
                        _buildQuickCard(
                          Icons.calendar_month, 
                          "Mi Agenda", 
                          _irAlDashboard,
                          
                        ),
                        _buildQuickCard(
                          Icons.search, 
                          "Reservas", 
                          () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ReservaPage())),
                        ),
                        _buildQuickCard(
                          Icons.info_outline, 
                          "Información", 
                          () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ServicePage())),
                        ),
                        _buildQuickCard(
                          Icons.person_outline, 
                          "Mi Perfil", 
                          () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage())),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickCard(IconData icon, String title, VoidCallback onTap, {bool isLoading = false}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                isLoading 
                  ? const SizedBox(
                      width: 24, 
                      height: 24, 
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                    )
                  : Icon(icon, size: 46, color: Colors.blueAccent), // Tamaño del icono de las tarjetas
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22, // Tamaño del texto de las tarjetas
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}