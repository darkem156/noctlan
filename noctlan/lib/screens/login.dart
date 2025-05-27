import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:noctlan/utils/api.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import './register.dart';
import '../utils/jwt.dart';
import './verUsuario.dart';
import './verPaciente.dart';
import '../services/websocket.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? error;

  Future<void> login() async {
    final response = await http.post(
      Uri.parse('http://$API_URI/signIn'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': _emailController.text,
        'password': _passwordController.text,
      }),
    );

    if (response.statusCode == 200) {
      final token = jsonDecode(response.body)['token'];
      final tipoUsuario = parseJwt(token)['tipo_usuario'];
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => Consumer<WebSocketService>(
                builder: (context, wsService, child) {
              final metricasPaciente1 =
                  wsService.getMetricasDePaciente(1); // ID de prueba

              return Scaffold(
                appBar: AppBar(title: const Text('Sistema de Monitoreo')),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Bienvenido al sistema'),
                      const SizedBox(height: 20),
                      const SizedBox(height: 20),
                      const Text('Bienvenido al sistema'),
                      const SizedBox(height: 20),
                      if (tipoUsuario == 'administrador')
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => RegisterScreen(jwt: token)),
                            );
                          },
                          child: const Text('Registrar usuario'),
                        ),
                      const SizedBox(height: 20),
                      if (tipoUsuario == 'administrador')
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => VerUsuarioScreen()),
                            );
                          },
                          child: const Text('Ver usuarios'),
                        ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => RegisterPacienteScreen()),
                          );
                        },
                        child: const Text('Registrar paciente'),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => VerPacienteScreen()),
                          );
                        },
                        child: const Text('Ver pacientes'),
                      ),
                      const SizedBox(height: 20),
                      if (tipoUsuario == 'administrador')
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => AdministrarAreasScreen()),
                            );
                          },
                          child: const Text('Administrar áreas'),
                        ),
                      const SizedBox(height: 20),
                      if (tipoUsuario == 'administrador')
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => AdministrarCuartosScreen()),
                            );
                          },
                          child: const Text('Administrar cuartos'),
                        ),
                      const SizedBox(height: 20),
                      if (tipoUsuario == 'administrador')
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => CamasScreen()),
                            );
                          },
                          child: const Text('Administrar camas'),
                        ),
                      /*
                        const SizedBox(height: 20),
                        if (tipoUsuario == 'administrador' ||
                            tipoUsuario == 'medico')
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => AsignarCamaMedicoScreen()),
                              );
                            },
                            child: const Text('Asignar camas a médicos'),
                          ),
                          */
                    ],
                  ),
                ),
              );
            }), //RegisterScreen(jwt: token)),
          ));
    } else {
      setState(() {
        error = 'Credenciales incorrectas';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (error != null)
              Text(error!, style: const TextStyle(color: Colors.red)),
            TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email')),
            TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password')),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: login, child: const Text('Iniciar sesión')),
          ],
        ),
      ),
    );
  }
}

class RegisterPacienteScreen extends StatefulWidget {
  const RegisterPacienteScreen({super.key});

  @override
  State<RegisterPacienteScreen> createState() => _RegisterPacienteScreenState();
}

class _RegisterPacienteScreenState extends State<RegisterPacienteScreen> {
  final _nombre = TextEditingController();
  final _apellido = TextEditingController();
  final _fechaNacimiento = TextEditingController();
  final _genero = TextEditingController();
  String? status;

  Future<void> registrar() async {
    final response = await http.post(
      Uri.parse('http://$API_URI/pacientes'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nombre': _nombre.text,
        'apellido': _apellido.text,
        'fechaNacimiento': _fechaNacimiento.text,
        'genero': _genero.text,
      }),
    );

