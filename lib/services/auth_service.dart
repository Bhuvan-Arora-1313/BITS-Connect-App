import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart'; // required for showing dialog

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get userChanges => _auth.authStateChanges();

  Future<User?> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);
      final User? user = result.user;

      // ✅ Enforce BITS Pilani email domain
      if (user != null &&
          user.email != null &&
          user.email!.endsWith('@pilani.bits-pilani.ac.in')) {
        return user;
      } else {
        await signOut(); // kick user out
        // ❌ Show error dialog
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Access Denied'),
            content: const Text('Only BITS Pilani email addresses are allowed.'),
          ),
        );
        return null;
      }
    } catch (e) {
      print("Google sign-in failed: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await _auth.signOut();
  }
}