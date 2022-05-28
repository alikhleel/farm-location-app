// @dart=2.9

import 'dart:async';

import '../models/user.dart' as UserModel;
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String getUID() {
    String uid = _auth.currentUser.uid;
    return uid;
  }

  UserModel.User _userFromFirebaseUser(User user) {
    return user != null ? UserModel.User(uid: user.uid) : null;
  }

  Stream<UserModel.User> get user {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
  }

  void logout() async {
    await _auth.signOut();
  }

  Future<bool> signInWithEmailAndPassword(
      {String email, String password}) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return (result != null) ? true : false;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }
}
