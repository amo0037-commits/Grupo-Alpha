import 'package:flutter/material.dart';

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
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1565C0)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Reserva aqui tu servicio',
          style: TextStyle(color: Color(0xFF1565C0)),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 700.0),
        child: Column(
        children: [
          const SizedBox(height:40),

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

                 const SizedBox(height: 30,),

                  ElevatedButton(
              onPressed: () {
                // lógica registro
              },
              child: const Text('Registrarse'),
                  ),

          ],
        ),
      ),
    );
  }
}