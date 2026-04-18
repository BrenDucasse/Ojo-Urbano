import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';

import '../widgets/custom_loader.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final TextEditingController nameController = TextEditingController();

  File? _imageFile;
  final picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    nameController.text = user?.displayName ?? '';
  }

  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String?> uploadImage() async {
    try {
      if (_imageFile == null) return null;

      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_pictures')
          .child('${user!.uid}.jpg');

      await ref.putFile(_imageFile!);

      return await ref.getDownloadURL();
    } catch (e) {
      print("❌ Error subiendo imagen: $e");
      return null;
    }
  }

  Future<void> updateProfile() async {
    try {
      setState(() => _isLoading = true);

      String? imageUrl = await uploadImage();

      print("URL subida: $imageUrl"); // 👈 DEBUG

      await user?.updateDisplayName(nameController.text);

      // 🔥 ACTUALIZAR FOTO EN AUTH
      if (imageUrl != null) {
        await user?.updatePhotoURL(imageUrl);
      }

      // 🔥 GUARDAR SIEMPRE EN FIRESTORE
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .set({
        'nombre': nameController.text,
        'foto': imageUrl ?? user?.photoURL ?? '',
      }, SetOptions(merge: true));

      await user?.reload(); // 🔥 importante

      Navigator.pop(context);

    } catch (e) {
      print("Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Perfil")),
      body: Stack(
        children: [
          // 🌊 FONDO
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

          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  SizedBox(height: 40),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: Column(
                          children: [

                            /// 🔥 FOTO CON STREAM (CLAVE)
                            StreamBuilder<DocumentSnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(user!.uid)
                                  .snapshots(),
                              builder: (context, snapshot) {

                                String foto = '';

                                if (snapshot.hasData && snapshot.data!.exists) {
                                  final data = snapshot.data!.data() as Map<String, dynamic>;
                                  foto = data['foto'] ?? '';
                                }

                                return CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.white24,
                                  backgroundImage: _imageFile != null
                                      ? FileImage(_imageFile!)
                                      : (foto.isNotEmpty
                                          ? NetworkImage(foto)
                                          : null) as ImageProvider?,
                                  child: (_imageFile == null && foto.isEmpty)
                                      ? Icon(Icons.person, size: 40, color: Colors.white)
                                      : null,
                                );
                              },
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

                            SizedBox(height: 10),

                            Text(
                              user?.email ?? "",
                              style: TextStyle(color: Colors.white70),
                            ),

                            SizedBox(height: 20),

                            TextField(
                              controller: nameController,
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: "Nombre",
                                labelStyle: TextStyle(color: Colors.white70),
                                prefixIcon: Icon(Icons.person, color: Colors.white70),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.05),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),

                            SizedBox(height: 25),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF00B4D8),
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: updateProfile,
                                child: Text(
                                  "Guardar cambios",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
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
          ),

          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: CustomLoader(text: "Guardando cambios..."),
                ),
              ),
            ),
        ],
      ),
    );
  }
}