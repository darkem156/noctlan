import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class SimulacionMetricasScreen extends StatefulWidget {
  const SimulacionMetricasScreen({super.key});

  @override
  State<SimulacionMetricasScreen> createState() =>
      _SimulacionMetricasScreenState();
}

class _SimulacionMetricasScreenState extends State<SimulacionMetricasScreen> {
  final int maxPoints = 20;
  final List<FlSpot> ritmoCardiaco = [];
  final List<FlSpot> respiracion = [];
  final List<FlSpot> ruido = [];
  double time = 0;
  Timer? timer;

  final Random rng = Random();

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (_) => _simularDatos());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _simularDatos() {
    setState(() {
      time += 1;
      _agregarDato(
          ritmoCardiaco, FlSpot(time, 60 + rng.nextInt(40).toDouble()));
      _agregarDato(respiracion, FlSpot(time, 10 + rng.nextInt(10).toDouble()));
      _agregarDato(ruido, FlSpot(time, rng.nextInt(100).toDouble()));
    });
  }

  void _agregarDato(List<FlSpot> lista, FlSpot dato) {
    if (lista.length >= maxPoints) {
      lista.removeAt(0);
    }
    lista.add(dato);
  }

  Widget _buildGrafica(String titulo, List<FlSpot> data, Color color) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(titulo,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: data,
                      isCurved: true,
                      color: color,
                      barWidth: 2,
                      dotData: FlDotData(show: false),
                    )
                  ],
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
            _buildGrafica(
                'Frecuencia Cardíaca (bpm)', ritmoCardiaco, Colors.red),
            _buildGrafica('Respiración (rpm)', respiracion, Colors.blue),
            _buildGrafica('Ruido Ambiental (dB)', ruido, Colors.green),
          ],
        ),
      ),
    );
  }
}
