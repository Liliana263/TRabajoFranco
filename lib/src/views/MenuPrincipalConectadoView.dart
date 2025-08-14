import 'package:flutter/material.dart';
import '../controllers/ProcedimientoController.dart';
import '../models/ProcedimientoModel.dart';
import 'DetallesClinica.dart';
import 'RegistrarUsuarioView.dart';
import 'PantallaLoginview.dart';
import 'menuDrawerPerfil.dart';

class MenuPrincipalConectadoSesion extends StatefulWidget {
  @override
  _MenuPrincipalSesionState createState() => _MenuPrincipalSesionState();
}

class _MenuPrincipalSesionState extends State<MenuPrincipalConectadoSesion> {
  final controller = ProcedimientoController();
  List<Procedimiento> procedimientos = [];
  bool cargando = true;

  final Color fondo = const Color(0xFF0F172A);
  final Color primario = const Color(0xFF1E293B);
  final Color segundario = const Color(0xFF334155);
  final Color texto = const Color(0xFFFFFFFF);

  @override
  void initState() { super.initState(); cargarDatos(); }

  Future<void> cargarDatos() async {
    try { procedimientos = await controller.obtenerProcedimientos(); }
    finally { if (mounted) setState(() => cargando = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fondo,
      drawer: MenuDrawerPerfil(),
      appBar: AppBar(title: const Text('Clinica Estetica - rejuvenezk'), backgroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: primario),
                hintText: "Buscar procedimiento",
                hintStyle: TextStyle(color: texto.withOpacity(0.5)),
                filled: true, fillColor: segundario,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: cargando
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: procedimientos.length,
                      itemBuilder: (context, i) {
                        final p = procedimientos[i];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8), elevation: 2,
                          child: InkWell(
                            onTap: () => Navigator.push(context, MaterialPageRoute(
                              builder: (_) => DetallesClinica(
                                imageUrl: p.imagen, nombre: p.nombre, duracion: p.duracion, precio: p.precio,
                              ),
                            )),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
                                  child: Image.asset(
                                    'assets/images/servicios/piel.jpg',
                                    width: 100, height: 100, fit: BoxFit.cover),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(p.nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        const SizedBox(height: 4),
                                        Text("💲 Precio: \$${p.precio}"),
                                        Text("⏱️ Duración: ${p.duracion} min"),
                                        Text("🩺 Evaluación: ${p.requiereEvaluacion == 1 ? 'Sí' : 'No'}"),
                                      ],
                                    ),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(right: 10),
                                  child: Icon(Icons.arrow_forward_ios, color: Colors.blueAccent, size: 18),
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
        onTap: (i) {
          switch (i) {
            case 0: Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreen())); break;
            case 1: Navigator.push(context, MaterialPageRoute(builder: (_) => MenuPrincipalConectadoSesion())); break;
            case 2: Navigator.push(context, MaterialPageRoute(builder: (_) => MenuDrawerPerfil())); break;
            case 3: Navigator.push(context, MaterialPageRoute(builder: (_) => RegistrarUsuario())); break;
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
