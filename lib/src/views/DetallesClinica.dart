import 'package:flutter/material.dart';
import '../widgets/modal_agendar_cita.dart';

class DetallesClinica extends StatelessWidget {
  final String imageUrl, nombre;
  final int duracion, precio;
  DetallesClinica({required this.imageUrl, required this.nombre, required this.duracion, required this.precio});

  final Color fondo = const Color(0xFF0D1B2A),
      encabezado = const Color(0xFF1B263B),
      campos = const Color(0xFF415A77),
      boton = const Color(0xFF2ECC71),
      texto = const Color(0xFFE0E1DD);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fondo,
      appBar: AppBar(title: const Text("Detalle del Servicio"), backgroundColor: Colors.white, foregroundColor: Colors.black),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(imageUrl, height: 240, width: double.infinity, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(height: 240, color: Colors.grey[300], alignment: Alignment.center, child: const Icon(Icons.broken_image, size: 60))),
          ),
          const SizedBox(height: 24),
          Text(nombre, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: texto), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          _info("💲 Precio del servicio:", "\$$precio"),
          _info("⏱️ Duración:", "$duracion minutos"),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () async {
              final r1 = await _abrirModal(context);
              if (r1 == null || r1['ok'] != true) return;
              DateTime fecha = r1['fecha'];
              String h24 = r1['hora'], h12 = _h12(h24);

              while (true) {
                final acc = await _confirmar(context, fecha, h12);
                if (!context.mounted) return;

                if (acc == _Accion.cancelar) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Agendamiento cancelado.")));
                  return;
                }

                if (acc == _Accion.reprogramar) {
                  final r2 = await _abrirModal(context, fechaInicial: fecha, horaInicial24: h24);
                  if (r2 == null || r2['ok'] != true) continue;
                  final nf = r2['fecha']; final nh24 = r2['hora'];
                  if (_menos24h(nf, nh24)) { await _alerta(context, "No permitido", "No puedes cambiar la cita con menos de 24 horas de anticipación."); continue; }
                  fecha = nf; h24 = nh24; h12 = _h12(h24); continue;
                }

                if (acc == _Accion.confirmar) {
                  if (_menos24h(fecha, h24)) { await _alerta(context, "No permitido", "No puedes agendar una cita con menos de 24 horas de anticipación."); continue; }
                  await _ok(context, "¡Cita agendada!", "Tu cita quedó para el ${_f(fecha)} a las $h12.");
                  return;
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: boton, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), textStyle: const TextStyle(fontSize: 18)),
            child: const Text('Agendar cita'),
          ),
        ]),
      ),
    );
  }

  Future<Map<String, dynamic>?> _abrirModal(BuildContext context, {DateTime? fechaInicial, String? horaInicial24}) {
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: encabezado,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => ModalAgendarCita(
        servicioId: 0, duracionMin: duracion,
        fondo: fondo, encabezado: encabezado, campos: campos, boton: boton, texto: texto,
        initialDate: fechaInicial, initialTime24: horaInicial24,
      ),
    );
  }

  Future<_Accion?> _confirmar(BuildContext context, DateTime fecha, String h12) {
    return showDialog<_Accion>(
      context: context, barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: encabezado, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          Container(decoration: BoxDecoration(color: boton.withOpacity(0.15), shape: BoxShape.circle), padding: const EdgeInsets.all(8), child: Icon(Icons.event_available, color: boton)),
          const SizedBox(width: 12),
          Expanded(child: Text('Confirmar agendamiento', style: TextStyle(color: texto, fontWeight: FontWeight.bold))),
        ]),
        content: RichText(text: TextSpan(style: TextStyle(color: texto, fontSize: 16), children: [
          const TextSpan(text: '¿Deseas agendar la cita para\n'),
          TextSpan(text: _f(fecha), style: const TextStyle(fontWeight: FontWeight.w700)),
          const TextSpan(text: ' a las '),
          TextSpan(text: h12, style: const TextStyle(fontWeight: FontWeight.w700)),
          const TextSpan(text: '?'),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, _Accion.reprogramar), style: TextButton.styleFrom(foregroundColor: Colors.amberAccent), child: const Text('Cambiar fecha/hora')),
          TextButton(onPressed: () => Navigator.pop(ctx, _Accion.cancelar), style: TextButton.styleFrom(foregroundColor: Colors.redAccent), child: const Text('Cancelar')),
          ElevatedButton.icon(onPressed: () => Navigator.pop(ctx, _Accion.confirmar),
            style: ElevatedButton.styleFrom(backgroundColor: boton, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            icon: const Icon(Icons.check_circle_outline), label: const Text('Confirmar')),
        ],
      ),
    );
  }

  Future<void> _ok(BuildContext c, String t, String m) {
    return showDialog<void>(
      context: c, barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: encabezado, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(decoration: BoxDecoration(color: boton.withOpacity(0.15), shape: BoxShape.circle), padding: const EdgeInsets.all(14), child: Icon(Icons.check_rounded, size: 40, color: boton)),
            const SizedBox(height: 14),
            Text(t, textAlign: TextAlign.center, style: TextStyle(color: texto, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(m, textAlign: TextAlign.center, style: TextStyle(color: texto.withOpacity(0.9), fontSize: 16)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: () => Navigator.pop(ctx), style: ElevatedButton.styleFrom(backgroundColor: boton, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('Listo')),
          ]),
        ),
      ),
    );
  }

  Future<void> _alerta(BuildContext c, String t, String m) {
    return showDialog<void>(
      context: c,
      builder: (ctx) => AlertDialog(
        backgroundColor: encabezado, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(t, style: TextStyle(color: texto, fontWeight: FontWeight.bold)),
        content: Text(m, style: TextStyle(color: texto)),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Entendido'))],
      ),
    );
  }

  bool _menos24h(DateTime f, String h24) {
    final p = h24.split(':'), h = int.parse(p[0]), m = int.parse(p[1]);
    final fh = DateTime(f.year, f.month, f.day, h, m);
    return fh.isBefore(DateTime.now().add(const Duration(hours: 24)));
  }

  String _f(DateTime d) => "${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
  String _h12(String h24) { final p = h24.split(':'); int h = int.parse(p[0]); final m = p.length > 1 ? p[1] : '00'; final s = h >= 12 ? 'PM' : 'AM'; h = h % 12; if (h == 0) h = 12; return "$h:$m $s"; }

  Widget _info(String a, String b) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Expanded(child: Text(a, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: texto))),
        Expanded(child: Text(b, textAlign: TextAlign.end, style: TextStyle(fontSize: 18, color: texto))),
      ]),
    );
  }
}

enum _Accion { confirmar, reprogramar, cancelar }
