import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class MapaClinicaView extends StatefulWidget {
  final String nombreClinica;
  final String direccion;
  final LatLng clinicaLatLng;

  const MapaClinicaView({
    super.key,
    required this.nombreClinica,
    required this.direccion,
    required this.clinicaLatLng,
  });

  @override
  State<MapaClinicaView> createState() => _MapaClinicaViewState();
}

class _MapaClinicaViewState extends State<MapaClinicaView> {
  final Completer<GoogleMapController> _controller = Completer();

  // 👇 v6: el stream emite List<ConnectivityResult>
  StreamSubscription<List<ConnectivityResult>>? _connSub;

  Position? _miPos;
  String? _error;
  bool _sinConexion = false;

  bool _mapReady = false;
  bool _useLiteMode = false;
  Timer? _mapTimeout;

  @override
  void initState() {
    super.initState();
    _init();

    _mapTimeout = Timer(const Duration(seconds: 4), () {
      if (mounted && !_mapReady) setState(() => _useLiteMode = true);
    });

    _connSub = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      setState(() => _sinConexion = results.contains(ConnectivityResult.none));
    });
  }

  @override
  void dispose() {
    _connSub?.cancel();
    _mapTimeout?.cancel();
    super.dispose();
  }

  Future<void> _init() async {
    // 👇 v6: checkConnectivity también devuelve List<ConnectivityResult>
    final results = await Connectivity().checkConnectivity();
    _sinConexion = results.contains(ConnectivityResult.none);

    try {
      final ok = await _ensureGpsPermission();
      if (ok) _miPos = await Geolocator.getCurrentPosition();
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) setState(() {});
  }

  Future<bool> _ensureGpsPermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      _error = 'GPS desactivado. Actívalo para ver tu ubicación.';
      return false;
    }
    var p = await Geolocator.checkPermission();
    if (p == LocationPermission.denied) p = await Geolocator.requestPermission();
    if (p == LocationPermission.deniedForever) {
      _error = 'Permiso de ubicación denegado permanentemente. Ve a ajustes.';
      return false;
    }
    return p == LocationPermission.always || p == LocationPermission.whileInUse;
  }

  Future<void> _moverCamaraALocal() async {
    if (_miPos == null || !_controller.isCompleted) return;
    final c = await _controller.future;
    await c.animateCamera(CameraUpdate.newLatLngZoom(
      LatLng(_miPos!.latitude, _miPos!.longitude), 16,
    ));
  }

  Future<void> _moverCamaraClinica() async {
    if (!_controller.isCompleted) return;
    final c = await _controller.future;
    await c.animateCamera(
      CameraUpdate.newLatLngZoom(widget.clinicaLatLng, 16),
    );
  }

  Future<void> _abrirRutas() async {
    final dest =
        '${widget.clinicaLatLng.latitude},${widget.clinicaLatLng.longitude}';
    final orig =
        (_miPos != null) ? '${_miPos!.latitude},${_miPos!.longitude}' : null;

    final url = orig == null
        ? 'https://www.google.com/maps/dir/?api=1&destination=$dest&travelmode=driving'
        : 'https://www.google.com/maps/dir/?api=1&origin=$orig&destination=$dest&travelmode=driving';

    final ok = await launchUrl(Uri.parse(url),
        mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir Google Maps')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final marcadorClinica = Marker(
      markerId: const MarkerId('clinica'),
      position: widget.clinicaLatLng,
      infoWindow: InfoWindow(
          title: widget.nombreClinica, snippet: widget.direccion),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Ubicación de la clínica')),
      body: Column(
        children: [
          if (_sinConexion)
            Container(
              width: double.infinity,
              color: Colors.amber.shade700,
              padding: const EdgeInsets.all(8),
              child: const Text('Sin conexión: el mapa puede no cargar.',
                  style: TextStyle(color: Colors.white)),
            ),
          if (_useLiteMode)
            Container(
              width: double.infinity,
              color: Colors.deepPurple.shade100,
              padding: const EdgeInsets.all(8),
              child: const Text('Modo simple por compatibilidad (sin gestos).'),
            ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text('Aviso: $_error',
                  style: const TextStyle(color: Colors.red)),
            ),
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: widget.clinicaLatLng,
                    zoom: 16,
                  ),
                  mapType: MapType.normal,
                  liteModeEnabled: _useLiteMode,
                  myLocationEnabled: !_useLiteMode && _miPos != null,
                  myLocationButtonEnabled: !_useLiteMode,
                  zoomControlsEnabled: true,
                  compassEnabled: true,
                  mapToolbarEnabled: true,
                  markers: {marcadorClinica},
                  onMapCreated: (c) {
                    _controller.complete(c);
                    _mapReady = true;
                    _moverCamaraClinica();
                    setState(() {});
                  },
                ),
                if (!_mapReady)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black12,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 12),
                          const Text('Cargando mapa...'),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: _abrirRutas,
                            icon: const Icon(Icons.directions),
                            label: const Text('Abrir en Google Maps'),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.location_on_outlined),
            title: Text(widget.nombreClinica),
            subtitle: Text(widget.direccion),
            trailing: ElevatedButton.icon(
              onPressed: _abrirRutas,
              icon: const Icon(Icons.directions),
              label: const Text('Cómo llegar'),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
      floatingActionButton: (_miPos != null && !_useLiteMode)
          ? FloatingActionButton(
              onPressed: _moverCamaraALocal,
              child: const Icon(Icons.my_location),
            )
          : null,
    );
  }
}
