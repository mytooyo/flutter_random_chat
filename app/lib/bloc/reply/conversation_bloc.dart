
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/firestore/conversation_firestore.dart';
import 'package:app/main.dart';
import 'package:app/model/firestore_model.dart';
import 'package:rxdart/rxdart.dart';

class ConversationScreenBloc {

  final subject = BehaviorSubject<List<Conversation>>();
  Stream<List<Conversation>> get stream => subject.stream;

  void dispose() {
    subject.close();
  }

  void load() async {
    String uid = (await auth.authUser()).uid;
    Firestore.instance.collection(ConversationFirestore.prefix)
      .where('users', arrayContains: uid)
      .snapshots().listen((event) async { 

        var _list = event.documentChanges.map(
          (e) => Conversation.fromSnapshot(e.document)
        ).toList();
        
        // 会話相手の情報を取得
        for ( var conv in _list) {
          await conv.fetchToUser(uid);
        }
         
        if (subject.isClosed) {
          // クローズされていた場合は再度オープンする処理が必要そう
          return;
        }
        subject.sink.add(_list);

       });
  }

}