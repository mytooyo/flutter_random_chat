import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/firestore/messages_firestore.dart';
import 'package:app/main.dart';
import 'package:app/model/firestore_model.dart';
import 'package:rxdart/rxdart.dart';

class MessageBloc {

  static MessageBloc _shared;
  static MessageBloc get shared => _shared ??= MessageBloc._();
  factory MessageBloc() => _shared ??= MessageBloc._();

  MessageBloc._();
  
  final subject = BehaviorSubject<Message>();
  Stream<Message> get stream => subject.stream;

  void dispose() {
    subject.close();
  }

  Future<void> updateLike(Message message, bool liked) async {

    var uid = user?.uid ?? 'aaaaaaaa';

    if (liked) {
      message.likes.add(uid);
    }
    else {
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
    String uid = (await auth.authUser()).uid;
    Firestore.instance.collection('${MessagesFirestore.receivePrefix}/$uid/messages')
      // .document('{wildcard}').collection('messages')
      // .where('uid', isEqualTo: uid)
      .orderBy('timestamp', descending: false)
      .snapshots().listen((event) { 
        var _list = event.documentChanges.map(
          (e) => Message.fromSnapshot(e.document)
        ).where((element) => !ids.contains(element.id)).toList();

        // 対象のID分ユーザを最新化
        _list.forEach((msg) => msg?.fetchUser());

        ids.addAll(_list.map((e) => e.id));
        
        subject.sink.add(_list);
      });
    
  }
}