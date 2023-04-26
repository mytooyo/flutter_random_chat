import 'package:app/bloc/users/unread_replys_bloc.dart';
import 'package:app/main.dart';
import 'package:app/ui/route/route.dart';
import 'package:app/ui/screen/activities/all_conversations_screen.dart';
import 'package:app/ui/screen/activities/messages_screen.dart';
import 'package:app/ui/theme/app_theme_data.dart';
import 'package:app/ui/utilities/app_background.dart';
import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreen();
}

class _ActivitiesScreen extends State<ActivitiesScreen> {
  int _current = 0;

  late List<ScrollController> _controllers;
  double topBarOpacity = 0.0;

  late UnreadReplysCounterBloc _bloc;
  late MessagesScreen _message;
  late AllConversationScreen _conversation;

  @override
  void initState() {
    _controllers = [ScrollController(), ScrollController()];

    _message = MessagesScreen(
      scrollController: _controllers[0],
    );
    _conversation = const AllConversationScreen();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    auth.checkSignin(context);
    _bloc = Provider.of<UnreadReplysCounterBloc>(context);

    return Stack(
      children: <Widget>[
        Container(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        const AppBackgroundPattern(),
        _main()
      ],
    );
  }

  Widget _main() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
              FontAwesomeIcons.globeAsia,
              size: 24,
              color: Theme.of(context).iconTheme.color,
            ),
            const SizedBox(width: 8),
            Material(
              color: Colors.transparent,
              child: Text(
                'Activities',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.merge(AppTheme.bold),
                textAlign: TextAlign.left,
              ),
            )
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(
          color: Theme.of(context).dividerColor,
        ),
        elevation: 0.0,
      ),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            _buildOffstage(0, _message),
            _buildOffstage(1, _conversation),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(RouteName.post);
        },
        backgroundColor: AppTheme.primary,
        child: const Icon(
          FontAwesomeIcons.solidPaperPlane,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: BubbleBottomBar(
        opacity: 0.2,
        backgroundColor: Theme.of(context).bottomAppBarColor,
        currentIndex: _current,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        elevation: 4.0,
        fabLocation: BubbleBottomBarFabLocation.end,
        hasNotch: true,
        hasInk: true,
        iconSize: 32,
        onTap: (index) {
          if (index != null) {
            setState(() {
              _current = index;
            });
          }
        },
        items: <BubbleBottomBarItem>[
          BubbleBottomBarItem(
              icon: Icon(
                FontAwesomeIcons.envelopeOpenText,
                color: Theme.of(context).disabledColor,
                size: 24,
              ),
              activeIcon: const Icon(
                FontAwesomeIcons.envelopeOpenText,
                color: AppTheme.primary,
                size: 24,
              ),
              backgroundColor: AppTheme.primary,
              title: const Text('INBOX')),
          BubbleBottomBarItem(
            icon: _replyItem(Theme.of(context).disabledColor),
            activeIcon: _replyItem(AppTheme.primary),
            backgroundColor: AppTheme.primary,
            title: const Text('CHATS'),
          ),
        ],
      ),
    );
  }

  Widget _replyItem(Color color) {
    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        fit: StackFit.loose,
        children: <Widget>[
          Center(
            child: Icon(
              FontAwesomeIcons.solidComments,
              color: color,
              size: 24,
            ),
          ),
          Positioned(
            right: 0,
            top: 2,
            child: StreamBuilder(
              stream: _bloc.stream,
              initialData: 0,
              builder: (_, snapshot) {
                if (snapshot.data as int == 0) {
                  return Container();
                }
                return Container(
                  padding: const EdgeInsets.all(0),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),
                  child: Center(
                    child: Text(
                      (snapshot.data as int).toString(),
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.merge(AppTheme.whiteStyle)
                          .merge(AppTheme.medium),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildOffstage(int index, Widget page) {
    return Offstage(
      offstage: index != _current,
      child: TickerMode(
        enabled: index == _current,
        child: page,
      ),
    );
  }
}
