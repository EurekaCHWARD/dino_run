import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  // Google sign in
  Future<User?> signInWithGoogle() async {
    try {
      // Begin interactive sign-in process
      final GoogleSignInAccount? gUser = await GoogleSignIn(
        clientId: '988810755372-n3dleol1d7r8lf6u612f7b328mepm7hc.apps.googleusercontent.com',
        serverClientId:'988810755372-qigqgof1d2cfo6agc6894bg224tt6nd5.apps.googleusercontent.com',
        scopes: ['email'],
      ).signIn();

      // Handle cancellation or null user
      if (gUser == null) {
        print("Google Sign-In canceled");
        return null;
      }

      // Obtain auth details from request
      final GoogleSignInAuthentication gAuth = await gUser.authentication;

      // Create new credentials for user
      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      // Sign in
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      print("Error signing in with Google: $e");
      return null;
    }
  }
}
