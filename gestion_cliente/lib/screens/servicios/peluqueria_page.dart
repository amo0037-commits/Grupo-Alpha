import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/date_symbol_data_local.dart';

class PeluqueriaPage extends StatefulWidget {

  final String userId;
  final String negocio;

  const PeluqueriaPage({super.key, required this.userId, required this.negocio});

  @override
  State<PeluqueriaPage> createState() => _PeluqueriaPageState();
}


  class _PeluqueriaPageState extends State<PeluqueriaPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  List<String> _horasDisponibles = [];

  String _horaSeleccionada = '';
  String _actividadSeleccionada = '';
  bool _loading = false;

  final List<String> actividades = [
    'Corte Caballero',
    'Corte Dama',
    'Coloración',
    'Tratamiento Capilar',
    'Barbería',
  ];

  final List<String> horariosTotales = [
    '08:00',
    '09:00',
    '10:00',
    '11:00',
    '12:00',
    '17:00',
    '18:00',
    '19:00',
    '20:00',
  ];

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es_ES', null);
    _horasDisponibles = List.from(horariosTotales);
  }

  Future<void> _actualizarHorasDisponibles() async {
    if (_selectedDay == null || _actividadSeleccionada.isEmpty) return;

    setState(() => _loading = true);

    DateTime fecha = DateTime(
      _selectedDay!.year,
      _selectedDay!.month,
      _selectedDay!.day,
    );

    final snapshot = await FirebaseFirestore.instance
        .collection('reservas')
        .where('servicio', isEqualTo: widget.negocio)
        .where('fecha', isEqualTo: Timestamp.fromDate(fecha))
        .where('clase', isEqualTo: _actividadSeleccionada)
        .where('estado', isEqualTo: 'activa')
        .get();

    Map<String, int> conteo = {};
    List<String> mias = [];

    for (var doc in snapshot.docs) {
      String hora = doc['hora'];
      String uid = doc['userId'];

      conteo[hora] = (conteo[hora] ?? 0) + 1;

      if (uid == widget.userId) {
        mias.add(hora);
      }
    }

    setState(() {
      _horasDisponibles = horariosTotales.where((h) {
        int total = conteo[h] ?? 0;
        bool yaEstoy = mias.contains(h);
        return total < 20 && !yaEstoy;
      }).toList();

      if (!_horasDisponibles.contains(_horaSeleccionada)) {
        _horaSeleccionada = '';
      }

      _loading = false;
    });
  }

   Future<void> _reservar() async {
    if (_selectedDay == null ||
        _horaSeleccionada.isEmpty ||
        _actividadSeleccionada.isEmpty) {
      _msg("Completa todos los campos");
      return;
    }

    setState(() => _loading = true);

    DateTime fecha = DateTime(
      _selectedDay!.year,
      _selectedDay!.month,
      _selectedDay!.day,
    );

    final check = await FirebaseFirestore.instance
        .collection('reservas')
        .where('servicio', isEqualTo: widget.negocio)
        .where('fecha', isEqualTo: Timestamp.fromDate(fecha))
        .where('clase', isEqualTo: _actividadSeleccionada)
        .where('hora', isEqualTo: _horaSeleccionada)
        .where('estado', isEqualTo: 'activa')
        .get();

    if (check.docs.any((d) => d['userId'] == widget.userId)) {
      _msg("Ya tienes reserva");
      setState(() => _loading = false);
      return;
    }

    if (check.docs.length >= 20) {
      _msg("Cupo lleno");
      setState(() => _loading = false);
      return;
    }
   await FirebaseFirestore.instance.collection('reservas').add({
      'userId': widget.userId,
      'servicio': widget.negocio,
      'fecha': fecha,
      'hora': _horaSeleccionada,
      'clase': _actividadSeleccionada,
      'estado': 'activa',
      'timestamp': FieldValue.serverTimestamp(),
    });

    _msg("Reserva confirmada");

    setState(() {
      _selectedDay = null;
      _horaSeleccionada = '';
      _actividadSeleccionada = '';
      _horasDisponibles = List.from(horariosTotales);
    });

    if (mounted) setState(() => _loading = false);
  }

  void _msg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }
 
 
 @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.transparent,

      appBar: AppBar(
        title: Text(
          widget.negocio,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E293B), Color(0xFF334155), Color(0xFF64B5F6)],
            ),
          ),
        ),
      ),
   body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFFFFF), 
              Color(0xFFFEFBDD), 
              Color(0xFFE1D3BB), 
              Color(0xFFD7A894),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

    child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 450),
                child: Column(
                  children: [
                    // LOGO
                    Image.asset(
                      'assets/images/LogoAlphaAppPeluquería.png',
                      width: screenWidth * 0.9,
                      height: 120,
                      fit: BoxFit.contain,
                    ),
       const SizedBox(height: 20),

                    // CALENDARIO
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TableCalendar(
                        locale: 'es_ES',
                        firstDay: DateTime.now(),
                        lastDay: DateTime.now().add(const Duration(days: 365)),
                        focusedDay: _focusedDay,
                        startingDayOfWeek: StartingDayOfWeek.monday,
                        selectedDayPredicate: (d) => isSameDay(_selectedDay, d),
                        onDaySelected: (s, f) {
                          setState(() {
                            _selectedDay = s;
                            _focusedDay = f;
                          });
                          _actualizarHorasDisponibles();
                        },
                        daysOfWeekStyle: const DaysOfWeekStyle(
                          weekdayStyle: TextStyle(
                            color: Color(0xFFD7A894), // amarillo
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        headerStyle: const HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                        ),

                        calendarStyle: const CalendarStyle(
                          todayDecoration: BoxDecoration(
                            color: Color(0xFFD7A894),

                            shape: BoxShape.circle,
                          ),

                          selectedDecoration: BoxDecoration(
                            color: Colors.blueAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),

              const SizedBox(height: 30),



                    // ACTIVIDAD
                    _buildDropdown(
                      label: "Actividad",
                      value: _actividadSeleccionada,
                      items: actividades,
                      onChanged: (v) {
                        setState(() => _actividadSeleccionada = v!);
                        _actualizarHorasDisponibles();
                      },
                    ),
                 const SizedBox(height: 15),

                    // HORA
                    _buildDropdown(
                      label: "Hora disponible",
                      value: _horaSeleccionada,
                      items: _horasDisponibles,
                      onChanged: _selectedDay == null
                          ? null
                          : (v) => setState(() => _horaSeleccionada = v!),
                    ),

                    const SizedBox(height: 35),

                    // BOTÓN
                    SizedBox(
                      width: screenWidth * 0.7,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _reservar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF1E293B),
                                Color(0xFF334155),
                                Color(0xFF64B5F6),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            child: _loading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    "RESERVAR",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                   const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

    Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?)? onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonFormField<String>(
        isExpanded: true,
       initialValue: value.isEmpty ? null : value,
        decoration: const InputDecoration(
          labelText: '',
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
        hint: Text(label),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}


