import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/date_symbol_data_local.dart';

class FisioterapiaPage extends StatefulWidget {
  final String userId;
  final String negocio;

  const FisioterapiaPage({
    super.key,
    required this.userId,
    required this.negocio,
  });

  @override
  State<FisioterapiaPage> createState() => _FisioterapiaPageState();
}

class _FisioterapiaPageState extends State<FisioterapiaPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<DateTime> _blockedDays = [];
  Map<DateTime, int> _reservasPorDia = {};
  List<String> _horasDisponibles = [];

  String _horaSeleccionada = '';
  String _especialistaSeleccionado = '';
  bool _loading = false;

  final List<String> especialistas = [
    'Especialista 1',
    'Especialista 2',
    'Especialista 3'
  ];

  final List<String> horariosTotales = [
    '09:30','10:30','11:30','12:30','13:30',
    '16:30','17:30','18:30'
  ];

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es_ES', null);
    _fetchBlockedDays();
    _horasDisponibles = List.from(horariosTotales);
  }

  Future<void> _fetchBlockedDays() async {
  final snapshot = await FirebaseFirestore.instance
      .collection('reservas')
      .where('servicio', isEqualTo: widget.negocio)
      .where('estado', isEqualTo: 'activa')
      .get();

  Map<DateTime, int> contador = {};

  for (var doc in snapshot.docs) {
    DateTime fecha = (doc['fecha'] as Timestamp).toDate();
    DateTime day = DateTime(fecha.year, fecha.month, fecha.day);

    contador[day] = (contador[day] ?? 0) + 1;
  }

  if (mounted) {
    setState(() {
      _reservasPorDia = contador;
      _blockedDays = contador.keys.toList();
    });
  }
}

 Future<void> _actualizarHorasDisponibles() async {
  if (_selectedDay == null || _especialistaSeleccionado.isEmpty) return;

  setState(() => _loading = true);

  final isSaturday = _selectedDay!.weekday == DateTime.saturday;
  final isSunday = _selectedDay!.weekday == DateTime.sunday;

  if (isSunday) {
    setState(() {
      _horasDisponibles = [];
      _loading = false;
    });
    return;
  }

  DateTime fecha = DateTime(
    _selectedDay!.year,
    _selectedDay!.month,
    _selectedDay!.day,
  );

  final snapshot = await FirebaseFirestore.instance
      .collection('reservas')
      .where('servicio', isEqualTo: widget.negocio)
      .where('fecha', isEqualTo: Timestamp.fromDate(fecha))
      .where('clase', isEqualTo: _especialistaSeleccionado)
      .where('estado', isEqualTo: 'activa')
      .get();

  List<String> ocupadas = snapshot.docs.map((e) => e['hora'] as String).toList();

  List<String> disponibles = List.from(horariosTotales);

 
  if (isSaturday) {
    disponibles = disponibles.where((h) => int.parse(h.split(':')[0]) < 14).toList();

    if (!['Especialista 4', 'Especialista 5'].contains(_especialistaSeleccionado)) {
      setState(() {
        _horasDisponibles = [];
        _loading = false;
      });
      _mostrar('Sábados solo Especialista 4 y 5');
      return;
    }
  }

  disponibles = disponibles.where((h) => !ocupadas.contains(h)).toList();

  setState(() {
    _horasDisponibles = disponibles;

    if (!_horasDisponibles.contains(_horaSeleccionada)) {
      _horaSeleccionada = '';
    }

    _loading = false;
  });
}

  Future<void> _reservar() async {
    if (_selectedDay == null ||
        _horaSeleccionada.isEmpty ||
        _especialistaSeleccionado.isEmpty) {
      _mostrar('Completa todos los campos');
      return;
    }

    setState(() => _loading = true);

    DateTime fecha = DateTime(
      _selectedDay!.year,
      _selectedDay!.month,
      _selectedDay!.day,
    );

    try {
      final mis = await FirebaseFirestore.instance
          .collection('reservas')
          .where('userId', isEqualTo: widget.userId)
          .where('servicio', isEqualTo: widget.negocio)
          .where('estado', isEqualTo: 'activa')
          .get();

      if (mis.docs.length >= 5) {
        _mostrar('Máximo 5 reservas activas');
        return;
      }

      final check = await FirebaseFirestore.instance
          .collection('reservas')
          .where('servicio', isEqualTo: widget.negocio)
          .where('fecha', isEqualTo: Timestamp.fromDate(fecha))
          .where('clase', isEqualTo: _especialistaSeleccionado)
          .where('hora', isEqualTo: _horaSeleccionada)
          .where('estado', isEqualTo: 'activa')
          .get();

      if (check.docs.isNotEmpty) {
        _mostrar('Hora no disponible');
        return;
      }

      await FirebaseFirestore.instance.collection('reservas').add({
        'userId': widget.userId,
        'servicio': widget.negocio,
        'fecha': fecha,
        'hora': _horaSeleccionada,
        'clase': _especialistaSeleccionado,
        'estado': 'activa',
        'timestamp': FieldValue.serverTimestamp(),
      });

      _mostrar('Reserva confirmada');

      _fetchBlockedDays();

      setState(() {
        _selectedDay = null;
        _horaSeleccionada = '';
        _especialistaSeleccionado = '';
        _horasDisponibles = List.from(horariosTotales);
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }

    final isSaturday = _selectedDay!.weekday == DateTime.saturday;

    if (isSaturday &&
        !_especialistaSeleccionado.contains('Especialista 4') &&
        !_especialistaSeleccionado.contains('Especialista 5')) {
      _mostrar('Sábados solo Especialista 4 y 5');
      return;
    }
  }

  void _mostrar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.transparent,

      // APPBAR
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
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E293B), Color(0xFF334155), Color(0xFF64B5F6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5F5F5), Color(0xFFB39DDB)],
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
                    Image.asset(
                      'assets/images/LogoAlphaAppFisioterapia.png',
                      width: screenWidth * 0.9,
                      height: 120,
                    ),

                    const SizedBox(height: 20),

                    // CALENDARIO
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: Colors.white.withOpacity(0.4)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
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
                        headerStyle: const HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,        
                        ),
                        enabledDayPredicate: (day) {
                          return day.weekday != DateTime.sunday;
                        },
                        daysOfWeekStyle: const DaysOfWeekStyle(
                          weekdayStyle: TextStyle(
                            color: Color(0xFF5E3B8C), // morado oscuro elegante
                            fontWeight: FontWeight.w600,
                          ),
                          weekendStyle: TextStyle(
                            color: Color.fromARGB(221, 126, 117, 117),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        calendarBuilders: CalendarBuilders(
                          markerBuilder: (context, date, events) {
                            final day = DateTime(date.year, date.month, date.day);
                            final count = _reservasPorDia[day] ?? 0;

                            if (count == 0) return null;

                            Color color;

                            if (count >= 4) {
                              color = Colors.orange;
                            } else {
                              color = Colors.green;
                            }

                            return Positioned(
                              bottom: 6,
                              child: Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            );
                          },
                          disabledBuilder: (context, date, focusedDay) {
                            final day = DateTime(date.year, date.month, date.day);

                            final count = _reservasPorDia[day] ?? 0;

                            if (count >= 8) {
                              return Center(
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.red.withOpacity(0.6),
                                  ),
                                  width: 30,
                                  height: 30,
                                ),
                              );
                            }

                            return null;
                          },
                        ),
                      ),
                    ),

                         const SizedBox(height: 30),

                    // ESPECIALISTA
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.4),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),

                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        alignment: AlignmentDirectional.center,

                        value: _especialistaSeleccionado.isEmpty
                            ? null
                            : _especialistaSeleccionado,
                        decoration: const InputDecoration(
                          labelText: 'Selecciona Especialista',
                          labelStyle: TextStyle(color: Colors.black87),
                          floatingLabelStyle: TextStyle(color: Colors.black),

                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,

                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        selectedItemBuilder: (context) {
                          return especialistas.map((c) {
                            return Center(
                              child: Text(
                                c,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.black),
                              ),
                            );
                          }).toList();
                        },
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.black,
                        ),

                        dropdownColor: Colors.white.withOpacity(0.95),

                        items: especialistas.map((c) {
                          return DropdownMenuItem(
                            value: c,
                            child: Center(child: Text(c)),
                          );
                        }).toList(),

                        onChanged: (val) {
                          setState(() => _especialistaSeleccionado = val!);
                          _actualizarHorasDisponibles();
                        },
                      ),
                    ),

                    const SizedBox(height: 15),

                    // DROPDOWN HORA
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.4),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),

                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        alignment: AlignmentDirectional.center,

                        value: _horaSeleccionada.isEmpty
                            ? null
                            : _horaSeleccionada,

                        decoration: InputDecoration(
                          labelText: 'Hora disponible',
                          labelStyle: const TextStyle(color: Colors.black87),
                          floatingLabelStyle: const TextStyle(
                            color: Colors.black,
                          ),

                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,

                          isCollapsed: true,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),

                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.black,
                        ),
                        selectedItemBuilder: (context) {
                          return _horasDisponibles.map((h) {
                            return Center(
                              child: Text(
                                h,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.black),
                              ),
                            );
                          }).toList();
                        },

                        dropdownColor: Colors.white.withOpacity(0.95),

                        items: _horasDisponibles.map((h) {
                          return DropdownMenuItem(
                            value: h,
                            child: Center(child: Text(h)),
                          );
                        }).toList(),

                        onChanged: _selectedDay == null
                            ? null
                            : (val) => setState(() => _horaSeleccionada = val!),
                      ),
                    ),

                    const SizedBox(height: 35),

                    // BOTÓN RESERVAR
                    SizedBox(
                      width: screenWidth * 0.7,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _reservar,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1E293B), Color(0xFF334155), Color(0xFF64B5F6)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            height: 55,
                            child: _loading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    'RESERVAR',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
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

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      floatingLabelAlignment: FloatingLabelAlignment.center,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
    );
  }
}
