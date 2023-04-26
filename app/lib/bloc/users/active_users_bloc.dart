import 'package:app/firestore/users_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

class ActiveUsersBloc {
  ActiveUsersBloc() {
    load();
  }

  final subject = BehaviorSubject<int>();
  Stream<int> get stream => subject.stream;

  void dispose() {
    subject.close();
  }

  void load() async {
    FirebaseFirestore.instance
        .collection(UsersFirestore.activatePrefix)
        .doc(UsersFirestore.activateId)
        .snapshots()
        .listen((event) {
      var json = event.data();
      if (json == null) return;
      var count = json['users'] as int;
      subject.sink.add(count);
    });
  }
}
