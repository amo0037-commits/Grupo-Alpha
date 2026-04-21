import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:gestion_cliente/notifications_service.dart';

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
      if (mounted) {
        setState(() {
          _blockedDays = blocked;
        });
      }
    } catch (e) {
      debugPrint("Error obteniendo días: $e");
    }
  }

  Future<void> _actualizarHorasDisponibles() async {
    if (_selectedDay == null || _claseSeleccionada.isEmpty) return;
    setState(() {
      _loading = true;
    });

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

      Map<String, int> conteoGlobal = {};
      List<String> misHoras = [];

      for (var doc in snapshot.docs) {
        String hora = doc['hora'] as String;
        String uid = doc['userId'] as String;
        conteoGlobal[hora] = (conteoGlobal[hora] ?? 0) + 1;
        if (uid == widget.userId) {
          misHoras.add(hora);
        }
      }

      setState(() {
        _horasDisponibles = horariosTotales.where((h) {
          int total = conteoGlobal[h] ?? 0;
          bool yoYaReserve = misHoras.contains(h);
          return total < 10 && !yoYaReserve;
        }).toList();

        if (!_horasDisponibles.contains(_horaSeleccionada)) {
          _horaSeleccionada = '';
        }
        _loading = false;
      });
    } catch (e) {
      debugPrint("Error: $e");
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _reservar() async {
    if (_selectedDay == null ||
        _horaSeleccionada.isEmpty ||
        _claseSeleccionada.isEmpty) {
      _mostrarMensaje('Completa todos los campos');
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      DateTime fechaBusqueda = DateTime(
        _selectedDay!.year,
        _selectedDay!.month,
        _selectedDay!.day,
      );

      // ── fechaCompleta para notificación ────────────────────
      final partesHora = _horaSeleccionada.split(':');
      final fechaCompleta = DateTime(
        fechaBusqueda.year,
        fechaBusqueda.month,
        fechaBusqueda.day,
        int.parse(partesHora[0]),
        int.parse(partesHora[1]),
      );
      // ───────────────────────────────────────────────────────

      final snapshotCheck = await FirebaseFirestore.instance
          .collection('reservas')
          .where('servicio', isEqualTo: widget.negocio)
          .where('fecha', isEqualTo: Timestamp.fromDate(fechaBusqueda))
          .where('clase', isEqualTo: _claseSeleccionada)
          .where('hora', isEqualTo: _horaSeleccionada)
          .where('estado', isEqualTo: 'activa')
          .get();

      bool yaEstoyInscrito = snapshotCheck.docs.any(
        (doc) => doc['userId'] == widget.userId,
      );

      if (yaEstoyInscrito) {
        _mostrarMensaje('Ya tienes una reserva para esta clase y hora.');
        _actualizarHorasDisponibles();
        return;
      }

      if (snapshotCheck.docs.length >= 10) {
        _mostrarMensaje('¡Lo sentimos! El cupo se acaba de llenar.');
        _actualizarHorasDisponibles();
        return;
      }

      await FirebaseFirestore.instance.collection('reservas').add({
        'userId': widget.userId,
        'servicio': widget.negocio,
        'fecha': fechaBusqueda,
        'hora': _horaSeleccionada,
        'clase': _claseSeleccionada,
        'estado': 'activa',
        'fechaHora': Timestamp.fromDate(fechaCompleta), // ← añadido
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

      // ── Programar notificación ──────────────────────────────
      try {
        await NotificationsService.scheduleNotification(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          servicio: widget.negocio,
          especialista: _claseSeleccionada,
          scheduledDate: fechaCompleta,
        );
      } catch (e) {
        debugPrint('Error al programar notificación: $e');
      }
      // ────────────────────────────────────────────────────────

    } catch (e) {
      _mostrarMensaje('Error al reservar: $e');
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _mostrarMensaje(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
      );

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
              colors: [Color(0xFF1E293B), Color(0xFF334155), Color(0xFF64B5F6)],
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
              Color(0xFFF5F5F5),
              Color(0xFFFFB74D),
              Color(0xFFF57C00),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 450),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/LogoAlphaAppAcademia.png',
                      width: screenWidth * 0.9,
                      height: 120,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 20),

                    // ── Calendario ──────────────────────────────────────────
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: TableCalendar(
                        locale: 'es_ES',
                        startingDayOfWeek: StartingDayOfWeek.monday,
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
                        headerStyle: const HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                          leftChevronIcon: Icon(
                            Icons.chevron_left,
                            color: Colors.black,
                          ),
                          rightChevronIcon: Icon(
                            Icons.chevron_right,
                            color: Colors.black,
                          ),
                        ),
                        daysOfWeekStyle: const DaysOfWeekStyle(
                          weekdayStyle: TextStyle(
                            color: Color.fromARGB(255, 255, 94, 0),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        calendarStyle: const CalendarStyle(
                          defaultTextStyle: TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                          selectedDecoration: BoxDecoration(
                            color: Colors.blueAccent,
                            shape: BoxShape.circle,
                          ),
                          todayDecoration: BoxDecoration(
                            color: Colors.orangeAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        calendarBuilders: CalendarBuilders(
                          markerBuilder: (context, date, events) {
                            if (_blockedDays.any((d) => isSameDay(d, date))) {
                              return Positioned(
                                bottom: 6,
                                child: Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              );
                            }
                            return null;
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ── Dropdown clase ──────────────────────────────────────
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
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
                        initialValue: _claseSeleccionada.isEmpty // ← fix
                            ? null
                            : _claseSeleccionada,
                        decoration: const InputDecoration(
                          labelText: 'Selecciona Materia',
                          labelStyle: TextStyle(color: Colors.black87),
                          floatingLabelStyle: TextStyle(color: Colors.black),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        selectedItemBuilder: (context) {
                          return clases.map((c) {
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
                        dropdownColor: Colors.white.withValues(alpha: 0.95),
                        items: clases.map((c) {
                          return DropdownMenuItem(
                            value: c,
                            child: Center(child: Text(c)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() => _claseSeleccionada = val!);
                          _actualizarHorasDisponibles();
                        },
                      ),
                    ),

                    const SizedBox(height: 15),

                    // ── Dropdown hora ───────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        alignment: AlignmentDirectional.center,
                        initialValue: _horaSeleccionada.isEmpty // ← fix
                            ? null
                            : _horaSeleccionada,
                        decoration: const InputDecoration(
                          labelText: 'Hora disponible',
                          labelStyle: TextStyle(color: Colors.black87),
                          floatingLabelStyle: TextStyle(color: Colors.black),
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
                        dropdownColor: Colors.white.withValues(alpha: 0.95),
                        items: _horasDisponibles.map((h) {
                          return DropdownMenuItem(
                            value: h,
                            child: Center(child: Text(h)),
                          );
                        }).toList(),
                        onChanged: _selectedDay == null
                            ? null
                            : (val) =>
                                setState(() => _horaSeleccionada = val!),
                      ),
                    ),

                    const SizedBox(height: 35),

                    // ── Botón reservar ──────────────────────────────────────
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
                              colors: [
                                Color(0xFF1E293B),
                                Color(0xFF334155),
                                Color(0xFF64B5F6),
                              ],
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
}