  import 'package:flutter/foundation.dart';
  import 'package:flutter/material.dart';
  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:gestion_cliente/screens/login_screen.dart';
  import 'package:image_picker/image_picker.dart'; 
  import 'package:firebase_storage/firebase_storage.dart';
  import 'package:cached_network_image/cached_network_image.dart';
  import 'package:crop_your_image/crop_your_image.dart';

  class ProfilePage extends StatefulWidget {
    const ProfilePage({super.key});

    @override
    State<ProfilePage> createState() => _ProfilePageState();
  }

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return const ProfilePage(); // o HomePage
        } else {
          return const LoginPage();
        }
      },
    );
  }
}

  class _ProfilePageState extends State<ProfilePage> {
    Uint8List? _localImageBytes;
    
    final CropController _cropController = CropController();
    Uint8List? _imageToCrop;
    Widget _buildAvatar(String? photoUrl) {
    // Mostrar imagen guardada en Firebase SIEMPRE
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return CachedNetworkImage(
        key: ValueKey(photoUrl),
        imageUrl: photoUrl,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      );
    }

    // Solo fallback si aún no hay nada en Firestore
    if (_localImageBytes != null) {
      return Image.memory(
        _localImageBytes!,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      );
    }


    return const Icon(Icons.person, size: 50, color: Colors.white);
  }

    
    void _showEditDialog(String uid) async {
  final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
  final data = doc.data() ?? {};

  final nombreController = TextEditingController(text: data['nombre'] ?? "");
  final apellidoController = TextEditingController(text: data['apellidos'] ?? "");
  final fechaController = TextEditingController(text: data['fechaNacimiento'] ?? "");
  final emailController = TextEditingController(text: data['email'] ?? "");
  final telefonoController = TextEditingController(text: data['telefono'] ?? "");
  final direccionController = TextEditingController(text: data['direccion'] ?? "");

  final List<String> serviciosDisponibles = [
   'Gimnasio'
   'Academia'
   'Fisioterapia'
   'Yoga'
   'Peluqueria'
];
  

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Editar Información"),
       content: SingleChildScrollView(
  child: Padding(
    padding: const EdgeInsets.all(10),
    child: Column(
      children: [
        TextField(
          controller: nombreController,
          decoration: const InputDecoration(
            labelText: "Nombre",
            prefixIcon: Icon(Icons.person),
          ),
        ),

        const SizedBox(height: 15),

        TextField(
          controller: apellidoController,
          decoration: const InputDecoration(
            labelText: "Apellidos",
            prefixIcon: Icon(Icons.person_outline),
          ),
        ),

        const SizedBox(height: 15),

        TextField(
          controller: telefonoController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: "Teléfono",
            prefixIcon: Icon(Icons.phone),
          ),
        ),

        const SizedBox(height: 15),

        TextField(
          controller: direccionController,
          decoration: const InputDecoration(
            labelText: "Dirección",
            prefixIcon: Icon(Icons.location_on),
          ),
        ),

        const SizedBox(height: 15),

        TextField(
          controller: fechaController,
          readOnly: true,
          decoration: const InputDecoration(
            labelText: "Fecha de nacimiento",
            prefixIcon: Icon(Icons.calendar_today),
          ),
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime(2000),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );

            if (pickedDate != null) {
              fechaController.text =
                  "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
            }
          },
        ),
      ],
    ),
  ),
),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              await _saveUserData(
                uid,
                nombreController.text,
                apellidoController.text,
                fechaController.text,
                telefonoController.text,
                direccionController.text,
              );

              Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(
               content: Row(
               children: const [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 10),
                  Text("Datos actualizados correctamente"),
                ],
              ),
                backgroundColor: Colors.green,
          )
                );
            },
            child: const Text("Guardar"),
          ),
        ],
      );
    },
  );
}

    void _showNotificationDialog(String uid) async {
  final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
  final data = doc.data() ?? {};

  bool notificacionesActivas = data['notificaciones'] ?? true;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text("Notificaciones"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  title: const Text("Activar notificaciones"),
                  secondary: const Icon(Icons.notifications),
                  value: notificacionesActivas,
                  onChanged: (value) {
                    setStateDialog(() {
                      notificacionesActivas = value;
                    });
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancelar"),
              ),
              ElevatedButton(
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .set(
                    {
                      'notificaciones': notificacionesActivas,
                    },
                    SetOptions(merge: true),
                  );

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        notificacionesActivas
                            ? "🔔 Notificaciones activadas"
                            : "🔕 Notificaciones desactivadas",
                      ),
                    ),
                  );
                },
                child: const Text("Guardar"),
              ),
            ],
          );
        },
      );
    },
  );
}

    void _showHelpDialog(String uid) {
  final mensajeController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Ayuda y Soporte"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              const Text(
                "¿Tienes algún problema o necesitas ayuda? Escríbenos:",
                style: TextStyle(fontSize: 14),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: mensajeController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: "Escribe tu mensaje",
                  prefixIcon: Icon(Icons.message),
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (mensajeController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("⚠️ Escribe un mensaje"),
                  ),
                );
                return;
              }

              await _sendSupportMessage(uid, mensajeController.text);

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("✅ Mensaje enviado correctamente"),
                ),
              );
            },
            child: const Text("Enviar"),
          ),
        ],
      );
    },
  );
}

