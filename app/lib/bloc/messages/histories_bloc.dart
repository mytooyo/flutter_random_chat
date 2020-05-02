import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/firestore/messages_firestore.dart';
import 'package:app/main.dart';
import 'package:app/model/firestore_model.dart';
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
    String uid = (await auth.authUser()).uid;
    Firestore.instance.collection(MessagesFirestore.postPrefix)
      .where('uid', isEqualTo: uid)
      .orderBy('timestamp', descending: false)
      .snapshots().listen((event) { 
        var _list = event.documentChanges.map(
          (e) => Message.fromSnapshot(e.document)
        ).where((element) => !ids.contains(element.id)).toList();

        ids.addAll(_list.map((e) => e.id));

        subject.sink.add(_list);    
      });
    
  }
}
