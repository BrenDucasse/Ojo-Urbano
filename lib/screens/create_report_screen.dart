import 'dart:io';
import 'dart:ui'; //  para blur
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart';


class CreateReportScreen extends StatefulWidget {
  @override
  _CreateReportScreenState createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {

  final FocusNode descripcionFocus = FocusNode();
  final FocusNode tipoFocus = FocusNode();
  final FocusNode categoriaFocus = FocusNode();
  
  final TextEditingController descripcionController = TextEditingController();

  final user = FirebaseAuth.instance.currentUser;

  // 📸 imagen
  File? _imageFile;
  final picker = ImagePicker();

  // 🔥 estado
  bool _isLoading = false;

  // 🧠 tipo y categorías dinámicas
  String tipo = 'Problema';

  List<String> categoriasProblema = [
    'Baches',
    'Corte de calle',
    'Falta de alumbrado',
    'Desagüe rebalsando',
    'Roturas por viento',
    'Otros'
  ];

  List<String> categoriasPositivas = [
    'Arreglo de calles',
    'Evento social',
    'Nuevo alumbrado',
    'Espacio verde',
    'Embellecimiento',
    'Otros'
  ];

  String categoriaSeleccionada = 'Baches';

  // 🚨 urgencia
  bool esUrgente = false;

  // 📸 seleccionar imagen
  Future<void> pickImage(ImageSource source) async {
    final picked = await picker.pickImage(source: source);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }
  // 🚀 crear reporte
  Future<void> crearReporte() async {

    final user = FirebaseAuth.instance.currentUser;

    try {
      // 1️⃣ OBTENER UBICACIÓN (ACÁ)
      final position = await _getLocation();

      print("📍 LAT: ${position.latitude}");
      print("📍 LNG: ${position.longitude}");

      // 2️⃣ crear doc vacío primero
      final docRef = FirebaseFirestore.instance.collection('reportes').doc();

      // 3️⃣ subir imagen
      String? imageUrl = await uploadImage(docRef.id);

      // 4️⃣ guardar TODO
      await docRef.set({
        'descripcion': descripcionController.text,
        'categoria': categoriaSeleccionada,
        'tipo': tipo,
        'fecha': Timestamp.now(),
        'userId': user?.uid,
        'userEmail': user?.email,
        'imagen': imageUrl ?? '',
        // UBICACIÓN
        'lat': position.latitude,
        'lng': position.longitude,
      });

      Navigator.pop(context);

    } catch (e) {
       print("Error: $e");
    }
  }
    
  Future<String?> uploadImage(String reportId) async {
    try {
      if (_imageFile == null) return null;

      final ref = FirebaseStorage.instance
          .ref()
          .child('reportes')
          .child('$reportId.jpg');

      await ref.putFile(_imageFile!);

      return await ref.getDownloadURL();

    } catch (e) {
      print("Error subiendo imagen: $e");
      return null;
    }
  }

  // fijar la long y lat al reporte
  Future<Position> _getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // GPS activado?
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('GPS desactivado');
    }

