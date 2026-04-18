import 'dart:io';
import 'dart:ui';
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

  File? _imageFile;
  final picker = ImagePicker();

  bool _isLoading = false;

  String tipo = 'Problema';

  List<String> categoriasProblema = [
    'Baches','Corte de calle','Falta de alumbrado',
    'Desagüe rebalsando','Roturas por viento','Otros'
  ];

  List<String> categoriasPositivas = [
    'Arreglo de calles','Evento social','Nuevo alumbrado',
    'Espacio verde','Embellecimiento','Otros'
  ];

  String categoriaSeleccionada = 'Baches';

  bool esUrgente = false;

  Future<void> pickImage(ImageSource source) async {
    final picked = await picker.pickImage(source: source);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<void> crearReporte() async {
    setState(() => _isLoading = true);

    try {
      final position = await _getLocation();
      final docRef = FirebaseFirestore.instance.collection('reportes').doc();
      String? imageUrl = await uploadImage(docRef.id);

      await docRef.set({
        'descripcion': descripcionController.text,
        'categoria': categoriaSeleccionada,
        'tipo': tipo,
        'fecha': Timestamp.now(),
        'userId': user?.uid,
        'userEmail': user?.email,
        'imagen': imageUrl ?? '',
        'lat': position.latitude,
        'lng': position.longitude,
      });

      Navigator.pop(context);

    } catch (e) {
      print("Error: $e");
    } finally {
      setState(() => _isLoading = false);
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

  Future<Position> _getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception('GPS desactivado');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Permiso denegado permanentemente');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Widget inputContainer({required Widget child, required FocusNode focus}) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 250),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: focus.hasFocus
            ? [
                BoxShadow(
                  color: Colors.white.withOpacity(0.25),
                  blurRadius: 12,
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
      appBar: AppBar(title: Text("Nuevo Reporte")),

      body: Stack(
        children: [

          // 🌊 Fondo
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0F4C5C), Color(0xFF00B4D8)],
                ),
              ),
            ),
          ),

          // 📱 Contenido
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => FocusScope.of(context).unfocus(),
            child: SafeArea(
              child: AnimatedPadding(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeOut,
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      // 🧊 LOGO
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(color: Colors.black26, blurRadius: 10),
                          ],
                        ),
                        child: Image.asset('assets/logo.png', height: 70),
                      ),

                      SizedBox(height: 15),

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

                                // 📸 Imagen
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

                                // ✏️ Descripción
                                inputContainer(
                                  focus: descripcionFocus,
                                  child: TextField(
                                    focusNode: descripcionFocus,
                                    controller: descripcionController,
                                    maxLines: 3,
                                    style: TextStyle(color: Colors.white),
                                    decoration: _inputDecoration("Descripción"),
                                  ),
                                ),

                                SizedBox(height: 20),

                                // 🔄 Tipo
                                inputContainer(
                                  focus: tipoFocus,
                                  child: DropdownButtonFormField<String>(
                                    focusNode: tipoFocus,
                                    value: tipo,
                                    dropdownColor: Color(0xFF0F4C5C),
                                    style: TextStyle(color: Colors.white),
                                    iconEnabledColor: Colors.white,
                                    items: ['Problema', 'Positivo']
                                        .map((e) => DropdownMenuItem(
                                              value: e,
                                              child: Text(e),
                                            ))
                                        .toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        tipo = value!;
                                        categoriaSeleccionada =
                                            tipo == 'Problema'
                                                ? categoriasProblema.first
                                                : categoriasPositivas.first;
                                      });
                                    },
                                    decoration: _inputDecoration("Tipo"),
                                  ),
                                ),

                                SizedBox(height: 20),

                                // 📂 Categoría
                                inputContainer(
                                  focus: categoriaFocus,
                                  child: DropdownButtonFormField<String>(
                                    focusNode: categoriaFocus,
                                    value: categoriaSeleccionada,
                                    dropdownColor: Color(0xFF0F4C5C),
                                    style: TextStyle(color: Colors.white),
                                    iconEnabledColor: Colors.white,
                                    items: (tipo == 'Problema'
                                            ? categoriasProblema
                                            : categoriasPositivas)
                                        .map((e) => DropdownMenuItem(
                                              value: e,
                                              child: Text(e),
                                            ))
                                        .toList(),
                                    onChanged: (value) {
                                      setState(() => categoriaSeleccionada = value!);
                                    },
                                    decoration: _inputDecoration("Categoría"),
                                  ),
                                ),

                                SizedBox(height: 20),

                                SwitchListTile(
                                  value: esUrgente,
                                  onChanged: (v) => setState(() => esUrgente = v),
                                  title: Text("Marcar como urgente 🚨",
                                      style: TextStyle(color: Colors.white)),
                                ),

                                SizedBox(height: 20),

                                ElevatedButton(
                                  onPressed: crearReporte,
                                  child: Text("Publicar reporte"),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 🔥 LOADING
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
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
        borderSide: BorderSide(color: Colors.white),
      ),
    );
  }
}