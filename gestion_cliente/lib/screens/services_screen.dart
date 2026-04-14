import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ServicePage extends StatelessWidget {
  const ServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    final services = [
      {
        "image": "assets/images/peluqueriainfo2.png",
        "title": "Peluquería",
        "description": """En nuestra peluquería te ofrecemos mucho más que un simple corte de cabello: te brindamos una experiencia de cuidado, estilo y bienestar pensada especialmente para ti. Nuestro equipo de profesionales está altamente capacitado para asesorarte y ayudarte a encontrar el look que mejor se adapte a tu personalidad, tipo de rostro y estilo de vida.

Entre nuestros servicios encontrarás cortes modernos para mujer, hombre y niños, peinados para ocasiones especiales, tintes, mechas, balayage, alisados, tratamientos capilares nutritivos y reparadores, así como servicios de lavado y secado con productos de alta calidad.

Nos enfocamos en cuidar la salud de tu cabello, utilizando técnicas actuales y productos profesionales que garantizan resultados duraderos y un acabado impecable. Además, ofrecemos un ambiente cómodo, relajante y acogedor donde cada cliente recibe una atención personalizada.

Ya sea que quieras un cambio de imagen completo o simplemente mantener tu estilo, estamos aquí para ayudarte a lucir y sentirte mejor que nunca. ¡Ven y descubre por qué nuestros clientes nos eligen una y otra vez!""",
      },
      {
        "image": "assets/images/clinicafisioinfo.png",
        "title": "Clínica de fisioterapia",
        "description": """En nuestra clínica de fisioterapia te ofrecemos un servicio profesional enfocado en mejorar tu salud, aliviar el dolor y ayudarte a recuperar tu bienestar físico. Nuestro objetivo es acompañarte en cada etapa de tu recuperación con tratamientos personalizados y eficaces.

Contamos con fisioterapeutas altamente cualificados que evalúan cada caso de forma individual para diseñar un plan de tratamiento adaptado a tus necesidades. Tratamos lesiones musculares, problemas articulares, dolores de espalda, rehabilitación postquirúrgica, lesiones deportivas y mucho más.

Utilizamos técnicas avanzadas de fisioterapia manual, terapia física, ejercicios terapéuticos y métodos de rehabilitación modernos que favorecen una recuperación segura y duradera.

Nuestro compromiso es mejorar tu calidad de vida, reducir el dolor y prevenir futuras lesiones, todo en un entorno profesional, tranquilo y cercano donde cada paciente recibe una atención personalizada.

Aquí no solo tratamos tu lesión, te ayudamos a recuperar tu movilidad, tu fuerza y tu bienestar para que vuelvas a tu día a día con total confianza. ¡Tu salud es nuestra prioridad!
""",
      },
      {
        "image": "assets/images/gimnasioinfo.png",
        "title": "Gimnasio",
        "description": """En nuestro gimnasio te ofrecemos mucho más que un lugar para entrenar: te brindamos una experiencia completa de salud, energía y transformación personal. Nuestro objetivo es ayudarte a alcanzar tu mejor versión, sin importar tu nivel de condición física.

Contamos con una amplia variedad de áreas y actividades diseñadas para adaptarse a tus necesidades: sala de musculación totalmente equipada, zonas de cardio, entrenamiento funcional, clases dirigidas como spinning, zumba, HIIT, pilates y entrenamiento personalizado con entrenadores cualificados.

Nuestro equipo de profesionales te acompañará en todo momento, creando rutinas adaptadas a tus objetivos, ya sea perder peso, ganar masa muscular, mejorar tu resistencia o simplemente mantenerte activo y saludable.

Además, ofrecemos un ambiente motivador, moderno y seguro, donde cada persona se siente parte de una comunidad que impulsa el esfuerzo, la constancia y la superación diaria.

Aquí no solo entrenas tu cuerpo, también fortaleces tu mente y tu confianza. ¡Empieza hoy tu cambio y descubre todo lo que eres capaz de lograr con nosotros!""",
      },
      {
        "image": "assets/images/yogainfo.png",
        "title": "Yoga y Pilates",
        "description": """En nuestra academia de yoga te ofrecemos un espacio diseñado para el equilibrio, la calma y el bienestar integral. Nuestro objetivo es ayudarte a conectar cuerpo, mente y respiración a través de la práctica consciente del yoga.

Contamos con clases para todos los niveles, desde principiantes hasta avanzados, donde aprenderás diferentes estilos como hatha yoga, vinyasa, yoga suave y técnicas de meditación y respiración. Cada sesión está guiada por instructores cualificados que te acompañan en tu progreso de forma personalizada.

El yoga en nuestra academia no solo mejora la flexibilidad y la fuerza, sino que también ayuda a reducir el estrés, mejorar la concentración y promover una vida más saludable y equilibrada.

Ofrecemos un ambiente tranquilo, armonioso y acogedor, ideal para desconectar de la rutina diaria y reconectar contigo mismo. Cada clase está pensada para que avances a tu propio ritmo, respetando tu cuerpo y tus necesidades.

Aquí no solo practicas yoga, cultivas bienestar, paz interior y una mejor calidad de vida. ¡Empieza hoy tu camino hacia una versión más equilibrada y consciente de ti mismo!""",
      },
      {
        "image": "assets/images/academiainfo.png",
        "title": "Academia",
        "description": """En nuestra academia te ofrecemos un espacio dedicado al aprendizaje, la mejora académica y el desarrollo personal. Nuestro objetivo es ayudarte a alcanzar tus metas educativas con apoyo constante, métodos eficaces y un ambiente motivador.

Contamos con profesores cualificados que imparten clases adaptadas a las necesidades de cada alumno, reforzando conocimientos y resolviendo dudas de forma personalizada. Ofrecemos apoyo en diferentes materias, técnicas de estudio, preparación de exámenes y seguimiento continuo del progreso.

Nuestro enfoque se basa en la atención individualizada, adaptando el ritmo de aprendizaje a cada estudiante para garantizar mejores resultados y una comprensión real de los contenidos.

Además, fomentamos la confianza, la constancia y la motivación, creando un entorno cercano donde aprender se vuelve más fácil y efectivo.

Aquí no solo mejoras tus notas, también desarrollas habilidades y seguridad para tu futuro académico. ¡Empieza hoy a construir tus objetivos con nosotros!""",
      },
    ];

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
          title: const Text(
            'Servicios disponibles',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white70),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 950),
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: services.length,
              itemBuilder: (context, index) {
                final service = services[index];

                return ServiceCard(
                  imagePath: service["image"]!,
                  title: service["title"]!,
                  description: service["description"]!,
                )
                    .animate(delay: (index * 200).ms)
                    .fade(duration: 800.ms)
                    .slideY(begin: 0.4, end: 0);
              },
            ),
          ),
        ),
      ),
    );
  }
}

