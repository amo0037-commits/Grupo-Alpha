import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gestion_cliente/screens/worker_check_screen.dart';
class InicioWorker extends StatefulWidget {
  const InicioWorker({super.key});

  @override
  State<InicioWorker> createState() => _InicioWorkerState();
}

class _InicioWorkerState extends State<InicioWorker>
    with SingleTickerProviderStateMixin {
  late AnimationController _iconController;
  late Animation<double> _iconAnim;

  @override
  void initState() {
    super.initState();

    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _iconAnim = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.easeInOut),
    );

    _iconController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _iconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double logoSize = screenWidth < 600 ? screenWidth * 0.55 : 280;

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
          toolbarHeight: 80,
          backgroundColor: Colors.transparent,
          leadingWidth: 150,
          leading: Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Image.asset(
              'assets/images/Icono_AlphaApp.png',
              fit: BoxFit.contain,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white70),
              onPressed: () => FirebaseAuth.instance.signOut(),
            ),
            const SizedBox(width: 10),
          ],
        ),

        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Column(
                children: [
                  const SizedBox(height: 30),

                  // LOGO
                  Image.asset(
                    'assets/images/LogoAlphaAppPagInicio.png',
                    width: logoSize,
                  ),

                  const SizedBox(height: 30),

                  // 🧱 CARD GRANDE
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Center(
                      child: ClipOval(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Container(
                            width: 280, //
                            height: 280, //

                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 25,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),

                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AnimatedBuilder(
                                  animation: _iconAnim,
                                  builder: (context, child) {
                                    return Transform.translate(
                                      offset: Offset(0, -_iconAnim.value),
                                      child: child,
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.blueAccent.withValues(
                                        alpha: 0.15,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.blueAccent.withValues(
                                            alpha: 0.3,
                                          ),
                                          blurRadius: 20,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.work_outline,
                                      size: 40,
                                      color: Colors.blueAccent,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 12),

                                const Text(
                                  "Panel de trabajador",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Text(
                                    "Accede a tus herramientas",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  HoverButton(
                    icon: Icons.how_to_reg,
                    text: "Fichar entrada/salida",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WorkerCheckScreen(),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 20),
                  HoverButton(
                    icon: Icons.schedule,
                    text: "Agenda",
                    onTap: () {},
                  ),
                  SizedBox(height: 20),
                  HoverButton(icon: Icons.person, text: "Perfil", onTap: () {}),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  //
}

class HoverButton extends StatefulWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const HoverButton({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  State<HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<HoverButton> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    //
    double maxWidth = screenWidth > 600 ? 420 : double.infinity;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovering = true),
          onExit: (_) => setState(() => _isHovering = false),
          child: Transform.translate(
            offset: Offset(0, _isHovering ? -6 : 0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              child: GestureDetector(
                onTap: widget.onTap,
                child: Container(
                  height: 60,

                  padding: const EdgeInsets.symmetric(horizontal: 16),

                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    boxShadow: _isHovering
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            ),
                          ]
                        : [],
                  ),

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedScale(
                        scale: _isHovering ? 1.15 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(widget.icon, color: Colors.blueAccent),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        widget.text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
