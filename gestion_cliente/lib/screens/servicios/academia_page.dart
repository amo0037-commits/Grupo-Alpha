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

  // Obtiene días que tienen alguna reserva para marcarlos en el calendario
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
      debugPrint("Error obteniendo días: $e");
    }
  }

  // Lógica principal: Filtra por aforo (10) y por reserva previa del usuario
  Future<void> _actualizarHorasDisponibles() async {
    if (_selectedDay == null || _claseSeleccionada.isEmpty) return;
    setState(() { _loading = true; });

    DateTime fechaBusqueda = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
    
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('reservas')
          .where('servicio', isEqualTo: widget.negocio)
          .where('fecha', isEqualTo: Timestamp.fromDate(fechaBusqueda))
          .where('clase', isEqualTo: _claseSeleccionada)
          .where('estado', isEqualTo: 'activa')
          .get();

      // 1. Mapa para contar aforo global
      Map<String, int> conteoGlobal = {};
      // 2. Lista para saber dónde ya reservó este usuario
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

          // Disponible si: hay menos de 10 personas Y yo no estoy en esa lista
          return total < 10 && !yoYaReserve;
        }).toList();

        if (!_horasDisponibles.contains(_horaSeleccionada)) _horaSeleccionada = '';
        _loading = false;
      });
    } catch (e) {
      debugPrint("Error: $e");
      setState(() { _loading = false; });
    }
  }

  Future<void> _reservar() async {
    if (_selectedDay == null || _horaSeleccionada.isEmpty || _claseSeleccionada.isEmpty) {
      _mostrarMensaje('Completa todos los campos');
      return;
    }

    setState(() { _loading = true; });

    try {
      DateTime fechaBusqueda = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);

      // Verificación de seguridad de último segundo (Cupo y duplicado)
      final snapshotCheck = await FirebaseFirestore.instance
          .collection('reservas')
          .where('servicio', isEqualTo: widget.negocio)
          .where('fecha', isEqualTo: Timestamp.fromDate(fechaBusqueda))
          .where('clase', isEqualTo: _claseSeleccionada)
          .where('hora', isEqualTo: _horaSeleccionada)
          .where('estado', isEqualTo: 'activa')
          .get();

      // Chequear si el usuario ya está ahí (por si acaso)
      bool yaEstoyInscrito = snapshotCheck.docs.any((doc) => doc['userId'] == widget.userId);
      
      if (yaEstoyInscrito) { // Esto no debería pasar porque ya filtramos, pero por seguridad lo volvemos a revisar antes de reservar
        _mostrarMensaje('Ya tienes una reserva para esta clase y hora.');
        _actualizarHorasDisponibles();
        return;
      }

      if (snapshotCheck.docs.length >= 10) { // Aforo máximo
        _mostrarMensaje('¡Lo sentimos! El cupo se acaba de llenar.'); 
        _actualizarHorasDisponibles();
        return;
      }

      // Si todo OK, guardamos
      await FirebaseFirestore.instance.collection('reservas').add({
        'userId': widget.userId,
        'servicio': widget.negocio,
        'fecha': fechaBusqueda,
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
      _mostrarMensaje('Error al reservar: $e');
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
        title: Text(widget.negocio, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF1565C0),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Column(
                children: [
                  Image.asset('assets/images/LogoAlphaAppAcademia.png', width: screenWidth * 0.8, height: 100, fit: BoxFit.contain),
                  const SizedBox(height: 20),

                  // CALENDARIO
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
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
                        leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black),
                        rightChevronIcon: Icon(Icons.chevron_right, color: Colors.black),
                      ),
                      calendarStyle: const CalendarStyle(
                        selectedDecoration: BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle),
                        todayTextStyle: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
                      ),
                      calendarBuilders: CalendarBuilders(
                        markerBuilder: (context, date, events) {
                          if (_blockedDays.any((d) => isSameDay(d, date))) {
                            return Positioned(
                              bottom: 6,
                              child: Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                            );
                          }
                          return null;
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // DROPDOWN MATERIA
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    alignment: AlignmentDirectional.center,
                    value: _claseSeleccionada.isEmpty ? null : _claseSeleccionada,
                    decoration: _inputDecoration('Selecciona Materia'),
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                    items: clases.map((c) => DropdownMenuItem(value: c, child: Center(child: Text(c)))).toList(),
                    onChanged: (val) {
                      setState(() => _claseSeleccionada = val!);
                      _actualizarHorasDisponibles();
                    },
                  ),

                  const SizedBox(height: 15),

                  // DROPDOWN HORA
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    alignment: AlignmentDirectional.center,
                    value: _horaSeleccionada.isEmpty ? null : _horaSeleccionada,
                    decoration: _inputDecoration('Hora disponible'),
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                    items: _horasDisponibles.map((h) => DropdownMenuItem(value: h, child: Center(child: Text(h)))).toList(),
                    onChanged: _selectedDay == null ? null : (val) => setState(() => _horaSeleccionada = val!),
                  ),

                  const SizedBox(height: 35),

                  // BOTÓN RESERVAR
                  SizedBox(
                    width: screenWidth * 0.7,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _reservar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: _loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('RESERVAR', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
    );
  }
}