import 'dart:ui';
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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white70),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Reserva tu servicio',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
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
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
                      ),
                      colors: const [
                        Color(0xFF64B5F6),
                        Color(0xFF42A5F5),
                        Color(0xFF93C5FD),
                        Colors.white70,
                      ],
                      speed: const Duration(milliseconds: 400),
                    ),
                  ],
                  repeatForever: true,
                ),
              ),

              const SizedBox(height: 30),

              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 400,
                  ),
                  child: DropdownButtonFormField<String>(
                    dropdownColor: const Color(0xFF1E293B),
                    value: servicioSeleccionado,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Selecciona un servicio',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.08),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.white.withOpacity(0.15),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF64B5F6),
                        ),
                      ),
                    ),
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

              const SizedBox(height: 30),

              AnimatedTextField(
                label: 'Nombre y Apellidos',
                controller: nombreController,
              ),
              const SizedBox(height: 15),

              AnimatedTextField(
                label: 'Dirección',
                controller: direccionController,
              ),
              const SizedBox(height: 15),

              AnimatedTextField(
                label: 'Teléfono',
                controller: telefonoController,
              ),
              const SizedBox(height: 15),

              AnimatedTextField(
                label: 'Email',
                controller: emailController,
              ),
              const SizedBox(height: 15),

              AnimatedTextField(
                label: 'Contraseña',
                controller: passwordController,
                obscureText: true,
              ),
              const SizedBox(height: 15),

              AnimatedTextField(
                label: 'Confirmar contraseña',
                controller: confirmPasswordController,
                obscureText: true,
              ),

              const SizedBox(height: 30),

              // 🔵 BOTÓN ACTUALIZADO (SOLO ESTE CAMBIO)
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      height: 55,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF3B82F6),
                            Color(0xFF60A5FA),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.35),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'Reservar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
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
        constraints: const BoxConstraints(maxWidth: 400),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white.withOpacity(0.08),
            border: Border.all(
              color: _hasFocus
                  ? const Color(0xFF64B5F6)
                  : Colors.white.withOpacity(0.15),
            ),
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: widget.obscureText,
            style: const TextStyle(color: Colors.white),
            cursorColor: const Color(0xFF64B5F6),
            decoration: InputDecoration(
              labelText: widget.label,
              labelStyle: const TextStyle(color: Colors.white70),
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