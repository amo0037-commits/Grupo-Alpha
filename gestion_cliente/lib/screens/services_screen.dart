import 'package:flutter/material.dart';


class ServicePage extends StatelessWidget {
  const ServicePage({super.key});

  @override
  Widget build(BuildContext context) {
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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Servicios disponibles'),
          backgroundColor: Colors.transparent,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF9CA3AF), Color(0xFF4B5563)],
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors:[ Color(0xFF9CA3AF), Color(0xFF4B5563)],
                ),
                borderRadius: BorderRadius.circular(
                  12,
                ), 
              ),
              child: Column(
                children: const [
                  ServiceRow(
                    imagePath: 'assets/images/peluqueriainfo2.png',
                    title: 'Peluquería',
                    description:
                       '\n Realza tu belleza con nuestro servicio de peluquería y estética: \n\n Te ofrecemos atención personalizada y profesional para que luzcas increíble en cada ocasión: \n cortes modernos, peinados, coloración, tratamientos capilares y mucho más.',
                  ),
                  SizedBox(height: 60),
                  ServiceRow(
                    imagePath: 'assets/images/clinicafisioinfo.png',
                    title: 'Clínica de fisioterapia',
                    description:
                        ' \n Recupera tu bienestar y mantener un ritmo saludable con nuestro servicio de fisioterapia. \n\n Te ofrecemos atención especializada para aliviar dolores musculares, rehabilitar lesiones, mejorar tu movilidad y ayudarte a recuperar tu calidad de vida. \n Contamos con tratamientos personalizados, terapia manual, ejercicios terapéuticos y acompañamiento profesional para cada necesidad.',
                  ),
                  SizedBox(height: 60),
                  ServiceRow(
                    imagePath: 'assets/images/gimnasioinfo.png',
                    title: 'Gimnasio',
                    description:
                        ' \n Transforma tu cuerpo y mejora tu salud en nuestro gimnasio. \n\n Te ofrecemos un espacio equipado para que entrenes con comodidad, seguridad y motivación. Contamos con rutinas personalizadas, asesoría profesional \n y actividades diseñadas para ayudarte a alcanzar tus objetivos.',
                  ),
                  SizedBox(height: 60),
                  ServiceRow(
                    imagePath: 'assets/images/yogainfo.png',
                    title: 'Centro de yoga y pilates',
                    description:
                        'Ofrecemos un servicio de yoga y pilates perfecto para la relajación y paz mental',
                  ),
                  SizedBox(height: 60),
                  ServiceRow(
                    imagePath: 'assets/images/academiainfo.png',
                    title: 'Academia',
                    description:
                        'Ofrecemos un servicio de academias de muchas asignaturas y especialidades',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}



class ServiceRow extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;

  const ServiceRow({
    super.key,
    required this.imagePath,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    // Tamaño de la imagen según ancho de pantalla
    double imageWidth;
    if (screenWidth < 600) {
      imageWidth = 200; // móvil (más grande que antes)
    } else if (screenWidth < 1200) {
      imageWidth = 250; // tablet/PC mediano
    } else {
      imageWidth = 300; // PC grande
    }

    // Layout móvil: columna vertical
    if (screenWidth < 600) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          buildImage(imageWidth),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 30, 156, 229), // azul
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 40),
        ],
      );
    }

    // Layout desktop/web: fila horizontal
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Imagen + título en columna
        Column(
          children: [
            buildImage(imageWidth),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1976D2), // azul
              ),
            ),
          ],
        ),
        const SizedBox(width: 20),
        // Descripción a la derecha
        Expanded(
          child: Text(
            description,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget buildImage(double width) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue, width: 3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          imagePath,
          width: width,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}