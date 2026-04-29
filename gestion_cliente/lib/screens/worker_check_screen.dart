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

  String name = "";
  String surname = "";
  String clase = "";

  double weeklyHours = 0;

  bool showHistory = false;
  List<Map<String, dynamic>> weeklyHistory = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    await Future.wait([
      loadUser(),
      loadCurrentStatus(),
      loadWeeklyHours(),
    ]);

    setState(() => isLoading = false);
  }

  Future<void> loadUser() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();

    name = doc['nombre'] ?? "";
    surname = doc['apellidos'] ?? "";
    clase = doc['clase'] ?? "";
  }

  Future<void> loadCurrentStatus() async {
    final query = await FirebaseFirestore.instance
        .collection('time_logs')
        .where('employeeId', isEqualTo: user!.uid)
        .where('status', isEqualTo: 'open')
        .limit(1)
        .get();

    isWorking = query.docs.isNotEmpty;
    setState(() {});
  }

  // ================= CHECK IN =================
  Future<void> checkIn() async {
    final existing = await FirebaseFirestore.instance
        .collection('time_logs')
        .where('employeeId', isEqualTo: user!.uid)
        .where('status', isEqualTo: 'open')
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) return;

    await FirebaseFirestore.instance.collection('time_logs').add({
      'employeeId': user!.uid,
      'checkIn': Timestamp.now(), // clave
      'checkInServer': FieldValue.serverTimestamp(),
      'status': 'open',
    });

    await loadCurrentStatus();
  }

  // ================= CHECK OUT =================
  Future<void> checkOut() async {
    final query = await FirebaseFirestore.instance
        .collection('time_logs')
        .where('employeeId', isEqualTo: user!.uid)
        .where('status', isEqualTo: 'open')
        .limit(1)
        .get();

    if (query.docs.isEmpty) return;

    final doc = query.docs.first;

    final checkIn = (doc['checkIn'] as Timestamp).toDate();
    final diff = DateTime.now().difference(checkIn);

    final hours = diff.inMinutes / 60;

    // 🚫 evita fichajes basura
    if (hours < 0.02) {
      await doc.reference.delete();
      await loadCurrentStatus();
      return;
    }

    await doc.reference.update({
      'checkOut': FieldValue.serverTimestamp(),
      'status': 'closed',
      'workedHours': hours,
    });

    await Future.wait([
      loadCurrentStatus(),
      loadWeeklyHours(),
    ]);
  }

  // ================= HORAS SEMANALES =================
  Future<void> loadWeeklyHours() async {
    DateTime now = DateTime.now();
    DateTime start =
        now.subtract(Duration(days: now.weekday - 1));

    DateTime end = start.add(const Duration(days: 7));

    final query = await FirebaseFirestore.instance
        .collection('time_logs')
        .where('employeeId', isEqualTo: user!.uid)
        .where('checkIn', isGreaterThanOrEqualTo: start)
        .where('checkIn', isLessThan: end)
        .get();

    double total = 0;

    for (var doc in query.docs) {
      if (doc.data().containsKey('workedHours')) {
        total += (doc['workedHours'] as num).toDouble();
      }
    }

    weeklyHours = total;
    setState(() {});
  }

  // ================= HISTORIAL =================
  Future<void> loadWeeklyHistory() async {
    DateTime now = DateTime.now();
    DateTime limit = now.subtract(const Duration(days: 60));

    final query = await FirebaseFirestore.instance
        .collection('time_logs')
        .where('employeeId', isEqualTo: user!.uid)
        .where('checkIn', isGreaterThan: limit)
        .get();

    Map<String, double> weeks = {};

    for (var doc in query.docs) {
      if (!doc.data().containsKey('workedHours') ||
          !doc.data().containsKey('checkIn')) {
             continue;
          }

      DateTime date = (doc['checkIn'] as Timestamp).toDate();

      DateTime start =
          date.subtract(Duration(days: date.weekday - 1));

      String key = "${start.year}-${start.month}-${start.day}";

      weeks[key] = (weeks[key] ?? 0) +
          (doc['workedHours'] as num).toDouble();
    }

    weeklyHistory = weeks.entries.map((e) {
      DateTime start = DateTime.parse(e.key);
      DateTime end = start.add(const Duration(days: 6));

      return {
        'start': start,
        'end': end,
        'hours': e.value,
      };
    }).toList();

    weeklyHistory.sort((a, b) =>
        b['start'].compareTo(a['start']));

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
      backgroundColor: const Color(0xFF1E293B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Fichaje trabajador"),
        leading: const SizedBox(), // evita avatar raro
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1E293B),
              Color(0xFF334155),
              Color(0xFF64B5F6),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [

                    Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text("👋", style: TextStyle(fontSize: 24)),
                        const SizedBox(width: 10),
                        Text(
                          "$name $surname",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                    const SizedBox(height: 35),

                    _toggle(),

                    const SizedBox(height: 25),

                    Expanded(
                      child: showHistory
                          ? _history()
                          : _main(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _toggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _tab("Resumen", !showHistory),
        const SizedBox(width: 10),
        _tab("Historial", showHistory),
      ],
    );
  }

  Widget _tab(String text, bool active) {
    return GestureDetector(
      onTap: () async {
        setState(() => showHistory = text == "Historial");

        if (showHistory && weeklyHistory.isEmpty) {
          await loadWeeklyHistory();
        }
      },
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: active
              ? Colors.blueAccent
              : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(text,
            style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _main() {
    return Column(
      children: [
        _card(
          Column(
            children: [
              Text(
                isWorking ? "🟢 Trabajando" : "🔴 No fichado",
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 60,
                width: 260,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isWorking ? Colors.redAccent : Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    isWorking ? checkOut() : checkIn();
                  },
                  child: Text(
                    isWorking
                        ? "FICHAR SALIDA"
                        : "FICHAR ENTRADA",
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 25),
        _card(
          Column(
            children: [
              const Text("📊 Horas semanales",
                  style: TextStyle(color: Colors.white)),
              const SizedBox(height: 10),
              Text(
                "${weeklyHours.toStringAsFixed(2)} h",
                style: const TextStyle(
                  fontSize: 26,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _history() {
    return ListView.builder(
      itemCount: weeklyHistory.length,
      itemBuilder: (_, i) {
        final w = weeklyHistory[i];

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _card(
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${w['start'].day}/${w['start'].month}/${w['start'].year} - "
                  "${w['end'].day}/${w['end'].month}/${w['end'].year}",
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  "${w['hours'].toStringAsFixed(1)} h",
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _card(Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }
}