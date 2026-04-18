import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('reportes')
          .orderBy('fecha', descending: true)
          .snapshots(),

      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        
        final reportes = snapshot.data!.docs;

        return ListView.builder(
          itemCount: reportes.length,
          itemBuilder: (context, index) {
            final reporte = reportes[index];

            // 🔥 👉 ACA VA
            final imagen = reporte['imagen'] ?? '';

            return Card(
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // 🖼 IMAGEN DEL REPORTE
                  if (imagen.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                      child: Image.network(
                        imagen,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),

                  // 📄 TEXTO
                  ListTile(
                    title: Text(reporte['descripcion'] ?? ''),
                    subtitle: Text(reporte['categoria'] ?? ''),
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }
}