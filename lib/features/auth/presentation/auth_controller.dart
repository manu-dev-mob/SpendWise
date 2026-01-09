import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthController {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<void> signInWithGoogle() async {
    final googleProvider = GoogleAuthProvider();
    final userCredential = await _auth.signInWithPopup(googleProvider);
    final user = userCredential.user;
    if (user != null || user?.email == null) {
      await _auth.signOut();
      throw Exception('Login Failed');
    }
    final snapshot = await _firestore
        .collection('allowed_users')
        .where('email', isEqualTo: user?.email)
        .get();
    if (snapshot.docs.isEmpty) {
      await _auth.signOut();
      throw Exception('Access denied: not authorized');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
