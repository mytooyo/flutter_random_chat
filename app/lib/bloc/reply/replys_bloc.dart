import 'package:app/firestore/conversation_firestore.dart';
import 'package:app/model/firestore_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

class ReplyScreenBloc {
  Conversation conv;
  ReplyScreenBloc({required this.conv});

  Map<String, bool> ids = {};

  final subject = BehaviorSubject<Map<String, Reply>>();
  Stream<Map<String, Reply>> get stream => subject.stream;

  void dispose() {
    subject.close();
  }

  void load() async {
    // if (conv == null) return;

    FirebaseFirestore.instance
        .collection(ConversationFirestore.prefix)
        .doc(conv.id)
        .collection(ConversationFirestore.replyPrefix)
        .orderBy('timestamp')
        .snapshots()
        .listen((event) {
      var list = event.docChanges
          .map((e) => Reply.fromSnapshot(e.doc))
          .where((element) =>
              ids[element.id] == null || ids[element.id] != element.tmp)
          .toList();

      Map<String, Reply> map = {};
      for (var e in list) {
        ids[e.id] = e.tmp ?? false;
        map[e.id] = e;
      }

      if (subject.isClosed) {
        // クローズされていた場合は再度オープンする処理が必要そう
        return;
      }
      subject.sink.add(map);
    });
  }
}