    setState(() {
      if (response.statusCode == 201) {
        _nombre.clear();
        _apellido.clear();
        _fechaNacimiento.clear();
        _genero.clear();
        status = 'Paciente registrado correctamente';
      } else {
        status =
            'Error al registrar paciente: ${response.statusCode} ${response.body}';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Paciente')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (status != null)
              Text(status!, style: const TextStyle(color: Colors.green)),
            TextField(
                controller: _nombre,
                decoration: const InputDecoration(labelText: 'Nombre')),
            TextField(
                controller: _apellido,
                decoration: const InputDecoration(labelText: 'Apellido')),
            TextField(
                controller: _fechaNacimiento,
                decoration:
                    const InputDecoration(labelText: 'Fecha de Nacimiento')),
            TextField(
                controller: _genero,
                decoration: const InputDecoration(labelText: 'Género')),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: registrar, child: const Text('Registrar paciente')),
          ],
        ),
      ),
    );
  }
}

class AdministrarAreasScreen extends StatefulWidget {
  const AdministrarAreasScreen({super.key});

  @override
  State<AdministrarAreasScreen> createState() => _AdministrarAreasScreenState();
}

class _AdministrarAreasScreenState extends State<AdministrarAreasScreen> {
  List<dynamic> areas = [];
  String? status;
  TextEditingController _nombreController = TextEditingController();

  Future<void> obtenerAreas() async {
    final response = await http.get(
      Uri.parse('http://$API_URI/areas'),
      headers: {'Content-Type': 'application/json'},
    );

    setState(() {
      if (response.statusCode == 200) {
        areas = jsonDecode(response.body);
        status = null;
      } else {
        status =
            'Error al obtener áreas: ${response.statusCode} ${response.body}';
      }
    });
  }

  Future<void> agregarArea(String nombre) async {
    final response = await http.post(
      Uri.parse('http://$API_URI/areas'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'nombre': nombre}),
    );

