import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/date_symbol_data_local.dart';

class YogaPage extends StatefulWidget {
  final String userId;
  final String negocio;

  const YogaPage({
    super.key,
    required this.userId,
    required this.negocio,
  });

  @override
  State<YogaPage> createState() => _YogaPageState();
}

class _YogaPageState extends State<YogaPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  List<DateTime> _blockedDays = [];
  List<String> _horasDisponibles = [];

  String _horaSeleccionada = '';
  String _claseSeleccionada = '';
  bool _loading = false;

  final List<String> clases = [
    'Yoga Suave',
    'Vinyasa',
    'Power Yoga',
    'Meditación'
  ];

  final List<String> horariosTotales = [
    '08:00',
    '10:00',
    '18:00',
    '20:00'
  ];

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es_ES', null);
    _fetchBlockedDays();
    _horasDisponibles = List.from(horariosTotales);
  }

  Future<void> _fetchBlockedDays() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('reservas')
          .where('servicio', isEqualTo: widget.negocio)
          .where('estado', isEqualTo: 'activa')
          .get();

      List<DateTime> blocked = [];

      for (var doc in snapshot.docs) {
        DateTime fecha = (doc['fecha'] as Timestamp).toDate();
        blocked.add(DateTime(fecha.year, fecha.month, fecha.day));
      }

      if (mounted) {
        setState(() {
          _blockedDays = blocked;
        });
      }
    } catch (e) {
      debugPrint("Error bloqueando días: $e");
    }
  }

  Future<void> _actualizarHorasDisponibles() async {
    if (_selectedDay == null || _claseSeleccionada.isEmpty) return;

    setState(() => _loading = true);

    DateTime fechaBusqueda = DateTime(
      _selectedDay!.year,
      _selectedDay!.month,
      _selectedDay!.day,
    );

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('reservas')
          .where('servicio', isEqualTo: widget.negocio)
          .where('fecha', isEqualTo: Timestamp.fromDate(fechaBusqueda))
          .where('clase', isEqualTo: _claseSeleccionada)
          .where('estado', isEqualTo: 'activa')
          .get();

      Map<String, int> conteo = {};
      List<String> misHoras = [];

      for (var doc in snapshot.docs) {
        String hora = doc['hora'];
        String uid = doc['userId'];

        conteo[hora] = (conteo[hora] ?? 0) + 1;

        if (uid == widget.userId) {
          misHoras.add(hora);
        }
      }

      setState(() {
        _horasDisponibles = horariosTotales.where((h) {
          int total = conteo[h] ?? 0;
          bool yaReserve = misHoras.contains(h);
          return total < 10 && !yaReserve;
        }).toList();

        if (!_horasDisponibles.contains(_horaSeleccionada)) {
          _horaSeleccionada = '';
        }

        _loading = false;
      });
    } catch (e) {
      debugPrint("Error horas: $e");
      setState(() => _loading = false);
    }
  }

  Future<void> _reservar() async {
    if (_selectedDay == null ||
        _horaSeleccionada.isEmpty ||
        _claseSeleccionada.isEmpty) {
      _mensaje("Completa todos los campos");
      return;
    }

    setState(() => _loading = true);

    try {
      DateTime fechaBusqueda = DateTime(
        _selectedDay!.year,
        _selectedDay!.month,
        _selectedDay!.day,
      );

      final check = await FirebaseFirestore.instance
          .collection('reservas')
          .where('servicio', isEqualTo: widget.negocio)
          .where('fecha', isEqualTo: Timestamp.fromDate(fechaBusqueda))
          .where('clase', isEqualTo: _claseSeleccionada)
          .where('hora', isEqualTo: _horaSeleccionada)
          .where('estado', isEqualTo: 'activa')
          .get();

      bool yaExiste = check.docs.any(
        (d) => d['userId'] == widget.userId,
      );

      if (yaExiste) {
        _mensaje("Ya tienes una reserva en esta clase");
        setState(() => _loading = false);
        return;
      }

      if (check.docs.length >= 10) {
        _mensaje("Cupo lleno");
        setState(() => _loading = false);
        return;
      }

      await FirebaseFirestore.instance.collection('reservas').add({
        'userId': widget.userId,
        'servicio': widget.negocio,
        'fecha': fechaBusqueda,
        'hora': _horaSeleccionada,
        'clase': _claseSeleccionada,
        'estado': 'activa',
        'timestamp': FieldValue.serverTimestamp(),
      });

      _mensaje("Reserva confirmada 🧘‍♀️");

      setState(() {
        _selectedDay = null;
        _horaSeleccionada = '';
        _claseSeleccionada = '';
        _horasDisponibles = List.from(horariosTotales);
      });

      _fetchBlockedDays();
    } catch (e) {
      _mensaje("Error: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _mensaje(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.transparent,

      appBar: AppBar(
        title: Text(
          widget.negocio,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
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
              colors: [
                Color(0xFF1E293B),
                Color(0xFF334155),
                Color(0xFF64B5F6)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
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
              Colors.white,
              Color(0xFF14B8A6),
              Color(0xFF0F766E),
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
                    Image.asset(
                      'assets/images/LogoAlphaAppYoga.png',
                      width: screenWidth * 0.9,
                      height: 120,
                      fit: BoxFit.contain,
                    ),

                    const SizedBox(height: 20),

                    // CALENDARIO (FIX "2 WEEKS")
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(25),
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
                      child: TableCalendar(
                        locale: 'es_ES',
                        startingDayOfWeek: StartingDayOfWeek.monday,

                        calendarFormat: CalendarFormat.month,
                        availableCalendarFormats: const {
                          CalendarFormat.month: '',
                        },

                        firstDay: DateTime.now(),
                        lastDay: DateTime.now().add(const Duration(days: 365)),
                        focusedDay: _focusedDay,
                        selectedDayPredicate: (day) =>
                            isSameDay(_selectedDay, day),

                        onDaySelected: (selected, focused) {
                          setState(() {
                            _selectedDay = selected;
                            _focusedDay = focused;
                          });
                          _actualizarHorasDisponibles();
                        },
                         daysOfWeekStyle: const DaysOfWeekStyle(
                          weekdayStyle: TextStyle(
                            color: Color.fromARGB(255, 0, 184, 197),
                            fontWeight: FontWeight.bold,
                          ),
                          
                        ),
                        
                        

                        calendarStyle: const CalendarStyle(
                          selectedDecoration: BoxDecoration(
                            color: Colors.blueAccent,
                            shape: BoxShape.circle,
                          ),
                           todayDecoration: BoxDecoration(
                            color:Color(0xFF14B8A6),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // CLASE
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.4),
                        ),
                      ),
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: _claseSeleccionada.isEmpty
                            ? null
                            : _claseSeleccionada,
                        decoration: const InputDecoration(
                          labelText: 'Tipo de Yoga',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        items: clases
                            .map((c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(c),
                                ))
                            .toList(),
                        onChanged: (val) {
                          setState(() => _claseSeleccionada = val!);
                          _actualizarHorasDisponibles();
                        },
                      ),
                    ),

                    const SizedBox(height: 15),

                    // HORA
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.4),
                        ),
                      ),
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: _horaSeleccionada.isEmpty
                            ? null
                            : _horaSeleccionada,
                        decoration: const InputDecoration(
                          labelText: 'Hora disponible',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        items: _horasDisponibles
                            .map((h) => DropdownMenuItem(
                                  value: h,
                                  child: Text(h),
                                ))
                            .toList(),
                        onChanged: _selectedDay == null
                            ? null
                            : (val) =>
                                setState(() => _horaSeleccionada = val!),
                      ),
                    ),

                    const SizedBox(height: 35),

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
                                Color(0xFF64B5F6)
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
}