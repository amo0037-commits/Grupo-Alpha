import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestion_cliente/core/app_colors.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController direccionController = TextEditingController();
  final TextEditingController edadController = TextEditingController();

  bool loading = false;
  double opacity = 0;
  double offsetY = 50;
  bool isPasswordHidden = true;
  bool isConfirmPasswordHidden = true;

  Map<String, bool> negocios = {
    "Gimnasio": false,
    "Centro de Yoga": false,
    "Peluqueria": false,
    "Centro de Fisioterapia": false,
    "Academia": false,
  };

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        opacity = 1;
        offsetY = 0;
      });
    });
  }

  Future<void> register() async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contraseñas no coinciden')),
      );
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contraseñas no coinciden')),
      );
      return;
    }

    setState(() => loading = true);

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      final user = userCredential.user;

      List<String> negociosSeleccionados = negocios.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList();

      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
        "email": user.email,
        "telefono": telefonoController.text.trim(),
        "direccion": direccionController.text.trim(),
        "edad": int.tryParse(edadController.text.trim()) ?? 0,
        "rol": "usuario",
        "negocios": negociosSeleccionados,
        "activo": true,
        "fecha_registro": Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario creado correctamente')),
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String mensaje = 'Error';

      if (e.code == 'email-already-in-use') {
        mensaje = 'El email ya está en uso';
      } else if (e.code == 'weak-password') {
        mensaje = 'La contraseña es muy débil';
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mensaje)));
    }

    setState(() => loading = false);
  }

  InputDecoration customInput(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide.none,
      ),
    );
  }

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
          title: const Text('Registro'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: opacity,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                  transform: Matrix4.translationValues(0, offsetY, 0),
                  child: Card(
                    color: const Color.fromARGB(255, 126, 141, 161),
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const SizedBox(height: 10),

                          // Email
                          TextField(
                            controller: emailController,
                            decoration: customInput('Email', Icons.email),
                          ),

                          const SizedBox(height: 15),

                          // Teléfono
                          TextField(
                            controller: telefonoController,
                            decoration: customInput('Teléfono', Icons.phone),
                          ),

                          const SizedBox(height: 15),

                          //  Dirección
                          TextField(
                            controller: direccionController,
                            decoration: customInput(
                              'Dirección',
                              Icons.location_on,
                            ),
                          ),

                          const SizedBox(height: 15),

                          // Edad
                          TextField(
                            controller: edadController,
                            keyboardType: TextInputType.number,
                            decoration: customInput('Edad', Icons.cake),
                          ),

                          const SizedBox(height: 15),

                          TextField(
                            controller: passwordController,
                            obscureText: isPasswordHidden,
                            decoration: customInput('Contraseña', Icons.lock)
                                .copyWith(
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      isPasswordHidden
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        isPasswordHidden = !isPasswordHidden;
                                      });
                                    },
                                  ),
                                ),
                          ),

                          const SizedBox(height: 15),

                          // Confirm Password
                          TextField(
                            controller: confirmPasswordController,
                            obscureText: isConfirmPasswordHidden,
                            decoration:
                                customInput(
                                  'Confirmar contraseña',
                                  Icons.lock,
                                ).copyWith(
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      isConfirmPasswordHidden
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        isConfirmPasswordHidden =
                                            !isConfirmPasswordHidden;
                                      });
                                    },
                                  ),
                                ),
                          ),

                          const SizedBox(height: 20),

                          // Negocios
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Tipo de negocio",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          Column(
                            children: negocios.keys.map((key) {
                              return CheckboxListTile(
                                title: Text(
                                  key,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                value: negocios[key],
                                onChanged: (value) {
                                  setState(() {
                                    negocios[key] = value!;
                                  });
                                },
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 20),

                          // Botón
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 250,
                              height: 50,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF1565C0),
                                      Color(0xFF64B5F6),
                                    ], // degradado azul
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ElevatedButton(
                                  onPressed: loading ? null : register,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF1565C0),
                                    elevation: 5,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    child: loading
                                        ? const SizedBox(
                                            key: ValueKey('loading'),
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Text(
                                            'Registrarse',
                                            key: ValueKey('text'),
                                            style: TextStyle(fontSize: 16),
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
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
