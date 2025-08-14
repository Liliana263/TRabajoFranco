import 'package:flutter/material.dart';
import '../controllers/ProcedimientoController.dart';
import '../models/ProcedimientoModel.dart';
import 'RegistrarUsuarioView.dart';
import 'PantallaLoginview.dart';
import 'menuDrawerPerfil.dart';
import 'LoginSinIniciarSesion.dart';
import 'DetallesClinicaSinSesion.dart';

class MenuPrincipalSesion extends StatefulWidget {
  @override
  _MenuPrincipalSesionState createState() => _MenuPrincipalSesionState();
}

class _MenuPrincipalSesionState extends State<MenuPrincipalSesion> {
  final controller = ProcedimientoController();
  List<Procedimiento> procedimientos = [];
  bool cargando = true;

  final Color fondo = Color(0xFF0F172A);
  final Color primario = Color(0xFF1E293B);
  final Color segundario = Color(0xFF334155);
  final Color texto = Color(0xFFFFFFFF);

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    try {
      final datos = await controller.obtenerProcedimientos();
      setState(() {
        procedimientos = datos;
        cargando = false;
      });
    } catch (e) {
      print("Error al obtener procedimientos: $e");
      setState(() => cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fondo,
      drawer: MenuDrawerSinSesion(),
      appBar: AppBar(
        title: Text('Clinica Estetica - rejuvenezk'),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: primario),
                hintText: "Buscar procedimiento",
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
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: procedimientos.length,
                      itemBuilder: (context, index) {
                        final proc = procedimientos[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          elevation: 2,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetallesClinicaSinSesion(
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
                                  child: Image.asset(
                                    'assets/images/servicios/piel.jpg',
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          proc.nombre,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text("💲 Precio: \$${proc.precio}"),
                                        Text("⏱️ Duración: ${proc.duracion} min"),
                                        Text("🩺 Evaluación: ${proc.requiereEvaluacion == 1 ? 'Sí' : 'No'}"),
                                      ],
                                    ),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(right: 10),
                                  child: Icon(Icons.arrow_forward_ios,
                                      color: Colors.blueAccent, size: 18),
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
              Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreen()));
              break;
            case 1:
              Navigator.push(context, MaterialPageRoute(builder: (_) => MenuPrincipalSesion()));
              break;
            case 2:
              Navigator.push(context, MaterialPageRoute(builder: (_) => MenuDrawerPerfil()));
              break;
            case 3:
              Navigator.push(context, MaterialPageRoute(builder: (_) => RegistrarUsuario()));
              break;
          }
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home, color: primario), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.person, color: primario), label: 'Alquiler'),
          BottomNavigationBarItem(icon: Icon(Icons.settings, color: primario), label: 'Usuario'),
          BottomNavigationBarItem(icon: Icon(Icons.app_registration, color: primario), label: 'Registrar'),
        ],
      ),
    );
  }
}
