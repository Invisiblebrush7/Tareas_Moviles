import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UserAuthRepository {
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ["email"]);
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // true -> go home page
  // false -> go login page
  bool isAlreadyAuthenticated() {
    print(_auth.currentUser);
    return _auth.currentUser != null;
  }

  Future<void> signOutGoogleUser() async {
    await _googleSignIn.signOut();
  }

  Future<void> signOutFirebaseUser() async {
    await _auth.signOut();
  }

  Future<void> signInWithGoogle() async {
    //Google sign in
    final googleUser = await _googleSignIn.signIn();
    final googleAuth = await googleUser!.authentication;

    print(">> User email:${googleUser.email}");
    print(">> User name:${googleUser.displayName}");
    print(">> User photo:${googleUser.photoUrl}");

    // credenciales de usuario autenticado con Google
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    // firebase sign in con credenciales de Google
    final authResult = await _auth.signInWithCredential(credential);

    // Extraer token**
    User user = authResult.user!;
    final firebaseToken = await user.getIdToken();
    print("user fcm token:$firebaseToken");

    // crear tabla users en firebase y agregar valor de fotolistId
    return await createUserCollectionFirebase(_auth.currentUser!.uid);
  }

  // Metodo para guardar nuevo usuario en la colección "users"
  Future createUserCollectionFirebase(String uid) async {
    var userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (!userDoc.exists) {
      User? user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance.collection('users').doc(uid).set(
        {
          "name": user!.displayName,
          "email": user.email,
          "address": "No address",
          "favsList": [],
          "profilePicture": user.photoURL,
        },
      );
    } else {
      return;
    }
  }

  Future createUserCollectionFromCopy(String uid, List<String> newList) async {
    var userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (userDoc.exists) {
      await FirebaseFirestore.instance.collection('users').doc(uid).update(
        {
          "favsList": newList,
        },
      );
    } else {
      return;
    }
  }
}
