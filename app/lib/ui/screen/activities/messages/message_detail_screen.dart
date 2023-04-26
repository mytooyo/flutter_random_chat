import 'package:app/firestore/messages_firestore.dart';
import 'package:app/firestore/users_firestore.dart';
import 'package:app/main.dart';
import 'package:app/model/firestore_model.dart';
import 'package:app/ui/route/route.dart';
import 'package:app/ui/screen/activities/conversation/conversation_screen.dart';
import 'package:app/ui/screen/activities/messages/message_image_screen.dart';
import 'package:app/ui/screen/user_profile_screen.dart';
import 'package:app/ui/theme/app_theme_data.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:load/load.dart';

class MessageDetailScreenArgument {
  final Message message;
  final MessageDetailType type;
  final void Function(Message) callback;
  MessageDetailScreenArgument({
    required this.message,
    required this.type,
    required this.callback,
  });
}

enum MessageDetailType { detail, history }

class MessageDetailScreen extends StatefulWidget {
  final Message message;
  final MessageDetailType type;
  final void Function(Message) callback;

  const MessageDetailScreen({
    super.key,
    required this.message,
    required this.type,
    required this.callback,
  });

  @override
  State<MessageDetailScreen> createState() => _MessageDetailScreen();
}

class _MessageDetailScreen extends State<MessageDetailScreen> {
  late TextEditingController _textController;

