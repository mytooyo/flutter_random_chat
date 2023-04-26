import 'dart:io';

import 'package:app/firestore/base_firestore.dart';
import 'package:app/main.dart';
import 'package:app/model/firestore_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

class MessagesFirestore extends BaseFirestore {
  static const String prefix = 'messages';
  static const String postPrefix = 'posted';
  static const String receivePrefix = 'received';

  Future<void> post(String message, {File? file}) async {
    String uid = auth.user.uid;
    String id = const Uuid().v4() + uid;

    // String img;

    Message message0 = Message(
      id: id,
      message: message,
      img: null,
      imgReg: file != null,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      uid: uid,
      from: self!,
    );

    await instance.collection(postPrefix).doc(id).set(message0.toJson);

    // 画像のアップロードがある場合は非同期で実施
    if (file != null) {
      var ext = path.extension(file.path);
      var contentType = ext.replaceAll('.', '');

      var filename = id + ext;

      final ref = FirebaseStorage.instance.ref().child(prefix).child(filename);
      final _ = ref.putFile(
        file,
        SettableMetadata(
          contentType: "image/$contentType",
        ),
      );
    }
  }

  Future<void> resetUsers(Message message) async {
    String uid = auth.user.uid;
    await instance
        .collection('${MessagesFirestore.receivePrefix}/$uid/messages')
        .doc(message.id)
        .delete();
    await instance.collection(MessagesFirestore.receivePrefix).doc(uid).update({
      'ids': FieldValue.arrayRemove([message.id])
    });
  }
}