class ServiceCard extends StatefulWidget {
  final String imagePath;
  final String title;
  final String description;

  const ServiceCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.description,
  });

  @override
  State<ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withOpacity(0.15),
            ),
          ),
          child: isMobile ? _buildMobile() : _buildDesktop(),
        ),
      ),
    );
  }

  Widget _buildMobile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildImage(200),
        const SizedBox(height: 12),

        Text(
          widget.title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white.withOpacity(0.9),
          ),
        ),

        const SizedBox(height: 10),

        Text(
          widget.description,
          textAlign: TextAlign.center,
          maxLines: isExpanded ? null : 4,
          overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.white70,
          ),
        ),

        TextButton(
          onPressed: () {
            setState(() {
              isExpanded = !isExpanded;
            });
          },
          child: Text(
            isExpanded ? "Mostrar menos" : "Mostrar más",
            style: const TextStyle(color: Color(0xFF60A5FA)),
          ),
        ),

        const SizedBox(height: 10),

        GestureDetector(
          onTap: () {},
          child: Container(
            height: 46,
            width: 170,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF3B82F6),
                  Color(0xFF60A5FA),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blueAccent.withOpacity(0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                "Reservar",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ).animate().fade(delay: 400.ms).scale(delay: 400.ms),
      ],
    );
  }

  Widget _buildDesktop() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            _buildImage(220),
            const SizedBox(height: 10),
            Text(
              widget.title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),

        const SizedBox(width: 20),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.description,
                maxLines: isExpanded ? null : 4,
                overflow: isExpanded
                    ? TextOverflow.visible
                    : TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),

              TextButton(
                onPressed: () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
                child: Text(
                  isExpanded ? "Mostrar menos" : "Mostrar más",
                  style: const TextStyle(color: Color(0xFF60A5FA)),
                ),
              ),

              const SizedBox(height: 10),

              GestureDetector(
                onTap: () {},
                child: Container(
                  height: 46,
                  width: 170,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF3B82F6),
                        Color(0xFF60A5FA),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueAccent.withOpacity(0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      "Reservar",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ).animate().fade(delay: 300.ms).scale(delay: 300.ms),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImage(double width) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(
        widget.imagePath,
        width: width,
        fit: BoxFit.contain,
      ),
    );
  }
}