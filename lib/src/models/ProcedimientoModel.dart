class Procedimiento {
  final String imagen;              // no se usa para mostrar (usamos asset local)
  final String nombre;
  final int duracion;
  final int precio;
  final int requiereEvaluacion;

  Procedimiento({
    required this.imagen,
    required this.nombre,
    required this.duracion,
    required this.precio,
    required this.requiereEvaluacion,
  });

  factory Procedimiento.fromJson(Map<String, dynamic> json) => Procedimiento(
        imagen: json['imagen'] ?? '',
        nombre: json['nombre'] ?? '',
        duracion: int.tryParse(json['duracion'].toString()) ?? 0,
        precio: int.tryParse(json['precio'].toString()) ?? 0,
        requiereEvaluacion:
            int.tryParse(json['requiere_evaluacion'].toString()) ?? 0,
      );
}
