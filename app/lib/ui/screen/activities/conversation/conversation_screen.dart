
import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
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
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:load/load.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class ConversationScreenArgument {
  final Message message;
  final User user;
  final Conversation conv;
  final Function callback;
  ConversationScreenArgument({this.message, this.user, this.conv, this.callback});
}

class ConversationScreen extends StatefulWidget {

  final Message message;
  final User user;
  final Conversation conv;
  final Function callback;

  ConversationScreen({Key key, this.message, this.user, this.conv, this.callback}) : super(key: key);

  @override
  _ConversationScreen createState() => _ConversationScreen();

}

class _ConversationScreen extends State<ConversationScreen> {

  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  FocusNode _focusNode = FocusNode();
  ListModel<Reply> _list;

  TextEditingController _textController;
  ScrollController _scrollController = ScrollController();

  ReplyScreenBloc _bloc;

  // Conversation conv;
  bool _begin = false;

  Map<String, File> _uplodingImages = {};

  @override
  void initState() {

    // conv = widget.conv;
    _begin = widget.conv == null;

    List<Reply> _initial = [];

    // if (widget.message != null) {
    //   _initial.add(Reply.fromMessage(widget.message));
    // }

    _list = ListModel<Reply>(
      listKey: _listKey,
      initialItems: _initial,
      removedItemBuilder: _buildRemovedItem,
    );

    _textController = TextEditingController();

    // 未読を全て既読に設定
    if (widget.conv != null) {
      _updateRead();
    }

    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.unfocus();
    _bloc.dispose();
    super.dispose();
  }

  void _updateRead() async {
    await ConversationFirestore().updateRead(widget.conv);
    widget.conv.unreadReplyer = 0;
    widget.conv.unreadMessagener = 0;
  }

