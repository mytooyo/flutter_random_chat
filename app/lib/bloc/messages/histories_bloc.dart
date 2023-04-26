import 'package:app/firestore/messages_firestore.dart';
import 'package:app/main.dart';
import 'package:app/model/firestore_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

class HistoriesScreenBloc {
  HistoriesScreenBloc();

  List<String> ids = [];

  final subject = BehaviorSubject<List<Message>>();
  Stream<List<Message>> get stream => subject.stream;

  void dispose() {
    subject.close();
  }

  void load() async {
    String uid = auth.user.uid;
    FirebaseFirestore.instance
        .collection(MessagesFirestore.postPrefix)
        .where('uid', isEqualTo: uid)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .listen((event) {
      var list = event.docChanges
          .map((e) => Message.fromSnapshot(e.doc))
          .where((element) => !ids.contains(element.id))
          .toList();

      ids.addAll(list.map((e) => e.id));

      subject.sink.add(list);
    });
  }
}
