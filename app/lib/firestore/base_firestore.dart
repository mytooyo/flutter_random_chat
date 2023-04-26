import 'package:cloud_firestore/cloud_firestore.dart';

abstract class BaseFirestore {
  var instance = FirebaseFirestore.instance;

  BaseFirestore() {
    instance.enablePersistence();
  }
}
