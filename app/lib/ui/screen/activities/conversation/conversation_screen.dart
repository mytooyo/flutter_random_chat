import 'dart:async';
import 'dart:io';

import 'package:app/bloc/reply/replys_bloc.dart';
import 'package:app/firestore/conversation_firestore.dart';
import 'package:app/main.dart';
import 'package:app/model/firestore_model.dart';
import 'package:app/ui/route/route.dart';
import 'package:app/ui/screen/activities/messages/message_image_screen.dart';
import 'package:app/ui/screen/user_profile_screen.dart';
import 'package:app/ui/theme/app_theme_data.dart';
import 'package:app/ui/utilities/app_date.dart';
import 'package:app/ui/utilities/app_images.dart';
import 'package:app/ui/utilities/app_list_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:load/load.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class ConversationScreenArgument {
  final Message? message;
  final User? user;
  final Conversation? conv;
  final void Function(Message)? callback;
  ConversationScreenArgument({
    this.message,
    this.user,
    this.conv,
    this.callback,
  });
}

class ConversationScreen extends StatefulWidget {
  final Message? message;
  final User? user;
  final Conversation? conv;
  final void Function(Message)? callback;

  const ConversationScreen({
    super.key,
    this.message,
    this.user,
    this.conv,
    this.callback,
  });

  @override
  State<ConversationScreen> createState() => _ConversationScreen();
}

