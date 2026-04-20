import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;

// Navigator key global — necesario para navegar desde fuera del contexto
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Emojis y configuración visual por servicio
const _servicioConfig = {
  'Fisioterapia': _ServicioConfig('🦴', 'ic_notif_fisioterapia', 'fisioterapia'),
  'Gimnasio':     _ServicioConfig('💪', 'ic_notif_gimnasio',     'gimnasio'),
  'Yoga':         _ServicioConfig('🧘', 'ic_notif_yoga',         'yoga'),
  'Peluqueria':   _ServicioConfig('✂️', 'ic_notif_peluqueria',   'peluqueria'),
  'Academia':     _ServicioConfig('📚', 'ic_notif_academia',     'academia'),
};

class _ServicioConfig {
  final String emoji;
  final String icono;
  final String ruta;
  const _ServicioConfig(this.emoji, this.icono, this.ruta);
}

class NotificationsService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    tzdata.initializeTimeZones();

    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      ),
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        _onNotificationTap(details.payload);
      },
    );

    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      try { await androidPlugin.requestNotificationsPermission(); } catch (_) {}
      try { await androidPlugin.requestExactAlarmsPermission(); } catch (_) {}
    }

    _initialized = true;
  }

  static void _onNotificationTap(String? payload) {
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/dashboard',
      (route) => false,
    );
  }

  static Future<void> scheduleNotification({
    required int id,
    required String servicio,
    required String especialista,
    required DateTime scheduledDate,
  }) async {
    if (!_initialized) await init();

    final notifyAt = scheduledDate.subtract(const Duration(hours: 1));
    if (notifyAt.isBefore(DateTime.now())) return;

    final config = _servicioConfig[servicio] ??
        const _ServicioConfig('📅', '@mipmap/ic_launcher', 'dashboard');

    final androidDetails = AndroidNotificationDetails(
      'reservas_channel',
      'Recordatorio de citas',
      channelDescription: 'Aviso 1 hora antes de tu cita',
      importance: Importance.max,
      priority: Priority.high,
      icon: config.icono,
      color: const Color(0xFF1E293B),
      styleInformation: BigTextStyleInformation(
        '${config.emoji} Tu cita de $servicio empieza en 1 hora\n'
        '👤 Especialista: $especialista\n'
        '🕐 ${_formatHora(scheduledDate)}',
        contentTitle: '${config.emoji} Recordatorio — $servicio',
        summaryText: servicio,
      ),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _plugin.zonedSchedule(
        id,
        '${config.emoji} Recordatorio — $servicio',
        'Tu cita empieza en 1 hora · $especialista',
        tz.TZDateTime.from(notifyAt, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: config.ruta,
      );
    } catch (_) {
      try {
        await _plugin.zonedSchedule(
          id,
          '${config.emoji} Recordatorio — $servicio',
          'Tu cita empieza en 1 hora · $especialista',
          tz.TZDateTime.from(notifyAt, tz.local),
          details,
          androidScheduleMode: AndroidScheduleMode.inexact,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: config.ruta,
        );
      } catch (_) {}
    }
  }

  static String _formatHora(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  static Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}