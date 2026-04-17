import 'package:flutter/material.dart';

class AcademiaInfo extends StatefulWidget {
  const AcademiaInfo({super.key});

  @override
  State<AcademiaInfo> createState() => _AcademiaInfoState();
}

class _AcademiaInfoState extends State<AcademiaInfo>
    with SingleTickerProviderStateMixin {
  final Color neonBlue = const Color(0xFF64B5F6);
  final Color neonOrange = const Color(0xFFFFA726);

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final List<Map<String, String>> clases = [
    {"title": "Matemáticas", "image": "assets/images/estudianteMoure.png"},
    {"title": "Inglés", "image": "assets/images/estudianteMoure.png"},
    {"title": "Repaso general", "image": "assets/images/estudianteMoure.png"},
  ];

  final List<Map<String, String>> refuerzo = [
    {"title": "Exámenes", "image": "assets/images/estudianteMoure.png"},
    {"title": "Técnicas de estudio", "image": "assets/images/estudianteMoure.png"},
    {"title": "Tutorías", "image": "assets/images/estudianteMoure.png"},
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.92,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
          title: Text(
            "Academia",
            style: TextStyle(
              color: neonOrange,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(color: neonOrange, blurRadius: 10),
                const Shadow(
                  color: Colors.black,
                  blurRadius: 6,
                  offset: Offset(2, 2),
                ),
              ],
            ),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white70),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),

        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),

            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🎬 BANNER CON LOGO + GLOW SUAVE
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        children: [
                          Image.asset(
                            "assets/images/academiainfo.png",
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),

                          Container(
                            height: 200,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withOpacity(0.75),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),

                          Positioned.fill(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  // TEXTO
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: Text(
                                      "Aprende a tu ritmo",
                                      style: TextStyle(
                                        color: neonOrange,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        shadows: [
                                          Shadow(
                                            color: neonOrange,
                                            blurRadius: 10,
                                          ),
                                          const Shadow(
                                            color: Colors.black,
                                            blurRadius: 8,
                                            offset: Offset(2, 2),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // LOGO CON GLOW SUAVE
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color: neonOrange.withOpacity(0.22),
                                            blurRadius: 16,
                                            spreadRadius: 0.5,
                                          ),
                                        ],
                                      ),
                                      child: Image.asset(
                                        "assets/images/LogoAlphaAppAcademia.png",
                                        height: 85,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 🧠 INTRODUCCIÓN
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    child: Text(
                      "En nuestra academia te ayudamos a mejorar tu rendimiento académico con un enfoque personalizado. "
                      "Ofrecemos clases adaptadas a tu nivel, apoyo continuo y técnicas de estudio efectivas para que "
                      "consigas tus objetivos con seguridad y confianza. Aprende, mejora y destaca con nosotros.",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 15,
                        height: 1.5,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 📚 CLASES
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "Clases disponibles",
                      style: TextStyle(
                        color: neonBlue,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(color: neonBlue, blurRadius: 10),
                          const Shadow(color: Colors.black, blurRadius: 6),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    height: 210,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: clases.length,
                      itemBuilder: (context, index) {
                        final item = clases[index];
                        return _buildCard(item["title"]!, item["image"]!);
                      },
                    ),
                  ),

                  const SizedBox(height: 25),

                  // 🧠 REFUERZO
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "Refuerzo y apoyo",
                      style: TextStyle(
                        color: neonBlue,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(color: neonBlue, blurRadius: 10),
                          const Shadow(color: Colors.black, blurRadius: 6),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    height: 210,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: refuerzo.length,
                      itemBuilder: (context, index) {
                        final item = refuerzo[index];
                        return _buildCard(item["title"]!, item["image"]!);
                      },
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(String title, String image) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 12),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              image,
              height: 140,
              width: 150,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            title,
            style: TextStyle(
              color: neonBlue,
              fontWeight: FontWeight.w600,
              shadows: [
                Shadow(color: neonBlue, blurRadius: 8),
                const Shadow(color: Colors.black, blurRadius: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}