class _ConversationScreen extends State<ConversationScreen> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final FocusNode _focusNode = FocusNode();
  late ListModel<Reply> _list;

  late TextEditingController _textController;
  final ScrollController _scrollController = ScrollController();

  ReplyScreenBloc? _bloc;

  // Conversation conv;
  bool _begin = false;

  final Map<String, File> _uplodingImages = {};

  @override
  void initState() {
    // conv = widget.conv;
    _begin = widget.conv == null;

    List<Reply> initial = [];

    // if (widget.message != null) {
    //   _initial.add(Reply.fromMessage(widget.message));
    // }

    _list = ListModel<Reply>(
      listKey: _listKey,
      initialItems: initial,
      removedItemBuilder: _buildRemovedItem,
    );

    _textController = TextEditingController();

    // 未読を全て既読に設定
    _updateRead();

    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.unfocus();
    _bloc?.dispose();
    super.dispose();
  }

  void _updateRead() async {
    if (widget.conv != null) {
      await ConversationFirestore().updateRead(widget.conv!);
      widget.conv!.unreadReplyer = 0;
      widget.conv!.unreadMessagener = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_bloc == null) {
      _bloc = Provider.of<ReplyScreenBloc>(context);
      _bloc?.load();
    }

    return Scaffold(
      backgroundColor: Theme.of(context).bottomAppBarColor,
      appBar: AppBar(
        title: _header(),
        centerTitle: false,
        backgroundColor: Theme.of(context).bottomAppBarColor,
        elevation: 0,
        leading: null,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: AppTheme.primaryLight),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: GestureDetector(
                child: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 4, left: 12, right: 12, bottom: 0),
                    child: _conversation(),
                  ),
                ),
                onTap: () {
                  _focusNode.unfocus();
                },
              ),
            ),
            _inputField()
          ],
        ),
      ),
    );
  }

  Widget _header() {
    const double imageSize = 32;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          width: imageSize,
          height: imageSize,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: AppTheme.lightGray),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: OverflowBox(
              minWidth: 0.0,
              minHeight: 0.0,
              // maxWidth: double.infinity,
              maxHeight: double.infinity,
              child: widget.user?.img == null
                  ? Image.asset('assets/images/person.png', color: Colors.white)
                  : CachedNetworkImage(
                      imageUrl: widget.user!.img!,
                      httpHeaders: {'Authorization': 'Bearer $token'},
                      fit: BoxFit.cover,
                      height: imageSize,
                      width: imageSize,
                      progressIndicatorBuilder:
                          (context, url, downloadProgress) =>
                              CircularProgressIndicator(
                                  value: downloadProgress.progress),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          // fit: FlexFit.loose,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                widget.user?.name ?? '',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.merge(AppTheme.medium),
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            splashColor: Colors.white24,
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              User user;
              if (widget.message == null) {
                user = widget.conv!.to;
              } else {
                user = widget.message!.from;
              }

              Navigator.of(context).pushNamed(
                RouteName.userProfile,
                arguments: UserProfileScreenArgumanet(user: user),
              );
            },
            child: const SizedBox(
              height: 40,
              width: 40,
              child: Center(
                child: Center(
                  child: Icon(
                    FontAwesomeIcons.solidUser,
                    size: 24,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _conversation() {
    return StreamBuilder(
      stream: _bloc!.stream,
      initialData: const [],
      builder: (_, snapshot) {
        if (snapshot.data is Map<String, Reply>) {
          (snapshot.data as Map<String, Reply>).forEach(
            (_, element) {
              // IDが一致する返信が存在する場合は更新、それ以外は追加
              var same = _list.where((Reply reply) => reply.id == element.id);
              if (same.isNotEmpty) {
                int index = _list.indexOf(same[0]);
                _list.update(index, element);
              } else {
                _insert(element);
              }
            },
          );
        }

        // 削除対象のKey一覧
        List<String> delKeys = [];
        // アップロード中の画像が存在する場合のチェックを実施
        _uplodingImages.forEach((key, value) {
          // キーがリスト内に存在し、tmpがfalseの場合はアップロード処理終了
          var uploaded = _list.where(
              (Reply element) => element.id == key && !(element.tmp ?? false));
          if (uploaded.isNotEmpty) delKeys.add(key);
        });

        // アップロード済みの画像はリストから削除
        if (delKeys.isNotEmpty) {
          for (var element in delKeys) {
            _uplodingImages.remove(element);
          }
        }

        // if (_scrollController.position != null) {
        _scroll();
        // }

        return AnimatedList(
            key: _listKey,
            controller: _scrollController,
            shrinkWrap: true,
            padding: const EdgeInsets.only(top: 12, bottom: 40),
            physics: const AlwaysScrollableScrollPhysics(),
            initialItemCount: _list.length + 1,
            itemBuilder: _buildItem);
      },
    );
  }

  Future<void> _scroll() async {
    if (!_scrollController.hasClients) return;
    Timer(
      const Duration(milliseconds: 500),
      () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 150),
          curve: const Interval(0.0, 1.0),
        );
      },
    );
  }

  // Used to build list items that haven't been removed.
  Widget _buildItem(
      BuildContext context, int index, Animation<double> animation) {
    if (index == 0) {
      return SizeTransition(
          axis: Axis.vertical, sizeFactor: animation, child: _initialMessage());
    }

    var i = index - 1;
    Reply reply = _list[i];

    return SizeTransition(
        axis: Axis.vertical,
        sizeFactor: animation,
        child: _conversionItem(reply, index: i));
  }

  Widget _buildRemovedItem(
      Reply item, BuildContext context, Animation<double> animation) {
    return SizeTransition(
        axis: Axis.vertical,
        sizeFactor: animation,
        child: _conversionItem(item));
  }

  void _insert(Reply item) {
    if (_list.indexOf(item) >= 0) return;
    _list.insert(_list.length, item);
  }

  Widget _initialMessage() {
    var msg = widget.message;
    msg ??= widget.conv!.message;

    return Stack(
      children: <Widget>[
        Padding(
          padding:
              const EdgeInsets.only(top: 32, left: 16, right: 16, bottom: 16),
          child: Container(
            decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Theme.of(context).dividerColor)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                    top: 32,
                    left: 16,
                    right: 16,
                    bottom: 16,
                  ),
                  child: Text(
                    msg.message,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                msg.img == null ? Container() : _initialMessageImage(msg)
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 12, bottom: 12, left: 24, right: 24),
                child: Text(
                  'Posted Message',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _initialMessageImage(Message msg) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 20, left: 12, right: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 120,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: OverflowBox(
                minWidth: 0.0,
                minHeight: 0.0,
                // maxWidth: double.infinity,
                maxHeight: double.infinity,
                child: CachedNetworkImage(
                  imageUrl: msg.img!,
                  httpHeaders: {'Authorization': 'Bearer $token'},
                  fit: BoxFit.cover,
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      CircularProgressIndicator(
                          value: downloadProgress.progress),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),
          ),
          onTap: () {
            Navigator.of(context).pushNamed(RouteName.showImage,
                arguments: MessageImageScreenArgument(img: msg.img));
          },
        ),
      ),
    );
  }

  Widget _conversionItem(Reply reply, {int? index}) {
    var isDisplayTime = index == null ? true : _isDisplayTime(index);

    return SizedBox(
        width: double.infinity,
        child: reply.from.id == self?.id
            ? _rightBubble(reply, isDisplayTime)
            : _leftBubble(reply, isDisplayTime)
        // )
        );
  }

  bool _isDisplayTime(int index) {
    // 最後のインデックスの場合
    if (index == _list.length - 1) return true;

    var reply = _list[index];
    var next = _list[index + 1];

    // 次のメッセージの送信元が違う場合
    if (reply.from.id != next.from.id) return true;

    // 同一の送信元で次のメッセージと時刻が異なる場合
    var time = dateFormatted(
        DateTime.fromMillisecondsSinceEpoch(reply.timestamp),
        format: 'HH:mm');

    var nextTime = dateFormatted(
        DateTime.fromMillisecondsSinceEpoch(next.timestamp),
        format: 'HH:mm');

    if (time != nextTime) return true;

    return false;
  }

  Widget _leftBubble(Reply reply, bool isDisplayTime) {
    return Padding(
      padding: EdgeInsets.only(bottom: isDisplayTime ? 16 : 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              reply.message == null
                  ? _image(url: reply.img, file: _uplodingImages[reply.id])
                  : Flexible(
                      flex: 1,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.7),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: const <BoxShadow>[
                              BoxShadow(
                                  color: Colors.black12,
                                  offset: Offset(0, 1.5),
                                  blurRadius: 2.0),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              reply.message ?? '',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ),
                      ),
                    ),
              Container(),
            ],
          ),
          const SizedBox(height: 4),
          isDisplayTime
              ? Padding(
                  padding: const EdgeInsets.only(top: 4, left: 4),
                  child: Text(
                    dateFormatted(
                        DateTime.fromMillisecondsSinceEpoch(reply.timestamp),
                        format: 'HH:mm'),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                )
              : Container()
        ],
      ),
    );
  }

  Widget _rightBubble(Reply reply, bool isDisplayTime) {
    return Padding(
      padding: EdgeInsets.only(bottom: isDisplayTime ? 16 : 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              reply.message == null
                  ? _image(url: reply.img, file: _uplodingImages[reply.id])
                  : Flexible(
                      flex: 1,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.primaryDark,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: const <BoxShadow>[
                              BoxShadow(
                                  color: Colors.black12,
                                  offset: Offset(0, 1.5),
                                  blurRadius: 2.0),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              reply.message ?? '',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.merge(AppTheme.whiteStyle),
                            ),
                          ),
                        ),
                      ),
                    ),
              Container(),
            ],
          ),
          const SizedBox(height: 4),
          isDisplayTime
              ? Padding(
                  padding: const EdgeInsets.only(top: 4, left: 4),
                  child: Text(
                    dateFormatted(
                      DateTime.fromMillisecondsSinceEpoch(reply.timestamp),
                      format: 'HH:mm',
                    ),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                )
              : Container()
        ],
      ),
    );
  }

  Widget _image({String? url, File? file}) {
    double width = MediaQuery.of(context).size.width * 0.5;
    return Container(
      width: width,
      height: width * 3 / 4,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 1.5),
            blurRadius: 2.0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: OverflowBox(
          minWidth: 0.0,
          minHeight: 0.0,
          // maxWidth: double.infinity,
          maxHeight: double.infinity,
          child: file != null
              ? Image.file(
                  file,
                  fit: BoxFit.cover,
                )
              : Material(
                  color: Colors.transparent,
                  child: InkWell(
                    child: CachedNetworkImage(
                      imageUrl: url ?? '',
                      httpHeaders: {'Authorization': 'Bearer $token'},
                      fit: BoxFit.cover,
                      height: width * 3 / 4,
                      width: width,
                      progressIndicatorBuilder:
                          (context, url, downloadProgress) =>
                              CircularProgressIndicator(
                                  value: downloadProgress.progress),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                    onTap: () {
                      if (url == null) return;
                      Navigator.of(context).pushNamed(RouteName.showImage,
                          arguments: MessageImageScreenArgument(img: url));
                    },
                  ),
                ),
        ),
      ),
    );
  }

  Widget _inputField() {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 32),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).bottomAppBarColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              ClipOval(
                child: Material(
                  color: Colors.transparent,
                  child: IconButton(
                    icon: const Icon(Icons.image),
                    color: Theme.of(context).disabledColor,
                    onPressed: () {
                      getImage();
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: TextFormField(
                  style: Theme.of(context).textTheme.bodyLarge,
                  controller: _textController,
                  decoration: InputDecoration(
                    hintText: 'Your message...',
                    hintStyle: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.merge(AppTheme.lightGrayStyle),
                    contentPadding: const EdgeInsets.all(8),
                    fillColor: Colors.transparent,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppTheme.primary.withOpacity(0.8),
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  focusNode: _focusNode,
                  minLines: 1,
                  maxLines: 3,
                ),
              ),
              ClipOval(
                child: Material(
                  color: Colors.transparent,
                  child: IconButton(
                    icon: const Icon(Icons.send),
                    color: AppTheme.primary,
                    onPressed: () {
                      if (_textController.text == '') return;

                      _postMessage();
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future getImage() async {
    XFile? image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 60,
    );

    if (image?.path == null) return;

    showAppLoadingWidget();
    File newImage = File(image!.path);

    newImage = await fixExifRotation(newImage.path);
    await _postImage(newImage);

    hideLoadingDialog();
  }

  Future<void> _postMessage() async {
    final firestore = ConversationFirestore();
    // 初回の会話情報の場合
    if (_begin) {
      firestore.register(widget.message!, reply: _textController.text).then(
        (value) {
          _bloc?.conv = value;
          _bloc?.load();
          _begin = false;
          widget.callback?.call(widget.message!);
        },
      );
    } else {
      firestore.sendMessage(widget.conv!, _textController.text);
    }

    _textController.text = '';
    // _focusNode.unfocus();
  }

  Future<void> _postImage(File file) async {
    final firestore = ConversationFirestore();

    String uid = auth.authUser()!.uid;
    var id = const Uuid().v4() + uid;

    _uplodingImages[id] = file;

    if (_begin) {
      var value = await firestore.register(widget.message!, file: file, id: id);
      _bloc?.conv = value;
      _bloc?.load();
      _begin = false;
      widget.callback?.call(widget.message!);
    } else {
      await firestore.sendImage(widget.conv!, file, id: id);
    }
  }
}
