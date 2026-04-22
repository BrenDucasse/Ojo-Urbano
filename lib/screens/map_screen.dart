import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

import 'report_detail_screen.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {

  Set<Marker> _markers = {};

  GoogleMapController? _mapController;
  
  LatLng? _currentPosition;

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
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ReportDetailScreen(data),
            ),
          );
        },
      );
    }).toSet();

    // ✅ AHORA SÍ
    print("TOTAL MARKERS: ${markers.length}");

    setState(() {
      _markers = markers;
    });
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

  //obtener la ubicación 
  Future<void> _getUserLocation() async {
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    _currentPosition = LatLng(position.latitude, position.longitude);

    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(_currentPosition!, 15),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mapa de Reportes"),
      ),
     body: Stack(
        children: [

          GoogleMap(
            key: ValueKey(_markers.length),
            initialCameraPosition: CameraPosition(
              target: LatLng(-46.43, -67.52),
              zoom: 13,
            ),
            markers: _markers,
            onMapCreated: (controller) {
              _mapController = controller;
              _getUserLocation(); // 🔥 acá sí funciona
            },
          ),

          // 🔥 REPORTES FLOTANTES
          Positioned(
            bottom: 20,
            left: 10,
            right: 10,
            child: FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection('reportes')
                  .orderBy('fecha', descending: true)
                  .limit(2)
                  .get(),
              builder: (context, snapshot) {

                if (!snapshot.hasData) return SizedBox();

                final docs = snapshot.data!.docs;

                return Column(
                  children: docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;

                    return GestureDetector(
                      onTap: () {
                        final lat = (data['lat'] as num).toDouble();
                        final lng = (data['lng'] as num).toDouble();

                        _mapController?.animateCamera(
                          CameraUpdate.newLatLngZoom(
                            LatLng(lat, lng),
                            17,
                          ),
                        );
                      },
                      child: Card(
                        elevation: 5,
                        child: ListTile(
                          title: Text(data['categoria'] ?? ''),
                          subtitle: Text(data['descripcion'] ?? ''),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}