    if (response.statusCode == 201) {
      _nombreController.clear();
      obtenerAreas();
    } else {
      setState(() {
        status =
            'Error al agregar área: ${response.statusCode} ${response.body}';
      });
    }
  }

  Future<void> eliminarArea(int id) async {
    final response = await http.delete(
      Uri.parse('http://$API_URI/areas/$id'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      obtenerAreas();
    } else {
      setState(() {
        status =
            'Error al eliminar área: ${response.statusCode} ${response.body}';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    obtenerAreas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Administrar Áreas')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (status != null)
              Text(status!, style: const TextStyle(color: Colors.red)),
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: 'Nombre del área'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_nombreController.text.isNotEmpty) {
                  agregarArea(_nombreController.text);
                }
              },
              child: const Text('Agregar Área'),
            ),
            const SizedBox(height: 20),
            const Divider(),
            ...areas.map((area) => ListTile(
                  title: Text(area['nombre']),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => eliminarArea(area['id']),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class AdministrarCuartosScreen extends StatefulWidget {
  const AdministrarCuartosScreen({super.key});

  @override
  State<AdministrarCuartosScreen> createState() =>
      _AdministrarCuartosScreenState();
}

class _AdministrarCuartosScreenState extends State<AdministrarCuartosScreen> {
  List<dynamic> cuartos = [];
  List<dynamic> areas = [];
  String? status;
  TextEditingController _numeroController = TextEditingController();
  int? _selectedAreaId;

  Future<void> obtenerCuartos() async {
    final response = await http.get(
      Uri.parse('http://$API_URI/cuartos'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      setState(() {
        cuartos = jsonDecode(response.body);
      });
    } else {
      setState(() {
        status =
            'Error al obtener cuartos: ${response.statusCode} ${response.body}';
      });
    }
  }

  Future<void> obtenerAreas() async {
    final response = await http.get(
      Uri.parse('http://$API_URI/areas'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      setState(() {
        areas = jsonDecode(response.body);
      });
    } else {
      setState(() {
        status =
            'Error al obtener áreas: ${response.statusCode} ${response.body}';
      });
    }
  }

  Future<void> agregarCuarto(String numero, int areaId) async {
    final response = await http.post(
      Uri.parse('http://$API_URI/cuartos'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'numero': numero, 'areaId': areaId}),
    );

    if (response.statusCode == 201) {
      _numeroController.clear();
      _selectedAreaId = null;
      obtenerCuartos();
    } else {
      setState(() {
        status =
            'Error al agregar cuarto: ${response.statusCode} ${response.body}';
      });
    }
  }

  Future<void> eliminarCuarto(int id) async {
    final response = await http.delete(
      Uri.parse('http://$API_URI/cuartos/$id'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      obtenerCuartos();
    } else {
      setState(() {
        status =
            'Error al eliminar cuarto: ${response.statusCode} ${response.body}';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    obtenerCuartos();
    obtenerAreas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Administrar Cuartos')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (status != null)
              Text(status!, style: const TextStyle(color: Colors.red)),
            TextField(
              controller: _numeroController,
              decoration: const InputDecoration(labelText: 'Número de cuarto'),
            ),
            DropdownButtonFormField<int>(
              value: _selectedAreaId,
              hint: const Text('Selecciona un área'),
              items: areas.map<DropdownMenuItem<int>>((area) {
                return DropdownMenuItem<int>(
                  value: area['id'],
                  child: Text(area['nombre']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedAreaId = value;
                });
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                if (_numeroController.text.isNotEmpty &&
                    _selectedAreaId != null) {
                  agregarCuarto(_numeroController.text, _selectedAreaId!);
                }
              },
              child: const Text('Agregar Cuarto'),
            ),
            const Divider(),
            const SizedBox(height: 10),
            ...cuartos.map((cuarto) => ListTile(
                  title: Text('${cuarto['nombre']} - id: ${cuarto['id']}'),
                  subtitle:
                      Text('Área: ${cuarto['Area']?['nombre'] ?? 'Sin área'}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => eliminarCuarto(cuarto['id']),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class CamasScreen extends StatefulWidget {
  const CamasScreen({super.key});

  @override
  State<CamasScreen> createState() => _CamasScreenState();
}

class _CamasScreenState extends State<CamasScreen> {
  List<dynamic> camas = [];
  String? status;
  TextEditingController _numeroController = TextEditingController();
  TextEditingController _cuartoIdController = TextEditingController();

  Future<void> obtenerCamas() async {
    final response = await http.get(
      Uri.parse('http://$API_URI/camas'),
      headers: {'Content-Type': 'application/json'},
    );

    setState(() {
      if (response.statusCode == 200) {
        camas = jsonDecode(response.body);
        status = null;
      } else {
        status =
            'Error al obtener camas: ${response.statusCode} ${response.body}';
      }
    });
  }

  Future<void> agregarCama() async {
    final response = await http.post(
      Uri.parse('http://$API_URI/camas'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'numero': _numeroController.text,
        'cuartoId': int.tryParse(_cuartoIdController.text),
      }),
    );

    if (response.statusCode == 201) {
      Navigator.of(context).pop();
      obtenerCamas();
    } else {
      setState(() {
        status =
            'Error al agregar cama: ${response.statusCode} ${response.body}';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    obtenerCamas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Camas')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (status != null)
              Text(status!, style: const TextStyle(color: Colors.red)),
            ...camas.map((cama) => ListTile(
                  title: Text('Cama N° ${cama['numero']}'),
                  subtitle: Text(
                    'Cuarto: ${cama['Cuarto']?['nombre'] ?? 'Desconocido'} - Medico asignado: ${cama['Atencion_pacientes'].length == 0 ? 'Ninguno' : "${cama['Atencion_pacientes'][0]['Usuario']?['nombre']} ${cama['Atencion_pacientes'][0]['Usuario']?['apellido']}"}',
                  ),
                )),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Agregar nueva cama'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _numeroController,
                        decoration:
                            const InputDecoration(labelText: 'Número de cama'),
                      ),
                      TextField(
                        controller: _cuartoIdController,
                        decoration:
                            const InputDecoration(labelText: 'ID del cuarto'),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: agregarCama,
                      child: const Text('Guardar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                  ],
                ),
              ),
              child: const Text('Agregar cama'),
            ),
          ],
        ),
      ),
    );
  }
}
