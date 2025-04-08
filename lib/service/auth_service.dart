import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }
}