  @override
  Widget build(BuildContext context) {

    if (_bloc == null) {
      _bloc = Provider.of<ReplyScreenBloc>(context);
      _bloc.load();
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
        iconTheme: IconThemeData(
          color: AppTheme.primaryLight
        ),
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
                    padding: EdgeInsets.only(top: 4, left: 12, right: 12, bottom: 0),
                    child: _conversation(),
                  )
                ),
                onTap: () {
                  _focusNode.unfocus();
                },
              )
            ),
            _inputField()
          ],
        )
      ),
    );
  }

  Widget _header() {
    const double _imageSize = 32;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          width: _imageSize,
          height: _imageSize,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: AppTheme.lightGray
          ),
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
                imageUrl: widget.user.img,
                httpHeaders: {'Authorization': 'Bearer $token'},
                fit: BoxFit.cover,
                height: _imageSize,
                width: _imageSize,
                progressIndicatorBuilder: (context, url, downloadProgress) => 
                  CircularProgressIndicator(value: downloadProgress.progress),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            )
          )
        ),
        SizedBox(width: 16),
        Expanded(
          // fit: FlexFit.loose,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                child: Text(
                  widget.user?.name ?? '',
                  style: Theme.of(context).textTheme.headline6.merge(AppTheme.medium),
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                )
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
              User user = widget.message == null ? widget.conv.to : widget.message.from;
              Navigator.of(context).pushNamed(
                RouteName.userProfile,
                arguments: UserProfileScreenArgumanet(user: user)
              );
            },
            child: Container(
              height: 40,
              width: 40,
              child: Center(
                child: Center(
                  child: Icon(
                    FontAwesomeIcons.solidUser,
                    size: 24,
                    color: AppTheme.primary,
                  )
                )
              )
            )
          )
      )
      ],
    );
  }

  Widget _conversation() {

    return StreamBuilder(
      stream: _bloc.stream,
      initialData: [],
      builder: (_, snapshot) {

        if (snapshot.data is Map<String, Reply>) {
          (snapshot.data as Map<String, Reply>).forEach((_, element) { 
            // IDが一致する返信が存在する場合は更新、それ以外は追加
            var same = _list.where((Reply reply) => reply.id == element.id);
            if (same.isNotEmpty) {
              int index = _list.indexOf(same[0]);
              _list.update(index, element);
            } else {
              _insert(element);
            }
             
          });
        }

        // 削除対象のKey一覧
        List<String> _delKeys = [];
        // アップロード中の画像が存在する場合のチェックを実施
        _uplodingImages.forEach((key, value) { 
          // キーがリスト内に存在し、tmpがfalseの場合はアップロード処理終了
          var uploaded = _list.where((Reply element) => element.id == key && !element.tmp);
          if (uploaded.isNotEmpty) _delKeys.add(key);
        });

        // アップロード済みの画像はリストから削除
        if (_delKeys.isNotEmpty) _delKeys.forEach((element) => _uplodingImages.remove(element));
        
        // if (_scrollController.position != null) {
        _scroll();
        // }

        return AnimatedList(
          key: _listKey,
          controller: _scrollController,
          shrinkWrap: true,
          padding: EdgeInsets.only(top: 12, bottom: 40),
          physics: AlwaysScrollableScrollPhysics(),
          initialItemCount: _list.length + 1,
          itemBuilder: _buildItem
        );
      },
    );
  }

  Future<void> _scroll() async {
    if (!_scrollController.hasClients) return;
    Timer(
      Duration(milliseconds: 500),
      () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent, 
          duration: Duration(milliseconds: 150), 
          curve: Interval(0.0, 1.0)
        );
      }
    );
  }

  // Used to build list items that haven't been removed.
  Widget _buildItem(BuildContext context, int index, Animation<double> animation) {

    if (index == 0) {
      return SizeTransition(
        axis: Axis.vertical,
        sizeFactor: animation,
        child: _initialMessage()
      );
    }
    
    var i = index - 1;
    Reply _reply = _list[i];

    return SizeTransition(
      axis: Axis.vertical,
      sizeFactor: animation,
      child: _conversionItem(_reply, index: i)
    );

  }

  Widget _buildRemovedItem(Reply item, BuildContext context, Animation<double> animation) {
    return SizeTransition(
      axis: Axis.vertical,
      sizeFactor: animation,
      child: _conversionItem(item)
    );
  }

  void _insert(Reply item) {
    if (_list.indexOf(item) >= 0) return;
    _list.insert(_list.length, item);
  }

  Widget _initialMessage() {

    var msg = widget.message;
    if (msg == null) {
      msg = widget.conv.message;
    }

    return Stack(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 32, left: 16, right: 16, bottom: 16),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Theme.of(context).dividerColor)
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 32, left: 16, right: 16, bottom: 16),
                  child: Container(
                    child: Text(
                      msg.message,
                      style: Theme.of(context).textTheme.bodyText2,
                    )
                    
                  ),
                ),
                msg.img == null ? Container() : _initialMessageImage(msg)
              ],
            )
          )
        ),
        Padding(
          padding: EdgeInsets.only(top: 12),
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Theme.of(context).dividerColor)
              ),
              child: Padding(
                padding: EdgeInsets.only(top: 12, bottom: 12, left: 24, right: 24),
                child: Text(
                  'Posted Message',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyText2,
                )
              )
            ),
          )
        )
      ],
    );  
  }

  Widget _initialMessageImage(Message msg) {
    return Padding(
      padding: EdgeInsets.only(top: 12, bottom: 20, left: 12, right: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 120,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: OverflowBox(
                minWidth: 0.0, 
                minHeight: 0.0, 
                // maxWidth: double.infinity,
                maxHeight: double.infinity, 
                child: CachedNetworkImage(
                  imageUrl: msg.img,
                  httpHeaders: {'Authorization': 'Bearer $token'},
                  fit: BoxFit.cover,
                  progressIndicatorBuilder: (context, url, downloadProgress) => 
                    CircularProgressIndicator(value: downloadProgress.progress),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              )
            )
          ),
          onTap: () {
            Navigator.of(context).pushNamed(
              RouteName.showImage,
              arguments: MessageImageScreenArgument(img: msg.img)
            );
          },
        )
      )
    );
  }

  Widget _conversionItem(Reply _reply, {int index}) {

    var isDisplayTime = index == null ? true : _isDisplayTime(index);


    return Container(
      width: double.infinity,
      child: _reply.from.id == self.id
        ? _rightBubble(_reply, isDisplayTime)
        : _leftBubble(_reply, isDisplayTime)
    // )
    );
  }

  bool _isDisplayTime(int index) {

    // 最後のインデックスの場合
    if (index == _list.length - 1) return true;

    var _reply = _list[index];
    var _next = _list[index + 1];

    // 次のメッセージの送信元が違う場合
    if (_reply.from.id != _next.from.id) return true;

    // 同一の送信元で次のメッセージと時刻が異なる場合
    var _time = dateFormatted(
      DateTime.fromMillisecondsSinceEpoch(_reply.timestamp),
      format: 'HH:mm'
    );

    var _nextTime = dateFormatted(
      DateTime.fromMillisecondsSinceEpoch(_next.timestamp),
      format: 'HH:mm'
    );

    if (_time != _nextTime) return true;

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
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: <BoxShadow>[
                        BoxShadow(color: Colors.black12, offset: Offset(0, 1.5), blurRadius: 2.0),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        reply.message,
                        style: Theme.of(context).textTheme.bodyText2,
                      )
                    )
                  )
                )
              ),
              Container(),
            ],
          ),
          SizedBox(height: 4),
          isDisplayTime ? Padding(
            padding: EdgeInsets.only(top: 4, left: 4),
            child: Text(
              dateFormatted(
                DateTime.fromMillisecondsSinceEpoch(reply.timestamp),
                format: 'HH:mm'
              ),
              style: Theme.of(context).textTheme.overline,
            )
          ): Container()
        ],
      )
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
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.primaryDark,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: <BoxShadow>[
                        BoxShadow(color: Colors.black12, offset: Offset(0, 1.5), blurRadius: 2.0),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        reply.message,
                        style: Theme.of(context).textTheme.bodyText2.merge(AppTheme.whiteStyle),
                      )
                    ),
                  ),
                )
              ),
              Container(),
            ],
          ),
          SizedBox(height: 4),
          isDisplayTime ? Padding(
            padding: EdgeInsets.only(top: 4, left: 4),
            child: Text(
              dateFormatted(
                DateTime.fromMillisecondsSinceEpoch(reply.timestamp),
                format: 'HH:mm'
              ),
              style: Theme.of(context).textTheme.overline,
            )
          ) : Container()
        ],
      )
    );
  }

  Widget _image({String url, File file}) {
    double width = MediaQuery.of(context).size.width * 0.5;
    return Container(
      width: width,
      height: width * 3 / 4,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: <BoxShadow>[
          BoxShadow(color: Colors.black12, offset: Offset(0, 1.5), blurRadius: 2.0),
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
                progressIndicatorBuilder: (context, url, downloadProgress) => 
                  CircularProgressIndicator(value: downloadProgress.progress),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
              onTap: () {
                if (url == null) return;
                Navigator.of(context).pushNamed(
                  RouteName.showImage,
                  arguments: MessageImageScreenArgument(img: url)
                );
              },
            )
          ),
        )
      )
    );
  }

  Widget _inputField() {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: 32),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).bottomAppBarColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          )
        ),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              ClipOval(
                child: Material(
                  color: Colors.transparent,
                  child: IconButton(
                    icon: Icon(
                      Icons.image
                    ),
                    color: Theme.of(context).cursorColor,
                    onPressed: () {
                      getImage();
                    },
                  )
                ),
              ),
              SizedBox(width: 8),
              Flexible(
                child: TextFormField(
                  style: Theme.of(context).textTheme.bodyText1,
                  controller: _textController,
                  decoration: InputDecoration(
                    hintText: 'Your message...',
                    hintStyle: Theme.of(context).textTheme.bodyText1.merge(AppTheme.lightGrayStyle),
                    contentPadding: EdgeInsets.all(8),
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
                )
              ),
              ClipOval(
                child: Material(
                  color: Colors.transparent,
                  child: IconButton(
                    icon: Icon(
                      Icons.send
                    ),
                    color: AppTheme.primary,
                    onPressed: () {

                      if (_textController.text == null || _textController.text == '') return;

                      _postMessage();

                    },
                  )
                ),
              )
            ],
          )
        )
      )
    );
  }

  Future getImage() async {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery, imageQuality: 60);

    if (image == null || image.path == null) return;

    showAppLoadingWidget();

    image = await fixExifRotation(image.path);

    await _postImage(image);

    hideLoadingDialog();
  }

  Future<void> _postMessage() async {

    final _firestore = ConversationFirestore();
    // 初回の会話情報の場合
    if (_begin) {
      _firestore.register(widget.message, reply: _textController.text).then((value) {
        _bloc.conv = value;
        _bloc.load();
        _begin = false;
        widget.callback(widget.message);
      });
    }
    else {
      _firestore.sendMessage(widget.conv, _textController.text);
    }

    _textController.text = '';
    // _focusNode.unfocus();

  }

  Future<void> _postImage(File file) async {

    final _firestore = ConversationFirestore();

    String uid = (await auth.authUser()).uid;
    var id = Uuid().v4() + uid;

    _uplodingImages[id] = file;

    if (_begin) {
      var value = await _firestore.register(widget.message, file: file, id: id);
      _bloc.conv = value;
      _bloc.load();
      _begin = false;
      widget.callback(widget.message);
    }
    else {
      await _firestore.sendImage(widget.conv, file, id: id);
    }
  }

}