import 'package:flutter/material.dart';
import 'package:gestion_cliente/core/app_colors.dart';

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
        )
      ),
       child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text('Informacion acerca de los servicios disponibles'),
          backgroundColor: Colors.transparent,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF9CA3AF),Color(0xFF4B5563) ],
             ),
            ), 
           ),
          ),

        body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,

                children: [
                  const SizedBox(height:60),

                 Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Column(
      children: [
        Image.asset(
          'assets/images/peluqueriainfo2.png',
          width: MediaQuery.of(context).size.width * 0.2,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 8),
        const Text(
          'Peluqueria',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),

    const SizedBox(width: 20),

    const Expanded(
      child: Text(
        'Ofrecemos un servicio de peluqueria y estetica',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  ],
),
                

                  
                  const SizedBox(height: 60),
                  Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Column(
      children: [
        Image.asset(
          'assets/images/clinicafisioinfo.png',
          width: MediaQuery.of(context).size.width * 0.2,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 8),
        const Text(
          'Clinica de fisioterapia',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),

    const SizedBox(width: 20),

    const Expanded(
      child: Text(
        'Ofrecemos un servicio de fisioterapia para rehabilitación y recuperación',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  ],
),
                  const SizedBox(height: 60),


                 Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Column(
      children: [
        Image.asset(
          'assets/images/gimnasioinfo.png',
          width: MediaQuery.of(context).size.width * 0.2,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 8),
        const Text(
          'Gimnasio',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),

    const SizedBox(width: 20),

    const Expanded(
      child: Text(
        'Ofrecemos un servicio de gimnasio altamente preparado y equipado',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  ],
),

                   const SizedBox(height: 60),

                  Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Column(
      children: [
        Image.asset(
          'assets/images/yogainfo.png',
          width: MediaQuery.of(context).size.width * 0.2,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 8),
        const Text(
          'Centro de yoga y pilates',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),

    const SizedBox(width: 20),

    const Expanded(
      child: Text(
        'Ofrecemos un servicio de yoga y pilates perfecto para la relajación y paz mental',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  ],
),
                  
                   const SizedBox(height: 60),


                 Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Column(
      children: [
        Image.asset(
          'assets/images/academiainfo.png',
          width: MediaQuery.of(context).size.width * 0.2,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 8),
        const Text(
          'Academia',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),

    const SizedBox(width: 20),

    const Expanded(
      child: Text(
        'Ofrecemos un servicio de academias de muchas asignaturas y especialidades',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
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