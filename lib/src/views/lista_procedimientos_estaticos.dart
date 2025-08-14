import 'package:flutter/material.dart';
import 'DetallesClinica.dart';

class ListaProcedimientos extends StatelessWidget {
  const ListaProcedimientos({Key? key}) : super(key: key);

  // Agrego "requiereEvaluacion" para poder mostrar Sí/No
  final List<Map<String, dynamic>> procedimientosEstaticos = const [
    {"imageUrl": "", "nombre": "Limpieza Facial Profunda", "precio": 80000,  "duracion": 60, "requiereEvaluacion": 1},
    {"imageUrl": "", "nombre": "Masaje Relajante",         "precio": 120000, "duracion": 90, "requiereEvaluacion": 0},
    {"imageUrl": "", "nombre": "Exfoliación Corporal",     "precio": 95000,  "duracion": 75, "requiereEvaluacion": 1},
  ];

  String _evalTxt(dynamic v) => (v == 1 || v == true) ? 'Sí' : 'No';

  // Fila con ícono + "Etiqueta: valor"
  Widget _filaIcon(IconData icon, Color color, String etiqueta, String valor) {
    return Padding(
      padding: const EdgeInsets.only(top: 2, bottom: 2),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Text('$etiqueta ',
              style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(valor)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text("Procedimientos"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: ListView.builder(
        itemCount: procedimientosEstaticos.length,
        padding: const EdgeInsets.all(12),
        itemBuilder: (context, i) {
          final p = procedimientosEstaticos[i];
          return Card(
            color: const Color(0xFFE0E1DD),
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(8),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/images/servicios/piel.jpg',
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(
                p["nombre"],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _filaIcon(Icons.attach_money, Colors.green.shade700,
                      'Precio:', '\$${p["precio"]}'),
                  _filaIcon(Icons.timer_outlined, Colors.grey.shade700,
                      'Duración:', '${p["duracion"]} min'),
                  _filaIcon(Icons.fact_check_outlined, Colors.blue.shade700,
                      'Evaluación:', _evalTxt(p["requiereEvaluacion"])),
                ],
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetallesClinica(
                      imageUrl: "", // no usado; DetallesClinica carga el asset
                      nombre: p["nombre"],
                      precio: p["precio"],
                      duracion: p["duracion"],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
