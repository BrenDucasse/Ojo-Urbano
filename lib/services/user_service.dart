import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {

  final _db = FirebaseFirestore.instance;

  Future<void> saveUserData(User user) async {
    await _db.collection('users').doc(user.uid).set({
      'email': user.email,
      'nombre': user.displayName ?? '',
      'foto': user.photoURL ?? '',
    }, SetOptions(merge: true));
  }

  Future<DocumentSnapshot> getUserData(String uid) {
    return _db.collection('users').doc(uid).get();
  }

  Future<void> updateUserData(String uid, Map<String, dynamic> data) {
    return _db.collection('users').doc(uid).set(
      data,
      SetOptions(merge: true),
    );
  }
}