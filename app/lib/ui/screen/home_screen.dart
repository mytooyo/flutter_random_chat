import 'dart:async';

import 'package:app/bloc/self_user_available_bloc.dart';
import 'package:app/firestore/users_firestore.dart';
import 'package:app/main.dart';
import 'package:app/ui/route/route.dart';
import 'package:app/ui/screen/contents/no_available_card.dart';
import 'package:app/ui/utilities/app_background.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'components/home_card_component.dart';
import 'components/home_profile_component.dart';

class HomeScreen extends StatefulWidget {

  @override
  _HomeScreen createState() => _HomeScreen();

}

class _HomeScreen extends State<HomeScreen> with WidgetsBindingObserver {

  TextEditingController _textController;
  PanelController _panelController  = PanelController();
  bool _panelOpened = false;
  double _panelOffset = 0.0;

  HomeCardComponent _compornents;
  HomeProfileComponent _profileComponent;

  SelfUserBloc _bloc;

  // Firebase Messaging
  
  @override
  void initState() {
    _textController = TextEditingController(text: self?.profile ?? '');
    super.initState();

    _configure();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {

    // アプリがインアクティブ状態となった場合
    if (state == AppLifecycleState.paused) {
      UsersFirestore().activate(false);
    }
    // アプリが最前面に復帰した場合
    else if (state == AppLifecycleState.resumed) {
      UsersFirestore().activate(true);
    }

    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    _compornents = HomeCardComponent(context: context);
    _profileComponent = HomeProfileComponent(
      context: context, 
      textController: _textController,
      panelOpened: _panelOpened,
      panelOffset: _panelOffset
    );

    auth.checkSignin(context);

    if (_bloc == null) {
      _bloc = Provider.of<SelfUserBloc>(context);
      _bloc.load();
    }
    
    return StreamBuilder(
      stream: _bloc.stream,
      initialData: self,
      builder: (_, snapshot){
        if (self.available) {
          return _standard();
        }
        // 利用停止中のアカウントの場合
        return _noAvailable();
      }
    );

  }

  Widget _standard() {
    double bottom = MediaQuery.of(context).padding.bottom > 0 
      ? MediaQuery.of(context).padding.bottom + 8
      : 24;

    return Stack(
      children: <Widget>[
        Container(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        AppBackgroundPattern(),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: _builder()
          ),
        ),
        SlidingUpPanel(
          controller: _panelController,
          panel: _profileComponent.card(),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12.0),
            topRight: Radius.circular(12.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.transparent,
              spreadRadius: 1.0,
              blurRadius: 10.0,
              offset: Offset(10, 10),
            ),
          ],
          color: Colors.transparent,
          minHeight: 172 + bottom,
          maxHeight: MediaQuery.of(context).size.height - 100,
          isDraggable: true,
          backdropEnabled: true,
          onPanelOpened: () {
            setState(() {
              _panelOpened = true;
            });
          },
          onPanelClosed: () {
            setState(() {
              _panelOpened = false;
            });
          },
          onPanelSlide: (val) {
            setState(() {
              _panelOffset = val;
            });
          },
        )
      ],
    );
  }

  Widget _builder() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          SizedBox(height: 40),
          Opacity(
            opacity: 0.8,
            child: Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    MediaQuery.platformBrightnessOf(context) == Brightness.dark
                    ? 'assets/images/title_logo_dark.png'
                    : 'assets/images/title_logo_light.png'
                  ),
                  fit: BoxFit.contain,
                ),
              )
            )
          ),
          SizedBox(height: 24),
          _compornents.activitiesCard(),
          _compornents.menuTiles(),
        ],
      )
    );
  }

  void _configure() async {
    // _messaging.configure(
    //   onMessage: (Map<String, dynamic> message) async {
    //     print("onMessage: $message");
    //   },
    //   onLaunch: (Map<String, dynamic> message) async {
    //     print("onLaunch: $message");
    //     launchByMessage();
    //   },
    //   onResume: (Map<String, dynamic> message) async {
    //     print("onResume: $message");
    //     launchByMessage();
    //   },
    // );
    // FutureOr<bool> request = _messaging.requestNotificationPermissions(
    //   const IosNotificationSettings(sound: true, badge: true, alert: true)
    // );
    // if (request is Future) {
    //   var permission = await request;
    //   // notificationが存在しない場合は初回のため、
    //   // Permission情報を設定
    //   if (self.notification == null) {
    //     UsersFirestore().updateNotification(permission);
    //   }
    //   // Permissionがfalseで設定値がtrueの場合は書き換え
    //   else if (!permission) {
    //     UsersFirestore().updateNotification(false);
    //   }
    // }
    // _messaging.onIosSettingsRegistered.listen((settings) {
    //   print("Settings registered: $settings");

    // });
    // _messaging.getToken().then((String token) {
    //   print("Push Messaging token: $token");
    //   UsersFirestore().updateToken(token);
    // });
    // _messaging.subscribeToTopic("all");
  }

  void launchByMessage() {
    Navigator.of(context).pushNamed(RouteName.activities);
  }

  Widget _noAvailable() {
    return Stack(
      children: <Widget>[
        Container(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        AppBackgroundPattern(),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 40),
                  Opacity(
                    opacity: 0.8,
                    child: Container(
                      width: double.infinity,
                      height: 48,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                            MediaQuery.platformBrightnessOf(context) == Brightness.dark
                            ? 'assets/images/title_logo_dark.png'
                            : 'assets/images/title_logo_light.png'
                          ),
                          fit: BoxFit.contain,
                        ),
                      )
                    )
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 80, left: 40, right: 40),
                    child: NoAvailableCard()
                  ),
                  
                ],
              )
            )
          ),
        )
      ]
    );
  }
  
}

