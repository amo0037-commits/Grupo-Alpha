import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController direccionController = TextEditingController();

  Map<String, bool> negocios = {
    "Gimnasio": false,
    "Centro de Yoga": false,
    "Peluqueria": false,
    "Centro de Fisioterapia": false,
    "Academia": false,
};


  Future<void> register() async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contraseñas no coinciden')),
      );
      return;
    }

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = userCredential.user;

      // Obtener negocios seleccionados
      List<String> negociosSeleccionados = negocios.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList();

      // Guardar en Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .set({
        "email": user.email,
        "telefono": telefonoController.text.trim(),
        "direccion": direccionController.text.trim(),
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensaje)),
      );
    }
  }


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
          'Registro',
          style: TextStyle(color: Color(0xFF1565C0)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 700.0),
        child: Column(
          children: [
            const SizedBox(height: 40),

            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                   border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: telefonoController,
              decoration: const InputDecoration(
                labelText: 'Teléfono',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: direccionController,
              decoration: const InputDecoration(
                labelText: 'Dirección',
                border: OutlineInputBorder(),
              ),
            ),  


            const SizedBox(height: 20),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirmar contraseña',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            Column(
              children: negocios.keys.map((key) {
                return CheckboxListTile(
                  title: Text(key),
                  value: negocios[key],
                  onChanged: (value) {
                    setState(() {
                      negocios[key] = value!;
                  }); 
                },  
              );
            }).toList(),
          ),


            const SizedBox(height: 30),

          ElevatedButton(
            onPressed: register,
            child: const Text('Registrarse'),
          ),
          ],
        ),
      ),
    );
  }
}
