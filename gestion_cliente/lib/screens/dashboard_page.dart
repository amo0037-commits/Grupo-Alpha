import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestion_cliente/screens/services_screen.dart';
import 'package:gestion_cliente/screens/profile_page.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

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

  final Map<String, Map<String, String>> rutasServicios = const {
    'Gimnasio': {'ruta': '/gimnasio', 'servicio': 'Gimnasio'},
    'Yoga': {'ruta': '/yoga', 'servicio': 'Yoga'},
    'Peluqueria': {'ruta': '/peluqueria', 'servicio': 'Peluqueria'},
    'Fisioterapia': {'ruta': '/fisioterapia', 'servicio': 'Fisioterapia'},
    'Academia': {'ruta': '/academia', 'servicio': 'Academia'},
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

  IconData getIcono(String negocio) {
    switch (negocio) {
      case 'Gimnasio':
        return Icons.fitness_center;
      case 'Yoga':
        return Icons.self_improvement;
      case 'Peluqueria':
        return Icons.content_cut;
      case 'Fisioterapia':
        return Icons.health_and_safety;
      case 'Academia':
        return Icons.school;
      default:
        return Icons.business;
    }
  }

  Widget buildAnimatedServiceCard(String negocio, double width) {
  final isHovering = _hoveringServicios[negocio] ?? false;
  bool isPressed = false;

  return StatefulBuilder(
    builder: (context, setLocalState) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hoveringServicios[negocio] = true),
        onExit: (_) => setState(() => _hoveringServicios[negocio] = false),
        child: GestureDetector(
          onTapDown: (_) => setLocalState(() => isPressed = true),
          onTapUp: (_) => setLocalState(() => isPressed = false),
          onTapCancel: () => setLocalState(() => isPressed = false),
          onTap: () {
            final data = rutasServicios[negocio];
            if (data != null) {
              Navigator.pushNamed(
                context,
                data['ruta']!,
                arguments: {
                  'userId': FirebaseAuth.instance.currentUser!.uid,
                  'negocio': data['servicio']!,
                },
              );
            }
          },
          child: AnimatedScale(
            scale: isPressed ? 0.95 : 1,
            duration: const Duration(milliseconds: 120),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              transform: Matrix4.translationValues(
                0,
                isHovering ? -6 : 0,
                0,
              ),
              width: width,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isHovering
                          ? Colors.white.withValues(alpha: 0.12)
                          : Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF64B5F6)
                            .withValues(alpha: 0.15),
                        child: Icon(
                          getIcono(negocio),
                          color: const Color(0xFF64B5F6),
                        ),
                      ),
                      title: Text(
                        negocio,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white70,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox();

    final screenWidth = MediaQuery.of(context).size.width;
    double sizeIcono = min(max(screenWidth * 0.06, 26), 42);

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFF1E293B),

      appBar: AppBar(
        toolbarHeight: 95,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E293B), Color(0xFF334155), Color(0xFF64B5F6)],
            ),
          ),
        ),
        title: SizedBox(
          height: 120,
          child: Image.asset(
            'assets/images/LogoAlphaAppPagInicio.png',
            fit: BoxFit.contain,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.info_outline,
              size: sizeIcono,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ServicePage()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.person, size: sizeIcono, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white.withValues(alpha: 0.15),
          ),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.build), text: 'Servicios'),
            Tab(icon: Icon(Icons.calendar_today), text: 'Reservas'),
          ],
        ),
      ),

      body: SizedBox.expand(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1E293B), Color(0xFF334155), Color(0xFF64B5F6)],
            ),
          ),
          child: SafeArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              child: _currentIndex == 0
                  ? _buildServiciosTab(user, screenWidth)
                  : _buildReservasTab(user, screenWidth),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiciosTab(User user, double screenWidth) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(bottom: 30),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                ),
                child: Column(
                  children: [
                    const FloatingHand(),
                    const SizedBox(height: 10),
                    const Text(
                      'Bienvenido/a',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            children: widget.negocios
                .map(
                  (n) => buildAnimatedServiceCard(
                    n,
                    screenWidth > 800 ? 300 : screenWidth * 0.95,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildReservaCard(
    String servicio,
    String clase,
    String hora,
    DateTime fecha,
    QueryDocumentSnapshot doc,
    double screenWidth,
  ) {
    return Center(
      child: SizedBox(
        width: screenWidth > 800 ? 500 : screenWidth * 0.95,
        child: Card(
          color: const Color(0xFF93C5FD),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ListTile(
            title: Text(servicio),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(clase),
                Text('📅 ${DateFormat('dd/MM/yyyy').format(fecha)}'),
                Text('⏰ $hora'),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('Eliminar reserva'),
                    content: const Text(
                      '¿Seguro que quieres eliminar esta reserva?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext, true),
                        child: const Text('Eliminar'),
                      ),
                    ],
                  ),
                );

                if (confirm != true) return;

                HapticFeedback.mediumImpact();

                try {
                  await FirebaseFirestore.instance
                      .collection('reservas')
                      .doc(doc.id)
                      .delete();

                  if (!mounted) return; // 👈 IMPORTANTE: usa mounted del STATE

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Reserva eliminada correctamente'),
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al eliminar: $e')),
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReservasTab(User user, double screenWidth) {
    final reservasQuery = FirebaseFirestore.instance
        .collection('reservas')
        .where('userId', isEqualTo: user.uid)
        .where('estado', isEqualTo: 'activa');

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: reservasQuery.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF64B5F6)),
          );
        }

        final reservas = snapshot.data!.docs;

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: reservas.isEmpty
              ? const Center(
                  key: ValueKey('empty'),
                  child: Text(
                    'No tienes reservas activas',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : ListView.builder(
                  key: const ValueKey('list'),
                  padding: const EdgeInsets.all(16),
                  itemCount: reservas.length,
                  itemBuilder: (context, index) {
                    final data = reservas[index].data();
                    final servicio = data['servicio'];
                    final clase = data['clase'];
                    final hora = data['hora'];
                    final fecha = (data['fecha'] as Timestamp).toDate();
                    final doc = reservas[index];

                    return _buildReservaCard(
                      servicio,
                      clase,
                      hora,
                      fecha,
                      doc,
                      screenWidth,
                    );
                  },
                ),
        );
      },
    );
  }
}

class FloatingHand extends StatefulWidget {
  const FloatingHand({super.key});

  @override
  State<FloatingHand> createState() => _FloatingHandState();
}

class _FloatingHandState extends State<FloatingHand>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _moveAnim;
  late Animation<double> _rotateAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _moveAnim = Tween<double>(
      begin: -6,
      end: 6,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _rotateAnim = Tween<double>(
      begin: -0.25,
      end: 0.25,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_moveAnim.value, 0),
          child: Transform.rotate(angle: _rotateAnim.value, child: child),
        );
      },
      child: const Icon(Icons.waving_hand, size: 40, color: Color(0xFF64B5F6)),
    );
  }
}
