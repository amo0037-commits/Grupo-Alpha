import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  List<String> _horasDisponibles = [];
  
  String _horaSeleccionada = '';
  String _claseSeleccionada = '';
  bool _loading = false;

  final List<String> clases = ['Inglés', 'Matemáticas', 'Repaso'];
  final List<String> horariosTotales = ['16:00', '17:00', '18:00', '19:00'];

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
      if (mounted) setState(() { _blockedDays = blocked; });
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  Future<void> _actualizarHorasDisponibles() async {
    if (_selectedDay == null || _claseSeleccionada.isEmpty) return;
    setState(() { _loading = true; });

    DateTime fechaBusqueda = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
    final snapshot = await FirebaseFirestore.instance
        .collection('reservas')
        .where('servicio', isEqualTo: widget.negocio)
        .where('fecha', isEqualTo: Timestamp.fromDate(fechaBusqueda))
        .where('clase', isEqualTo: _claseSeleccionada)
        .where('estado', isEqualTo: 'activa')
        .get();

    List<String> horasOcupadas = snapshot.docs.map((doc) => doc['hora'] as String).toList();

    setState(() {
      _horasDisponibles = horariosTotales.where((h) => !horasOcupadas.contains(h)).toList();
      if (!_horasDisponibles.contains(_horaSeleccionada)) _horaSeleccionada = '';
      _loading = false;
    });
  }

  Future<void> _reservar() async {
    if (_selectedDay == null || _horaSeleccionada.isEmpty || _claseSeleccionada.isEmpty) {
      _mostrarMensaje('Completa todos los campos');
      return;
    }
    setState(() { _loading = true; });
    try {
      await FirebaseFirestore.instance.collection('reservas').add({
        'userId': widget.userId,
        'servicio': widget.negocio,
        'fecha': DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day),
        'hora': _horaSeleccionada,
        'clase': _claseSeleccionada,
        'estado': 'activa',
        'timestamp': FieldValue.serverTimestamp(),
      });
      _mostrarMensaje('¡Reserva confirmada!');
      _fetchBlockedDays();
      setState(() {
        _selectedDay = null;
        _horaSeleccionada = '';
        _claseSeleccionada = '';
        _horasDisponibles = List.from(horariosTotales);
      });
    } catch (e) {
      _mostrarMensaje('Error: $e');
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  void _mostrarMensaje(String msg) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating)
  );

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          widget.negocio, 
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF1565C0), 
        // iconTheme fuerza a que los iconos (como la flecha de atrás) sean negros
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0, 
        surfaceTintColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey[300], height: 1.0),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/LogoAlphaAppAcademia.png', 
                    width: screenWidth * 0.8,
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 20),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5)),
                      ],
                    ),
                    child: TableCalendar(
                      locale: 'es_ES',
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      firstDay: DateTime.now(),
                      lastDay: DateTime.now().add(const Duration(days: 365)),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                      onDaySelected: (selected, focused) {
                        setState(() { _selectedDay = selected; _focusedDay = focused; });
                        _actualizarHorasDisponibles();
                      },
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextStyle: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                        // Iconos de las flechas del calendario en negro
                        leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black),
                        rightChevronIcon: Icon(Icons.chevron_right, color: Colors.black),
                      ),
                      calendarStyle: CalendarStyle(
                        outsideDaysVisible: false,
                        weekendTextStyle: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                        selectedDecoration: const BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle),
                        todayDecoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.1), shape: BoxShape.circle),
                        todayTextStyle: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
                      ),
                      calendarBuilders: CalendarBuilders(
                        markerBuilder: (context, date, events) {
                          if (_blockedDays.any((d) => isSameDay(d, date))) {
                            return Positioned(
                              bottom: 6,
                              child: Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                              ),
                            );
                          }
                          return null;
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    alignment: AlignmentDirectional.center,
                    value: _claseSeleccionada.isEmpty ? null : _claseSeleccionada,
                    decoration: _inputDecoration('Selecciona Materia'),
                    // Icono del dropdown en negro
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                    items: clases.map((c) => DropdownMenuItem(
                      value: c, 
                      child: Center(child: Text(c, textAlign: TextAlign.center))
                    )).toList(),
                    onChanged: (val) {
                      setState(() => _claseSeleccionada = val!);
                      _actualizarHorasDisponibles();
                    },
                  ),

                  const SizedBox(height: 15),

                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    alignment: AlignmentDirectional.center,
                    value: _horaSeleccionada.isEmpty ? null : _horaSeleccionada,
                    decoration: _inputDecoration('Hora disponible'),
                    // Icono del dropdown en negro
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                    items: _horasDisponibles.map((h) => DropdownMenuItem(
                      value: h, 
                      child: Center(child: Text(h, textAlign: TextAlign.center))
                    )).toList(),
                    onChanged: _selectedDay == null ? null : (val) => setState(() => _horaSeleccionada = val!),
                  ),

                  const SizedBox(height: 35),

                  SizedBox(
                    width: screenWidth * 0.7,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _reservar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        elevation: 3,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: _loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('RESERVAR', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
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
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
    );
  }
}