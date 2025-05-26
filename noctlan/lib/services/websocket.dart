// services/websocket_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:noctlan/services/notifications.dart';
import 'package:noctlan/utils/api.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService with ChangeNotifier {
  final WebSocketChannel _channel =
      WebSocketChannel.connect(Uri.parse('ws://$API_URI/metrics'));

  final Map<int, Map<String, dynamic>> _metricasPorPaciente = {};

  WebSocketService() {
    _channel.stream.listen((event) {
      final data = jsonDecode(event);
      data['pacientes'].forEach((paciente) {
        if (paciente['ritmoCardiaco'] > 90) {
          mostrarNotificacion(
            'Alerta de Ritmo Cardíaco',
            'El paciente ${paciente['nombre']} tiene un ritmo cardíaco elevado: ${paciente['ritmoCardiaco']} bpm.',
          );
        }
        if (paciente['respiracion'] > 18) {
          mostrarNotificacion(
            'Alerta de Respiración',
            'El paciente ${paciente['nombre']} tiene una respiración elevada: ${paciente['respiracion']} rpm.',
          );
        }
        if (paciente['ruido'] > 80) {
          mostrarNotificacion(
            'Alerta de Ruido',
            'El paciente ${paciente['nombre']} tiene un nivel de ruido elevado: ${paciente['ruido']} dB.',
          );
        }
        final pacienteId = paciente['id'];
        _metricasPorPaciente[pacienteId] = {
          'ritmo_cardiaco': paciente['ritmoCardiaco'],
          'respiracion': paciente['respiracion'],
          'ruido': paciente['ruido'],
        };
      });
      //final int pacienteId = data['id'];
      //_metricasPorPaciente[pacienteId] = data;
      notifyListeners();
    });
  }

  Map<String, dynamic>? getMetricasDePaciente(int pacienteId) {
    return _metricasPorPaciente[pacienteId];
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }
}
