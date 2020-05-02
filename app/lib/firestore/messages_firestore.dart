import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/firestore/base_firestore.dart';
import 'package:app/main.dart';
import 'package:app/model/firestore_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

class MessagesFirestore extends BaseFirestore {

  static final String prefix = 'messages';
  static final String postPrefix = 'posted';
  static final String receivePrefix = 'received';

  Future<void> post(String message, {File file}) async {
    
    String uid = (await auth.authUser()).uid;
    String id = Uuid().v4() + uid;
    
    // String img;
    
    Message _message = Message(
      id: id,
      message: message,
      img: null,
      imgReg: file != null,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      uid: uid,
      from: self,
    );

    await instance.collection(postPrefix).document(id).setData(_message.toJson);

    // 画像のアップロードがある場合は非同期で実施
    if (file != null) {
      var ext = path.extension(file.path);
      var contentType = ext.replaceAll('.', '');

      var filename = id + ext;
      final StorageReference ref = FirebaseStorage().ref().child(prefix).child(filename);
      final StorageUploadTask _ = ref.putFile(
        file,
        StorageMetadata(
          contentType: "image/$contentType",
        )
      );
      
    }

  }

  Future<void> resetUsers(Message message) async {
    String uid = (await auth.authUser()).uid;
    await instance.collection('${MessagesFirestore.receivePrefix}/$uid/messages').document(message.id).delete();
    await instance.collection(MessagesFirestore.receivePrefix).document(uid).updateData({
      'ids': FieldValue.arrayRemove([message.id]) 
    });
  }

}
