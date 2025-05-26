import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:noctlan/utils/api.dart';

class AsignarCamaMedicoScreen extends StatefulWidget {
  const AsignarCamaMedicoScreen({super.key});

  @override
  State<AsignarCamaMedicoScreen> createState() =>
      _AsignarCamaMedicoScreenState();
}

class _AsignarCamaMedicoScreenState extends State<AsignarCamaMedicoScreen> {
  List<dynamic> medicos = [];
  List<dynamic> camas = [];
  String? status;

  @override
  void initState() {
    super.initState();
    obtenerMedicosYCamas();
  }

  Future<void> obtenerMedicosYCamas() async {
    try {
      final medicosResponse =
          await http.get(Uri.parse('http://$API_URI/usuarios?rol=medico'));
      final camasResponse = await http.get(Uri.parse('http://$API_URI/camas'));

      if (medicosResponse.statusCode == 200 &&
          camasResponse.statusCode == 200) {
        setState(() {
          medicos = jsonDecode(medicosResponse.body);
          camas = jsonDecode(camasResponse.body);
        });
      } else {
        setState(() {
          status = 'Error al obtener datos del servidor';
        });
      }
    } catch (e) {
      setState(() {
        status = 'Error: $e';
      });
    }
  }

  Future<void> asignarCama(int camaId, int medicoId) async {
    final response = await http.put(
      Uri.parse('http://$API_URI/camas/$camaId/asignar-medico'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'medicoId': medicoId}),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cama asignada correctamente')),
      );
      obtenerMedicosYCamas(); // refrescar
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al asignar cama: ${response.body}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Asignar Camas a Médicos')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: status != null
            ? Text(status!, style: const TextStyle(color: Colors.red))
            : ListView.builder(
                itemCount: medicos.length,
                itemBuilder: (context, index) {
                  final medico = medicos[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${medico['nombre']} ${medico['apellido']}',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<int>(
                            decoration: const InputDecoration(
                              labelText: 'Asignar cama',
                              border: OutlineInputBorder(),
                            ),
                            value: camas.firstWhere(
                              (cama) => cama['medicoId'] == medico['id'],
                              orElse: () => null,
                            )?['id'],
                            items: camas.map<DropdownMenuItem<int>>((cama) {
                              return DropdownMenuItem<int>(
                                value: cama['id'],
                                child: Text(
                                    'Cama ${cama['numero']} (ID: ${cama['id']})'),
                              );
                            }).toList(),
                            onChanged: (camaId) {
                              if (camaId != null) {
                                asignarCama(camaId, medico['id']);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
