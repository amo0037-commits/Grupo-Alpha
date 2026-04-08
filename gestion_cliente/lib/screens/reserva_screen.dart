import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

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

  final TextEditingController nombreController = TextEditingController();
  final TextEditingController direccionController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE0E3E7), Color(0xFF64B5F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Reserva tu servicio'),
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
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.10,
            vertical: 20,
          ),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Center(
                child: AnimatedTextKit(
                  animatedTexts: [
                    ColorizeAnimatedText(
                      'Ofrecemos una gama variada de servicios',
                      textAlign: TextAlign.center,
                      textStyle: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
                      ),
                      colors: const [
                        Color(0xFF0D47A1),
                        Color(0xFF1565C0),
                        Color(0xFF64B5F6),
                        Color(0xFF9CA3AF),
                      ],
                      speed: const Duration(milliseconds: 400),
                    ),
                  ],
                  repeatForever: true,
                  isRepeatingAnimation: true,
                ),
              ),
              const SizedBox(height: 20),
              const SizedBox(height: 20),

              // Dropdown de servicios
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 400,
                    minWidth: 200,
                  ),
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Selecciona un servicio',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: const Color.fromARGB(255, 141, 196, 241),
                    ),
                    dropdownColor: const Color.fromARGB(255, 184, 214, 245),
                    value: servicioSeleccionado,
                    items: servicios.map((servicio) {
                      return DropdownMenuItem(
                        value: servicio,
                        child: Text(servicio),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        servicioSeleccionado = value;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Campos de texto con borde animado al estilo LoginPage
              AnimatedTextField(
                label: 'Nombre y Apellidos',
                controller: nombreController,
              ),
              const SizedBox(height: 20),
              AnimatedTextField(
                label: 'Dirección',
                controller: direccionController,
              ),
              const SizedBox(height: 20),
              AnimatedTextField(
                label: 'Teléfono',
                controller: telefonoController,
              ),
              const SizedBox(height: 20),
              AnimatedTextField(label: 'Email', controller: emailController),
              const SizedBox(height: 20),
              AnimatedTextField(
                label: 'Contraseña',
                controller: passwordController,
                obscureText: true,
              ),
              const SizedBox(height: 20),
              AnimatedTextField(
                label: 'Confirmar contraseña',
                controller: confirmPasswordController,
                obscureText: true,
              ),
              const SizedBox(height: 30),

              // Botón de reserva
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 400,
                    minWidth: 200,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4B5563), Color(0xFF9CA3AF)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        // Lógica de reserva
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Reservar'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------
// Widget animado reutilizable (igual LoginPage)
// -----------------------
class AnimatedTextField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final bool obscureText;

  const AnimatedTextField({
    required this.label,
    required this.controller,
    this.obscureText = false,
    super.key,
  });

  @override
  State<AnimatedTextField> createState() => _AnimatedTextFieldState();
}

class _AnimatedTextFieldState extends State<AnimatedTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _hasFocus = _focusNode.hasFocus);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400, minWidth: 200),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _hasFocus ? Colors.blueAccent : Colors.grey.shade400,
              width: _hasFocus ? 2 : 1,
            ),
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: widget.obscureText,
            decoration: InputDecoration(
              labelText: widget.label,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
