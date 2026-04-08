import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class AcademiaPage extends StatefulWidget {
  final String userId;
  final String negocio;

  const AcademiaPage({super.key, required this.userId, required this.negocio});

  @override
  State<AcademiaPage> createState() => _AcademiaPageState();
}

class _AcademiaPageState extends State<AcademiaPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<DateTime> _blockedDays = [];
  String _horaSeleccionada = '';
  String _claseSeleccionada = '';
  bool _loading = false;

  final List<String> clases = ['Inglés', 'Matemáticas', 'Repaso'];
  final List<String> horarios = ['16:00', '17:00', '18:00', '19:00'];

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es_ES', null);
    _fetchBlockedDays();
  }

  Future<void> _fetchBlockedDays() async {
    final today = DateTime.now();
    final snapshot = await FirebaseFirestore.instance
        .collection('reservas')
        .where('servicio', isEqualTo: widget.negocio)
        .where('estado', isEqualTo: 'activa')
        .get();

    List<DateTime> blocked = [];
    for (var doc in snapshot.docs) {
      DateTime fecha = (doc['fecha'] as Timestamp).toDate();
      if (fecha.isAfter(today.subtract(const Duration(days: 1)))) {
        blocked.add(fecha);
      }
    }

    setState(() {
      _blockedDays = blocked;
    });
  }

  Future<void> _reservar() async {
    if (_selectedDay == null || _horaSeleccionada.isEmpty || _claseSeleccionada.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona fecha, hora y clase')),
      );
      return;
    }

    setState(() { _loading = true; });

    final now = DateTime.now();
    final snapshot = await FirebaseFirestore.instance
        .collection('reservas')
        .where('userId', isEqualTo: widget.userId)
        .where('servicio', isEqualTo: widget.negocio)
        .where('estado', isEqualTo: 'activa')
        .get();

    int reservasActivas = snapshot.docs
        .where((doc) => (doc['fecha'] as Timestamp).toDate().isAfter(now))
        .length;

    if (reservasActivas >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solo puedes tener 3 reservas activas')),
      );
      setState(() { _loading = false; });
      return;
    }

    // Guardar reserva
    await FirebaseFirestore.instance.collection('reservas').add({
      'userId': widget.userId,
      'servicio': widget.negocio,
      'fecha': _selectedDay,
      'hora': _horaSeleccionada,
      'clase': _claseSeleccionada,
      'estado': 'activa',
      'timestamp': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reserva realizada correctamente')),
    );

    _fetchBlockedDays();
    setState(() {
      _selectedDay = null;
      _horaSeleccionada = '';
      _claseSeleccionada = '';
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.negocio)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Logo
              Image.asset(
                'assets/images/LogoAlphaAppAcademia.png',
                width: 250, // un poco más grande
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 20),

              // Calendario
              TableCalendar(
                locale: 'es_ES',
                firstDay: DateTime.now(),
                lastDay: DateTime.now().add(const Duration(days: 365)),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() { _selectedDay = selectedDay; _focusedDay = focusedDay; });
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: const BoxDecoration(
                      color: Colors.blue, shape: BoxShape.circle),
                  selectedDecoration: const BoxDecoration(
                      color: Colors.orange, shape: BoxShape.circle),
                  markerDecoration: const BoxDecoration(
                      color: Colors.green, shape: BoxShape.circle),
                  outsideDaysVisible: true,
                  defaultDecoration: const BoxDecoration(
                      shape: BoxShape.circle),
                  weekendDecoration: const BoxDecoration(
                      shape: BoxShape.circle),
                ),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    if (_blockedDays.any((d) => isSameDay(d, date))) {
                      return const Positioned(
                        bottom: 1,
                        child: Icon(Icons.circle, size: 8, color: Colors.green),
                      );
                    }
                    return null;
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Selección de clase
              DropdownButton<String>(
                value: _claseSeleccionada.isEmpty ? null : _claseSeleccionada,
                hint: const Text('Selecciona clase'),
                items: clases.map((c) =>
                  DropdownMenuItem(value: c, child: Text(c))
                ).toList(),
                onChanged: (value) {
                  setState(() { _claseSeleccionada = value ?? ''; });
                },
              ),

              const SizedBox(height: 10),

              // Selección de hora
              DropdownButton<String>(
                value: _horaSeleccionada.isEmpty ? null : _horaSeleccionada,
                hint: const Text('Selecciona hora'),
                items: horarios.map((h) =>
                  DropdownMenuItem(value: h, child: Text(h))
                ).toList(),
                onChanged: (value) {
                  setState(() { _horaSeleccionada = value ?? ''; });
                },
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _loading ? null : _reservar,
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Reservar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}