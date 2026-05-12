import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _loading = false;
  String? _error;

  Future<void> _signInWithGoogle() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final googleProvider = GoogleAuthProvider();

      final userCredential = await FirebaseAuth.instance.signInWithPopup(
        googleProvider,
      );

      final user = userCredential.user;
      if (user == null) throw Exception('User is null');

      // Check allowed users
      final snapshot = await FirebaseFirestore.instance
          .collection('allowed_users')
          .where('email', isEqualTo: user.email)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        await FirebaseAuth.instance.signOut();
        setState(() {
          _error = 'Access denied: not authorized';
          _loading = false;
        });
        return;
      }
      setState(() => _loading = false);
      if(mounted){
        context.go('/dashboard');
      }
    } catch (e) {
      setState(() {
        _error = 'Login failed: ${e.toString()}';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.login),
                    label: const Text('Sign in with Google'),
                    onPressed: _signInWithGoogle,
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                  ],
                ],
              ),
      ),
    );
  }
}
