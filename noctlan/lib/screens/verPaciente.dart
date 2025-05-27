import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:noctlan/utils/api.dart';
import './metricas.dart';

class VerPacienteScreen extends StatefulWidget {
  const VerPacienteScreen({super.key});

  @override
  State<VerPacienteScreen> createState() => _VerPacienteScreenState();
}

class _VerPacienteScreenState extends State<VerPacienteScreen> {
  List<dynamic> pacientes = [];
  List<dynamic> camas = [];
  List<dynamic> medicos = [];
  String? status;

  // Para guardar las selecciones de cada paciente
  Map<int, int?> camasSeleccionadas = {};
  Map<int, int?> medicosSeleccionados = {};

  Future<void> obtenerDatos() async {
    try {
      final responses = await Future.wait([
        http.get(Uri.parse('http://$API_URI/pacientes')),
        http.get(Uri.parse('http://$API_URI/camas')),
        http.get(Uri.parse('http://$API_URI/usuarios?rol=medico')),
      ]);

      if (responses.any((res) => res.statusCode != 200)) {
        setState(() {
          status = 'Error al cargar datos';
        });
        return;
      }

      final pacs = jsonDecode(responses[0].body);
      final camasResp = jsonDecode(responses[1].body);
      final medicosResp = jsonDecode(responses[2].body);

      // Inicializamos los mapas con los valores actuales
      final nuevasCamasSeleccionadas = <int, int?>{};
      final nuevosMedicosSeleccionados = <int, int?>{};

      for (var paciente in pacs) {
        final atencion = (paciente['Atencion_pacientes'] as List).isNotEmpty
            ? paciente['Atencion_pacientes'][0]
            : null;
        nuevasCamasSeleccionadas[paciente['id']] = atencion?['Cama']?['id'];
        nuevosMedicosSeleccionados[paciente['id']] =
            atencion?['Usuario']?['id'];
      }

      setState(() {
        pacientes = pacs;
        camas = camasResp;
        medicos = medicosResp;
        camasSeleccionadas = nuevasCamasSeleccionadas;
        medicosSeleccionados = nuevosMedicosSeleccionados;
        status = null;
      });
    } catch (e) {
      setState(() {
        status = 'Error inesperado al obtener datos';
      });
    }
  }

  Future<void> darDeAlta(int pacienteId) async {
    final response = await http.delete(
      Uri.parse('http://$API_URI/pacientes/$pacienteId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      await obtenerDatos(); // Refrescar datos para actualizar la UI
      setState(() {
        status = 'Paciente dado de alta correctamente';
      });
    } else {
      setState(() {
        status = 'Error al dar de alta: ${response.statusCode}';
      });
    }
  }

  Future<void> guardarAsignacion(int pacienteId) async {
    final camaId = camasSeleccionadas[pacienteId];
    final medicoId = medicosSeleccionados[pacienteId];

    if (camaId == null || medicoId == null) {
      setState(() {
        status = 'Debe seleccionar cama y médico';
      });
      return;
    }

    final response = await http.patch(
      Uri.parse('http://$API_URI/pacientes/$pacienteId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'camaId': camaId,
        'usuarioId': medicoId,
      }),
    );

    if (response.statusCode == 200) {
      await obtenerDatos(); // Refrescar datos para actualizar la UI
      setState(() {
        status = 'Asignación guardada correctamente';
      });
    } else {
      setState(() {
        status = 'Error al asignar: ${response.statusCode}';
      });
    }
  }

  // Obtiene las camas que no están ocupadas por otros pacientes (excepto la actual del paciente)
  List<dynamic> camasDisponiblesParaPaciente(int pacienteId) {
    // IDs de camas ocupadas excluyendo la cama actual del pacienteId
    final camasOcupadas = <int>{};
    for (var pac in pacientes) {
      if (pac['id'] == pacienteId) continue;
      final atencion = (pac['Atencion_pacientes'] as List).isNotEmpty
          ? pac['Atencion_pacientes'][0]
          : null;
      final camaId = atencion?['Cama']?['id'];
      if (camaId != null) {
        camasOcupadas.add(camaId);
      }
    }
    // Filtramos camas para no mostrar las ocupadas
    return camas.where((cama) => !camasOcupadas.contains(cama['id'])).toList();
  }

  @override
  void initState() {
    super.initState();
    obtenerDatos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pacientes')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (status != null)
              Text(status!, style: const TextStyle(color: Colors.red)),
            ...pacientes.map((paciente) {
              final pacienteId = paciente['id'];
              final atencion =
                  (paciente['Atencion_pacientes'] as List).isNotEmpty
                      ? paciente['Atencion_pacientes'][0]
                      : null;

              final camaActual = atencion?['Cama'];
              final medicoActual = atencion?['Usuario'];

              final camasDisponibles = camasDisponiblesParaPaciente(pacienteId);

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${paciente['nombre']} ${paciente['apellido']}',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      if (camaActual != null)
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SimulacionMetricasScreen(
                                  wsUrl: 'ws://$API_URI/metrics',
                                  userId: paciente['id'],
                                  nombrePaciente: '${paciente['nombre']}',
                                  camaString:
                                      '${camaActual['numero']} - ${camaActual['Cuarto']['nombre']}',
                                ),
                              ),
                            );
                          },
                          child: const Text('Ver métricas'),
                        ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        value: camasSeleccionadas[pacienteId],
                        items:
                            camasDisponibles.map<DropdownMenuItem<int>>((cama) {
                          print(cama);
                          return DropdownMenuItem<int>(
                            value: cama['id'],
                            child: Text(
                                'Cama ${cama['numero']} - ${cama['Cuarto']['nombre']}'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            camasSeleccionadas[pacienteId] = value;
                          });
                        },
                        decoration:
                            const InputDecoration(labelText: 'Asignar Cama'),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        value: medicosSeleccionados[pacienteId],
                        items: medicos.map<DropdownMenuItem<int>>((medico) {
                          return DropdownMenuItem<int>(
                            value: medico['id'],
                            child: Text(
                                'Dr. ${medico['nombre']} ${medico['apellido']}'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            medicosSeleccionados[pacienteId] = value;
                          });
                        },
                        decoration:
                            const InputDecoration(labelText: 'Asignar Médico'),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => guardarAsignacion(pacienteId),
                        child: const Text('Guardar asignación'),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                          onPressed: () => darDeAlta(pacienteId),
                          child: const Text('Dar de alta'))
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
