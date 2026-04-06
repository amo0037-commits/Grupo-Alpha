import 'package:flutter/material.dart';
import 'package:gestion_cliente/core/app_colors.dart';

class ReservaPage extends StatefulWidget {
  const ReservaPage({super.key});

  @override
  State<ReservaPage> createState() => _ReservaPageState();
}

class _ReservaPageState extends State<ReservaPage> {
  String? servicioSeleccionado;

  final List<String> servicios = [
    'Peluquería',
    'Clínicas Fisioterapia',
    'Gimnasio',
    'Centros de yoga o pilates',
    'Academias',
  ];

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
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text('Reserva aqui tu servicio'),
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
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.10,
          ),
          child: Column(
            children: [
              const SizedBox(height: 40),

              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Selecciona un servicio',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                value: servicioSeleccionado,
                items: servicios.map((String servicio) {
                  return DropdownMenuItem<String>(
                    value: servicio,
                    child: Text(servicio),
                  );
                }).toList(),
                onChanged: (String? nuevoValor) {
                  setState(() {
                    servicioSeleccionado = nuevoValor;
                  });
                },
              ),

              const SizedBox(height: 20),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Nombre y apellidos',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              const SizedBox(height: 20),

              TextField(
                decoration: const InputDecoration(
                  labelText: 'direccion',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              TextField(
                decoration: const InputDecoration(
                  labelText: 'telefono',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              const SizedBox(height: 20),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              TextField(
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              TextField(
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirmar contraseña',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 30),

              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4B5563), Color(0xFF9CA3AF)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    // lógica registro
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  child: const Text('Registrarse'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
