
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/firestore/base_firestore.dart';
import 'package:app/main.dart';
import 'package:app/model/firestore_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

class UsersFirestore extends BaseFirestore {

  static String prefix = 'users';

  static String activatePrefix = 'activate';
  static String activateId = 'appactivateusersdocumentid';

  static String refusalKey = 'refusal';

  Future<void> update(User user) async {
    var uid = (await auth.authUser()).uid;
    await instance.collection(prefix).document(uid).setData(user.toJson);
    savePrefs(user);
  }

  Future<void> updateNotification(bool isOn) async {
    var uid = (await auth.authUser()).uid;
    await instance.collection(prefix).document(uid).updateData({
      'notification': isOn
    });
    _savePrefsNotification(isOn);
  }

  Future<void> updateToken(String token) async {
    var uid = (await auth.authUser()).uid;
    await instance.collection(prefix).document(uid).updateData({
      'token': token
    });
    _saveToken(token);
  }

  Future<User> fetch(String id) async {
    var snapshot = await instance.collection(prefix).document(id).get();
    return User.fromSnapshot(snapshot);
  }

  Future<String> uploadImage(String id, File file, bool isback) async {
    var ext = path.extension(file.path);
    var filename = isback ? 'bgimage' + ext : 'image' + ext;
    var contentType = ext.replaceAll('.', '');

    final StorageReference ref = FirebaseStorage().ref().child(prefix).child(id).child(filename);
    final StorageUploadTask uploadTask = ref.putFile(
      file,
      StorageMetadata(
        contentType: "image/$contentType",
      )
    );
    StorageTaskSnapshot snapshot = await uploadTask.onComplete;

    if (snapshot.error == null) {
      return await snapshot.ref.getDownloadURL();
    } else {
      return 'Something goes wrong';
    }
  }

  /// 拒否リストに登録
  Future<void> report(String id) async {
    var user = await auth.authUser();
    // 拒否リストの配列に追加
    await instance.collection(prefix).document(user.uid).updateData(
      { refusalKey: FieldValue.arrayUnion([id]) }
    );

    return;
  }

  Future<void> activate(bool isOn) async {
    var user = await auth.authUser();

    // IDが存在しない場合はエラー（基本的にはこんなことはないと思う
    if (user == null || user.uid == null) return;

    // ドキュメントをアップデート
    await instance.collection(prefix).document(user.uid).updateData(
      {'active': isOn}
    );

    // アクティブ数の合計を更新(CloudFunctionで実装)
    // await instance.collection(activatePrefix).document(activateId).updateData({
    //   'users': FieldValue.increment(isOn ? 1 : -1) 
    // });
  }

  Future<void> savePrefs(User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('id', user.id);
    await prefs.setString('name', user.name);
    await prefs.setString('img', user.img);
    await prefs.setInt('age', user.age);
    await prefs.setString('lang', user.lang);
    await prefs.setString('profile', user.profile);
    await prefs.setString('bgImage', user.bgImage);
    await prefs.setBool('available', user.available);
    await prefs.setInt('timestamp', user.timestamp);
    await prefs.setBool('notification', user.notification);
    await prefs.setBool('active', user.active);

    self = User.fromPrefs(prefs);
  }

  Future<void> _savePrefsNotification(bool isOn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notification', isOn);
    self = User.fromPrefs(prefs);
  }

  Future<void> _saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    self = User.fromPrefs(prefs);
  }

  Future<User> cache() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return User.fromPrefs(prefs);
  }
}