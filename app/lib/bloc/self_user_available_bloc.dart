import 'package:app/firestore/users_firestore.dart';
import 'package:app/main.dart';
import 'package:app/model/firestore_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

class SelfUserBloc {
  bool available = false;
  SelfUserBloc() {
    available = self?.available ?? false;
  }

  final subject = BehaviorSubject<User>();
  Stream<User> get stream => subject.stream;

  void dispose() {
    subject.close();
  }

  void load() async {
    if (self?.id == null) return;
    FirebaseFirestore.instance
        .collection(UsersFirestore.prefix)
        .doc(self!.id)
        .snapshots()
        .listen((event) async {
      // 取得したスナップショットをユーザに設定
      var user = User.fromSnapshot(event);
      var firestore = UsersFirestore();
      await firestore.savePrefs(user);

      // 変更があった場合は基本的にStreamに流す
      subject.sink.add(user);
    });
  }
}
