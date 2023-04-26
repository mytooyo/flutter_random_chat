import 'package:app/firestore/messages_firestore.dart';
import 'package:app/main.dart';
import 'package:app/model/firestore_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

class MessageBloc {
  static final _shared = MessageBloc._();
  static MessageBloc get shared => _shared;

  MessageBloc._();

  factory MessageBloc() {
    return _shared;
  }

  final subject = BehaviorSubject<Message>();
  Stream<Message> get stream => subject.stream;

  void dispose() {
    subject.close();
  }

  Future<void> updateLike(Message message, bool liked) async {
    var uid = user?.uid ?? 'aaaaaaaa';

    if (liked) {
      message.likes.add(uid);
    } else {
      message.likes.remove(uid);
    }

    // Update

    // subject.sink.add(message);
  }
}

class MessagesScreenBloc {
  MessagesScreenBloc();

  List<String> ids = [];

  final subject = BehaviorSubject<List<Message>>();
  Stream<List<Message>> get stream => subject.stream;

  void dispose() {
    subject.close();
  }

  void load() async {
    String uid = auth.user.uid;
    FirebaseFirestore.instance
        .collection('${MessagesFirestore.receivePrefix}/$uid/messages')
        // .document('{wildcard}').collection('messages')
        // .where('uid', isEqualTo: uid)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .listen((event) {
      var list = event.docChanges
          .map((e) => Message.fromSnapshot(e.doc))
          .where((element) => !ids.contains(element.id))
          .toList();

      // 対象のID分ユーザを最新化
      for (var msg in list) {
        msg.fetchUser();
      }

      ids.addAll(list.map((e) => e.id));

      subject.sink.add(list);
    });
  }
}
