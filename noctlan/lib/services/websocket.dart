// services/websocket_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
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
        final pacienteId = paciente['id'];
        _metricasPorPaciente[pacienteId] = {
          'ritmo_cardiaco': paciente['ritmo_cardiaco'],
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
