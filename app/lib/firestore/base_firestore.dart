
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class BaseFirestore {

  var instance = Firestore.instance;
  
  BaseFirestore() {
    instance.settings(persistenceEnabled: true);
  }
}