import 'PantallaLoginview.dart';
import 'package:flutter/material.dart';
import 'menuDrawerPerfil.dart';
import '../views/RegistrarUsuarioView.dart';
import 'DetallesClinica.dart';
import '../services/ProcedimientoSerivice.dart';
import '../models/ProcedimientoModel.dart';
import 'DashboardDoctorview.dart';
import 'DashboardUsuarioview.dart';

class MenuPrincipalSesion extends StatefulWidget {
  final String rol;
  const MenuPrincipalSesion({Key? key, required this.rol}) : super(key: key);

  @override
  _MenuPrincipalSesionState createState() => _MenuPrincipalSesionState();
}

class _MenuPrincipalSesionState extends State<MenuPrincipalSesion> {
  // Colores principales
  final Color fondo = const Color(0xFF0F172A);
  final Color primario = const Color(0xFF1E293B);
  final Color segundario = const Color(0xFF334155);
  final Color detalle = const Color(0xFF22C55E);
  final Color texto = const Color(0xFFFFFFFF);
  final Color linkAzul = const Color(0xFF3B82F6);
  final Color grisClaro = const Color(0xFF94A3B8);

  List<Procedimiento> procedimientos = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarProcedimientos();
  }

  // ------ FALLBACK ESTÁTICO ------
  List<Procedimiento> _fallbackProcedimientos() {
    // Si tu modelo no tiene fromJson, crea con el constructor que tengas.
    return [
      Procedimiento.fromJson({
        "nombre": "Limpieza Facial Profunda",
        "precio": 80000,
        "duracion": 60,
        "requiereEvaluacion": 0,
        "imagen": "https://i.ibb.co/fX4p9CN/facial1.jpg",
      }),
      Procedimiento.fromJson({
        "nombre": "Masaje Relajante",
        "precio": 120000,
        "duracion": 90,
        "requiereEvaluacion": 0,
        "imagen": "https://i.ibb.co/6HmbXZm/masaje1.jpg",
      }),
      Procedimiento.fromJson({
        "nombre": "Exfoliación Corporal",
        "precio": 95000,
        "duracion": 75,
        "requiereEvaluacion": 1,
        "imagen": "https://i.ibb.co/RDY72sk/exfoliacion1.jpg",
      }),
    ];
  }

  Future<void> _cargarProcedimientos() async {
    try {
      final lista = await ProcedimientoService.listarProcedimientos();
      setState(() {
        // Si la API viene vacía, usa los 3 estáticos
        procedimientos = (lista.isEmpty) ? _fallbackProcedimientos() : lista;
        cargando = false;
      });
    } catch (e) {
      print('Error al cargar procedimientos: $e');
      // En error, también muestra los estáticos
      setState(() {
        procedimientos = _fallbackProcedimientos();
        cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.rol == 'doctor') {
      return const PantallaDoctor();
    } else if (widget.rol == 'usuario') {
      return const PantallaUsuario();
    } else {
      return Scaffold(
        backgroundColor: fondo,
        drawer: MenuDrawerPerfil(),
        appBar: AppBar(
          title: const Text('Clinica Estetica - rejuvenezk'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: primario),
                  hintText: 'Buscar procedimiento...',
                  hintStyle: TextStyle(color: texto.withOpacity(0.5)),
                  filled: true,
                  fillColor: segundario,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: cargando
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: procedimientos.length,
                        itemBuilder: (BuildContext context, int index) {
                          final proc = procedimientos[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            elevation: 2,
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetallesClinica(
                                      imageUrl: proc.imagen,
                                      nombre: proc.nombre,
                                      duracion: proc.duracion,
                                      precio: proc.precio,
                                    ),
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      bottomLeft: Radius.circular(10),
                                    ),
                                    child: Image.network(
                                      proc.imagen,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                                width: 100,
                                                height: 100,
                                                color: Colors.grey[300],
                                                child: const Icon(
                                                  Icons.image_not_supported,
                                                ),
                                              ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            proc.nombre,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text("💲 Precio: \$${proc.precio}"),
                                          Text(
                                            "⏱️ Duración: ${proc.duracion} min",
                                          ),
                                          Text(
                                            "🩺 Evaluación: ${(proc.requiereEvaluacion) == 1 ? 'Sí' : 'No'}",
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.only(right: 10),
                                    child: Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.blueAccent,
                                      size: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 1,
          onTap: (index) {
            switch (index) {
              case 0:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
                break;
              case 1:
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MenuPrincipalSesion(rol: widget.rol),
                  ),
                );
                break;
              case 2:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MenuDrawerPerfil()),
                );
                break;
              case 3:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegistrarUsuario()),
                );
                break;
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Alquiler'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Usuario'),
            BottomNavigationBarItem(icon: Icon(Icons.app_registration), label: 'Registrar'),
          ],
        ),
      );
    }
  }
}