  @override
  void initState() {
    _textController = TextEditingController(
      text: widget.message.message,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(''),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: null,
          automaticallyImplyLeading: false,
          actions: <Widget>[
            IconButton(
              icon: const Icon(
                Icons.close,
              ),
              color: AppTheme.primaryLight,
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        ),
        body: SafeArea(
          child: Stack(
            children: <Widget>[
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 24, left: 16, right: 16, bottom: 160),
                  child: Hero(
                    tag: widget.message.id,
                    child: GestureDetector(
                      child: _card(),
                      onTap: () {},
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: widget.type == MessageDetailType.detail
                    ? _buttonsArea()
                    : _historyButtonsArea(),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _card() {
    return Card(
      elevation: 3.0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            widget.type == MessageDetailType.detail ? _profile() : Container(),
            widget.type == MessageDetailType.detail
                ? Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 20),
                    child: Container(
                      height: 1,
                      color: Theme.of(context).dividerColor,
                    ),
                  )
                : Container(),
            _contents(),
            widget.message.img == null ? Container() : _postImage(),
          ],
        ),
      ),
    );
  }

  Widget _profile() {
    const double imageSize = 60;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          width: imageSize,
          height: imageSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.grey.withOpacity(0.6),
                  offset: const Offset(0, 1.5),
                  blurRadius: 4.0),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: OverflowBox(
              minWidth: 0.0,
              minHeight: 0.0,
              // maxWidth: double.infinity,
              maxHeight: double.infinity,
              child: widget.message.from.img == null
                  ? Image.asset('assets/images/person.png', color: Colors.white)
                  : CachedNetworkImage(
                      imageUrl: widget.message.from.img!,
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
        Flexible(
          // fit: FlexFit.loose,
          child: Text(
            widget.message.from.name,
            style:
                Theme.of(context).textTheme.bodyLarge?.merge(AppTheme.medium),
            textAlign: TextAlign.left,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Widget _contents() {
    return Expanded(
      child: SingleChildScrollView(
        child: Material(
          color: Colors.transparent,
          type: MaterialType.transparency,
          child: TextFormField(
            controller: _textController,
            style: Theme.of(context).textTheme.bodyLarge,
            enabled: false,
            maxLines: null,
            decoration: InputDecoration(
              hintText: 'No Message...',
              hintStyle: Theme.of(context).textTheme.bodyLarge,
              contentPadding: const EdgeInsets.all(8),
              fillColor: Colors.transparent,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Colors.transparent,
                  width: 0.0,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Colors.transparent,
                  width: 0.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: AppTheme.primary.withOpacity(0.4),
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _postImage() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 12),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 150,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: OverflowBox(
                  minWidth: 0.0,
                  minHeight: 0.0,
                  // maxWidth: double.infinity,
                  maxHeight: double.infinity,
                  child: CachedNetworkImage(
                    imageUrl: widget.message.img!,
                    httpHeaders: {'Authorization': 'Bearer $token'},
                    fit: BoxFit.cover,
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
            onTap: () {
              Navigator.of(context).pushNamed(
                RouteName.showImage,
                arguments: MessageImageScreenArgument(img: widget.message.img),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buttonsArea() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 44, left: 24, right: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _button(
              icon: FontAwesomeIcons.exclamationCircle,
              title: 'Report',
              iconColor: Colors.white,
              backgroundColor: Colors.red,
              onTap: _reportConfirm,
            ),
            Expanded(child: Container()),
            _button(
              icon: FontAwesomeIcons.reply,
              title: 'Reply',
              iconColor: Colors.white,
              backgroundColor: AppTheme.primary,
              onTap: () {
                Navigator.of(context).pushNamed(
                  RouteName.conversation,
                  arguments: ConversationScreenArgument(
                    message: widget.message,
                    user: widget.message.from,
                    callback: widget.callback,
                  ),
                );
              },
            ),
            const SizedBox(width: 16),
            // _button(
            //   icon: _isLiked ? Icons.favorite : Icons.favorite_border,
            //   title: 'Like',
            //   iconColor: _isLiked ? Colors.pinkAccent : Theme.of(context).cursorColor,
            //   backgroundColor: Theme.of(context).cardColor,
            //   onTap: () {
            //     setState(() {
            //       MessageBloc.shared.updateLike(widget.message, !_isLiked);
            //     });
            //   }
            // ),
            // SizedBox(width: 16),
            _button(
              icon: FontAwesomeIcons.solidUser,
              title: 'Profile',
              iconColor: Theme.of(context).disabledColor,
              backgroundColor: Theme.of(context).cardColor,
              onTap: () {
                Navigator.of(context).pushNamed(RouteName.userProfile,
                    arguments:
                        UserProfileScreenArgumanet(user: widget.message.from));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _historyButtonsArea() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 44, left: 24, right: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // _button(
            //   icon: Icons.delete,
            //   title: 'Delete',
            //   iconColor: Colors.white,
            //   backgroundColor: Colors.red,
            //   onTap: _reportConfirm
            // ),
            Expanded(child: Container()),
            // _button(
            //   icon: Icons.favorite,
            //   title: 'Likes',
            //   iconColor: Colors.pinkAccent,
            //   backgroundColor: Theme.of(context).cardColor,
            //   onTap: () {

            //   }
            // ),
          ],
        ),
      ),
    );
  }

  Widget _button({
    required IconData icon,
    required String title,
    required Color iconColor,
    required Color backgroundColor,
    required void Function() onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: Column(
        children: <Widget>[
          Card(
            color: backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            elevation: 2.0,
            child: InkWell(
              splashColor: Colors.white12,
              onTap: onTap,
              borderRadius: BorderRadius.circular(30),
              child: SizedBox(
                height: 52,
                width: 52,
                child: Center(
                  child: Icon(
                    icon,
                    size: 24,
                    color: iconColor,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }

  void _reportConfirm() {
    showDialog(
        context: context,
        builder: (context) {
          return Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                title: Text(
                  'Do you want to report?',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.merge(AppTheme.bold),
                ),
                content: Column(
                  children: <Widget>[
                    Padding(
                        padding: const EdgeInsets.only(
                            top: 8, left: 12, right: 12, bottom: 24),
                        child: _profile()),
                    Text(
                      'You can only report if the content is offensive or inappropriate.\nIf determined to be inappropriate, \nthis user\'s posts will no longer be displayed. \nIs it OK?',
                      textAlign: TextAlign.left,
                      style: Theme.of(context).textTheme.bodyMedium,
                    )
                  ],
                ),
                actions: <Widget>[
                  ElevatedButton(
                    style: ButtonStyle(
                      elevation: MaterialStateProperty.all<double>(0),
                    ),
                    child: const Text("Cancel"),
                    onPressed: () => Navigator.pop(context),
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                        AppTheme.primary,
                      ),
                      elevation: MaterialStateProperty.all<double>(0),
                    ),
                    onPressed: () {
                      showAppLoadingWidget();
                      _report();
                    },
                    child: Text(
                      'Report',
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge
                          ?.merge(AppTheme.whiteStyle),
                    ),
                  ),
                ],
              )
            ],
          ));
        });
  }

  Future<void> _report() async {
    // 拒否リストに登録
    await UsersFirestore().report(widget.message.from.id);
    // メッセージを削除(とりあえず該当のメッセージだけ)
    // 他のメッセージは1時間ぐらいで消えるため、ここで全件消すことはしない
    await MessagesFirestore().resetUsers(widget.message);

    // 非同期でCloudFunctionを直接呼び出してレポート処理を行う

    var functions = FirebaseFunctions.instance;
    functions.httpsCallable('refusal').call(
      {'uid': widget.message.from.id, 'messageId': widget.message.id},
    );

    hideLoadingDialog();
    if (mounted) {
      Navigator.pop(context);
      await Future.delayed(const Duration(seconds: 1)).then(
        (_) => Navigator.pop(context),
      );
    }
  }
}
