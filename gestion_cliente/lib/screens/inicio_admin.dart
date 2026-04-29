
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InicioAdmin extends StatelessWidget {
  const InicioAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E293B),
            Color(0xFF334155),
            Color(0xFF64B5F6),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,

          leadingWidth: 160,
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
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
              },
            ),
            const SizedBox(width: 10),
          ],
        ),

        body: Center(
          child: SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    
                    
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withValues(alpha: 0.4),
                            blurRadius: 35,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/moureperfil.png',
                        width: 200,
                      ),
                    ),

                    
                    Positioned(
                      top: -100,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            constraints: const BoxConstraints(maxWidth: 280),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 15,
                                ),
                              ],
                            ),
                            child: const Text(
                              "Todavía no podemos administrar, gracias por su paciencia",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                          ),

                          // 🔺 TRIÁNGULO GLASS
                          CustomPaint(
                            size: const Size(20, 20),
                            painter: _TrianglePainter(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class _TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.12);

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}