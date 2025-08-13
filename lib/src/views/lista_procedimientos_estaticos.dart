import 'package:flutter/material.dart';
// Usa el nombre EXACTO del archivo/clase que ya tienes:
import 'DetallesClinica.dart';

class ListaProcedimientos extends StatelessWidget {
  const ListaProcedimientos({Key? key}) : super(key: key);

  final List<Map<String, dynamic>> procedimientosEstaticos = const [
    {
      "imageUrl": "https://i.ibb.co/fX4p9CN/facial1.jpg",
      "nombre": "Limpieza Facial Profunda",
      "precio": 80000,
      "duracion": 60
    },
    {
      "imageUrl": "https://i.ibb.co/6HmbXZm/masaje1.jpg",
      "nombre": "Masaje Relajante",
      "precio": 120000,
      "duracion": 90
    },
    {
      "imageUrl": "https://i.ibb.co/RDY72sk/exfoliacion1.jpg",
      "nombre": "Exfoliación Corporal",
      "precio": 95000,
      "duracion": 75
    }
  ];

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
        itemBuilder: (context, index) {
          final proc = procedimientosEstaticos[index];
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
                child: Image.network(
                  proc["imageUrl"],
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(
                proc["nombre"],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("💲 ${proc["precio"]}"),
                  Text("⏱️ ${proc["duracion"]} min"),
                ],
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetallesClinica(
                      imageUrl: proc["imageUrl"],
                      nombre: proc["nombre"],
                      precio: proc["precio"],
                      duracion: proc["duracion"],
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
