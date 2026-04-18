import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'create_report_screen.dart';
import 'map_screen.dart';
import '../services/auth_service.dart';
import '../widgets/reportes_list.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/logo.png',
              height: 28,
            ),
            SizedBox(width: 8),
            Text('Ojo Urbano'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.map),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => MapScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await AuthService().signOut();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),

      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user?.uid)
                  .snapshots(),
              builder: (context, snapshot) {

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Text("Usuario nuevo");
                }

                final data = snapshot.data!.data() as Map<String, dynamic>;
                final nombre = data['nombre'] ?? 'Sin nombre';
                final foto = data['foto'] ?? '';

                return Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: foto.isNotEmpty
                          ? NetworkImage(foto)
                          : null,
                      child: foto.isEmpty
                          ? Icon(Icons.person)
                          : null,
                    ),
                    SizedBox(width: 10),
                    Text(nombre),
                  ],
                );
              },
            ),
          ),

          Expanded(
            child: ReportesList(),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CreateReportScreen(),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}