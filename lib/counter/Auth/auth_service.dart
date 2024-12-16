import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  // Future<void> signInUser(String email, String password) async {
  //   await FirebaseAuth.instance
  //       .signInWithEmailAndPassword(email: email, password: password);
  //   await FirebaseAuth.instance.currentUser!.reload();
  // }

  Future<void> signInUser(String email, String password) async {
    try {
      await firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      await firebaseAuth.currentUser!.reload();
    } on FirebaseAuthException catch (e) {
      // You can log or throw specific error messages
      switch (e.code) {
        case 'user-not-found':
          throw Exception('No user found for that email.');
        case 'wrong-password':
          throw Exception('Wrong password provided for that user.');
        case 'invalid-email':
          throw Exception('The email address is badly formatted.');
        default:
          throw Exception('An unknown error occurred: ${e.message}');
      }
    } catch (e) {
      print('Error signing in: $e');
    }
  }

  Future<void> signOutUser() async {
    final User? firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      await FirebaseAuth.instance.signOut();
      await FirebaseAuth.instance.currentUser!.reload();
    }
  }
}
