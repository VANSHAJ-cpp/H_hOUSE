import 'package:firebase_auth/firebase_auth.dart';

class FireBaseUser {
  final String uid;
  final String? email;

  FireBaseUser({
    required this.uid,
    this.email,
  });

  Future<void> sendEmailVerification() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null && !user.emailVerified) {
      try {
        await user.sendEmailVerification();
        print("Verification email sent to ${user.email}");
      } catch (e) {
        print("Error sending verification email: $e");
      }
    } else {
      print("User is already verified or user is null");
    }
  }
}
