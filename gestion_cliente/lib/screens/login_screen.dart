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
    await messaging.requestPermission();
    String? token = await messaging.getToken();

    if (token != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'fcmToken': token});
    }

    messaging.onTokenRefresh.listen((newToken) async {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'fcmToken': newToken});
    });
  }

  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      _mostrarMensaje("Por favor, rellena todos los campos");
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      await saveFcmToken();

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const PaginaInicio()),
        (Route<dynamic> route) => false,
      );
    } on FirebaseAuthException catch (e) {
      String mensaje = 'Error al iniciar sesión';
      if (e.code == 'user-not-found') mensaje = 'Usuario no encontrado';
      if (e.code == 'wrong-password') mensaje = 'Contraseña incorrecta';
      if (e.code == 'invalid-email') mensaje = "Email no válido";
      
      _mostrarMensaje(mensaje);
    } catch (e) {
      _mostrarMensaje("Error inesperado: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
          title: const Text('Iniciar sesión', style: TextStyle(color: Colors.white)),
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
                    isPasswordField: true, // Habilitamos el modo contraseña
                    controller: passwordController,
                    textInputAction: TextInputAction.done,
                    onSubmitted: login,
                  ),
                ),
                const SizedBox(height: 30),
                GestureDetector(
                  onTapDown: (_) => setState(() => _buttonPressed = true),
                  onTapUp: (_) => setState(() => _buttonPressed = false),
                  onTapCancel: () => setState(() => _buttonPressed = false),
                  onTap: login,
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 120),
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
                              ? [const Color(0xFF2F6FE4), const Color(0xFF4D94FF)]
                              : [const Color(0xFF3B82F6), const Color(0xFF60A5FA)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withValues(alpha: _buttonPressed ? 0.25 : 0.4),
                            blurRadius: _buttonPressed ? 10 : 15,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text(
                                'Iniciar sesión',
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
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
                      MaterialPageRoute(builder: (_) => const RegisterPage()),
                    );
                  },
                  child: const Text('¿No tienes cuenta? Regístrate', style: TextStyle(color: Colors.white70)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedTextField extends StatefulWidget {
  final String label;
  final bool isPasswordField; // Cambiado para identificar si es contraseña
  final TextEditingController controller;
  final TextInputAction? textInputAction;
  final VoidCallback? onSubmitted;

  const AnimatedTextField({
    required this.label,
    this.isPasswordField = false,
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
  late bool _obscureText; // Estado interno para el ojo

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPasswordField;
    _focusNode.addListener(() {
      setState(() => _hasFocus = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: const TextStyle(color: Colors.white),
      controller: widget.controller,
      focusNode: _focusNode,
      obscureText: _obscureText,
      textInputAction: widget.textInputAction,
      onSubmitted: (value) => widget.onSubmitted?.call(),
      decoration: InputDecoration(
        hintStyle: TextStyle(color: _hasFocus ? Colors.white : Colors.white70),
        hintText: widget.label,
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        // AÑADIMOS EL OJO AQUÍ
        suffixIcon: widget.isPasswordField 
          ? IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility_off : Icons.visibility,
                color: Colors.white70,
              ),
              onPressed: () {
                setState(() => _obscureText = !_obscureText);
              },
            )
          : null,
      ),
    );
  }
}