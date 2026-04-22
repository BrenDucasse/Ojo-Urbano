import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';

class ReportDetailScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  ReportDetailScreen(this.data);

  // 📍 Convertir lat/lng a dirección
  Future<String> getAddress(double lat, double lng) async {
    final placemarks = await placemarkFromCoordinates(lat, lng);
    final place = placemarks.first;

    return "${place.street}, ${place.locality}";
  }

  // 📅 Formatear fecha
  String formatDate(dynamic timestamp) {
    try {
      final date = timestamp.toDate();
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      return "Fecha desconocida";
    }
  }

  @override
  Widget build(BuildContext context) {
    final lat = (data['lat'] as num?)?.toDouble();
    final lng = (data['lng'] as num?)?.toDouble();

    return Scaffold(
      appBar: AppBar(
        title: Text("Detalle del reporte"),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 🖼️ IMAGEN HEADER
            if (data['imagen'] != null && data['imagen'] != '')
              ClipRRect(
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
                child: Image.network(
                  data['imagen'],
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),

            SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // 🏷️ CATEGORÍA + TIPO
                  Row(
                    children: [
                      Chip(
                        label: Text(data['categoria'] ?? 'Sin categoría'),
                      ),
                      SizedBox(width: 10),
                      Chip(
                        backgroundColor: data['tipo'] == 'Problema'
                            ? Colors.red.shade100
                            : Colors.green.shade100,
                        label: Text(
                          data['tipo'] ?? '',
                          style: TextStyle(
                            color: data['tipo'] == 'Problema'
                                ? Colors.red
                                : Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16),

                  // 📝 DESCRIPCIÓN
                  Text(
                    "Descripción",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 6),
                  Text(
                    data['descripcion'] ?? '',
                    style: TextStyle(fontSize: 16),
                  ),

                  SizedBox(height: 20),

                  // 👤 USUARIO
                  Row(
                    children: [
                      Icon(Icons.person, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(data['userEmail'] ?? 'Usuario desconocido'),
                      ),
                    ],
                  ),

                  SizedBox(height: 10),

                  // 📅 FECHA
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 20),
                      SizedBox(width: 8),
                      Text(formatDate(data['fecha'])),
                    ],
                  ),

                  SizedBox(height: 20),

                  // 📍 DIRECCIÓN (FutureBuilder 🔥)
                  if (lat != null && lng != null)
                    FutureBuilder<String>(
                      future: getAddress(lat, lng),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Row(
                            children: [
                              Icon(Icons.location_on, size: 20),
                              SizedBox(width: 8),
                              Text("Obteniendo dirección..."),
                            ],
                          );
                        }

                        if (snapshot.hasError) {
                          return Row(
                            children: [
                              Icon(Icons.error, size: 20, color: Colors.red),
                              SizedBox(width: 8),
                              Text("No se pudo obtener la dirección"),
                            ],
                          );
                        }

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.location_on, size: 20),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(snapshot.data ?? ''),
                            ),
                          ],
                        );
                      },
                    ),

                  SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}