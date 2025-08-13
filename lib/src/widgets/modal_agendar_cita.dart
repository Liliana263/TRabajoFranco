import 'package:flutter/material.dart';

/// Modal para agendar cita SIN backend (estático).
/// - Genera horarios locales cada 30 min entre 08:00 y 17:00.
/// - Si la fecha es hoy, oculta horarios ya pasados.
/// - Soporta reprogramación con initialDate e initialTime24 (HH:mm).
/// - Muestra los horarios en 12h (AM/PM), pero devuelve 'hora' en 24h (HH:mm).
class ModalAgendarCita extends StatefulWidget {
  final int servicioId;      // para futura API
  final int duracionMin;     // informativo
  final Color fondo;
  final Color encabezado;
  final Color campos;
  final Color boton;
  final Color texto;

  /// Opcionales para reprogramar:
  final DateTime? initialDate;     // Fecha preseleccionada
  final String? initialTime24;     // "HH:mm" preseleccionada

  const ModalAgendarCita({
    super.key,
    required this.servicioId,
    required this.duracionMin,
    required this.fondo,
    required this.encabezado,
    required this.campos,
    required this.boton,
    required this.texto,
    this.initialDate,
    this.initialTime24,
  });

  @override
  State<ModalAgendarCita> createState() => _ModalAgendarCitaState();
}

class _ModalAgendarCitaState extends State<ModalAgendarCita> {
  late DateTime _selectedDate;
  List<String> _slots24 = [];   // valores reales "HH:mm"
  String? _selectedSlot24;      // valor seleccionado "HH:mm"
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Fecha inicial: la que venga o hoy
    final now = DateTime.now();
    _selectedDate = (widget.initialDate != null && !widget.initialDate!.isBefore(DateTime(now.year, now.month, now.day)))
        ? widget.initialDate!
        : now;
    _loadDisponibilidadLocal(preselect: widget.initialTime24);
  }

  // ---- DISPONIBILIDAD ESTÁTICA ----
  // Reglas: 08:00 - 17:00, cada 30 min. Si es hoy, excluye horas pasadas.
  void _loadDisponibilidadLocal({String? preselect}) {
    setState(() {
      _loading = true;
      _error = null;
      // Solo limpiar selección si no estamos intentando preseleccionar
      if (preselect == null) _selectedSlot24 = null;
    });

    try {
      final now = DateTime.now();
      final isToday = _isSameDate(_selectedDate, now);

      final start = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 8, 0);
      final end   = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 17, 0);

      final slots = <String>[];
      DateTime cursor = start;
      while (cursor.isBefore(end) || _isSameMinute(cursor, end)) {
        if (!isToday || cursor.isAfter(now)) {
          slots.add(_fmtHora24(cursor)); // almacenamos "HH:mm"
        }
        cursor = cursor.add(const Duration(minutes: 30));
      }

      // Si quieres cerrar domingos, descomenta:
      // final isSunday = _selectedDate.weekday == DateTime.sunday;
      // if (isSunday) slots.clear();

      // Intentar preseleccionar si el valor existe
      if (preselect != null && slots.contains(preselect)) {
        _selectedSlot24 = preselect;
      }

      setState(() => _slots24 = slots);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ---- AGENDAR ESTÁTICO ----
  Future<void> _confirmar() async {
    if (_selectedSlot24 == null) {
      setState(() => _error = 'Selecciona un horario para continuar.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    // Simula latencia / éxito
    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;
    Navigator.pop(context, {
      'ok': true,
      'fecha': _selectedDate,
      'hora': _selectedSlot24, // Devolvemos "HH:mm"
    });

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final textoSuave = widget.texto.withOpacity(0.85);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16, right: 16, top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 44,
                height: 5,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            Text(
              'Agendar cita',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: widget.texto),
            ),
            const SizedBox(height: 6),
            Text(
              'Duración estimada: ${widget.duracionMin} min',
              style: TextStyle(fontSize: 13, color: textoSuave),
            ),

            const SizedBox(height: 12),
            // Calendario
            Container(
              decoration: BoxDecoration(
                color: widget.campos,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: CalendarDatePicker(
                initialDate: _selectedDate.isBefore(DateTime.now())
                    ? DateTime.now()
                    : _selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 120)),
                onDateChanged: (d) {
                  setState(() => _selectedDate = d);
                  _loadDisponibilidadLocal(); // recalcula slots
                },
              ),
            ),

            const SizedBox(height: 16),
            Text(
              'Horarios disponibles',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: widget.texto),
            ),
            const SizedBox(height: 8),

            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'No se pudo generar la disponibilidad.\n$_error',
                  style: const TextStyle(color: Colors.redAccent),
                ),
              )
            else if (_slots24.isEmpty)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'No hay horarios disponibles para este día.',
                  style: TextStyle(color: widget.texto),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _slots24.map((h24) {
                  final selected = _selectedSlot24 == h24;
                  final etiqueta = _fmtHora12(h24); // mostramos 12h
                  return ChoiceChip(
                    label: Text(
                      etiqueta,
                      style: TextStyle(
                        color: selected ? Colors.black : widget.texto,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    selected: selected,
                    selectedColor: widget.boton,
                    backgroundColor: widget.campos.withOpacity(0.65),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: selected ? widget.boton : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    onSelected: (_) => setState(() => _selectedSlot24 = h24),
                  );
                }).toList(),
              ),

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: (_selectedSlot24 != null && !_loading) ? _confirmar : null,
                icon: const Icon(Icons.event_available),
                label: const Text('Confirmar cita'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.boton,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---- Helpers ----
  bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isSameMinute(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day &&
      a.hour == b.hour && a.minute == b.minute;

  /// "HH:mm"
  String _fmtHora24(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  /// Muestra 12h (AM/PM) a partir de "HH:mm"
  String _fmtHora12(String hora24) {
    final partes = hora24.split(':');
    int h = int.parse(partes[0]);
    final m = partes.length > 1 ? partes[1] : '00';
    final sufijo = h >= 12 ? 'PM' : 'AM';
    h = h % 12;
    if (h == 0) h = 12;
    return "$h:$m $sufijo";
  }
}
