import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser =
          await GoogleSignIn().signIn();

      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    
      final userCredential =
          await _auth.signInWithCredential(credential);
          await UserService().saveUserData(userCredential.user!);

  
      return userCredential.user;
    } catch (e) {
      print("❌ Error Google: $e");
      return null;
    }
  }
  User? getCurrentUser() {
    return _auth.currentUser;
  }
  Future<void> signOut() async {
    await _auth.signOut();
    await GoogleSignIn().signOut(); // importante para Google
  }
  Future<void> saveUserData(User user) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set({
      'email': user.email,
      'nombre': user.displayName ?? '',
      'foto': user.photoURL,
    }, SetOptions(merge: true));
  }
  
}
