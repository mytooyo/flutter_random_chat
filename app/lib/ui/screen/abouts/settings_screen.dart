import 'package:app/firestore/users_firestore.dart';
import 'package:app/main.dart';
import 'package:app/ui/route/route.dart';
import 'package:app/ui/theme/app_theme_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreen();
}

class _SettingsScreen extends State<SettingsScreen> {
  bool _notification = false;

  late List<SettingItem> _list;

  late List<SettingItem> _services;

  @override
  void initState() {
    _notification = self!.notification;

    _list = [
      // SettingItem(
      //   title: 'Launguage',
      //   type: SettingItemType.text,
      //   callback: () {},
      //   detailText: 'ja'
      // ),
      SettingItem(
        title: 'Notification',
        type: SettingItemType.uiswitch,
        callback: () {},
        switchValue: _notification,
        switchCallback: (newValue) {
          setState(
            () {
              _notification = newValue;
              UsersFirestore().updateNotification(newValue);
            },
          );
        },
      ),
    ];

    _services = [
      SettingItem(
          title: 'Terms of Service',
          type: SettingItemType.next,
          callback: () {}),
      SettingItem(
          title: 'Privacy Policy', type: SettingItemType.next, callback: () {}),
      SettingItem(
        title: 'Open Source Software',
        type: SettingItemType.next,
        callback: () {},
      ),
    ];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: null,
        centerTitle: true,
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
        child: Column(
          children: <Widget>[
            const SizedBox(height: 24),
            _builder(_list),
            const SizedBox(height: 60),
            _builder(_services),
            Expanded(child: Container()),
            _item(
              SettingItem(
                title: 'Delete Acount',
                style: AppTheme.attensionStyle.merge(AppTheme.bold),
                type: SettingItemType.none,
                callback: () {
                  auth.signout();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      RouteName.start, (route) => false);
                },
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _builder(List list) {
    return ListView.builder(
      shrinkWrap: true,
      itemBuilder: (_, index) {
        return _item(list[index]);
      },
      itemCount: list.length,
    );
  }

  Widget _item(SettingItem item) {
    return Material(
      color: Theme.of(context).cardColor,
      child: InkWell(
        splashColor: AppTheme.primaryLight.withOpacity(0.2),
        onTap: () {
          item.callback();
        },
        child: SizedBox(
          height: 60,
          child: Padding(
            padding: const EdgeInsets.only(left: 24, right: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  item.title,
                  style:
                      Theme.of(context).textTheme.bodyLarge?.merge(item.style),
                ),
                Expanded(child: Container()),
                item.detail(context),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum SettingItemType { text, next, none, uiswitch }

class SettingItem {
  final String title;
  final TextStyle style;
  final SettingItemType type;
  final Function callback;

  String? detailText;
  bool? switchValue;
  Function? switchCallback;

  SettingItem({
    required this.title,
    this.style = AppTheme.medium,
    required this.type,
    required this.callback,
    this.detailText,
    this.switchValue,
    this.switchCallback,
  });

  Widget detail(BuildContext context) {
    switch (type) {
      case SettingItemType.none:
        return Container();
      case SettingItemType.text:
        return Material(
          color: Colors.transparent,
          child: Text(
            detailText ?? '',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        );
      case SettingItemType.next:
        return Icon(
          Icons.arrow_forward_ios,
          color: Theme.of(context).dividerColor,
          size: 16,
        );
      default:
        return CupertinoSwitch(
          value: switchValue ?? false,
          activeColor: AppTheme.primary,
          onChanged: (newValue) {
            switchValue = newValue;
            switchCallback?.call(newValue);
          },
        );
    }
  }
}
