import 'package:app/firestore/users_firestore.dart';
import 'package:app/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

class UnreadReplysBloc {
  UnreadReplysBloc() {
    load();
  }

  final subject = BehaviorSubject<int>();
  Stream<int> get stream => subject.stream;

  void dispose() {
    subject.close();
  }

  void load() async {
    if (self?.id == null) return;
    FirebaseFirestore.instance
        .collection(UsersFirestore.prefix)
        .doc(self!.id)
        .snapshots()
        .listen((event) {
      var json = event.data();

      if (json == null) {
        subject.sink.add(0);
      } else if (json.keys.contains('unread')) {
        var count = json['unread'] as int;
        int data = 0;
        if (count > 0) {
          data = count;
        }
        subject.sink.add(data);
      } else {
        subject.sink.add(0);
      }
    });
  }
}

class UnreadReplysCounterBloc {
  UnreadReplysCounterBloc() {
    load();
  }

  final subject = BehaviorSubject<int>();
  Stream<int> get stream => subject.stream;

  void dispose() {
    subject.close();
  }

  void load() async {
    FirebaseFirestore.instance
        .collection(UsersFirestore.prefix)
        .doc(self!.id)
        .snapshots()
        .listen((event) {
      if (subject.isClosed) return;

      var json = event.data();
      if (json == null) {
        subject.sink.add(0);
      } else if (json.keys.contains('unread')) {
        var count = json['unread'] as int;
        int data = 0;
        if (count > 0) {
          data = count;
        }
        subject.sink.add(data);
      } else {
        subject.sink.add(0);
      }
    });
  }
}
