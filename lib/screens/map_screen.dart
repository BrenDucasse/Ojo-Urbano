import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {

  Set<Marker> _markers = {};

  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    cargarReportes();
  }
  //carga los reportes en el mapa
  Future<void> cargarReportes() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('reportes')
        .get();

    final markers = snapshot.docs.map((doc) {
      final data = doc.data();

      final lat = (data['lat'] as num).toDouble();
      final lng = (data['lng'] as num).toDouble();

      return Marker(
        markerId: MarkerId(doc.id),
        position: LatLng(lat, lng),

        icon: data['tipo'] == 'Problema'
            ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed)
            : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),

        infoWindow: InfoWindow(
          title: data['categoria'],
          snippet: data['descripcion'],
        ),
      );
    }).toSet();

    // ✅ AHORA SÍ
    print("TOTAL MARKERS: ${markers.length}");

    setState(() {
      _markers = markers;
    });

    // centrar mapa
    if (_mapController != null && _markers.isNotEmpty) {
      _centrarMapa();
    }
  }
  //centra el mapa
  void _centrarMapa() {
    if (_markers.isEmpty || _mapController == null) return;

    double minLat = _markers.first.position.latitude;
    double maxLat = minLat;
    double minLng = _markers.first.position.longitude;
    double maxLng = minLng;

    for (var m in _markers) {
      minLat = m.position.latitude < minLat ? m.position.latitude : minLat;
      maxLat = m.position.latitude > maxLat ? m.position.latitude : maxLat;
      minLng = m.position.longitude < minLng ? m.position.longitude : minLng;
      maxLng = m.position.longitude > maxLng ? m.position.longitude : maxLng;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 50),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mapa de Reportes"),
      ),
      body: GoogleMap(

        key: ValueKey(_markers.length), // 🔥 fuerza refresh

        initialCameraPosition: CameraPosition(
          target: LatLng(-46.43, -67.52),
          zoom: 13,
        ),

        markers: _markers,

        onMapCreated: (controller) {
          _mapController = controller;
        },
      ),
    );
  }
}