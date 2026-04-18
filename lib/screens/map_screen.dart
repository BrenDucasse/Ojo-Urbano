import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {

  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    cargarReportes();
  }

  Future<void> cargarReportes() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('reportes')
        .get();

    final markers = snapshot.docs.map((doc) {
      final data = doc.data();

      final lat = data['lat'];
      final lng = data['lng'];

      if (lat == null || lng == null) return null;

      return Marker(
        markerId: MarkerId(doc.id),
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(
          title: data['categoria'],
          snippet: data['descripcion'],
        ),
      );
    }).whereType<Marker>().toSet();

    setState(() {
      _markers = markers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mapa de Reportes"),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(-46.43, -67.52), // tu zona aprox
          zoom: 13,
        ),
        markers: _markers,
      ),
    );
  }
}