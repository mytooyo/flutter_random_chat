import 'package:app/ui/route/route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AppAuth {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? authUser() {
    return _auth.currentUser;
  }

  User get user => _auth.currentUser!;

  Future<String> token() async {
    var idToken = await _auth.currentUser!.getIdToken(true);
    return idToken;
  }

  Future<User?> signinInAnonymously() async {
    try {
      User? user = (await _auth.signInAnonymously()).user;
      return user;
    } catch (e) {
      return null;
    }
  }

  void checkSignin(BuildContext context) async {
    var user = authUser();
    if (user == null) {
      Navigator.of(context).pushNamed(RouteName.start);
    }
  }

  void signout() {
    _auth.signOut();
  }
}
