
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/firestore/base_firestore.dart';
import 'package:app/firestore/messages_firestore.dart';
import 'package:app/firestore/users_firestore.dart';
import 'package:app/main.dart';
import 'package:app/model/firestore_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;

class ConversationFirestore extends BaseFirestore {

  static final String prefix = 'conversation';
  static final String replyPrefix = 'replys';

  Future<Conversation> register(Message message, {String reply, File file, String id}) async {

    String uid = (await auth.authUser()).uid;

    var id = Uuid().v4() + DateTime.now().millisecondsSinceEpoch.toString();
    var conv = Conversation(
      id: id,
      message: message,
      users: [uid, message.from.id],
      timestamp: DateTime.now().millisecondsSinceEpoch,
      unreadMessagener: 0,
      unreadReplyer: 0
    );
    conv.to = message.from;

    await instance.collection(prefix).document(id).setData(conv.toJson);

    // メッセージの送信の場合
    if (reply != null) {
      await sendMessage(conv, reply);
    }
    // 画像送信の場合
    else {
      await sendImage(conv, file, id: id);
    }

    // 再度表示されないように対象から除外
    await MessagesFirestore().resetUsers(message);

    return conv;

  }


  Future<void> sendMessage(Conversation conv, String reply) async {
    String uid = (await auth.authUser()).uid;
    var id = Uuid().v4() + uid;

    var to = conv.users.where((id) => uid != id).first;
    var _reply = Reply(
      id: id,
      message: reply,
      img: null,
      from: self,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      tmp: false,
      read: false,
      to: to
    );

    await instance.collection(prefix).document(conv.id)
      .collection(replyPrefix).document(id).setData(_reply.toJson);

    // 未読件数はそこまで大事なわけではないため、
    // 非同期で処理させることでUXを向上させたい
    updateUnread(conv, uid);
  }

  Future<void> sendImage(Conversation conv, File file, {String id}) async {
    
    // ここで払い出したIDはそのままCloudFunctionで引き継いで利用
    String uid = (await auth.authUser()).uid;
    var repId = id ?? Uuid().v4() + uid;

    var to = conv.users.where((id) => uid != id).first;
    var _reply = Reply(
      id: repId,
      message: null,
      img: null,
      from: self,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      tmp: true,
      read: false,
      to: to
    );

    await instance.collection(prefix).document(conv.id)
      .collection(replyPrefix).document(id).setData(_reply.toJson);


    var ext = path.extension(file.path);
    var contentType = ext.replaceAll('.', '');

    var filename = id + ext;
    final StorageReference ref = FirebaseStorage().ref().child(prefix).child(conv.id).child(filename);
    final StorageUploadTask _ = ref.putFile(
      file,
      StorageMetadata(
        contentType: "image/$contentType",
      )
    );

    // 未読件数はそこまで大事なわけではないため、
    // 非同期で処理させることでUXを向上させたい
    updateUnread(conv, uid);

  }

  Future<void> updateUnread(Conversation conv, String uid) async {
    // Conversationに未読件数として設定
    // 自分がメッセージ投稿者であった場合はreplyerに対して未読を登録
    var key = 'unreadMessagener';
    if (conv.message.from.id == uid) {
      key = 'unreadReplyer';
    }

    await instance.collection(prefix).document(conv.id).updateData({
      key: FieldValue.increment(1)
    });

    // ユーザ毎の未読件数を設定
    await instance.collection(UsersFirestore.prefix).document(conv.to.id).updateData({
      'unread': FieldValue.increment(1)
    });
  }

  Future<void> updateRead(Conversation conv) async {
    String uid = (await auth.authUser()).uid;
    // 自分がメッセージ投稿者であった場合はreplyerに対して未読を登録
    var key = 'unreadMessagener';
    var decrement = conv.unreadMessagener;
    if (conv.message.from.id != uid) {
      key = 'unreadReplyer';
      decrement = conv.unreadReplyer;
    }
    // Conversationに未読件数を0に更新
    await instance.collection(prefix).document(conv.id).updateData({
      key: 0
    });

    // ユーザ毎の未読件数をConversation分デクリメント
    await instance.collection(UsersFirestore.prefix).document(uid).updateData({
      'unread': FieldValue.increment(-decrement)
    });
  }

}