    // permisos
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Permiso denegado permanentemente');
    }

    // obtener ubicación
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
  //contenedor animado para inputs
  Widget inputContainer({required Widget child, required FocusNode focus}) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: focus.hasFocus
            ? [
                BoxShadow(
                  color: Colors.white.withOpacity(0.25),
                  blurRadius: 12,
                  spreadRadius: 1,
                )
              ]
            : [],
      ),
      child: child,
    );
  }

  @override
  void dispose() {
    descripcionFocus.dispose();
    tipoFocus.dispose();
    categoriaFocus.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Nuevo Reporte"),
      ),

      body: Stack(
        children: [

          // 🌊 FONDO GRADIENTE
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0F4C5C), Color(0xFF00B4D8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          // 📱 CONTENIDO
          GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // 🔥 FRANJA LOGO FULL WIDTH
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      color: Colors.white,
                      child: Center(
                        child: Image.asset('assets/logo.png', height: 50),
                      ),
                    ),

                    // 👇 ahora sí el padding para el resto
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // 🧊 CARD
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                padding: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),

                                child: Column(
                                  children: [

                                    // 📸 FOTO
                                    GestureDetector(
                                      onTap: () => pickImage(ImageSource.gallery),
                                      child: Container(
                                        height: 180,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(15),
                                          color: Colors.white12,
                                        ),
                                        child: _imageFile != null
                                            ? Image.file(_imageFile!, fit: BoxFit.cover)
                                            : Icon(Icons.camera_alt, color: Colors.white70),
                                      ),
                                    ),

                                    SizedBox(height: 10),

                                    // BOTONES FOTO
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.photo, color: Colors.white),
                                          onPressed: () => pickImage(ImageSource.gallery),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.camera_alt, color: Colors.white),
                                          onPressed: () => pickImage(ImageSource.camera),
                                        ),
                                      ],
                                    ),

                                    SizedBox(height: 20),

                                    // ✏️ DESCRIPCIÓN
                                    inputContainer(
                                      focus: descripcionFocus,
                                      child: TextField(
                                        focusNode: descripcionFocus,
                                        controller: descripcionController,
                                        maxLines: 3,
                                        style: TextStyle(color: Colors.white),
                                        decoration: InputDecoration(
                                          labelText: "Descripción",
                                          labelStyle: TextStyle(color: Colors.white70),
                                          filled: true,
                                          fillColor: Colors.white.withOpacity(0.08),
                                          contentPadding: EdgeInsets.all(15),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(15),
                                            borderSide: BorderSide.none,
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(15),
                                            borderSide: BorderSide(color: Colors.white, width: 1.5),
                                          ),
                                        ),
                                      ),
                                    ),

                                    SizedBox(height: 20),

                                    // 🔄 TIPO
                                    inputContainer(
                                      focus: tipoFocus,
                                      child: DropdownButtonFormField<String>(
                                        focusNode: tipoFocus,
                                        value: tipo,
                                        dropdownColor: Color(0xFF0F4C5C),
                                        iconEnabledColor: Colors.white,
                                        style: TextStyle(color: Colors.white),

                                        items: ['Problema', 'Positivo']
                                            .map((e) => DropdownMenuItem(
                                                  value: e,
                                                  child: Text(e, style: TextStyle(color: Colors.white)),
                                                ))
                                            .toList(),

                                        onChanged: (value) {
                                          setState(() {
                                            tipo = value!;
                                            categoriaSeleccionada = (tipo == 'Problema')
                                                ? categoriasProblema.first
                                                : categoriasPositivas.first;
                                          });
                                        },
                                        
                                        decoration: InputDecoration(
                                          labelText: "Tipo",
                                          labelStyle: TextStyle(color: Colors.white70),
                                          filled: true,
                                          fillColor: Colors.white.withOpacity(0.08),
                                          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 18),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(15),
                                            borderSide: BorderSide.none,
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(15),
                                            borderSide: BorderSide(color: Colors.white, width: 1.5),
                                          ),
                                        ),
                                      ),
                                    ),

                                    SizedBox(height: 20),

                                    // 📂 CATEGORÍA DINÁMICA
                                    inputContainer(
                                      focus: categoriaFocus,
                                      child: DropdownButtonFormField<String>(
                                        focusNode: categoriaFocus,
                                        value: categoriaSeleccionada,
                                        dropdownColor: Color(0xFF0F4C5C),
                                        iconEnabledColor: Colors.white,
                                        style: TextStyle(color: Colors.white),

                                        items: (tipo == 'Problema'
                                                ? categoriasProblema
                                                : categoriasPositivas)
                                            .map((e) => DropdownMenuItem(
                                                  value: e,
                                                  child: Text(e, style: TextStyle(color: Colors.white)),
                                                ))
                                            .toList(),

                                        onChanged: (value) {
                                          setState(() => categoriaSeleccionada = value!);
                                        },

                                        decoration: InputDecoration(
                                          labelText: "Categoría",
                                          labelStyle: TextStyle(color: Colors.white70),
                                          filled: true,
                                          fillColor: Colors.white.withOpacity(0.08),
                                          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 18),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(15),
                                            borderSide: BorderSide.none,
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(15),
                                            borderSide: BorderSide(color: Colors.white, width: 1.5),
                                          ),
                                        ),
                                      ),
                                    ),

                                    SizedBox(height: 20),

                                    // 🚨 URGENCIA
                                    SwitchListTile(
                                      value: esUrgente,
                                      onChanged: (value) {
                                        setState(() => esUrgente = value);
                                      },
                                      title: Text("Marcar como urgente 🚨",
                                          style: TextStyle(color: Colors.white)),
                                    ),

                                    SizedBox(height: 25),

                                    // 🚀 BOTÓN
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: crearReporte,
                                        child: Text("Publicar reporte"),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
            // 🔥 LOADING
            if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}