import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class WorkerCheckScreen extends StatefulWidget {
  const WorkerCheckScreen({super.key});

  @override
  State<WorkerCheckScreen> createState() => _WorkerCheckScreenState();
}

class _WorkerCheckScreenState extends State<WorkerCheckScreen> {
  final user = FirebaseAuth.instance.currentUser;

  bool isLoading = true;
  bool isWorking = false;

  DateTime? checkInTime;

  String name = "";
  String surname = "";
  String clase = "";

  String today =
      "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}";

  double weeklyHours = 0;

  @override
  void initState() {
    super.initState();
    init();
  }

  // ================= INIT =================
  Future<void> init() async {
    await loadUser();
    await loadTodayFichaje();
    await loadWeeklyHours();

    setState(() => isLoading = false);
  }

  // ================= USER =================
  Future<void> loadUser() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();

    name = doc['nombre'] ?? "";
    surname = doc['apellidos'] ?? "";
    clase = doc['clase'] ?? "";
  }

  // ================= HOY =================
  Future<void> loadTodayFichaje() async {
    final query = await FirebaseFirestore.instance
        .collection('time_logs')
        .where('employeeId', isEqualTo: user!.uid)
        .where('date', isEqualTo: today)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      final doc = query.docs.first;

      isWorking = doc['status'] == 'open';

      if (isWorking) {
        checkInTime = (doc['checkIn'] as Timestamp).toDate();
      }
    }

    setState(() {});
  }

  // ================= CHECK IN =================
  Future<void> checkIn() async {
    await FirebaseFirestore.instance.collection('time_logs').add({
      'employeeId': user!.uid,
      'date': today,
      'checkIn': FieldValue.serverTimestamp(),
      'status': 'open',
    });

    await loadTodayFichaje();
  }

  // ================= CHECK OUT =================
  Future<void> checkOut() async {
    final query = await FirebaseFirestore.instance
        .collection('time_logs')
        .where('employeeId', isEqualTo: user!.uid)
        .where('date', isEqualTo: today)
        .where('status', isEqualTo: 'open')
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      final doc = query.docs.first;

      final checkIn =
          (doc['checkIn'] as Timestamp).toDate();

      final hours =
          DateTime.now().difference(checkIn).inMinutes / 60;

      await doc.reference.update({
        'checkOut': FieldValue.serverTimestamp(),
        'status': 'closed',
        'workedHours': hours,
      });
    }

    await loadTodayFichaje();
    await loadWeeklyHours();
  }

  // ================= SEMANA =================
  Future<void> loadWeeklyHours() async {
    final query = await FirebaseFirestore.instance
        .collection('time_logs')
        .where('employeeId', isEqualTo: user!.uid)
        .get();

    double total = 0;

    for (var doc in query.docs) {
      if (doc.data()['workedHours'] != null) {
        total += (doc['workedHours'] as num).toDouble();
      }
    }

    weeklyHours = total;
    setState(() {});
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF1E293B),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFF1E293B),

      // ================= APPBAR (MISMO ESTILO DASHBOARD) =================
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Fichaje trabajador",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      // ================= BACKGROUND GRADIENT =================
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1E293B),
              Color(0xFF334155),
              Color(0xFF64B5F6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [

                // ================= HEADER =================
                _header(),

                const SizedBox(height: 15),

                // ================= FICHAJE =================
                _fichajeCard(),

                const SizedBox(height: 15),

                // ================= HORAS =================
                _hoursCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= HEADER =================
  Widget _header() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "👋 Bienvenido $name $surname",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "📚 Clase: $clase",
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  // ================= FICHAJE =================
  Widget _fichajeCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isWorking
            ? Colors.green.withOpacity(0.15)
            : Colors.red.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [

          Text(
            isWorking
                ? "🟢 Trabajando"
                : "🔴 No fichado",
            style: const TextStyle(color: Colors.white),
          ),

          const SizedBox(height: 10),

          if (checkInTime != null)
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 500),
              builder: (_, value, child) => Opacity(
                opacity: value,
                child: Text(
                  "${checkInTime!.hour}:${checkInTime!.minute.toString().padLeft(2, '0')}",
                  style: const TextStyle(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          const SizedBox(height: 15),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isWorking ? Colors.red : Colors.green,
              minimumSize: const Size(double.infinity, 50),
            ),
            onPressed: () {
              isWorking ? checkOut() : checkIn();
            },
            child: Text(
              isWorking ? "FICHAR SALIDA" : "FICHAR ENTRADA",
            ),
          ),
        ],
      ),
    );
  }

  // ================= HORAS =================
  Widget _hoursCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [

          const Text(
            "📊 Horas semanales",
            style: TextStyle(color: Colors.white),
          ),

          const SizedBox(height: 10),

          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: weeklyHours),
            duration: const Duration(milliseconds: 800),
            builder: (_, value, __) {
              return Text(
                "${value.toStringAsFixed(2)} h",
                style: const TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
