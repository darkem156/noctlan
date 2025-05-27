import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class SimulacionMetricasScreen extends StatefulWidget {
  final String
      wsUrl; // URL del WebSocket, por ejemplo: ws://localhost:3000/metrics
  final int userId; // ID del usuario, aunque no se usa en esta simulación
  final String nombrePaciente;
  final String camaString;
  const SimulacionMetricasScreen(
      {super.key,
      required this.wsUrl,
      required this.userId,
      required this.nombrePaciente,
      required this.camaString});

  @override
  State<SimulacionMetricasScreen> createState() =>
      _SimulacionMetricasScreenState();
}

class _SimulacionMetricasScreenState extends State<SimulacionMetricasScreen> {
  late WebSocketChannel channel;

  Map<int, List<FlSpot>> ritmoCardiacoMap = {};
  Map<int, List<FlSpot>> respiracionMap = {};
  Map<int, List<FlSpot>> ruidoMap = {};

  final int maxPoints = 20;
  double time = 0;

  @override
  void initState() {
    super.initState();
    channel = WebSocketChannel.connect(Uri.parse(widget.wsUrl));
    channel.stream.listen((message) {
      _procesarDatos(message);
    });
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  void _procesarDatos(String message) {
    final data = jsonDecode(message);
    final pacientes = data['pacientes'] as List<dynamic>?;
    if (pacientes == null) return;

    setState(() {
      time += 1;

      for (final paciente in pacientes) {
        final id = paciente['id'] as int;
        if (id != widget.userId) continue;

        final ritmo = (paciente['ritmoCardiaco'] as num).toDouble();
        final resp = (paciente['respiracion'] as num).toDouble();
        final ruido = (paciente['ruido'] as num).toDouble();

        _agregarDato(ritmoCardiacoMap, id, FlSpot(time, ritmo));
        _agregarDato(respiracionMap, id, FlSpot(time, resp));
        _agregarDato(ruidoMap, id, FlSpot(time, ruido));
      }
    });
  }

  void _agregarDato(Map<int, List<FlSpot>> map, int id, FlSpot dato) {
    final lista = map.putIfAbsent(id, () => []);
    if (lista.length >= maxPoints) {
      lista.removeAt(0);
    }
    lista.add(dato);
  }

  Widget _buildGrafica(
      String titulo, Map<int, List<FlSpot>> dataMap, Color color) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: true),
                  lineBarsData: dataMap.entries.map((entry) {
                    final pacienteId = entry.key;
                    return LineChartBarData(
                      spots: entry.value,
                      isCurved: true,
                      color:
                          color.withOpacity(0.3 + 0.7 * (pacienteId % 10) / 10),
                      barWidth: 2,
                      dotData: FlDotData(show: false),
                      // Puedes poner aquí un tooltip o nombre del paciente si quieres
                    );
                  }).toList(),
                  minY: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Simulación de Métricas')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('${widget.nombrePaciente} - Cama: ${widget.camaString}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            _buildGrafica(
                'Frecuencia Cardíaca (bpm)', ritmoCardiacoMap, Colors.red),
            _buildGrafica('Respiración (rpm)', respiracionMap, Colors.blue),
            _buildGrafica('Ruido Ambiental (dB)', ruidoMap, Colors.green),
          ],
        ),
      ),
    );
  }
}