void _showNegociosDialog(String uid) async {
  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .get();

  final data = doc.data();
  if (data == null) return;

  final List<String> serviciosDisponibles = [
    "Gimnasio",
    "Academia",
    "Fisioterapia",
    "Yoga",
    "Peluqueria",
  ];

  final List<String> negocios =
      List<String>.from(data['negocios'] ?? []);

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text("Mis servicios"),
            content: SizedBox(
              width: double.maxFinite,
              height: 500,
              child: ListView(
                children: [
                  const Text(
                    "Activos",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  if (negocios.isEmpty)
                    const Text("No tienes servicios activos"),

                  ...negocios.map((servicio) {
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.store, color: Colors.green),
                        title: Text(servicio),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () async {
                            setStateDialog(() {
                              negocios.remove(servicio);
                            });

                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(uid)
                                .set({
                              'negocios': negocios
                            }, SetOptions(merge: true));

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("❌ '$servicio' dado de baja"),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 20),

                  const Text(
                    "Disponibles",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  ...serviciosDisponibles.map((servicio) {
                    final yaActivo = negocios.contains(servicio);

                    return Card(
                      child: ListTile(
                        leading: Icon(
                          yaActivo ? Icons.check_circle : Icons.add_circle,
                          color: yaActivo ? Colors.green : Colors.grey,
                        ),
                        title: Text(servicio),
                        subtitle: Text(yaActivo ? "Activo" : "Disponible"),
                        trailing: SizedBox(
  width: 100,
  child: ElevatedButton(
    onPressed: yaActivo
    ? null
    : () async {
        setStateDialog(() {
          negocios.add(servicio);
        });

        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .set(
              {'negocios': negocios},
              SetOptions(merge: true),
            );

        // ✅ MENSAJE DE CONFIRMACIÓN
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("✅ Te has dado de alta en '$servicio'"),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      },
    child: Text(yaActivo ? "Activo" : "Alta"),
  ),
),
                      ),
                    );
                  }),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cerrar"),
              ),
            ],
          );
        },
      );
    },
  );
}

    void _showImagePickerOptions(String uid) {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) {
          return SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text("Galería"),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(uid, ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text("Cámara"),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(uid, ImageSource.camera);
                  },
                ),
              ],
            ),
          );
        },
      );
    }


    Future<void> _saveUserData(
          String uid,
          String nombre,
          String apellidos,
          String fechaNacimiento,
          String telefono,
          String direccion,
      ) async {
          try {
            await FirebaseFirestore.instance.collection('users').doc(uid).set(
      {
        'nombre': nombre,
        'apellidos': apellidos,
        'fechaNacimiento': fechaNacimiento,
        'telefono': telefono,
        'direccion': direccion,
      },
      SetOptions(merge: true),
    );

    debugPrint("✅ Datos actualizados correctamente");
  } catch (e) {
    debugPrint("❌ Error guardando datos: $e");
  }
}

  Future<void> _sendSupportMessage(String uid, String mensaje) async {
  try {
    await FirebaseFirestore.instance.collection('soporte').add({
      'uid': uid,
      'mensaje': mensaje,
      'fecha': FieldValue.serverTimestamp(),
    });

    debugPrint("✅ Mensaje enviado a soporte");
  } catch (e) {
    debugPrint("❌ Error enviando mensaje: $e");
  }
}

  Future<void> _uploadCroppedImage(String uid, Uint8List image) async {
    
    debugPrint("🟡 INICIO upload");

    debugPrint("UID usado: $uid");
    debugPrint("UID auth: ${FirebaseAuth.instance.currentUser?.uid}");

    debugPrint("📦 Bytes imagen: ${image.lengthInBytes}");

    final fileName =
        '${uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final ref = FirebaseStorage.instance
      .ref()
      .child('profile_images')
      .child(fileName);

      try {
      debugPrint("🚀 Subiendo imagen a Storage...");

      final uploadTask = ref.putData(
        image,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      await uploadTask.timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw Exception("⏱ Timeout subiendo imagen a Storage");
        },
      );

      debugPrint("✅ Imagen subida a Storage");

      final url = await ref.getDownloadURL();

      debugPrint("🔗 URL original: $url");

      final updatedUrl =
          "$url?v=${DateTime.now().millisecondsSinceEpoch}";

      debugPrint("🔗 URL final: $updatedUrl");

      debugPrint("💾 Guardando en Firestore...");

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(
            {'photoUrl': updatedUrl},
            SetOptions(merge: true),
          );

      debugPrint("✅ Guardado en Firestore OK");

      if (mounted) {
        setState(() {
          _localImageBytes = image;
        });
      }

      debugPrint("🏁 FIN upload exitoso");
    } catch (e) {
      debugPrint("❌ ERROR en upload: $e");
    }
  }


  Future<void> _pickImage(String uid, ImageSource source) async {
    final picker = ImagePicker();

    try {
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 70,
      );

      if (pickedFile == null) return;

      final Uint8List imageBytes = await pickedFile.readAsBytes();

      setState(() {
        _imageToCrop = imageBytes;
      });


      _showCropDialog(uid);

    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  void _showCropDialog(String uid) {
    if (_imageToCrop == null) return;
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 400,
                child:Crop(
                        image: _imageToCrop!,
                        controller: _cropController,
                        aspectRatio: 1,
                        withCircleUi: true, // 👈 opcional pero recomendable
                        onCropped: (cropped) async {
                        debugPrint("📸 onCropped ejecutado"); // 🔥 DEBUG

                if (cropped == null) return;

                Navigator.pop(context);

                setState(() {
                _localImageBytes = cropped;
                });

              await _uploadCroppedImage(uid, cropped);
    },
  ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                      onPressed: () {
                        debugPrint("🟡 Botón Guardar presionado"); // 🔥 DEBUG
                        _cropController.crop();
                  },
                    child: const Text("Guardar"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancelar"),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

    @override
    Widget build(BuildContext context) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return const Scaffold(body: Center(child: Text("Usuario no autenticado")));

      return Scaffold(
        appBar: AppBar(
          title: const Text('Mi Perfil'),
          centerTitle: true,
          elevation: 0,
          foregroundColor: Colors.black,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xFF9CA3AF), Color(0xFF4B5563)],
              ),
            ),
          ),
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFE0E3E7), Color(0xFF64B5F6)],
            ),
          ),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF64B5F6), Color(0xFFE0E3E7)],
                  ),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
                ),
                padding: const EdgeInsets.only(bottom: 30),
                child: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
                  builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                  return const Center(
                  child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: CircularProgressIndicator(),
            ),
          );
    }

                  var data = snapshot.data!.data() as Map<String, dynamic>?;

                  if (data == null) {
                  return const Text("Sin datos de usuario");
    }

                    String nombre = data['nombre'] ?? "Usuario";
                    String apellido = data['apellidos'] ?? "";
                    String telefono = data['telefono'] ?? "";
                    String direccion = data['direccion'] ?? "";
                    String email = data['email'] ?? "email";
                    String? photoUrl = data['photoUrl'];

                    return Column(
                      children: [
                        const SizedBox(height: 30),
                        GestureDetector(
                        onTap: () => _showImagePickerOptions(user.uid),
                      child: CircleAvatar(
                        radius: 50,
                          backgroundColor: const Color(0xFF64B5F6),
                              child: ClipOval(
                            child: _buildAvatar(photoUrl),
                            ),
                            ),
                            ),
                        const SizedBox(height: 15),
                        Text("$nombre $apellido".trim(), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        Text(email, 
                        style: TextStyle(color: Colors.grey[600]),)
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                  _buildOption(
                    Icons.person_outline,
                     "Editar Información",
                       onTap: () => _showEditDialog(user.uid),
            ),
                 _buildOption(
                     Icons.notifications_none,
                      "Notificaciones",
                        onTap: () => _showNotificationDialog(user.uid),
            ),
                  _buildOption(
                    Icons.build_outlined,
                      "Servicios",
                         onTap: () {
  debugPrint("🟢 Abriendo servicios");
  _showNegociosDialog(user.uid);
},
            ), 
                   
                   _buildOption(
                      Icons.help_outline,
                        "Ayuda y Soporte",
                            onTap: () => _showHelpDialog(user.uid),
            ),

                    const Divider(height: 40),
                  _buildOption(
                    Icons.logout,
                      "Cerrar Sesión",
                        isDestructive: true,
                        onTap: () async {
                  await FirebaseAuth.instance.signOut();
            },
          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

  Widget _buildOption(
    IconData icon,
    String title, {
    bool isDestructive = false,
    VoidCallback? onTap,
  }) {
    final color = isDestructive ? Colors.red : Colors.black87;

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(color: color, fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap, // 👈 IMPORTANTE
    );
  }
  }