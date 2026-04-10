import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestion_cliente/screens/services_screen.dart';
import 'package:gestion_cliente/screens/profile_page.dart';
import 'package:intl/intl.dart';


class DashboardPage extends StatefulWidget {
  final List<String> negocios;
  const DashboardPage({super.key, required this.negocios});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  final Map<String, String> rutasServicios = const {
    'Gimnasio': '/gimnasio',
    'Centro de Yoga': '/yoga',
    'Peluqueria': '/peluqueria',
    'Centro de Fisioterapia': '/fisioterapia',
    'Academia': '/academia',
  };

  final Map<String, bool> _hoveringServicios = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() => _currentIndex = _tabController.index);
      }
    });

    for (var n in widget.negocios) {
      _hoveringServicios[n] = false;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ICONOS PERSONALIZADOS
  IconData getIcono(String negocio) {
    switch (negocio) {
      case 'Gimnasio':
        return Icons.fitness_center;
      case 'Centro de Yoga':
        return Icons.self_improvement;
      case 'Peluqueria':
        return Icons.content_cut;
      case 'Centro de Fisioterapia':
        return Icons.health_and_safety;
      case 'Academia':
        return Icons.school;
      default:
        return Icons.business;
    }
  }

  Widget buildAnimatedServiceCard(String negocio, double width) {
    final isHovering = _hoveringServicios[negocio] ?? false;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hoveringServicios[negocio] = true),
      onExit: (_) => setState(() => _hoveringServicios[negocio] = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(0, isHovering ? -8 : 0, 0),
        width: width,
        child: Material(
          color: Colors.white,
          elevation: isHovering ? 10 : 4,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              final ruta = rutasServicios[negocio];
              if (ruta != null) {
                Navigator.pushNamed(context, ruta, arguments: {
                  'userId': FirebaseAuth.instance.currentUser!.uid,
                  'negocio': negocio,
                });
              }
            },
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFF1565C0).withOpacity(0.15),
                child: Icon(
                  getIcono(negocio),
                  color: const Color(0xFF1565C0),
                  size: 26,
                ),
              ),
              title: Text(
                negocio,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox();

    final screenWidth = MediaQuery.of(context).size.width;
    double sizeIcono = min(max(screenWidth * 0.06, 26), 42);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 95,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF9CA3AF), Color(0xFF4B5563)],
            ),
          ),
        ),

        // LOGO MÁS GRANDE
        title: SizedBox(
          height: 130,
          child: Image.asset(
            'assets/images/LogoAlphaAppPagInicio.png',
            fit: BoxFit.contain,
          ),
        ),

        actions: [
          IconButton(
            icon: Icon(Icons.info_outline, size: sizeIcono),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ServicePage()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.person, size: sizeIcono),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
            },
          ),
        ],

        // TABS CON ANIMACIÓN
        bottom: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white.withOpacity(0.2),
          ),
          tabs: const [
            Tab(icon: Icon(Icons.build), text: 'Servicios'),
            Tab(icon: Icon(Icons.calendar_today), text: 'Reservas'),
          ],
        ),
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0E3E7), Color(0xFF64B5F6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween(begin: 0.98, end: 1.0).animate(animation),
                child: child,
              ),
            );
          },
          child: _currentIndex == 0
              ? _buildServiciosTab(user, screenWidth)
              : _buildReservasTab(user, screenWidth),
        ),
      ),
    );
  }

  // =========================
  // SERVICIOS
  // =========================
  Widget _buildServiciosTab(User user, double screenWidth) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              children: [
                // HEADER MEJORADO
                Center(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: screenWidth > 1600 ? 1100 : screenWidth * 0.98,
                    ),
                    padding: const EdgeInsets.all(25),
                    margin: const EdgeInsets.only(bottom: 40),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.25),
                          Colors.white.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.grey.shade400, // borde del contenedor
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Emoji con borde
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(color: Colors.transparent,),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.waving_hand, size: 42, color: Colors.white),
                      ),
                      const SizedBox(height: 10),

                      // Texto "Bienvenido" con borde
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(color: Colors.transparent,),
                          borderRadius: BorderRadius.circular(8),
                        ),
                          child: const Text(
                            'Bienvenido',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Email del usuario con borde
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border.all(color: Colors.transparent,),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            user.email ?? '',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  children: widget.negocios
                      .map((negocio) => buildAnimatedServiceCard(
                          negocio,
                          screenWidth > 800
                              ? 300
                              : screenWidth * 0.95))
                      .toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // =========================
  // RESERVAS
  // =========================
  Widget _buildReservasTab(User user, double screenWidth) {
    final reservasQuery = FirebaseFirestore.instance
        .collection('reservas')
        .where('userId', isEqualTo: user.uid)
        .where('estado', isEqualTo: 'activa');

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: reservasQuery.snapshots(),
      builder: (context, snapshot) {
        return LayoutBuilder(
          builder: (context, constraints) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildSkeleton(constraints);
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return ConstrainedBox(
                constraints:
                    BoxConstraints(minHeight: constraints.maxHeight),
                child: const Center(
                  child: Text(
                    'No tienes reservas activas',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              );
            }

            final reservas = snapshot.data!.docs;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints:
                    BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  children: reservas.map((doc) {
                    final data = doc.data();
                    final servicio = data['servicio'];
                    final clase = data['clase'];
                    final hora = data['hora'];
                    final fecha = (data['fecha'] as Timestamp).toDate();


                    return Center(
                      child: SizedBox(
                        width: screenWidth > 800
                            ? 500
                            : screenWidth * 0.95,
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          child: ListTile(
                            title: Text('$servicio'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(clase),
                                Text('📅 ${DateFormat('dd/MM/yyyy').format(fecha)}'),
                                Text('⏰ $hora'),
                              ],
                            ),

                            trailing: IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.red),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Eliminar reserva'),
                                    content: const Text('¿Seguro que quieres eliminar esta reserva?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text('Cancelar'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        child: const Text('Eliminar',
                                          style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                    try {
                                      await FirebaseFirestore.instance
                                        .collection('reservas')
                                        .doc(doc.id)
                                        .delete();

                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Reserva eliminada correctamente'),
                                        ),
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Error al eliminar: $e'),
                                        ),
                                      );
                                    }
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSkeleton(BoxConstraints constraints) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: constraints.maxHeight),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 3,
        itemBuilder: (_, __) => Container(
          margin: const EdgeInsets.only(bottom: 15),
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}