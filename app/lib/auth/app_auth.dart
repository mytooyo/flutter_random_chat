import 'package:app/ui/route/route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AppAuth {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<FirebaseUser> authUser() async {
    return await _auth.currentUser();
  }

  Future<String> token() async {
    var _idToken = await (await authUser()).getIdToken(refresh: true);
    return _idToken.token;
  }

  Future<FirebaseUser> signinInAnonymously() async {

    try {
      FirebaseUser user  = (await _auth.signInAnonymously()).user;
      return user;
    } catch (e) {
      print(e);
      return null;
    }

  }

  void checkSignin(BuildContext context) async {
    var user = await authUser();
    if (user == null) {
      Navigator.of(context).pushNamed(RouteName.start);
    }
  }

  void signout() {
    _auth.signOut();
  }
}