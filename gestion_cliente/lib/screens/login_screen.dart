import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestion_cliente/screens/inicio_screen.dart';

import 'register_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _buttonPressed = false;
  bool _isLoading = false;

  Future<void> saveFcmToken() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final messaging = FirebaseMessaging.instance;

  // pedir permisos (solo la primera vez)
  await messaging.requestPermission();

  // obtener token del dispositivo
  String? token = await messaging.getToken();

  print("FCM TOKEN: $token");

  if (token != null) {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({
          'fcmToken': token,
        });
  }

  // si el token cambia en el futuro
  messaging.onTokenRefresh.listen((newToken) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({
          'fcmToken': newToken,
        });
  });
}


  Future<void> login() async {
    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      await saveFcmToken();

    } on FirebaseAuthException catch (e) {
      String mensaje = 'Error al iniciar sesión';

      if (e.code == 'user-not-found') mensaje = 'Usuario no encontrado';
      if (e.code == 'wrong-password') mensaje = 'Contraseña incorrecta';

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(mensaje)));
    }

    if (!mounted) return;
    setState(() => _isLoading = false);
  // 1. Validación básica antes de disparar Firebase
  if (emailController.text.isEmpty || passwordController.text.isEmpty) {
    _mostrarMensaje("Por favor, rellena todos los campos");
    return;
  }

  setState(() => _isLoading = true);

  try {
    // 2. Intento de inicio de sesión
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    // 3. Verificación de montaje
    if (!mounted) return;

    // 4. NAVEGACIÓN CRÍTICA:
    // Usamos pushAndRemoveUntil para limpiar la memoria de la pantalla de login
    // y evitar que el usuario pueda volver atrás al login con el botón del móvil.
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const PaginaInicio()),
      (Route<dynamic> route) => false,
    );

  } on FirebaseAuthException catch (e) {
    String errorMsg = "Ocurrió un error";
    if (e.code == 'user-not-found') errorMsg = "Usuario no encontrado";
    else if (e.code == 'wrong-password') errorMsg = "Contraseña incorrecta";
    else if (e.code == 'invalid-email') errorMsg = "Email no válido";
    
    _mostrarMensaje(errorMsg);
  } catch (e) {
    _mostrarMensaje("Error inesperado: $e");
  } finally {
    // Solo quitamos el loading si seguimos en esta pantalla
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}

// Asegúrate de que el método se llame así o cámbialo en el catch
void _mostrarMensaje(String msg) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
  );
}
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
          leading: Navigator.canPop(context)
              ? IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                )
              : null,
          title: const Text('Iniciar sesión'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              left: screenWidth * 0.10,
              right: screenWidth * 0.10,
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              children: [
                const SizedBox(height: 40),

                // LOGO
                Image.asset(
                  'assets/images/LogoAlphaAppPagInicio.png',
                  width: 180,
                ),

                const SizedBox(height: 40),

                _glassField(
  AnimatedTextField(
    label: 'Email',
    controller: emailController,
    textInputAction: TextInputAction.next,
  ),
),

                const SizedBox(height: 20),

               _glassField(
  AnimatedTextField(
    label: 'Contraseña',
    obscureText: true,
    controller: passwordController,
    textInputAction: TextInputAction.done, // Esto cambia el icono del teclado a un "Check" o "Done"
    onSubmitted: login, // Al pulsar el botón del teclado, llama a login()
  ),
),

                const SizedBox(height: 30),

                // BOTÓN
               GestureDetector(
  onTapDown: (_) {
    setState(() => _buttonPressed = true);
  },
  onTapUp: (_) {
    setState(() => _buttonPressed = false);
    login();
  },
  onTapCancel: () {
    setState(() => _buttonPressed = false);
  },
  child: AnimatedScale(
    duration: const Duration(milliseconds: 120),
    curve: Curves.easeOut,
    scale: _buttonPressed ? 0.96 : 1.0,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      height: 55,
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: _buttonPressed
              ? [
                  const Color(0xFF2F6FE4),
                  const Color(0xFF4D94FF),
                ]
              : [
                  const Color(0xFF3B82F6),
                  const Color(0xFF60A5FA),
                ],
        ),
        boxShadow: _buttonPressed
            ? [
                BoxShadow(
                  color: Colors.blueAccent.withOpacity(0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                )
              ]
            : [
                BoxShadow(
                  color: Colors.blueAccent.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                )
              ],
      ),
      child: Center(
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Iniciar sesión',
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

                const SizedBox(height: 20),

                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RegisterPage(),
                      ),
                    );
                  },
                  child: const Text(
                    '¿No tienes cuenta? Regístrate',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // GLASS EFFECT
  Widget _glassField(Widget child) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

// TEXTFIELD
class AnimatedTextField extends StatefulWidget {
  final String label;
  final bool obscureText;
  final TextEditingController controller;
  final TextInputAction? textInputAction;
  final VoidCallback? onSubmitted;

  const AnimatedTextField({
    required this.label,
    this.obscureText = false,
    required this.controller,
    this.textInputAction,
    this.onSubmitted,
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
  return TextField(
    controller: widget.controller,
    focusNode: _focusNode,
    obscureText: widget.obscureText,
    textInputAction: widget.textInputAction, // 'next' para email, 'done' para password
    
    // Cambia/asegúrate de que esto esté así:
    onSubmitted: (value) {
      if (widget.onSubmitted != null) {
        widget.onSubmitted!();
      }
    },
    
    style: const TextStyle(color: Colors.white),
    decoration: InputDecoration(
      labelText: widget.label,
      labelStyle: TextStyle(
        color: _hasFocus ? Colors.white : Colors.white70,
      ),
      border: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 18,
      ),
    ),
  );
}
}