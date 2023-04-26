import 'package:app/firestore/users_firestore.dart';
import 'package:app/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class User {
  final String id;
  String name;
  String? img; // URL
  int? age;
  final String lang;
  String profile;
  String? bgImage;
  final bool available;
  bool notification;
  final int timestamp;
  bool active;
  String? token;

  User({
    required this.id,
    required this.name,
    this.img,
    this.age,
    this.lang = 'ja',
    required this.profile,
    required this.bgImage,
    required this.available,
    required this.notification,
    required this.timestamp,
    required this.active,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      img: json['img'] as String,
      age: json['age'] as int,
      lang: (json['lang'] as String?) ?? 'ja',
      profile: json['profile'] as String,
      bgImage: json['bgImage'] as String,
      available: json['available'] as bool,
      timestamp: json['timestamp'] as int,
      notification: json['notification'] as bool,
      active: (json['active'] as bool?) ?? false,
      token: json['token'] as String?,
    );
  }

  factory User.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data()! as Map<String, dynamic>;
    return User.fromJson(Map<String, dynamic>.from(data));
  }

  factory User.fromPrefs(SharedPreferences prefs) {
    return User(
      id: prefs.getString('id')!,
      name: prefs.getString('name')!,
      img: prefs.getString('img'),
      age: prefs.getInt('age'),
      lang: prefs.getString('lang')!,
      profile: prefs.getString('profile')!,
      bgImage: prefs.getString('bgImage'),
      available: prefs.getBool('available')!,
      timestamp: prefs.getInt('timestamp')!,
      notification: prefs.getBool('notification')!,
      active: prefs.getBool('active') ?? false,
      token: prefs.getString('token'),
    );
  }

  Map<String, dynamic> get toJson => <String, dynamic>{
        'id': id,
        'name': name,
        'img': img,
        'age': age,
        'lang': lang,
        'profile': profile,
        'bgImage': bgImage,
        'available': available,
        'timestamp': timestamp,
        'notification': notification,
        'active': active,
        'token': token
      };
}

class Message {
  final String id;
  final String message;
  final String? img;
  final bool imgReg;
  final int timestamp;
  final String? uid;
  User from;
  List<String> likes = [];

  // 内部で広告表示のために用いるフラグのため、
  // Firestore上には存在しない
  // このフラグがtrueの場合は他の項目には何も設定されない
  bool ad = false;

  Message({
    required this.id,
    required this.message,
    this.img,
    required this.imgReg,
    required this.timestamp,
    this.uid,
    required this.from,
    this.likes = const [],
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      message: json['message'] as String,
      img: json['img'],
      imgReg: (json['imgReg'] as bool?) ?? false,
      timestamp: json['timestamp'] as int,
      from: User.fromJson(Map<String, dynamic>.from(json['from'])),
    );
  }

  factory Message.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Message.fromJson(Map<String, dynamic>.from(data));
  }

  Map<String, dynamic> get toJson => <String, dynamic>{
        'id': id,
        'message': message,
        'img': img,
        'imgReg': imgReg,
        'timestamp': timestamp,
        'uid': uid,
        'from': from.toJson
      };

  // 送信元ユーザの情報を最新化する
  Future<void> fetchUser() async {
    final usersFirestore = UsersFirestore();

    if (uid == null) return;

    var user = await usersFirestore.fetch(uid!);
    from = user;
  }
}

class Conversation {
  final String id;
  final Message message;
  final List<String> users;
  final int timestamp;
  int unreadMessagener;
  int unreadReplyer;
  late User to;

  Conversation({
    required this.id,
    required this.message,
    required this.users,
    required this.timestamp,
    required this.unreadMessagener,
    required this.unreadReplyer,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as String,
      message: Message.fromJson(Map<String, dynamic>.from(json['message'])),
      users: (json['users'] as List<dynamic>).map((e) => e.toString()).toList(),
      timestamp: json['timestamp'] as int,
      unreadMessagener: json['unreadMessagener'] as int,
      unreadReplyer: json['unreadReplyer'] as int,
    );
  }

  factory Conversation.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Conversation.fromJson(Map<String, dynamic>.from(data));
  }

  Map<String, dynamic> get toJson => <String, dynamic>{
        'id': id,
        'message': message.toJson,
        'users': users,
        'timestamp': timestamp,
        'unreadMessagener': unreadMessagener,
        'unreadReplyer': unreadReplyer
      };

  // 会話相手のユーザ情報を取得
  Future<void> fetchToUser(String uid) async {
    final usersFirestore = UsersFirestore();

    var toUid = users.where((element) => element != uid).toList()[0];

    var user = await usersFirestore.fetch(toUid);
    to = user;
  }
}

class Reply {
  final String id;
  final String? message;
  final String? img;
  final User from;
  final int timestamp;
  final bool? tmp;
  final bool? read;
  final String to;

  Reply({
    required this.id,
    required this.message,
    required this.img,
    required this.from,
    required this.timestamp,
    this.tmp = false,
    this.read = true,
    required this.to,
  });

  factory Reply.fromJson(Map<String, dynamic> json) {
    return Reply(
      id: json['id'] as String,
      message: json['message'] as String,
      img: json['img'] as String,
      from: User.fromJson(Map<String, dynamic>.from(json['from'])),
      timestamp: json['timestamp'] as int,
      tmp: json['tmp'] ?? false,
      read: json['read'] ?? true,
      to: json['to'] as String,
    );
  }

  factory Reply.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Reply.fromJson(Map<String, dynamic>.from(data));
  }

  factory Reply.fromMessage(Message msg) {
    return Reply(
      id: msg.id,
      message: msg.message,
      img: msg.img,
      from: msg.from,
      timestamp: msg.timestamp,
      read: true,
      to: self!.id,
    );
  }

  Map<String, dynamic> get toJson => <String, dynamic>{
        'id': id,
        'message': message,
        'img': img,
        'timestamp': timestamp,
        'from': from.toJson,
        'tmp': tmp,
        'read': read ?? false,
        'to': to
      };
}
