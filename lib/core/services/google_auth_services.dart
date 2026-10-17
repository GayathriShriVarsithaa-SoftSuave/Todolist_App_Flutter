
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  Future<UserCredential?> signInWithGoogle() async {
    try {
      // 1. Open the Google account selection screen.
      final GoogleSignInAccount googleUser =
          await _googleSignIn.authenticate();

      // 2. Get the Google ID token.
      final GoogleSignInAuthentication googleAuth =
          googleUser.authentication;

      // 3. Convert it into a Firebase credential.
      final OAuthCredential credential =
          GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // 4. Sign in to Firebase with that credential.
      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      return userCredential;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
  }
}
